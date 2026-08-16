import 'package:test/test.dart';
import 'package:recipe_domain/recipe_domain.dart';

void main() {
  const normalizer = RecipeNormalizer();

  group('RecipeNormalizer Ingredient Parsing', () {
    test('parses mixed fraction with unit and prep text', () {
      final ing = normalizer.normalizeIngredient(
        '2 1/2 cups all-purpose flour, sifted',
        recipeId: 'rec_1',
      );
      expect(ing.quantity, equals(Rational(5, 2)));
      expect(ing.unitCode, equals('cup'));
      expect(ing.displayName, equals('all-purpose flour'));
      expect(ing.prepText, equals('sifted'));
      expect(ing.scalingPolicy, equals(ScalingPolicy.scale));
    });

    test('parses simple quantity with unit and prep text', () {
      final ing = normalizer.normalizeIngredient(
        '3 cloves garlic, finely minced',
        recipeId: 'rec_1',
      );
      expect(ing.quantity, equals(Rational(3)));
      expect(ing.unitCode, equals('cloves'));
      expect(ing.displayName, equals('garlic'));
      expect(ing.prepText, equals('finely minced'));
    });

    test('identifies to-taste policy correctly', () {
      final ing = normalizer.normalizeIngredient(
        'Kosher salt and freshly cracked black pepper to taste',
        recipeId: 'rec_1',
      );
      expect(ing.quantity, isNull);
      expect(ing.scalingPolicy, equals(ScalingPolicy.toTaste));
      expect(ing.displayName, contains('Kosher salt'));
    });

    test('parses metric units', () {
      final ing = normalizer.normalizeIngredient(
        '500 g spaghetti',
        recipeId: 'rec_1',
      );
      expect(ing.quantity, equals(Rational(500)));
      expect(ing.unitCode, equals('g'));
      expect(ing.displayName, equals('spaghetti'));
    });
  });

  group('RecipeNormalizer Step Parsing', () {
    test('detects action verb, duration, and timers', () {
      final step = normalizer.normalizeStep(
        'Sauté onions in olive oil for 8 minutes until golden.',
        recipeId: 'rec_1',
        position: 1,
      );
      expect(step.actionKey, equals('sauté'));
      expect(step.durationSeconds, equals(480));
      expect(step.timers.length, equals(1));
      expect(step.timers.first.durationSeconds, equals(480));
    });

    test('detects oven temperatures in Fahrenheit and Celsius', () {
      final step = normalizer.normalizeStep(
        'Preheat oven to 375°F and line baking sheet with parchment.',
        recipeId: 'rec_1',
        position: 2,
      );
      expect(step.actionKey, equals('preheat'));
      expect(step.temperatureF, equals(375));
      expect(step.temperatureC, equals(191));
    });
  });
}
