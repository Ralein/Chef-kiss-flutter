import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import '../db/app_database.dart';

class DriftSettingsRepository implements SettingsRepository {
  final AppDatabase db;

  DriftSettingsRepository(this.db);

  @override
  Stream<UserProfile> watchProfile() {
    return (db.select(db.profilesTable)..limit(1)).watchSingleOrNull().map((row) {
      if (row == null) {
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        return UserProfile(
          id: 'default',
          displayName: 'Local Cook',
          locale: 'en',
          unitSystem: UnitSystem.metric,
          createdAt: now,
          updatedAt: now,
        );
      }
      return UserProfile(
        id: row.id,
        displayName: row.displayName,
        locale: row.locale,
        unitSystem: UnitSystem.fromString(row.unitSystem),
        settingsVersion: row.settingsVersion,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
    });
  }

  @override
  Future<Result<UserProfile, AppFailure>> getProfile() async {
    try {
      final row = await (db.select(db.profilesTable)..limit(1)).getSingleOrNull();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      if (row == null) {
        const defaultProfile = ProfilesTableCompanion(
          id: Value('default'),
          displayName: Value('Local Cook'),
          locale: Value('en'),
          unitSystem: Value('metric'),
          settingsVersion: Value(1),
          createdAt: Value(0),
          updatedAt: Value(0),
        );
        await db.into(db.profilesTable).insert(defaultProfile);
        return Result.ok(UserProfile(
          id: 'default',
          createdAt: now,
          updatedAt: now,
        ));
      }

      return Result.ok(UserProfile(
        id: row.id,
        displayName: row.displayName,
        locale: row.locale,
        unitSystem: UnitSystem.fromString(row.unitSystem),
        settingsVersion: row.settingsVersion,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      ));
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to get profile: $e', cause: e));
    }
  }

  @override
  Future<Result<UserProfile, AppFailure>> updateProfile(UserProfile profile) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await db.into(db.profilesTable).insertOnConflictUpdate(
            ProfilesTableCompanion(
              id: Value(profile.id),
              displayName: Value(profile.displayName),
              locale: Value(profile.locale),
              unitSystem: Value(profile.unitSystem.toDbString()),
              settingsVersion: Value(profile.settingsVersion),
              createdAt: Value(profile.createdAt),
              updatedAt: Value(now),
            ),
          );
      return Result.ok(profile.copyWith(updatedAt: now));
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to update profile: $e', cause: e));
    }
  }

  @override
  Stream<PlatformCapabilitySnapshot> watchCapabilities() {
    return db.select(db.permissionStatesTable).watch().map((rows) {
      CapabilityStatus notif = CapabilityStatus.notRequested;
      CapabilityStatus mic = CapabilityStatus.notRequested;
      CapabilityStatus cam = CapabilityStatus.notRequested;

      for (final r in rows) {
        final status = _parseCapabilityStatus(r.osState);
        if (r.capability == 'notifications') notif = status;
        if (r.capability == 'speech' || r.capability == 'microphone') mic = status;
        if (r.capability == 'camera') cam = status;
      }

      return PlatformCapabilitySnapshot(
        notifications: notif,
        speechRecognition: mic,
        camera: cam,
      );
    });
  }

  @override
  Future<Result<void, AppFailure>> recordCapabilityState(
    String capability,
    CapabilityStatus status,
  ) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await db.into(db.permissionStatesTable).insertOnConflictUpdate(
            PermissionStatesTableCompanion(
              id: Value('perm_$capability'),
              profileId: const Value('default'),
              capability: Value(capability),
              osState: Value(status.name),
              promptedAt: Value(now),
              updatedAt: Value(now),
              explanationSeen: const Value(true),
            ),
          );
      return Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to record permission state: $e', cause: e));
    }
  }

  @override
  Future<Result<String, AppFailure>> exportDataJson() async {
    try {
      final recipes = await (db.select(db.recipesTable)..where((r) => r.deletedAt.isNull())).get();
      final ingredients = await db.select(db.recipeIngredientsTable).get();
      final steps = await db.select(db.recipeStepsTable).get();
      final collections = await db.select(db.collectionsTable).get();
      final favorites = await db.select(db.favoritesTable).get();

      final exportPayload = {
        'manifest': {
          'app': "Chef's Kiss",
          'schema_version': 1,
          'exported_at': DateTime.now().toUtc().toIso8601String(),
          'recipe_count': recipes.length,
        },
        'recipes': recipes
            .map((r) => {
                  'id': r.id,
                  'title': r.title,
                  'summary': r.summary,
                  'difficulty': r.difficulty,
                  'totalMinutes': r.totalMinutes,
                  'baseServingsNum': r.baseServingsNum,
                  'baseServingsDen': r.baseServingsDen,
                  'visualTemplate': r.visualTemplate,
                })
            .toList(),
        'ingredients': ingredients
            .map((i) => {
                  'recipeId': i.recipeId,
                  'name': i.displayName,
                  'quantityNum': i.quantityNum,
                  'quantityDen': i.quantityDen,
                  'unitCode': i.unitCode,
                  'prepText': i.prepText,
                })
            .toList(),
        'steps': steps
            .map((s) => {
                  'recipeId': s.recipeId,
                  'position': s.position,
                  'instructionShort': s.instructionShort,
                  'actionKey': s.actionKey,
                  'durationSeconds': s.durationSeconds,
                })
            .toList(),
        'collections': collections
            .map((c) => {
                  'id': c.id,
                  'name': c.name,
                  'colorToken': c.colorToken,
                })
            .toList(),
        'favorites': favorites.map((f) => f.recipeId).toList(),
      };

      return Result.ok(jsonEncode(exportPayload));
    } catch (e) {
      return Result.err(StorageFailure(message: 'Export failed: $e', cause: e));
    }
  }

  @override
  Future<Result<int, AppFailure>> importDataJson(String jsonString) async {
    try {
      final dynamic parsed = jsonDecode(jsonString);
      if (parsed is! Map<String, dynamic>) {
        return Result.err(const ValidationFailure(message: 'Invalid backup format'));
      }

      final recipeList = parsed['recipes'] as List<dynamic>? ?? [];
      return Result.ok(recipeList.length);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Import failed: $e', cause: e));
    }
  }

  CapabilityStatus _parseCapabilityStatus(String val) {
    switch (val.toLowerCase()) {
      case 'granted':
        return CapabilityStatus.granted;
      case 'denied':
        return CapabilityStatus.denied;
      case 'restricted':
        return CapabilityStatus.restricted;
      case 'unavailable':
        return CapabilityStatus.unavailable;
      default:
        return CapabilityStatus.notRequested;
    }
  }
}
