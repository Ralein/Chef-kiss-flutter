import '../models/rational.dart';
import '../models/recipe.dart';
import '../models/scaling_policy.dart';

class ScaledIngredientResult {
  final RecipeIngredient original;
  final Rational? scaledQuantity;
  final bool isApproximate;
  final String formattedDisplay;

  const ScaledIngredientResult({
    required this.original,
    required this.scaledQuantity,
    this.isApproximate = false,
    required this.formattedDisplay,
  });
}

class RecipeScalingEngine {
  const RecipeScalingEngine();

  /// Calculates the scale multiplier: targetServings / baseServings
  Rational calculateMultiplier(Rational baseServings, Rational targetServings) {
    if (baseServings.isZero) {
      throw ArgumentError('Base servings cannot be zero');
    }
    return targetServings / baseServings;
  }

  /// Scales a single ingredient based on its scaling policy
  ScaledIngredientResult scaleIngredient(
    RecipeIngredient ingredient,
    Rational multiplier,
  ) {
    switch (ingredient.scalingPolicy) {
      case ScalingPolicy.scale:
        if (ingredient.quantity != null) {
          final scaled = ingredient.quantity!.scale(multiplier);
          return ScaledIngredientResult(
            original: ingredient,
            scaledQuantity: scaled,
            isApproximate: false,
            formattedDisplay: ingredient.formatDisplay(scaled),
          );
        } else {
          return ScaledIngredientResult(
            original: ingredient,
            scaledQuantity: null,
            isApproximate: true,
            formattedDisplay: ingredient.formatDisplay(),
          );
        }

      case ScalingPolicy.fixed:
      case ScalingPolicy.toTaste:
        return ScaledIngredientResult(
          original: ingredient,
          scaledQuantity: ingredient.quantity,
          isApproximate: false,
          formattedDisplay: ingredient.formatDisplay(ingredient.quantity),
        );

      case ScalingPolicy.approximate:
        final scaled = ingredient.quantity?.scale(multiplier);
        return ScaledIngredientResult(
          original: ingredient,
          scaledQuantity: scaled,
          isApproximate: true,
          formattedDisplay: '~ ${ingredient.formatDisplay(scaled)}',
        );
    }
  }

  /// Scales all ingredients of a recipe for the target servings
  List<ScaledIngredientResult> scaleAllIngredients(
    Recipe recipe,
    Rational targetServings,
  ) {
    final multiplier = calculateMultiplier(recipe.baseServings, targetServings);
    return recipe.ingredients
        .map((ing) => scaleIngredient(ing, multiplier))
        .toList(growable: false);
  }

  /// Returns a new Recipe instance with scaled quantities in its ingredients list
  Recipe scaleRecipe(Recipe recipe, Rational targetServings) {
    if (recipe.baseServings == targetServings) return recipe;
    final multiplier = calculateMultiplier(recipe.baseServings, targetServings);

    final scaledIngredients = recipe.ingredients.map((ing) {
      if (ing.scalingPolicy == ScalingPolicy.scale && ing.quantity != null) {
        return ing.copyWith(quantity: ing.quantity!.scale(multiplier));
      }
      return ing;
    }).toList(growable: false);

    return recipe.copyWith(
      baseServings: targetServings,
      ingredients: scaledIngredients,
    );
  }
}
