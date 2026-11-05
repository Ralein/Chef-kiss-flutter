import 'package:recipe_domain/recipe_domain.dart';

/// Memoized nutrition analysis for list/grid rendering.
///
/// Keyed by recipe id + updatedAt + version, so any saved edit produces a
/// fresh analysis while favorites toggles (which don't touch the recipe row)
/// reuse the cached one.
class RecipeInsights {
  RecipeInsights._();

  static final _analyzer = RecipeNutritionAnalyzer();
  static final _cache = <String, RecipeNutritionReport>{};
  static const _maxEntries = 400;

  static RecipeNutritionReport of(Recipe recipe) {
    final key = '${recipe.id}:${recipe.updatedAt}:${recipe.version}:${recipe.nutritionOverrides.length}';
    final cached = _cache[key];
    if (cached != null) return cached;
    if (_cache.length >= _maxEntries) _cache.clear();
    return _cache[key] = _analyzer.analyze(recipe);
  }

  /// Calories per serving when the estimate is trustworthy enough to show on
  /// a card (most ingredients resolved), else null.
  static double? kcalPerServing(Recipe recipe) {
    final report = of(recipe);
    if (report.coverage < 0.7 || report.total.calories <= 0) return null;
    return report.perServing.calories;
  }
}
