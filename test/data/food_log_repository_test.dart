import 'dart:io';

import 'package:drift/native.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:test/test.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/data/repositories/drift_food_log_repository.dart';

FoodLogEntry entry(String id, String day, double kcal, {MealSlot slot = MealSlot.lunch, int at = 0}) => FoodLogEntry(
      id: id,
      dayKey: day,
      mealSlot: slot,
      title: 'Meal $id',
      source: FoodLogSource.scan,
      nutrition: NutritionFacts(calories: kcal, proteinG: kcal / 20),
      analysis: const FoodAnalysis(mode: ScanMode.meal, isFood: true, title: 'Bowl', description: '', confidence: .8),
      loggedAt: at,
    );

void main() {
  group('DriftFoodLogRepository', () {
    late AppDatabase db;
    late DriftFoodLogRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFoodLogRepository(db);
    });
    tearDown(() => db.close());

    test('saves, lists by day in time order, and round-trips the analysis', () async {
      await repo.saveEntry(entry('b', '2026-11-05', 300, at: 20));
      await repo.saveEntry(entry('a', '2026-11-05', 450, slot: MealSlot.breakfast, at: 10));
      await repo.saveEntry(entry('c', '2026-11-04', 999, at: 5));

      final day = await repo.watchDay('2026-11-05').first;
      expect(day.map((e) => e.id), ['a', 'b']);
      expect(day.first.mealSlot, MealSlot.breakfast);
      expect(day.first.analysis?.title, 'Bowl');
    });

    test('summaries aggregate per day within the requested range', () async {
      await repo.saveEntry(entry('1', '2026-11-03', 100));
      await repo.saveEntry(entry('2', '2026-11-04', 200));
      await repo.saveEntry(entry('3', '2026-11-04', 300));
      await repo.saveEntry(entry('4', '2026-11-09', 400));

      final sums = await repo.watchSummaries(fromDayKey: '2026-11-03', toDayKey: '2026-11-05').first;
      expect(sums.map((s) => s.dayKey), ['2026-11-03', '2026-11-04']);
      expect(sums[1].total.calories, 500);
      expect(sums[1].entryCount, 2);
    });

    test('updating an entry replaces it; deleting removes it', () async {
      final e = entry('x', '2026-11-05', 200);
      await repo.saveEntry(e);
      await repo.saveEntry(e.copyWith(portionMultiplier: 2, nutrition: const NutritionFacts(calories: 400)));
      expect((await repo.watchDay('2026-11-05').first).single.nutrition.calories, 400);

      await repo.deleteEntry('x');
      expect(await repo.watchDay('2026-11-05').first, isEmpty);
    });
  });

  group('DriftPreferencesRepository', () {
    test('stores JSON values and NutritionGoals survive a round trip', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final prefs = DriftPreferencesRepository(db);
      expect(await prefs.readJson('goals'), isNull);

      await prefs.writeJson('goals', const NutritionGoals(calories: 1800, proteinG: 120).toJson());
      final goals = NutritionGoals.fromJson(await prefs.readJson('goals'));
      expect(goals.calories, 1800);
      expect(goals.proteinG, 120);
      expect(goals.fatG, NutritionGoals.standard.fatG);
      await db.close();
    });
  });

  test('migrates a v1 database to v2 without losing recipes', () async {
    final dir = Directory.systemTemp.createTempSync('chefs_kiss_migration');
    final file = File('${dir.path}/app.sqlite');
    addTearDown(() => dir.deleteSync(recursive: true));

    // Build a database, then make it look exactly like a v1 install.
    var db = AppDatabase(NativeDatabase(file));
    await db.customStatement(
      "INSERT INTO recipes_table (id, profile_id, title, created_at, updated_at) VALUES ('keep', 'default', 'Old', 1, 1)",
    );
    await db.customStatement('DROP TABLE food_log_entries_table');
    await db.customStatement('PRAGMA user_version = 1');
    await db.close();

    db = AppDatabase(NativeDatabase(file));
    final repo = DriftFoodLogRepository(db);
    final saved = await repo.saveEntry(entry('m', '2026-11-05', 250));
    expect(saved.isSuccess, isTrue, reason: saved.error?.message);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 2);
    final recipes = await db.select(db.recipesTable).get();
    expect(recipes.single.title, 'Old');
    await db.close();
  });
}
