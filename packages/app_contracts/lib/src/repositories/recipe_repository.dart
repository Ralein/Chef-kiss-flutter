import 'package:recipe_domain/recipe_domain.dart';
import '../result.dart';
import '../failures.dart';

class RecipeFilter {
  final String? query;
  final bool onlyFavorites;
  final String? collectionId;
  final String? cuisine;
  final String? dietary;
  final RecipeDifficulty? difficulty;
  final int? maxTotalMinutes;
  final bool includeArchived;

  const RecipeFilter({
    this.query,
    this.onlyFavorites = false,
    this.collectionId,
    this.cuisine,
    this.dietary,
    this.difficulty,
    this.maxTotalMinutes,
    this.includeArchived = false,
  });

  RecipeFilter copyWith({
    String? query,
    bool? onlyFavorites,
    String? collectionId,
    String? cuisine,
    String? dietary,
    RecipeDifficulty? difficulty,
    int? maxTotalMinutes,
    bool? includeArchived,
  }) {
    return RecipeFilter(
      query: query ?? this.query,
      onlyFavorites: onlyFavorites ?? this.onlyFavorites,
      collectionId: collectionId ?? this.collectionId,
      cuisine: cuisine ?? this.cuisine,
      dietary: dietary ?? this.dietary,
      difficulty: difficulty ?? this.difficulty,
      maxTotalMinutes: maxTotalMinutes ?? this.maxTotalMinutes,
      includeArchived: includeArchived ?? this.includeArchived,
    );
  }
}

abstract interface class RecipeRepository {
  /// Reactive stream of recipes matching the filter
  Stream<List<Recipe>> watchRecipes({RecipeFilter filter = const RecipeFilter()});

  /// Synchronous/Future retrieval of recipes matching the filter
  Future<Result<List<Recipe>, AppFailure>> getRecipes({RecipeFilter filter = const RecipeFilter()});

  /// Get single recipe by ID with all relations
  Future<Result<Recipe, AppFailure>> getRecipeById(String id);

  /// Watch single recipe by ID
  Stream<Recipe?> watchRecipeById(String id);

  /// Save or update a recipe draft/ready version atomically
  Future<Result<Recipe, AppFailure>> saveRecipe(Recipe recipe);

  /// Soft-delete recipe (moves to trash)
  Future<Result<void, AppFailure>> deleteRecipe(String id);

  /// Restore soft-deleted recipe
  Future<Result<void, AppFailure>> restoreRecipe(String id);

  /// Permanently delete recipe and cascade all relations
  Future<Result<void, AppFailure>> purgeRecipe(String id);

  /// Toggle favorite status
  Future<Result<bool, AppFailure>> toggleFavorite(String id);

  /// Stream soft-deleted recipes
  Stream<List<Recipe>> watchDeletedRecipes();

  /// Search recipes by query text across title, summary, and ingredients
  Future<Result<List<Recipe>, AppFailure>> searchRecipes(String query);

  /// Idempotently seeds initial curated recipes
  Future<Result<int, AppFailure>> seedStarterRecipes(List<Recipe> recipes);
}
