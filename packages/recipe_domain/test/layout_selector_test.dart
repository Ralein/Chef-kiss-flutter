import 'package:recipe_domain/recipe_domain.dart';
import 'package:test/test.dart';

void main() {
  group('RecipeLayoutSelector', () {
    const selector = RecipeLayoutSelector();

    test('selects bakeForward when oven temperature is present', () {
      final bakeRecipe = Recipe(
        id: 'r_bake',
        profileId: 'p_1',
        title: 'Sourdough Bread',
        status: RecipeStatus.ready,
        baseServings: Rational(1),
        createdAt: 1000,
        updatedAt: 1000,
        ingredients: List.generate(
          4,
          (i) => RecipeIngredient(
            id: 'i_$i',
            recipeId: 'r_bake',
            displayName: 'Ing $i',
            position: i + 1,
          ),
        ),
        steps: const [
          RecipeStep(
            id: 's_1',
            recipeId: 'r_bake',
            position: 1,
            instructionShort: 'Preheat dutch oven',
            temperatureC: 230,
          ),
        ],
      );

      expect(selector.selectTemplate(bakeRecipe), equals(RecipeLayoutTemplate.bakeForward));
    });

    test('selects processForward when recipe has 5+ steps', () {
      final longRecipe = Recipe(
        id: 'r_long',
        profileId: 'p_1',
        title: 'Complex Stew',
        status: RecipeStatus.ready,
        baseServings: Rational(4),
        createdAt: 1000,
        updatedAt: 1000,
        ingredients: List.generate(
          5,
          (i) => RecipeIngredient(
            id: 'i_$i',
            recipeId: 'r_long',
            displayName: 'Ing $i',
            position: i + 1,
          ),
        ),
        steps: List.generate(
          6,
          (i) => RecipeStep(
            id: 's_$i',
            recipeId: 'r_long',
            position: i + 1,
            instructionShort: 'Step $i',
          ),
        ),
      );

      expect(selector.selectTemplate(longRecipe), equals(RecipeLayoutTemplate.processForward));
    });

    test('selects safetyForward when allergen warning exists', () {
      final allergyRecipe = Recipe(
        id: 'r_nut',
        profileId: 'p_1',
        title: 'Peanut Sauce',
        status: RecipeStatus.ready,
        baseServings: Rational(2),
        createdAt: 1000,
        updatedAt: 1000,
        labels: const [
          RecipeLabel(
            id: 'l_1',
            recipeId: 'r_nut',
            labelId: 'lbl_allergen',
            kind: 'allergen',
            canonicalKey: 'peanuts',
            displayName: 'Contains Peanuts',
          ),
        ],
        ingredients: const [
          RecipeIngredient(id: 'i_1', recipeId: 'r_nut', displayName: 'Peanuts', position: 1),
        ],
        steps: const [
          RecipeStep(id: 's_1', recipeId: 'r_nut', position: 1, instructionShort: 'Blend'),
        ],
      );

      expect(selector.selectTemplate(allergyRecipe), equals(RecipeLayoutTemplate.safetyForward));
    });

    test('selects minimalNote for incomplete draft', () {
      final draftRecipe = Recipe(
        id: 'r_draft',
        profileId: 'p_1',
        title: 'Idea',
        status: RecipeStatus.draft,
        baseServings: Rational(1),
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(selector.selectTemplate(draftRecipe), equals(RecipeLayoutTemplate.minimalNote));
    });
  });

  group('RecipeValidator', () {
    const validator = RecipeValidator();

    test('blocks empty title, 0 servings, missing ingredients, missing steps for ready status', () {
      final invalidRecipe = Recipe(
        id: 'r_inv',
        profileId: 'p_1',
        title: '',
        baseServings: Rational(0),
        createdAt: 1000,
        updatedAt: 1000,
      );

      final res = validator.validateForReady(invalidRecipe);
      expect(res.isValid, isFalse);
      expect(res.blockingErrors.length, greaterThanOrEqualTo(3));
    });

    test('passes valid ready recipe', () {
      final validRecipe = Recipe(
        id: 'r_val',
        profileId: 'p_1',
        title: 'Tomato Toast',
        status: RecipeStatus.ready,
        baseServings: Rational(2),
        createdAt: 1000,
        updatedAt: 1000,
        ingredients: const [
          RecipeIngredient(id: 'i_1', recipeId: 'r_val', displayName: 'Bread', position: 1),
          RecipeIngredient(id: 'i_2', recipeId: 'r_val', displayName: 'Tomato', position: 2),
        ],
        steps: const [
          RecipeStep(id: 's_1', recipeId: 'r_val', position: 1, instructionShort: 'Toast bread'),
        ],
      );

      final res = validator.validateForReady(validRecipe);
      expect(res.isValid, isTrue);
      expect(res.blockingErrors, isEmpty);
    });
  });
}
