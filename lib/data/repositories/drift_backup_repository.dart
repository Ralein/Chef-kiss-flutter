import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import 'package:uuid/uuid.dart';
import '../db/app_database.dart';
import 'drift_recipe_repository.dart';
import 'drift_collection_repository.dart';
import 'drift_settings_repository.dart';

class DriftBackupRepository implements BackupRepository {
  final AppDatabase _db;
  final DriftRecipeRepository _recipeRepo;
  final DriftCollectionRepository _collectionRepo;
  final DriftSettingsRepository _settingsRepo;
  final Uuid _uuid;

  DriftBackupRepository(
    this._db, {
    DriftRecipeRepository? recipeRepo,
    DriftCollectionRepository? collectionRepo,
    DriftSettingsRepository? settingsRepo,
    Uuid uuid = const Uuid(),
  })  : _recipeRepo = recipeRepo ?? DriftRecipeRepository(_db),
        _collectionRepo = collectionRepo ?? DriftCollectionRepository(_db),
        _settingsRepo = settingsRepo ?? DriftSettingsRepository(_db),
        _uuid = uuid;

  @override
  Future<Result<String, AppFailure>> exportBackupJson({required String profileId}) async {
    try {
      final recipesRes = await _recipeRepo.getRecipes(
        filter: const RecipeFilter(includeArchived: false),
      );
      final recipes = recipesRes.orNull ?? [];

      final collectionsRes = await _collectionRepo.getCollections();
      final collections = collectionsRes.orNull ?? [];

      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final profileRes = await _settingsRepo.getProfile();
      final profile = profileRes.orNull ??
          UserProfile(
            id: 'default',
            createdAt: now,
            updatedAt: now,
          );

      final payloadJson = {
        'recipes': recipes.map((r) => r.title).toList(),
        'collections': collections.map((c) => c.name).toList(),
      };
      final checksum = payloadJson.toString().hashCode.toString();

      final manifest = BackupManifest(
        schemaVersion: 1,
        appVersion: '1.0.0+1',
        exportedAt: now,
        profileId: profileId,
        recipeCount: recipes.length,
        collectionCount: collections.length,
        sha256Checksum: checksum,
      );

      final pkg = ChefBackupPackage(
        manifest: manifest,
        profile: profile,
        recipes: recipes,
        collections: collections,
      );

      final jsonStr = JsonEncoder.withIndent('  ').convert(pkg.toJson());
      return Result.ok(jsonStr);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to export backup: $e', cause: e));
    }
  }

  @override
  Future<Result<BackupValidationResult, AppFailure>> validateBackupJson(String jsonStr) async {
    try {
      final pkg = ChefBackupPackage.fromJsonString(jsonStr);

      final existingRes = await _recipeRepo.getRecipes();
      final existingRecipes = existingRes.orNull ?? [];
      final existingTitles = existingRecipes.map((r) => r.title.toLowerCase()).toSet();

      final duplicates = <String>[];
      for (final r in pkg.recipes) {
        if (existingTitles.contains(r.title.toLowerCase())) {
          duplicates.add(r.title);
        }
      }

      return Result.ok(BackupValidationResult(
        isValid: true,
        recipeCount: pkg.recipes.length,
        collectionCount: pkg.collections.length,
        duplicateRecipeTitles: duplicates,
      ));
    } catch (e) {
      return Result.ok(BackupValidationResult(
        isValid: false,
        recipeCount: 0,
        collectionCount: 0,
        blockingErrors: ['Failed to parse JSON backup package: $e'],
      ));
    }
  }

  @override
  Future<Result<int, AppFailure>> restoreBackupJson({
    required String jsonStr,
    required DuplicatePolicy duplicatePolicy,
    required String profileId,
  }) async {
    try {
      final pkg = ChefBackupPackage.fromJsonString(jsonStr);

      final existingRes = await _recipeRepo.getRecipes();
      final existingRecipes = existingRes.orNull ?? [];
      final existingMap = {for (var r in existingRecipes) r.title.toLowerCase(): r};

      int restoredCount = 0;

      await _db.transaction(() async {
        for (final recipe in pkg.recipes) {
          final existing = existingMap[recipe.title.toLowerCase()];

          if (existing != null) {
            switch (duplicatePolicy) {
              case DuplicatePolicy.skip:
                continue;
              case DuplicatePolicy.replace:
                await _recipeRepo.saveRecipe(recipe.copyWith(
                  id: existing.id,
                  profileId: profileId,
                  updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
                ));
                restoredCount++;
                break;
              case DuplicatePolicy.keepBoth:
                final newId = _uuid.v4();
                await _recipeRepo.saveRecipe(recipe.copyWith(
                  id: newId,
                  profileId: profileId,
                  title: '${recipe.title} (Restored)',
                  updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
                ));
                restoredCount++;
                break;
            }
          } else {
            await _recipeRepo.saveRecipe(recipe.copyWith(profileId: profileId));
            restoredCount++;
          }
        }

        // Restore collections
        for (final col in pkg.collections) {
          await _collectionRepo.createCollection(
            profileId: profileId,
            name: col.name,
            colorToken: col.colorToken,
            description: col.description,
          );
        }
      });

      return Result.ok(restoredCount);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to restore backup: $e', cause: e));
    }
  }

  @override
  Future<Result<void, AppFailure>> resetAllData({required String profileId}) async {
    try {
      await _db.transaction(() async {
        await _db.recipesTable.delete().go();
        await _db.recipeIngredientsTable.delete().go();
        await _db.recipeStepsTable.delete().go();
        await _db.stepTimersTable.delete().go();
        await _db.collectionsTable.delete().go();
        await _db.collectionRecipesTable.delete().go();
        await _db.cookingSessionsTable.delete().go();
        await _db.sessionTimersTable.delete().go();
      });
      return const Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to reset all data: $e', cause: e));
    }
  }
}
