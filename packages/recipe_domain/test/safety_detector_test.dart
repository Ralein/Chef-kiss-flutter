import 'package:test/test.dart';
import 'package:recipe_domain/recipe_domain.dart';

void main() {
  const detector = SafetyDetector();

  group('SafetyDetector', () {
    test('identifies dairy and gluten allergens', () {
      final recipe = Recipe(
        id: 'rec_cake',
        profileId: 'default',
        title: 'Butter Cake',
        status: RecipeStatus.ready,
        baseServings: Rational(8),
        difficulty: RecipeDifficulty.medium,
        totalMinutes: 45,
        createdAt: 1000,
        updatedAt: 1000,
        ingredients: [
          RecipeIngredient(
            id: 'ing_1',
            recipeId: 'rec_cake',
            displayName: 'All-purpose flour',
            quantity: Rational(2),
            unitCode: 'cup',
            position: 1,
          ),
          RecipeIngredient(
            id: 'ing_2',
            recipeId: 'rec_cake',
            displayName: 'Unsalted butter',
            quantity: Rational(1),
            unitCode: 'cup',
            position: 2,
          ),
        ],
        steps: const [],
      );

      final alerts = detector.analyzeRecipe(recipe);
      expect(alerts.any((a) => a.title.contains('Dairy')), isTrue);
      expect(alerts.any((a) => a.title.contains('Gluten')), isTrue);
    });

    test('generates poultry safe internal temperature warning', () {
      final recipe = Recipe(
        id: 'rec_chicken',
        profileId: 'default',
        title: 'Roast Chicken',
        status: RecipeStatus.ready,
        baseServings: Rational(4),
        difficulty: RecipeDifficulty.medium,
        totalMinutes: 60,
        createdAt: 1000,
        updatedAt: 1000,
        ingredients: [
          RecipeIngredient(
            id: 'ing_chicken',
            recipeId: 'rec_chicken',
            displayName: 'Whole chicken',
            quantity: Rational(1),
            unitCode: 'each',
            position: 1,
          ),
        ],
        steps: const [
          RecipeStep(
            id: 'step_1',
            recipeId: 'rec_chicken',
            position: 1,
            instructionShort: 'Roast in oven.',
            actionKey: 'roast',
          ),
        ],
      );

      final alerts = detector.analyzeRecipe(recipe);
      expect(alerts.any((a) => a.type == SafetyAlertType.temperatureWarning), isTrue);
      expect(alerts.any((a) => a.message.contains('74°C (165°F)')), isTrue);
    });
  });
}
