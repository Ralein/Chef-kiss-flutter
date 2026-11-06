import 'package:recipe_domain/recipe_domain.dart';

/// A cookbook on the shelf: a collection of recipes standing as one book,
/// like a "French" cookbook holding every French recipe.
///
/// It passes through the shelf's layout, arranging and painting as a
/// stand-in [Recipe] whose id is the collection's id behind a prefix; the
/// library opens it as a journal of its own recipes.
abstract final class Cookbook {
  static const _prefix = 'cookbook:';

  static bool isCookbook(Recipe r) => r.id.startsWith(_prefix);

  /// The collection a stand-in was made from.
  static String collectionIdOf(Recipe r) => r.id.substring(_prefix.length);

  static String volumeId(String collectionId) => '$_prefix$collectionId';

  /// Cloths a cookbook is bound in, picked by its id so each keeps its own.
  static const _cloths = ['#7A2E2A', '#A04E3B', '#B8862D', '#2F4A3A', '#2F5E61', '#273A5C', '#5B3A6B', '#8C6B47'];

  /// [collection] as a book holding [recipes] recipes: tall, thick and ribbed.
  static Recipe volume(RecipeCollection collection, {required int recipes}) => Recipe(
    id: volumeId(collection.id),
    profileId: collection.profileId,
    title: collection.name,
    summary: recipes == 1 ? '1 recipe' : '$recipes recipes',
    status: RecipeStatus.ready,
    baseServings: Rational(1),
    createdAt: collection.createdAt,
    updatedAt: collection.updatedAt,
    bookStyle: BookStyle(
      spineColor: _cloths[collection.id.hashCode.abs() % _cloths.length],
      height: SpineScale.large,
      width: SpineScale.large,
      pattern: SpinePattern.ribs,
      display: BookDisplay.spine,
    ),
  );
}
