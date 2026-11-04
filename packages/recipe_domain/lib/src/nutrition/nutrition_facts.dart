import 'package:meta/meta.dart';

/// An immutable bundle of the core nutrients tracked by Chef's Kiss.
///
/// Energy is in kilocalories; macros in grams; sodium in milligrams. Values are
/// always finite and non-negative — every parsing path clamps garbage input so
/// downstream arithmetic and UI never see NaN, infinity or negative numbers.
@immutable
class NutritionFacts {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final double sodiumMg;

  const NutritionFacts({
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.fiberG = 0,
    this.sugarG = 0,
    this.sodiumMg = 0,
  });

  static const NutritionFacts zero = NutritionFacts();

  bool get isZero =>
      calories == 0 && proteinG == 0 && carbsG == 0 && fatG == 0 && fiberG == 0 && sugarG == 0 && sodiumMg == 0;

  NutritionFacts operator +(NutritionFacts other) => NutritionFacts(
        calories: calories + other.calories,
        proteinG: proteinG + other.proteinG,
        carbsG: carbsG + other.carbsG,
        fatG: fatG + other.fatG,
        fiberG: fiberG + other.fiberG,
        sugarG: sugarG + other.sugarG,
        sodiumMg: sodiumMg + other.sodiumMg,
      );

  /// Multiplies every nutrient by [factor]. Non-finite or negative factors
  /// collapse to zero rather than poisoning totals.
  NutritionFacts scale(double factor) {
    if (!factor.isFinite || factor <= 0) return zero;
    return NutritionFacts(
      calories: calories * factor,
      proteinG: proteinG * factor,
      carbsG: carbsG * factor,
      fatG: fatG * factor,
      fiberG: fiberG * factor,
      sugarG: sugarG * factor,
      sodiumMg: sodiumMg * factor,
    );
  }

  static NutritionFacts sum(Iterable<NutritionFacts> items) => items.fold(zero, (a, b) => a + b);

  /// Share of energy contributed by each macro (Atwater factors 4/4/9).
  /// Returns zeros when there is no macro energy to split.
  ({double protein, double carbs, double fat}) get macroEnergySplit {
    final p = proteinG * 4;
    final c = carbsG * 4;
    final f = fatG * 9;
    final total = p + c + f;
    if (total <= 0) return (protein: 0, carbs: 0, fat: 0);
    return (protein: p / total, carbs: c / total, fat: f / total);
  }

  Map<String, dynamic> toJson() => {
        'calories': _round(calories),
        'protein_g': _round(proteinG),
        'carbs_g': _round(carbsG),
        'fat_g': _round(fatG),
        'fiber_g': _round(fiberG),
        'sugar_g': _round(sugarG),
        'sodium_mg': _round(sodiumMg),
      };

  factory NutritionFacts.fromJson(Map<String, dynamic>? json) {
    if (json == null) return zero;
    return NutritionFacts(
      calories: _clean(json['calories'] ?? json['kcal']),
      proteinG: _clean(json['protein_g'] ?? json['protein']),
      carbsG: _clean(json['carbs_g'] ?? json['carbohydrates_g'] ?? json['carbs']),
      fatG: _clean(json['fat_g'] ?? json['fat']),
      fiberG: _clean(json['fiber_g'] ?? json['fiber']),
      sugarG: _clean(json['sugar_g'] ?? json['sugar']),
      sodiumMg: _clean(json['sodium_mg'] ?? json['sodium']),
    );
  }

  /// Decodes a fingerprint → facts map persisted alongside a recipe.
  static Map<String, NutritionFacts> decodeOverrides(Object? raw) {
    if (raw is! Map) return const {};
    final out = <String, NutritionFacts>{};
    raw.forEach((key, value) {
      if (key is String && value is Map<String, dynamic>) {
        out[key] = NutritionFacts.fromJson(value);
      }
    });
    return out;
  }

  static Map<String, dynamic> encodeOverrides(Map<String, NutritionFacts> overrides) =>
      overrides.map((key, value) => MapEntry(key, value.toJson()));

  /// Parses a JSON number (or numeric string) into a finite, non-negative double.
  static double _clean(Object? value) {
    double? parsed;
    if (value is num) {
      parsed = value.toDouble();
    } else if (value is String) {
      parsed = double.tryParse(value.trim());
    }
    if (parsed == null || !parsed.isFinite || parsed < 0) return 0;
    return parsed;
  }

  static double _round(double v) => (v * 10).roundToDouble() / 10;

  @override
  bool operator ==(Object other) =>
      other is NutritionFacts &&
      other.calories == calories &&
      other.proteinG == proteinG &&
      other.carbsG == carbsG &&
      other.fatG == fatG &&
      other.fiberG == fiberG &&
      other.sugarG == sugarG &&
      other.sodiumMg == sodiumMg;

  @override
  int get hashCode => Object.hash(calories, proteinG, carbsG, fatG, fiberG, sugarG, sodiumMg);

  @override
  String toString() =>
      'NutritionFacts(${calories.toStringAsFixed(0)} kcal, P ${proteinG.toStringAsFixed(1)}g, '
      'C ${carbsG.toStringAsFixed(1)}g, F ${fatG.toStringAsFixed(1)}g)';
}
