import 'package:app_contracts/app_contracts.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../core/ai/ai_prompts.dart';
import '../../../core/ai/claude_client.dart';

/// Fills nutrition gaps the offline catalog cannot resolve.
class AiNutritionService {
  final ClaudeClient _client;
  AiNutritionService(this._client);

  /// Returns estimates keyed by [RecipeNutritionAnalyzer.fingerprint], ready
  /// to merge into `Recipe.nutritionOverrides`.
  Future<Result<Map<String, NutritionFacts>, AppFailure>> estimate(List<RecipeIngredient> lines) async {
    if (lines.isEmpty) return const Result.ok({});
    final listing = StringBuffer();
    for (var i = 0; i < lines.length; i++) {
      listing.writeln('${i + 1}. ${lines[i].formatDisplay()}');
    }
    final res = await _client.createStructured(
      system: AiPrompts.ingredientNutritionSystem,
      content: [ClaudeText('Ingredient lines:\n$listing')],
      schema: AiPrompts.ingredientNutritionSchema,
      effort: 'low',
      feature: 'nutrition_estimate',
    );
    return res.map((response) {
      final out = <String, NutritionFacts>{};
      for (final e in (response.json['estimates'] as List? ?? const []).whereType<Map<String, dynamic>>()) {
        final line = (e['line'] as num?)?.toInt();
        if (line == null || line < 1 || line > lines.length) continue;
        final facts = NutritionFacts.fromJson(e);
        // Reject absurd outliers (> 10,000 kcal for one ingredient line).
        if (facts.calories > 10000) continue;
        out[RecipeNutritionAnalyzer.fingerprint(lines[line - 1])] = facts;
      }
      return out;
    });
  }
}
