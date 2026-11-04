import 'package:app_contracts/app_contracts.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../core/ai/ai_prompts.dart';
import '../../../core/ai/claude_client.dart';
import '../../../core/media/image_prep.dart';
import 'ai_recipe_mapper.dart';

/// Recipe extraction (text, web page text, photos) and generation via Claude.
class AiRecipeService {
  final ClaudeClient _client;
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
