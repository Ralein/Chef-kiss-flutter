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

  Future<Result<FoodAnalysis, AppFailure>> analyze(ScanMode mode, PreparedImage image, {String? hint}) async {
    assert(mode != ScanMode.recipeCard, 'Recipe cards go through AiRecipeService.extractFromImage');
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
