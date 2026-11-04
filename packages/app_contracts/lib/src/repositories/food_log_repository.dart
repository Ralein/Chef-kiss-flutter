import 'package:recipe_domain/recipe_domain.dart';
import '../result.dart';
import '../failures.dart';

/// Persistence for eaten meals and daily nutrition totals.
abstract interface class FoodLogRepository {
  /// Entries for one local day, oldest first.
  Stream<List<FoodLogEntry>> watchDay(String dayKey, {String profileId = 'default'});

  /// One summary per day that has entries, between the two day keys inclusive.
  Stream<List<DailyNutritionSummary>> watchSummaries({
    required String fromDayKey,
    required String toDayKey,
    String profileId = 'default',
  });

  Future<Result<FoodLogEntry, AppFailure>> saveEntry(FoodLogEntry entry, {String profileId = 'default'});

  Future<Result<void, AppFailure>> deleteEntry(String id);
}

/// Small typed key/value store for app preferences (goals, onboarding flags).
abstract interface class PreferencesRepository {
  Future<Object?> readJson(String key);
  Stream<Object?> watchJson(String key);
  Future<Result<void, AppFailure>> writeJson(String key, Object? value);
}
