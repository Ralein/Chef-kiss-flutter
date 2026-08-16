import 'package:recipe_domain/recipe_domain.dart';
import 'package:test/test.dart';

void main() {
  group('RecipeScalingEngine', () {
    const engine = RecipeScalingEngine();

    final testRecipe = Recipe(
      id: 'r_1',
      profileId: 'p_1',
      title: 'Pasta',
      baseServings: Rational(2),
      createdAt: 1000,
      updatedAt: 1000,
      ingredients: [
        RecipeIngredient(
          id: 'i_1',
          recipeId: 'r_1',
          displayName: 'Flour',
          quantity: Rational(200),
          unitCode: 'g',
          scalingPolicy: ScalingPolicy.scale,
          position: 1,
        ),
        RecipeIngredient(
          id: 'i_2',
          recipeId: 'r_1',
          displayName: 'Eggs',
          quantity: Rational(2),
          unitCode: 'each',
          scalingPolicy: ScalingPolicy.scale,
          position: 2,
        ),
        const RecipeIngredient(
          id: 'i_3',
          recipeId: 'r_1',
          displayName: 'Salt',
          authoredQuantity: 'to taste',
          scalingPolicy: ScalingPolicy.toTaste,
          position: 3,
        ),
        RecipeIngredient(
          id: 'i_4',
          recipeId: 'r_1',
          displayName: 'Bay Leaf',
          quantity: Rational(1),
          unitCode: 'each',
          scalingPolicy: ScalingPolicy.fixed,
          position: 4,
        ),
      ],
      steps: const [
        RecipeStep(
          id: 's_1',
          recipeId: 'r_1',
          position: 1,
          instructionShort: 'Mix flour and eggs.',
        ),
      ],
    );

    test('doubles scalable ingredients when scaled 2 -> 4 servings', () {
      final scaled = engine.scaleRecipe(testRecipe, Rational(4));
      expect(scaled.baseServings, equals(Rational(4)));

      // Flour: 200g * 2 = 400g
      expect(scaled.ingredients[0].quantity, equals(Rational(400)));
      // Eggs: 2 * 2 = 4
      expect(scaled.ingredients[1].quantity, equals(Rational(4)));
      // Salt: to taste (unchanged)
      expect(scaled.ingredients[2].authoredQuantity, equals('to taste'));
      // Bay leaf: fixed 1 (unchanged)
      expect(scaled.ingredients[3].quantity, equals(Rational(1)));
    });

    test('halves scalable ingredients when scaled 2 -> 1 serving', () {
      final scaled = engine.scaleRecipe(testRecipe, Rational(1));
      expect(scaled.ingredients[0].quantity, equals(Rational(100)));
      expect(scaled.ingredients[1].quantity, equals(Rational(1)));
    });
  });
}
