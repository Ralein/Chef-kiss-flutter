import 'package:app_contracts/app_contracts.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../core/ai/ai_prompts.dart';
import '../../../core/ai/ai_client.dart';
import '../../../core/ai/claude_client.dart';
import '../../../core/media/image_prep.dart';
import 'ai_recipe_mapper.dart';

/// Recipe extraction (text, web page text, photos) and generation via Claude.
class AiRecipeService {
  final AiClient _client;
  final AiRecipeMapper _mapper;

  AiRecipeService(this._client, {AiRecipeMapper mapper = const AiRecipeMapper()}) : _mapper = mapper;

  Future<Result<AiRecipeDraft, AppFailure>> extractFromText(String text) {
    return _run(
      system: AiPrompts.extractSystem,
      content: [ClaudeText('Convert this recipe source into structured data.\n\n<source>\n$text\n</source>')],
      origin: Origin.imported,
      feature: 'import_text',
    );
  }

  Future<Result<AiRecipeDraft, AppFailure>> extractFromImage(PreparedImage image) {
    return _run(
      system: AiPrompts.extractSystem,
      content: [
        ClaudeImage(image.bytes, image.mediaType),
        const ClaudeText('Transcribe the recipe in this photo into structured data.'),
      ],
      origin: Origin.imported,
      feature: 'import_photo',
    );
  }

  Future<Result<AiRecipeDraft, AppFailure>> generate(String request, {ScrapbookTheme theme = ScrapbookTheme.terracottaClassic}) {
    return _run(
      system: AiPrompts.generateSystem,
      content: [ClaudeText('Recipe request: $request')],
      origin: Origin.aiProposed,
      theme: theme,
      feature: 'generate',
    );
  }

  /// Dishes to cook with [ingredients] on hand, plus pantry staples.
  Future<Result<List<DishIdea>, AppFailure>> suggestDishes(List<String> ingredients) async {
    final res = await _client.createStructured(
      system: AiPrompts.dishIdeasSystem,
      content: [ClaudeText('Ingredients on hand:\n${ingredients.map((i) => '- $i').join('\n')}')],
      schema: AiPrompts.dishIdeasSchema,
      effort: 'low',
      maxTokens: 4000,
      feature: 'dish_ideas',
    );
    return res.flatMap((response) {
      final ideas = DishIdea.listFrom(response.json);
      return ideas.isEmpty
          ? const Result.err(RemoteFailure(message: 'No ideas came back.', recoveryAction: 'Try again, or add an ingredient.'))
          : Result.ok(ideas);
    });
  }

  Future<Result<AiRecipeDraft, AppFailure>> _run({
    required String system,
    required List<ClaudeContent> content,
    required Origin origin,
    required String feature,
    ScrapbookTheme theme = ScrapbookTheme.terracottaClassic,
  }) async {
    final res = await _client.createStructured(
      system: system,
      content: content,
      schema: AiPrompts.recipeSchema,
      feature: feature,
    );
    return res.flatMap((response) {
      final json = response.json;
      final hasContent = (json['ingredients'] as List?)?.isNotEmpty == true || (json['steps'] as List?)?.isNotEmpty == true;
      if (json['is_recipe'] == false || !hasContent) {
        return const Result.err(ValidationFailure(
          message: "That doesn't look like a recipe.",
          recoveryAction: 'Try a clearer photo or paste the full recipe text.',
        ));
      }
      return Result.ok(_mapper.map(json, origin: origin, theme: theme));
    });
  }
}

/// A dish the AI suggests for what's on hand.
class DishIdea {
  final String title;
  final String summary;
  final int minutes;

  /// Ingredients on hand it uses, and others it needs that aren't staples.
  final List<String> uses;
  final List<String> missing;

  const DishIdea({
    required this.title,
    required this.summary,
    this.minutes = 0,
    this.uses = const [],
    this.missing = const [],
  });

  static List<DishIdea> listFrom(Map<String, dynamic> json) {
    List<String> strings(Object? v) => [
          if (v is List)
            for (final s in v)
              if (s is String && s.trim().isNotEmpty) s.trim(),
        ];
    return [
      for (final i in json['ideas'] as List? ?? const [])
        if (i is Map && i['title'] is String && (i['title'] as String).trim().isNotEmpty)
          DishIdea(
            title: (i['title'] as String).trim(),
            summary: (i['summary'] as String? ?? '').trim(),
            minutes: (i['minutes'] as num?)?.toInt().clamp(0, 24 * 60) ?? 0,
            uses: strings(i['uses']),
            missing: strings(i['missing']),
          ),
    ];
  }

  /// What to ask for when making it a full recipe.
  String get request => [
        '$title: $summary',
        if (uses.isNotEmpty) 'Use mainly ${uses.join(', ')}.',
        if (missing.isNotEmpty) 'It may also use ${missing.join(', ')}.',
        'Keep to about $minutes minutes.',
      ].join(' ');
}
