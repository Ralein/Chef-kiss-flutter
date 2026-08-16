import '../models/recipe.dart';

enum RecipeLayoutTemplate {
  /// 3–8 ingredients, few steps. Hero plus radial/stacked ingredient cards
  ingredientForward,

  /// 5+ sequential actions or timers. Linear step story with technique/tool chips
  processForward,

  /// Oven/temperature data present. Temperature hero badge, prep versus bake grouping
  bakeForward,

  /// Partial/manual recipe. Plain paper-like note, visible "complete recipe" prompt
  minimalNote,

  /// Allergen/safety warnings present. Alert placed before ingredients/cook action
  safetyForward;

  String toDbString() {
    switch (this) {
      case RecipeLayoutTemplate.ingredientForward:
        return 'ingredient_forward';
      case RecipeLayoutTemplate.processForward:
        return 'process_forward';
      case RecipeLayoutTemplate.bakeForward:
        return 'bake_forward';
      case RecipeLayoutTemplate.minimalNote:
        return 'minimal_note';
      case RecipeLayoutTemplate.safetyForward:
        return 'safety_forward';
    }
  }

  static RecipeLayoutTemplate fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'process_forward':
      case 'processforward':
        return RecipeLayoutTemplate.processForward;
      case 'bake_forward':
      case 'bakeforward':
        return RecipeLayoutTemplate.bakeForward;
      case 'minimal_note':
      case 'minimalnote':
        return RecipeLayoutTemplate.minimalNote;
      case 'safety_forward':
      case 'safetyforward':
        return RecipeLayoutTemplate.safetyForward;
      case 'ingredient_forward':
      case 'ingredientforward':
      default:
        return RecipeLayoutTemplate.ingredientForward;
    }
  }
}

class RecipeLayoutSelector {
  const RecipeLayoutSelector();

  /// Deterministically select layout template based on recipe facts
  RecipeLayoutTemplate selectTemplate(Recipe recipe) {
    // 1. If explicitly configured and valid, respect it unless overridden by safety
    final hasSafetyAlert = recipe.steps.any((s) => s.safetyJson != null && s.safetyJson!.isNotEmpty) ||
        recipe.labels.any((l) => l.kind == 'allergen' || l.kind == 'safety');

    if (hasSafetyAlert) {
      return RecipeLayoutTemplate.safetyForward;
    }

    if (recipe.visualTemplate != null) {
      return RecipeLayoutTemplate.fromString(recipe.visualTemplate);
    }

    // 2. Minimal note check for incomplete or draft notes
    if (recipe.status == RecipeStatus.draft ||
        recipe.ingredients.length <= 2 ||
        recipe.steps.isEmpty) {
      return RecipeLayoutTemplate.minimalNote;
    }

    // 3. Bake / temperature forward check
    final hasBakeTemperature = recipe.steps.any(
      (s) => (s.temperatureC != null && s.temperatureC! > 0) ||
          (s.temperatureF != null && s.temperatureF! > 0),
    );
    if (hasBakeTemperature) {
      return RecipeLayoutTemplate.bakeForward;
    }

    // 4. Process forward check: 5+ steps or 3+ timers
    final totalTimers = recipe.steps.fold<int>(
      0,
      (count, step) => count + step.timers.length + (step.durationSeconds != null ? 1 : 0),
    );
    if (recipe.steps.length >= 5 || totalTimers >= 3) {
      return RecipeLayoutTemplate.processForward;
    }

    // 5. Default to ingredient forward for concise meals (3-8 ingredients)
    return RecipeLayoutTemplate.ingredientForward;
  }
}
