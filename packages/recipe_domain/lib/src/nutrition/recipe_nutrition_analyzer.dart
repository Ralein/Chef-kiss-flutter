import 'package:meta/meta.dart';

import '../models/recipe.dart';
import 'food_catalog.dart';
import 'food_matcher.dart';
import 'nutrition_facts.dart';

/// How a single ingredient line contributed to a nutrition estimate.
enum NutritionLineStatus {
  /// Matched to the reference catalog and converted to grams.
  matched,

  /// A stored estimate (e.g. from AI) was used for this exact line.
  override,

  /// A negligible seasoning (salt, herbs, water). Always counts as covered.
  trace,

  /// Recognised, but the quantity/unit could not be converted to grams.
  unquantified,

  /// Not in the reference catalog.
  unmatched;

  bool get isCovered => this == matched || this == override || this == trace;
}

@immutable
class IngredientNutritionLine {
  final RecipeIngredient ingredient;
  final FoodEntry? food;
  final double? grams;
  final NutritionFacts facts;
  final NutritionLineStatus status;

  const IngredientNutritionLine({
    required this.ingredient,
    required this.food,
    required this.grams,
    required this.facts,
    required this.status,
  });
}

/// Diet badges and allergens derived from matched ingredients.
@immutable
class DietProfile {
  final Set<FoodTrait> traits;

  /// False when some ingredients could not be identified, so a badge such as
  /// "vegan" is only *likely* rather than verified.
  final bool isComplete;

  const DietProfile({required this.traits, required this.isComplete});

  bool get isVegetarian =>
      !traits.contains(FoodTrait.meat) &&
      !traits.contains(FoodTrait.poultry) &&
      !traits.contains(FoodTrait.fish) &&
      !traits.contains(FoodTrait.shellfish);

  bool get isVegan =>
      isVegetarian &&
      !traits.contains(FoodTrait.dairy) &&
      !traits.contains(FoodTrait.egg) &&
      !traits.contains(FoodTrait.animalDerived);

  bool get isGlutenFree => !traits.contains(FoodTrait.gluten);
  bool get isDairyFree => !traits.contains(FoodTrait.dairy);

  /// Human-readable allergen names present in the recipe, in a stable order.
  List<String> get allergens => [
        if (traits.contains(FoodTrait.gluten)) 'Gluten',
        if (traits.contains(FoodTrait.dairy)) 'Dairy',
        if (traits.contains(FoodTrait.egg)) 'Egg',
        if (traits.contains(FoodTrait.peanut)) 'Peanuts',
        if (traits.contains(FoodTrait.treeNut)) 'Tree nuts',
        if (traits.contains(FoodTrait.soy)) 'Soy',
        if (traits.contains(FoodTrait.sesame)) 'Sesame',
        if (traits.contains(FoodTrait.fish)) 'Fish',
        if (traits.contains(FoodTrait.shellfish)) 'Shellfish',
      ];
}

@immutable
class RecipeNutritionReport {
  final List<IngredientNutritionLine> lines;
  final NutritionFacts total;
  final double servings;
  final DietProfile diet;

  const RecipeNutritionReport({
    required this.lines,
    required this.total,
    required this.servings,
    required this.diet,
  });

  NutritionFacts get perServing => total.scale(1 / servings);

  int get countedLines => lines.length;
  int get coveredLines => lines.where((l) => l.status.isCovered).length;

  /// Fraction of ingredient lines that contributed a usable estimate.
  double get coverage => countedLines == 0 ? 0 : coveredLines / countedLines;

  /// Lines that would benefit from a better estimate (AI refine or editing).
  List<IngredientNutritionLine> get unresolved => lines.where((l) => !l.status.isCovered).toList(growable: false);

  bool get hasData => total.calories > 0 || coveredLines > 0;
}

/// Grams represented by one unit of a kitchen measure, or null if unknown.
class KitchenUnits {
  KitchenUnits._();

  static const Map<String, double> _massGrams = {
    'g': 1, 'gram': 1, 'grams': 1, 'gr': 1, 'kg': 1000, 'kilogram': 1000, 'kilograms': 1000, 'mg': 0.001,
    'oz': 28.3495, 'ounce': 28.3495, 'ounces': 28.3495, 'lb': 453.592, 'lbs': 453.592, 'pound': 453.592,
    'pounds': 453.592,
  };

  static const Map<String, double> _volumeMl = {
    'ml': 1, 'milliliter': 1, 'milliliters': 1, 'millilitre': 1, 'millilitres': 1, 'cl': 10, 'dl': 100,
    'l': 1000, 'liter': 1000, 'liters': 1000, 'litre': 1000, 'litres': 1000,
    'tsp': 4.92892, 'teaspoon': 4.92892, 'teaspoons': 4.92892, 't': 4.92892,
    'tbsp': 14.7868, 'tablespoon': 14.7868, 'tablespoons': 14.7868, 'tbs': 14.7868, 'tb': 14.7868, 'tbl': 14.7868,
    'cup': 236.588, 'cups': 236.588, 'c': 236.588, 'fl oz': 29.5735, 'floz': 29.5735, 'fluid ounce': 29.5735,
    'pint': 473.176, 'pints': 473.176, 'pt': 473.176, 'quart': 946.353, 'quarts': 946.353, 'qt': 946.353,
    'gallon': 3785.41, 'gallons': 3785.41,
    'pinch': 0.31, 'pinches': 0.31, 'dash': 0.62, 'dashes': 0.62, 'drop': 0.05, 'drops': 0.05,
    'splash': 5, 'shot': 44, 'jigger': 44,
  };

