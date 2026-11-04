import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import 'package:uuid/uuid.dart';

import 'json_ld_recipe_parser.dart';

enum _TextSection { header, ingredients, steps }

class HeuristicRecipeExtractor implements RecipeExtractionAdapter {
  final RecipeNormalizer _normalizer;
  final Uuid _uuid;

  HeuristicRecipeExtractor({
    RecipeNormalizer normalizer = const RecipeNormalizer(),
    Uuid uuid = const Uuid(),
  })  : _normalizer = normalizer,
        _uuid = uuid;

  @override
  Future<Result<Recipe, AppFailure>> extractRecipe({
    required ImportSource source,
    required String profileId,
    String? localeHint,
  }) async {
    try {
      final rawText = source.rawText ?? '';
      if (rawText.trim().isEmpty) {
        return const Result.err(ValidationFailure(message: 'Source content is empty.'));
      }

      // 1. Structured schema.org Recipe data (JSON-LD or an HTML page with it).
      if (rawText.contains('"@type"')) {
        final jsonLdRecipe = JsonLdRecipeParser(uuid: _uuid).parse(rawText, profileId: profileId);
        if (jsonLdRecipe != null) return Result.ok(jsonLdRecipe);
      }

      // 2. Freeform Text Heuristic Parsing
      final recipe = _parseFreeformText(rawText, profileId);
      return Result.ok(recipe);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Extraction failed: $e', cause: e));
    }
  }

  @override
  Future<int> getRemainingDailyQuota(String profileId) async {
    return 1 << 30; // Offline parsing has no quota.
  }

  Recipe _parseFreeformText(String text, String profileId) {
    final recipeId = _uuid.v4();
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    String title = 'Imported Recipe';
    String? summary;
    Rational servings = Rational(2);
    final ingredients = <RecipeIngredient>[];
    final steps = <RecipeStep>[];

    _TextSection currentSection = _TextSection.header;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();

      // Detect section headers
      if (lower.startsWith('ingredient') || lower == 'ingredients:' || lower == '## ingredients') {
        currentSection = _TextSection.ingredients;
        continue;
      } else if (lower.startsWith('instruction') || lower.startsWith('direction') || lower.startsWith('step') || lower.startsWith('method') || lower == '## instructions') {
        currentSection = _TextSection.steps;
        continue;
      }

      switch (currentSection) {
        case _TextSection.header:
          if (i == 0) {
            title = line.replaceAll(RegExp(r'^#+\s*'), '').trim();
          } else if (lower.startsWith('serv') || lower.contains('yield')) {
            final numMatch = RegExp(r'\d+').firstMatch(line);
            if (numMatch != null) {
              final s = int.tryParse(numMatch.group(0)!);
              if (s != null && s > 0) servings = Rational(s);
            }
          } else if (summary == null && line.length < 200) {
            summary = line;
          }
          break;

        case _TextSection.ingredients:
          ingredients.add(_normalizer.normalizeIngredient(
            line,
            recipeId: recipeId,
            position: ingredients.length + 1,
          ));
          break;

        case _TextSection.steps:
          steps.add(_normalizer.normalizeStep(
            line,
            recipeId: recipeId,
            position: steps.length + 1,
          ));
          break;
      }
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    return Recipe(
      id: recipeId,
      profileId: profileId,
      title: title,
      summary: summary,
      status: RecipeStatus.ready,
      baseServings: servings,
      difficulty: RecipeDifficulty.medium,
      totalMinutes: 20,
      createdAt: now,
      updatedAt: now,
      origin: Origin.imported,
      ingredients: ingredients,
      steps: steps,
    );
  }
}
