import 'package:app_contracts/app_contracts.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../core/ai/ai_prompts.dart';
import '../../../core/ai/ai_client.dart';
import '../../../core/ai/claude_client.dart';
import '../../../core/media/image_prep.dart';

/// Meal and ingredient recognition from photos.
class FoodVisionService {
  final AiClient _client;
  FoodVisionService(this._client);

  /// [image] is the photo; without one, [hint] describes the food in words.
  Future<Result<FoodAnalysis, AppFailure>> analyze(ScanMode mode, PreparedImage? image, {String? hint}) async {
    assert(mode != ScanMode.recipeCard, 'Recipe cards go through AiRecipeService.extractFromImage');
    if (image == null) {
      final res = await _client.createStructured(
        system: mode == ScanMode.meal ? AiPrompts.mealSystem : AiPrompts.ingredientsSystem,
        content: [
          ClaudeText(
            mode == ScanMode.meal
                ? 'There is no photo; the user describes what they ate. Analyze this meal, judging typical '
                      'portions where they are not given:\n\n${hint?.trim() ?? ''}'
                : 'There is no photo; the user lists what they have. Suggest dishes:\n\n${hint?.trim() ?? ''}',
          ),
        ],
        schema: AiPrompts.foodAnalysisSchema,
        feature: 'scan_${mode.key}_text',
      );
      return res.map((response) => FoodAnalysis.fromJson(response.json, mode: mode));
    }
    final instruction = mode == ScanMode.meal
        ? 'Analyze the food in this photo.'
        : 'List the ingredients in this photo and suggest dishes.';
    final note = (hint == null || hint.trim().isEmpty) ? '' : '\n\nNote from the user: ${hint.trim()}';

    final res = await _client.createStructured(
      system: mode == ScanMode.meal ? AiPrompts.mealSystem : AiPrompts.ingredientsSystem,
      content: [ClaudeImage(image.bytes, image.mediaType), ClaudeText('$instruction$note')],
      schema: AiPrompts.foodAnalysisSchema,
      feature: 'scan_${mode.key}',
    );
    return res.map((response) => FoodAnalysis.fromJson(response.json, mode: mode));
  }
}
