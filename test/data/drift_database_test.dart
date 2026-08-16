import 'package:test/test.dart';
import 'package:drift/native.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/data/repositories/drift_recipe_repository.dart';

void main() {
  late AppDatabase db;
  late DriftRecipeRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftRecipeRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DriftRecipeRepository', () {
    final testRecipe = Recipe(
      id: 'test_pasta_1',
      profileId: 'default',
      title: 'Simple Garlic Pasta',
      summary: 'Quick weeknight dinner with olive oil and garlic.',
      status: RecipeStatus.ready,
      baseServings: Rational(2),
      difficulty: RecipeDifficulty.easy,
      totalMinutes: 12,
      createdAt: 1000,
      updatedAt: 1000,
      ingredients: [
        RecipeIngredient(
          id: 'i_1',
          recipeId: 'test_pasta_1',
          displayName: 'Spaghetti',
          quantity: Rational(200),
          unitCode: 'g',
          position: 1,
        ),
        RecipeIngredient(
          id: 'i_2',
          recipeId: 'test_pasta_1',
          displayName: 'Garlic',
          quantity: Rational(3),
          unitCode: 'cloves',
          position: 2,
        ),
      ],
      steps: const [
        RecipeStep(
          id: 's_1',
          recipeId: 'test_pasta_1',
          position: 1,
          instructionShort: 'Boil spaghetti in salted water.',
          durationSeconds: 600,
        ),
        RecipeStep(
          id: 's_2',
          recipeId: 'test_pasta_1',
          position: 2,
          instructionShort: 'Sauté sliced garlic in olive oil.',
          durationSeconds: 120,
        ),
      ],
    );

    test('saves and retrieves recipe with all relations', () async {
      final saveRes = await repo.saveRecipe(testRecipe);
      expect(saveRes.isSuccess, isTrue);

      final fetchedRes = await repo.getRecipeById('test_pasta_1');
      expect(fetchedRes.isSuccess, isTrue);
      final recipe = fetchedRes.orNull!;

      expect(recipe.title, equals('Simple Garlic Pasta'));
      expect(recipe.baseServings, equals(Rational(2)));
      expect(recipe.ingredients.length, equals(2));
      expect(recipe.ingredients[0].displayName, equals('Spaghetti'));
      expect(recipe.ingredients[0].quantity, equals(Rational(200)));
      expect(recipe.steps.length, equals(2));
      expect(recipe.steps[0].instructionShort, equals('Boil spaghetti in salted water.'));
    });

    test('toggles favorite status correctly', () async {
      await repo.saveRecipe(testRecipe);

      // Initially not favorite
      var fetched = (await repo.getRecipeById('test_pasta_1')).orNull!;
      expect(fetched.isFavorite, isFalse);

      // Toggle favorite ON
      final fav1 = await repo.toggleFavorite('test_pasta_1');
      expect(fav1.orNull, isTrue);

      fetched = (await repo.getRecipeById('test_pasta_1')).orNull!;
      expect(fetched.isFavorite, isTrue);

      // Toggle favorite OFF
      final fav2 = await repo.toggleFavorite('test_pasta_1');
      expect(fav2.orNull, isFalse);

      fetched = (await repo.getRecipeById('test_pasta_1')).orNull!;
      expect(fetched.isFavorite, isFalse);
    });

    test('soft-deletes and restores recipe', () async {
      await repo.saveRecipe(testRecipe);

      // Soft delete
      await repo.deleteRecipe('test_pasta_1');
      final fetchedAfterDelete = (await repo.getRecipeById('test_pasta_1')).orNull!;
      expect(fetchedAfterDelete.isDeleted, isTrue);

      // Restore
      await repo.restoreRecipe('test_pasta_1');
      final fetchedAfterRestore = (await repo.getRecipeById('test_pasta_1')).orNull!;
      expect(fetchedAfterRestore.isDeleted, isFalse);
    });

    test('searches recipes by title keyword', () async {
      await repo.saveRecipe(testRecipe);

      final searchRes = await repo.searchRecipes('garlic');
      expect(searchRes.isSuccess, isTrue);
      expect(searchRes.orNull!.length, equals(1));
      expect(searchRes.orNull!.first.id, equals('test_pasta_1'));
    });

    test('seeds starter recipes idempotently', () async {
      final seededCount1 = await repo.seedStarterRecipes([testRecipe]);
      expect(seededCount1.orNull, equals(1));

      // Running seed second time should not duplicate or overwrite
      final seededCount2 = await repo.seedStarterRecipes([testRecipe]);
      expect(seededCount2.orNull, equals(0));
    });
  });
}
