import 'package:recipe_domain/recipe_domain.dart';
import '../result.dart';
import '../failures.dart';

abstract interface class CollectionRepository {
  Stream<List<RecipeCollection>> watchCollections();
  Future<Result<List<RecipeCollection>, AppFailure>> getCollections();
  Future<Result<RecipeCollection, AppFailure>> createCollection({
    required String profileId,
    required String name,
    required String colorToken,
    String? description,
  });
  Future<Result<RecipeCollection, AppFailure>> updateCollection(RecipeCollection collection);
  Future<Result<void, AppFailure>> deleteCollection(String id);
  Future<Result<void, AppFailure>> addRecipeToCollection(String collectionId, String recipeId);
  Future<Result<void, AppFailure>> removeRecipeFromCollection(String collectionId, String recipeId);
}
