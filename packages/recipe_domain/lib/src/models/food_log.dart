import 'package:meta/meta.dart';
import '../nutrition/food_analysis.dart';
import '../nutrition/nutrition_facts.dart';

enum MealSlot {
  breakfast,
  lunch,
  dinner,
  snack;

  String get label => switch (this) {
        MealSlot.breakfast => 'Breakfast',
        MealSlot.lunch => 'Lunch',
        MealSlot.dinner => 'Dinner',
        MealSlot.snack => 'Snack',
      };

  static MealSlot fromName(String? name) =>
      MealSlot.values.firstWhere((s) => s.name == name, orElse: () => MealSlot.snack);

  /// Sensible default for "log this now" based on local time of day.
  static MealSlot forTime(DateTime local) {
    final h = local.hour;
    if (h >= 5 && h < 11) return MealSlot.breakfast;
    if (h >= 11 && h < 16) return MealSlot.lunch;
    if (h >= 17 && h < 22) return MealSlot.dinner;
    return MealSlot.snack;
  }
}

enum FoodLogSource {
  scan,
  recipe,
  manual;

  static FoodLogSource fromName(String? name) =>
      FoodLogSource.values.firstWhere((s) => s.name == name, orElse: () => FoodLogSource.manual);
}

/// `YYYY-MM-DD` for a local calendar day. Food is logged against the day it
/// was eaten in the user's timezone, not UTC.
String dayKeyFor(DateTime local) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-${two(local.day)}';
}

DateTime dateForDayKey(String dayKey) {
  final parts = dayKey.split('-').map(int.tryParse).toList();
  if (parts.length != 3 || parts.any((p) => p == null)) return DateTime.now();
  return DateTime(parts[0]!, parts[1]!, parts[2]!);
}

@immutable
class FoodLogEntry {
  final String id;
  final String dayKey;
  final MealSlot mealSlot;
  final String title;
  final FoodLogSource source;
  final String? recipeId;
  final String? imagePath;
  final double portionMultiplier;

  /// What was actually eaten (base estimate × [portionMultiplier]).
  final NutritionFacts nutrition;
  final FoodAnalysis? analysis;
  final int loggedAt;

  const FoodLogEntry({
    required this.id,
    required this.dayKey,
    required this.mealSlot,
    required this.title,
    required this.source,
    this.recipeId,
    this.imagePath,
    this.portionMultiplier = 1,
    required this.nutrition,
    this.analysis,
    required this.loggedAt,
  });

  FoodLogEntry copyWith({
    String? dayKey,
    MealSlot? mealSlot,
    String? title,
    double? portionMultiplier,
    NutritionFacts? nutrition,
  }) =>
      FoodLogEntry(
        id: id,
        dayKey: dayKey ?? this.dayKey,
        mealSlot: mealSlot ?? this.mealSlot,
        title: title ?? this.title,
        source: source,
        recipeId: recipeId,
        imagePath: imagePath,
        portionMultiplier: portionMultiplier ?? this.portionMultiplier,
        nutrition: nutrition ?? this.nutrition,
        analysis: analysis,
        loggedAt: loggedAt,
      );
}

@immutable
class DailyNutritionSummary {
  final String dayKey;
  final NutritionFacts total;
  final int entryCount;

  const DailyNutritionSummary({required this.dayKey, required this.total, required this.entryCount});
}

/// Daily targets. Defaults follow the U.S. FDA Daily Values for a 2,000 kcal
/// reference diet; users can change them in Settings.
@immutable
class NutritionGoals {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sodiumMg;

  const NutritionGoals({
    this.calories = 2000,
    this.proteinG = 50,
    this.carbsG = 275,
    this.fatG = 78,
    this.fiberG = 28,
    this.sodiumMg = 2300,
  });

  static const NutritionGoals standard = NutritionGoals();

  NutritionGoals copyWith({double? calories, double? proteinG, double? carbsG, double? fatG}) => NutritionGoals(
        calories: calories ?? this.calories,
        proteinG: proteinG ?? this.proteinG,
        carbsG: carbsG ?? this.carbsG,
        fatG: fatG ?? this.fatG,
        fiberG: fiberG,
        sodiumMg: sodiumMg,
      );

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'fiber_g': fiberG,
        'sodium_mg': sodiumMg,
      };

  factory NutritionGoals.fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return standard;
    double pick(String key, double fallback) {
      final v = raw[key];
      final d = v is num ? v.toDouble() : null;
      return d != null && d.isFinite && d > 0 ? d : fallback;
    }

    return NutritionGoals(
      calories: pick('calories', standard.calories),
      proteinG: pick('protein_g', standard.proteinG),
      carbsG: pick('carbs_g', standard.carbsG),
      fatG: pick('fat_g', standard.fatG),
      fiberG: pick('fiber_g', standard.fiberG),
      sodiumMg: pick('sodium_mg', standard.sodiumMg),
    );
  }
}
