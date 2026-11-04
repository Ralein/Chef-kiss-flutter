import 'package:drift/native.dart';
import 'package:test/test.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/data/repositories/drift_recipe_repository.dart';

/// Regression tests for data-integrity defects found during the production
/// readiness audit. Each test documents the user-visible symptom it guards.
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

  Recipe recipeWithTimer(String id, {String childPrefix = 'x'}) {
    return Recipe(
      id: id,
      profileId: 'default',
      title: 'Recipe $id',
      baseServings: Rational(2),
      createdAt: 1000,
      updatedAt: 1000,
      ingredients: [
        RecipeIngredient(
          id: '$childPrefix-ing-1',
          recipeId: id,
          displayName: 'Flour',
          quantity: Rational(200),
          unitCode: 'g',
          position: 1,
        ),
      ],
      steps: [
        RecipeStep(
          id: '$childPrefix-step-1',
          recipeId: id,
          position: 1,
          instructionShort: 'Rest the dough.',
          timers: [
            StepTimer(
              id: '$childPrefix-timer-1',
              recipeStepId: '$childPrefix-step-1',
              label: 'Rest',
              durationSeconds: 600,
            ),
          ],
        ),
      ],
    );
  }

  group('saveRecipe integrity', () {
    test('re-saving a recipe that has step timers succeeds and keeps the timer', () async {
      // Symptom: any edit (title, sticker, servings) to a recipe with timers was
      // silently rolled back because stale timer rows collided on primary key.
      final first = await repo.saveRecipe(recipeWithTimer('r1'));
      expect(first.isSuccess, isTrue, reason: first.error?.message);

      final edited = first.orNull!.copyWith(title: 'Renamed');
      final second = await repo.saveRecipe(edited);
      expect(second.isSuccess, isTrue, reason: second.error?.message);

      final reloaded = (await repo.getRecipeById('r1')).orNull!;
      expect(reloaded.title, 'Renamed');
      expect(reloaded.steps.single.timers.single.durationSeconds, 600);
    });

    test('two recipes whose child rows share ids can both be saved', () async {
      // Symptom: "New Recipe" only worked once because every blank recipe
      // reused the literal ids ing-1 / st-1.
      final a = await repo.saveRecipe(recipeWithTimer('ra', childPrefix: 'same'));
      final b = await repo.saveRecipe(recipeWithTimer('rb', childPrefix: 'same'));
      expect(a.isSuccess, isTrue, reason: a.error?.message);
      expect(b.isSuccess, isTrue, reason: b.error?.message);

      final ra = (await repo.getRecipeById('ra')).orNull!;
      final rb = (await repo.getRecipeById('rb')).orNull!;
      expect(ra.ingredients.single.displayName, 'Flour');
      expect(rb.ingredients.single.displayName, 'Flour');
      expect(ra.ingredients.single.id, isNot(rb.ingredients.single.id));
      expect(rb.steps.single.timers, hasLength(1));
    });

    test('saveRecipe persists the isFavorite flag', () async {
      // Symptom: the heart on the library card showed a success toast but
      // never changed, because favorites live in a separate table.
      await repo.saveRecipe(recipeWithTimer('fav').copyWith(isFavorite: true));
      expect((await repo.getRecipeById('fav')).orNull!.isFavorite, isTrue);

      final current = (await repo.getRecipeById('fav')).orNull!;
      await repo.saveRecipe(current.copyWith(isFavorite: false));
      expect((await repo.getRecipeById('fav')).orNull!.isFavorite, isFalse);
    });

    test('version history is bounded so frequent edits do not grow the DB forever', () async {
      var current = (await repo.saveRecipe(recipeWithTimer('busy'))).orNull!;
      for (var i = 0; i < 40; i++) {
        current = (await repo.saveRecipe(current.copyWith(title: 'Edit $i'))).orNull!;
      }
      final versions = await (db.select(db.recipeVersionsTable)..where((v) => v.recipeId.equals('busy'))).get();
      expect(versions.length, lessThanOrEqualTo(DriftRecipeRepository.maxStoredVersions));
    });
  });

  group('reactive streams', () {
    test('watchRecipes re-emits when only the favorites table changes', () async {
      await repo.saveRecipe(recipeWithTimer('w1'));

      final emissions = <bool>[];
      final sub = repo.watchRecipes().listen((list) {
        if (list.isNotEmpty) emissions.add(list.first.isFavorite);
      });

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await repo.toggleFavorite('w1');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(emissions.first, isFalse);
      expect(emissions.last, isTrue, reason: 'library list must reflect favorite toggles');
    });

    test('watchRecipes loads full relations for many recipes', () async {
      for (var i = 0; i < 12; i++) {
        await repo.saveRecipe(recipeWithTimer('bulk$i', childPrefix: 'bulk$i'));
      }
      final list = await repo.watchRecipes().first;
      expect(list, hasLength(12));
      expect(list.every((r) => r.ingredients.length == 1 && r.steps.single.timers.length == 1), isTrue);
    });
  });

  group('notes', () {
    test('recipe notes are persisted and reloaded', () async {
      final r = recipeWithTimer('noted').copyWith(notes: const [
        RecipeNote(id: 'n1', recipeId: 'noted', body: 'Source: https://example.com', noteType: 'source', position: 1),
      ]);
      await repo.saveRecipe(r);
      final reloaded = (await repo.getRecipeById('noted')).orNull!;
      expect(reloaded.notes.single.body, 'Source: https://example.com');
      expect(reloaded.notes.single.noteType, 'source');
    });
  });

  group('deletion', () {
    test('purgeRecipe removes every child row', () async {
      await repo.saveRecipe(recipeWithTimer('gone'));
      await repo.toggleFavorite('gone');
      final res = await repo.purgeRecipe('gone');
      expect(res.isSuccess, isTrue);

      expect(await db.select(db.recipeIngredientsTable).get(), isEmpty);
      expect(await db.select(db.recipeStepsTable).get(), isEmpty);
      expect(await db.select(db.stepTimersTable).get(), isEmpty);
      expect(await db.select(db.favoritesTable).get(), isEmpty);
      expect(await db.select(db.recipeVersionsTable).get(), isEmpty);
    });
  });
}
