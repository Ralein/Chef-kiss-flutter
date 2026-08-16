import 'dart:convert';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import 'package:uuid/uuid.dart';

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

      // 1. Try parsing as JSON-LD Schema.org Recipe
      if (rawText.contains('"@type"') && (rawText.contains('"Recipe"') || rawText.contains('schema.org'))) {
        try {
          final jsonLdRecipe = _parseJsonLd(rawText, profileId);
          if (jsonLdRecipe != null) {
            return Result.ok(jsonLdRecipe);
          }
        } catch (_) {
          // Fall through to text heuristic parsing
        }
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
    return 3; // Offline heuristic has unlimited quota
  }

  Recipe? _parseJsonLd(String jsonStr, String profileId) {
    // Extract JSON block if surrounded by HTML script tags
    String cleanJson = jsonStr;
    final scriptMatch = RegExp(r'<script[^>]*type=["\x27]application/ld\+json["\x27][^>]*>(.*?)</script>', dotAll: true).firstMatch(jsonStr);
    if (scriptMatch != null) {
      cleanJson = scriptMatch.group(1)!.trim();
    }

    final dynamic parsed = jsonDecode(cleanJson);
    Map<String, dynamic>? recipeMap;

    if (parsed is Map<String, dynamic>) {
      if (parsed['@type'] == 'Recipe' || parsed['@type']?.toString().contains('Recipe') == true) {
        recipeMap = parsed;
      } else if (parsed['@graph'] is List) {
        final graph = parsed['@graph'] as List;
        for (final item in graph) {
          if (item is Map<String, dynamic> && item['@type']?.toString().contains('Recipe') == true) {
            recipeMap = item;
            break;
          }
        }
      }
    }

    if (recipeMap == null) return null;

    final recipeId = _uuid.v4();
    final title = recipeMap['name'] as String? ?? 'Imported Recipe';
    final description = recipeMap['description'] as String?;

    // Servings
    Rational servings = Rational(2);
    final yieldVal = recipeMap['recipeYield'];
    if (yieldVal != null) {
      final yieldStr = yieldVal is List ? yieldVal.first.toString() : yieldVal.toString();
      final numMatch = RegExp(r'\d+').firstMatch(yieldStr);
      if (numMatch != null) {
        final parsedServ = int.tryParse(numMatch.group(0)!);
        if (parsedServ != null && parsedServ > 0) servings = Rational(parsedServ);
      }
    }

    // Ingredients
    final rawIngredients = (recipeMap['recipeIngredient'] as List<dynamic>?) ?? [];
    final ingredients = <RecipeIngredient>[];
    for (int i = 0; i < rawIngredients.length; i++) {
      final raw = rawIngredients[i].toString();
      ingredients.add(_normalizer.normalizeIngredient(raw, recipeId: recipeId, position: i + 1));
    }

    // Instructions
    final steps = <RecipeStep>[];
    final rawInstructions = recipeMap['recipeInstructions'];
    if (rawInstructions is List) {
      for (int i = 0; i < rawInstructions.length; i++) {
        final item = rawInstructions[i];
        String stepText = '';
        if (item is Map && item['text'] != null) {
          stepText = item['text'].toString();
        } else {
          stepText = item.toString();
        }
        if (stepText.isNotEmpty) {
          steps.add(_normalizer.normalizeStep(stepText, recipeId: recipeId, position: steps.length + 1));
        }
      }
    } else if (rawInstructions is String) {
      final lines = rawInstructions.split('\n').where((l) => l.trim().isNotEmpty).toList();
      for (int i = 0; i < lines.length; i++) {
        steps.add(_normalizer.normalizeStep(lines[i], recipeId: recipeId, position: i + 1));
      }
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    return Recipe(
      id: recipeId,
      profileId: profileId,
      title: title,
      summary: description,
      status: RecipeStatus.ready,
      baseServings: servings,
      difficulty: RecipeDifficulty.medium,
      totalMinutes: 30,
      createdAt: now,
      updatedAt: now,
      origin: Origin.imported,
      ingredients: ingredients,
      steps: steps,
    );
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
