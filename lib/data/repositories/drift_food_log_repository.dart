import 'dart:convert';

import 'package:app_contracts/app_contracts.dart';
import 'package:drift/drift.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../db/app_database.dart';

class DriftFoodLogRepository implements FoodLogRepository {
  final AppDatabase db;

  DriftFoodLogRepository(this.db);

  @override
  Stream<List<FoodLogEntry>> watchDay(String dayKey, {String profileId = 'default'}) {
    final query = db.select(db.foodLogEntriesTable)
      ..where((e) => e.profileId.equals(profileId) & e.dayKey.equals(dayKey))
      ..orderBy([(e) => OrderingTerm.asc(e.loggedAt)]);
    return query.watch().map((rows) => rows.map(_toEntry).toList(growable: false));
  }

  @override
  Stream<List<DailyNutritionSummary>> watchSummaries({
    required String fromDayKey,
    required String toDayKey,
    String profileId = 'default',
  }) {
    final t = db.foodLogEntriesTable;
    final count = t.id.count();
    final cal = t.calories.sum();
    final protein = t.proteinG.sum();
    final carbs = t.carbsG.sum();
    final fat = t.fatG.sum();
    final fiber = t.fiberG.sum();
    final sugar = t.sugarG.sum();
    final sodium = t.sodiumMg.sum();

    final query = db.selectOnly(t)
      ..addColumns([t.dayKey, count, cal, protein, carbs, fat, fiber, sugar, sodium])
      ..where(t.profileId.equals(profileId) & t.dayKey.isBetweenValues(fromDayKey, toDayKey))
      ..groupBy([t.dayKey])
      ..orderBy([OrderingTerm.asc(t.dayKey)]);

    return query.watch().map((rows) => rows
        .map((r) => DailyNutritionSummary(
              dayKey: r.read(t.dayKey)!,
              entryCount: r.read(count) ?? 0,
              total: NutritionFacts(
                calories: r.read(cal) ?? 0,
                proteinG: r.read(protein) ?? 0,
                carbsG: r.read(carbs) ?? 0,
                fatG: r.read(fat) ?? 0,
                fiberG: r.read(fiber) ?? 0,
                sugarG: r.read(sugar) ?? 0,
                sodiumMg: r.read(sodium) ?? 0,
              ),
            ))
        .toList(growable: false));
  }

  @override
  Future<Result<FoodLogEntry, AppFailure>> saveEntry(FoodLogEntry entry, {String profileId = 'default'}) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final n = entry.nutrition;
      await db.into(db.foodLogEntriesTable).insertOnConflictUpdate(
            FoodLogEntriesTableCompanion(
              id: Value(entry.id),
              profileId: Value(profileId),
              dayKey: Value(entry.dayKey),
              mealSlot: Value(entry.mealSlot.name),
              title: Value(entry.title),
              source: Value(entry.source.name),
              recipeId: Value(entry.recipeId),
              imagePath: Value(entry.imagePath),
              portionMultiplier: Value(entry.portionMultiplier),
              calories: Value(n.calories),
              proteinG: Value(n.proteinG),
              carbsG: Value(n.carbsG),
              fatG: Value(n.fatG),
              fiberG: Value(n.fiberG),
              sugarG: Value(n.sugarG),
              sodiumMg: Value(n.sodiumMg),
              analysisJson: Value(entry.analysis == null ? '{}' : jsonEncode(entry.analysis!.toJson())),
              loggedAt: Value(entry.loggedAt),
              createdAt: Value(now),
            ),
          );
      return Result.ok(entry);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Could not save this meal to your food log.', cause: e));
    }
  }

  @override
  Future<Result<void, AppFailure>> deleteEntry(String id) async {
    try {
      await (db.delete(db.foodLogEntriesTable)..where((e) => e.id.equals(id))).go();
      return const Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Could not delete this entry.', cause: e));
    }
  }

  FoodLogEntry _toEntry(FoodLogEntriesTableData row) {
    FoodAnalysis? analysis;
    try {
      final decoded = jsonDecode(row.analysisJson);
      if (decoded is Map<String, dynamic> && decoded.isNotEmpty) {
        analysis = FoodAnalysis.fromJson(decoded);
      }
    } catch (_) {
      // A corrupt snapshot must not hide the entry itself.
    }
    return FoodLogEntry(
      id: row.id,
      dayKey: row.dayKey,
      mealSlot: MealSlot.fromName(row.mealSlot),
      title: row.title,
      source: FoodLogSource.fromName(row.source),
      recipeId: row.recipeId,
      imagePath: row.imagePath,
      portionMultiplier: row.portionMultiplier,
      nutrition: NutritionFacts(
        calories: row.calories,
        proteinG: row.proteinG,
        carbsG: row.carbsG,
        fatG: row.fatG,
        fiberG: row.fiberG,
        sugarG: row.sugarG,
        sodiumMg: row.sodiumMg,
      ),
      analysis: analysis,
      loggedAt: row.loggedAt,
    );
  }
}

/// Key/value preferences on top of `app_settings_table`.
class DriftPreferencesRepository implements PreferencesRepository {
  final AppDatabase db;
  final String profileId;

  DriftPreferencesRepository(this.db, {this.profileId = 'default'});

  String _rowId(String key) => '$profileId::$key';

  @override
  Future<Object?> readJson(String key) async {
    final row = await (db.select(db.appSettingsTable)..where((s) => s.id.equals(_rowId(key)))).getSingleOrNull();
    return _decode(row?.valueJson);
  }

  @override
  Stream<Object?> watchJson(String key) {
    return (db.select(db.appSettingsTable)..where((s) => s.id.equals(_rowId(key))))
        .watchSingleOrNull()
        .map((row) => _decode(row?.valueJson));
  }

  @override
  Future<Result<void, AppFailure>> writeJson(String key, Object? value) async {
    try {
      await db.into(db.appSettingsTable).insertOnConflictUpdate(
            AppSettingsTableCompanion(
              id: Value(_rowId(key)),
              profileId: Value(profileId),
              key: Value(key),
              valueJson: Value(jsonEncode(value)),
              updatedAt: Value(DateTime.now().toUtc().millisecondsSinceEpoch),
            ),
          );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Could not save preference.', cause: e));
    }
  }

  static Object? _decode(String? json) {
    if (json == null) return null;
    try {
      return jsonDecode(json);
    } catch (_) {
      return null;
    }
  }
}
