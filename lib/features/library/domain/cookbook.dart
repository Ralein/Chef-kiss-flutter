import 'package:recipe_domain/recipe_domain.dart';

import 'book_covers.dart';

/// A book on the shelf: My Recipes, or a cookbook like "French", holding
/// many recipes.
///
/// It passes through the shelf's layout, arranging and painting as a
/// stand-in [Recipe] whose id is the book's id behind a prefix; the library
/// opens it as a journal of its own recipes.
abstract final class Cookbook {
  static const _prefix = 'cookbook:';

  static bool isCookbook(Recipe r) => r.id.startsWith(_prefix);

  /// The book a stand-in stands for: a collection id, or [myRecipesId].
  static String collectionIdOf(Recipe r) => r.id.substring(_prefix.length);

  static String volumeId(String bookId) => '$_prefix$bookId';

  /// Cloths a book is bound in until it's given its own, picked by its id so
  /// each keeps one.
  static const _cloths = ['#7A2E2A', '#A04E3B', '#B8862D', '#2F4A3A', '#2F5E61', '#273A5C', '#5B3A6B', '#8C6B47'];

  /// [collection] as a book holding [recipes] recipes, as [cover] dresses it.
  static Recipe volume(RecipeCollection collection, {required int recipes, BookCover? cover}) => _volume(
    collection.id,
    collection.name,
    recipes: recipes,
    cover: cover,
    profileId: collection.profileId,
    createdAt: collection.createdAt,
    updatedAt: collection.updatedAt,
  );

  /// My Recipes: every recipe not moved to a book of its own.
  static Recipe myRecipes({required int recipes, BookCover? cover}) =>
      _volume(myRecipesId, cover?.title ?? 'My Recipes', recipes: recipes, cover: cover);

  static Recipe _volume(
    String id,
    String title, {
    required int recipes,
    BookCover? cover,
    String profileId = 'default',
    int createdAt = 0,
    int updatedAt = 0,
  }) {
    final style = cover?.style ?? BookCover.defaultStyle;
    return Recipe(
      id: volumeId(id),
      profileId: profileId,
      title: title,
      summary: recipes == 1 ? '1 recipe' : '$recipes recipes',
      status: RecipeStatus.ready,
      baseServings: Rational(1),
      coverImage: cover?.photo,
      createdAt: createdAt,
      updatedAt: updatedAt,
      bookStyle: style.spineColor != null ? style : style.copyWith(spineColor: _cloths[id.hashCode.abs() % _cloths.length]),
    );
  }
}