  static const Set<String> _countUnits = {
    '', 'each', 'ea', 'piece', 'pieces', 'pc', 'pcs', 'whole', 'small', 'medium', 'large', 'extra large', 'xl',
    'unit', 'units', 'head', 'heads', 'stalk', 'stalks', 'rib', 'ribs', 'fillet', 'fillets', 'breast', 'breasts',
    'nest', 'nests', 'sheet', 'sheets', 'thumb', 'knob', 'ear', 'ears', 'link', 'links', 'wedge', 'wedges',
    'cloves', 'clove', 'slice', 'slices', 'can', 'cans', 'tin', 'tins', 'jar', 'jars',
  };

  /// Returns grams for [quantity] of [unit] of [food], or null when the
  /// measurement cannot be converted (no quantity, unknown unit, missing data).
  static double? toGrams(double? quantity, String? unit, FoodEntry food) {
    if (quantity == null || !quantity.isFinite || quantity <= 0) return null;
    final u = (unit ?? '').trim().toLowerCase().replaceAll('.', '');

    final mass = _massGrams[u];
    if (mass != null) return quantity * mass;

    final ml = _volumeMl[u];
    if (ml != null) {
      final density = food.densityGPerMl;
      return density == null ? null : quantity * ml * density;
    }

    switch (u) {
      case 'clove':
      case 'cloves':
        final g = food.cloveGrams ?? food.pieceGrams;
        return g == null ? null : quantity * g;
      case 'slice':
      case 'slices':
        final g = food.sliceGrams ?? food.pieceGrams;
        return g == null ? null : quantity * g;
      case 'can':
      case 'cans':
      case 'tin':
      case 'tins':
      case 'jar':
      case 'jars':
        return quantity * (food.canGrams ?? 400);
      case 'bunch':
      case 'bunches':
        final g = food.bunchGrams ?? 100;
        return quantity * g;
      case 'handful':
      case 'handfuls':
        return quantity * 30;
      case 'sprig':
      case 'sprigs':
        return quantity * 1;
      case 'leaf':
      case 'leaves':
        return quantity * 0.5;
      case 'stick':
      case 'sticks':
        return quantity * (food.pieceGrams ?? 113);
    }

    if (_countUnits.contains(u)) {
      final g = food.pieceGrams;
      return g == null ? null : quantity * g;
    }
    return null;
  }
}

/// Estimates nutrition for recipes from the offline reference catalog.
class RecipeNutritionAnalyzer {
  final FoodMatcher matcher;

  RecipeNutritionAnalyzer({FoodMatcher? matcher}) : matcher = matcher ?? FoodMatcher.standard;

  /// Stable identity for one ingredient line (name + quantity + unit). Stored
  /// estimates are keyed by fingerprint so they silently stop applying when the
  /// user edits that line, instead of reporting stale numbers.
  static String fingerprint(RecipeIngredient ingredient) {
    final name = FoodMatcher.normalizeWords(ingredient.displayName).join(' ');
    final qty = ingredient.quantity?.toDouble();
    final qtyKey = qty == null ? '-' : qty.toStringAsFixed(3);
    final unit = (ingredient.unitCode ?? '').trim().toLowerCase();
    return '$name|$qtyKey|$unit';
  }

  RecipeNutritionReport analyze(Recipe recipe) {
    final lines = <IngredientNutritionLine>[];
    final traits = <FoodTrait>{};
    var allIdentified = true;

    for (final ing in recipe.ingredients) {
      if (ing.displayName.trim().isEmpty) continue;
      final line = analyzeIngredient(ing, overrides: recipe.nutritionOverrides);
      lines.add(line);
      if (line.food != null) {
        traits.addAll(line.food!.traits);
      } else {
        // Even with a stored calorie estimate we cannot vouch for diet traits.
        allIdentified = false;
      }
    }

    final servings = recipe.baseServings.toDouble();
    return RecipeNutritionReport(
      lines: List.unmodifiable(lines),
      total: NutritionFacts.sum(lines.map((l) => l.facts)),
      servings: servings.isFinite && servings >= 0.25 ? servings : 1,
      diet: DietProfile(traits: traits, isComplete: allIdentified),
    );
  }

  IngredientNutritionLine analyzeIngredient(
    RecipeIngredient ing, {
    Map<String, NutritionFacts> overrides = const {},
  }) {
    final food = matcher.match(ing.displayName);
    final override = overrides[fingerprint(ing)];
    if (override != null) {
      return IngredientNutritionLine(
        ingredient: ing,
        food: food,
        grams: null,
        facts: override,
        status: NutritionLineStatus.override,
      );
    }
    if (food == null) {
      return IngredientNutritionLine(
        ingredient: ing,
        food: null,
        grams: null,
        facts: NutritionFacts.zero,
        status: NutritionLineStatus.unmatched,
      );
    }

    final grams = KitchenUnits.toGrams(ing.quantity?.toDouble(), ing.unitCode, food);
    final facts = grams == null ? NutritionFacts.zero : food.per100g.scale(grams / 100);
    final NutritionLineStatus status;
    if (food.isTrace) {
      status = NutritionLineStatus.trace;
    } else if (grams == null) {
      status = NutritionLineStatus.unquantified;
    } else {
      status = NutritionLineStatus.matched;
    }
    return IngredientNutritionLine(ingredient: ing, food: food, grams: grams, facts: facts, status: status);
  }
}
