import 'package:test/test.dart';
import 'package:drift/native.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/data/repositories/drift_recipe_repository.dart';
import 'package:chefs_kiss/data/repositories/drift_collection_repository.dart';
import 'package:chefs_kiss/data/repositories/drift_backup_repository.dart';

void main() {
  late AppDatabase db;
  late DriftRecipeRepository recipeRepo;
  late DriftCollectionRepository collectionRepo;
  late DriftBackupRepository backupRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    recipeRepo = DriftRecipeRepository(db);
    collectionRepo = DriftCollectionRepository(db);
    backupRepo = DriftBackupRepository(db, recipeRepo: recipeRepo, collectionRepo: collectionRepo);
  });

  tearDown(() async {
    await db.close();
  });

  group('DriftBackupRepository', () {
    final testRecipe = Recipe(
      id: 'rec_sourdough_1',
      profileId: 'default',
      title: 'Rustic Sourdough Boule',
      summary: 'Naturally leavened crusty sourdough loaf.',
      status: RecipeStatus.ready,
      baseServings: Rational(1),
      difficulty: RecipeDifficulty.hard,
      totalMinutes: 1440,
      createdAt: 1000,
      updatedAt: 1000,
      ingredients: [
        RecipeIngredient(
          id: 'i_flour',
          recipeId: 'rec_sourdough_1',
          displayName: 'Bread Flour',
          quantity: Rational(500),
          unitCode: 'g',
          position: 1,
        ),
      ],
      steps: const [
        RecipeStep(
          id: 's_mix',
          recipeId: 'rec_sourdough_1',
          position: 1,
          instructionShort: 'Mix flour and water and autolyse.',
          durationSeconds: 1800,
        ),
      ],
    );

    test('exports full backup package JSON with manifest and checksum', () async {
      await recipeRepo.saveRecipe(testRecipe);
      await collectionRepo.createCollection(
        profileId: 'default',
        name: 'Baking Projects',
        colorToken: 'accent.tomato',
      );

      final exportRes = await backupRepo.exportBackupJson(profileId: 'default');
      expect(exportRes.isSuccess, isTrue);

      final jsonStr = exportRes.orNull!;
      expect(jsonStr, contains('Rustic Sourdough Boule'));
      expect(jsonStr, contains('Baking Projects'));
      expect(jsonStr, contains('schemaVersion'));
    });

    test('validates backup schema and flags existing duplicate titles', () async {
      await recipeRepo.saveRecipe(testRecipe);

      final exportRes = await backupRepo.exportBackupJson(profileId: 'default');
      final jsonStr = exportRes.orNull!;

      final validationRes = await backupRepo.validateBackupJson(jsonStr);
      expect(validationRes.isSuccess, isTrue);
      final validation = validationRes.orNull!;

      expect(validation.isValid, isTrue);
      expect(validation.recipeCount, equals(1));
      expect(validation.duplicateRecipeTitles, contains('Rustic Sourdough Boule'));
    });

    test('restores backup with keepBoth duplicate policy', () async {
      await recipeRepo.saveRecipe(testRecipe);

      final exportRes = await backupRepo.exportBackupJson(profileId: 'default');
      final jsonStr = exportRes.orNull!;

      // Restore with keepBoth policy
      final restoreRes = await backupRepo.restoreBackupJson(
        jsonStr: jsonStr,
        duplicatePolicy: DuplicatePolicy.keepBoth,
        profileId: 'default',
      );

      expect(restoreRes.isSuccess, isTrue);
      expect(restoreRes.orNull, equals(1));

      final allRecipes = (await recipeRepo.getRecipes()).orNull!;
      expect(allRecipes.length, equals(2));
      expect(allRecipes.any((r) => r.title == 'Rustic Sourdough Boule'), isTrue);
      expect(allRecipes.any((r) => r.title == 'Rustic Sourdough Boule (Restored)'), isTrue);
    });

    test('resets all local data cleanly', () async {
      await recipeRepo.saveRecipe(testRecipe);
      await collectionRepo.createCollection(
        profileId: 'default',
        name: 'To Delete',
        colorToken: 'accent.herb',
      );

      final resetRes = await backupRepo.resetAllData(profileId: 'default');
      expect(resetRes.isSuccess, isTrue);

      final recipesAfterReset = (await recipeRepo.getRecipes()).orNull!;
      expect(recipesAfterReset, isEmpty);

      final collectionsAfterReset = (await collectionRepo.getCollections()).orNull!;
      expect(collectionsAfterReset, isEmpty);
    });
  });
}
