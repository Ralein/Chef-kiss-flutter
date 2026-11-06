import 'package:app_contracts/app_contracts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/providers.dart';

/// The book every recipe is in until it's moved to a book of its own.
const myRecipesId = 'my-recipes';

/// How a book on the shelf looks: its cover photo, its spine, whether it
/// stands spine-out or cover-out, the colours picked from its photo — and,
/// for My Recipes, its title (other books are named by their collection).
@immutable
class BookCover {
  final String? title;
  final String? photo;
  final BookStyle style;

  /// Colours picked from the photo (hex, cloth first), for Shuffle.
  final List<String> palette;

  const BookCover({this.title, this.photo, this.style = defaultStyle, this.palette = const []});

  /// Tall, thick, ribbed, spine-out.
  static const defaultStyle = BookStyle(
    height: SpineScale.large,
    width: SpineScale.large,
    pattern: SpinePattern.ribs,
    display: BookDisplay.spine,
  );

  bool get facesOut => style.display == BookDisplay.cover;

  BookCover copyWith({
    String? title,
    String? photo,
    bool clearPhoto = false,
    BookStyle? style,
    List<String>? palette,
  }) => BookCover(
    title: title ?? this.title,
    photo: clearPhoto ? null : (photo ?? this.photo),
    style: style ?? this.style,
    palette: palette ?? this.palette,
  );

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (photo != null) 'photo': photo,
    'style': style.toJson(),
    if (palette.isNotEmpty) 'palette': palette,
  };

  factory BookCover.fromJson(Object? json) {
    if (json is! Map) return const BookCover();
    final palette = json['palette'];
    return BookCover(
      title: json['title'] is String ? json['title'] as String : null,
      photo: json['photo'] is String ? json['photo'] as String : null,
      style: json['style'] is Map ? BookStyle.fromJson(json['style']) : defaultStyle,
      palette: [if (palette is List) ...palette.whereType<String>()],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BookCover &&
      other.title == title &&
      other.photo == photo &&
      other.style == style &&
      listEquals(other.palette, palette);

  @override
  int get hashCode => Object.hash(title, photo, style, Object.hashAll(palette));
}

const bookCoversKey = 'library.books';

Map<String, BookCover> _covers(Object? json) => {
  if (json is Map)
    for (final MapEntry(:key, :value) in json.entries)
      if (key is String) key: BookCover.fromJson(value),
};

/// Every book's look, by book id: a collection's id, or [myRecipesId].
final bookCoversProvider = StreamProvider<Map<String, BookCover>>((ref) {
  return ref.watch(preferencesRepositoryProvider).watchJson(bookCoversKey).map(_covers);
});

/// Saves one book's look, keeping the others.
Future<Result<void, AppFailure>> saveBookCover(PreferencesRepository prefs, String bookId, BookCover cover) async {
  final all = _covers(await prefs.readJson(bookCoversKey))..[bookId] = cover;
  return prefs.writeJson(bookCoversKey, {for (final e in all.entries) e.key: e.value.toJson()});
}

/// Forgets a deleted book's look.
Future<Result<void, AppFailure>> forgetBookCover(PreferencesRepository prefs, String bookId) async {
  final all = _covers(await prefs.readJson(bookCoversKey))..remove(bookId);
  return prefs.writeJson(bookCoversKey, {for (final e in all.entries) e.key: e.value.toJson()});
}

/// The book [recipeId] is in: the cookbook holding it, else My Recipes.
String bookOf(List<RecipeCollection> books, String recipeId) =>
    books.where((b) => b.recipeIds.contains(recipeId)).firstOrNull?.id ?? myRecipesId;

/// A book's name: a cookbook's own, or My Recipes' as renamed.
String bookName(String bookId, List<RecipeCollection> books, Map<String, BookCover> covers) => bookId == myRecipesId
    ? (covers[myRecipesId]?.title ?? 'My Recipes')
    : (books.where((b) => b.id == bookId).firstOrNull?.name ?? 'Book');

/// My Recipes' pages: the recipes in no cookbook.
List<Recipe> unfiledRecipes(List<Recipe> all, List<RecipeCollection> books) {
  final filed = {for (final b in books) ...b.recipeIds};
  return [
    for (final r in all)
      if (!filed.contains(r.id)) r,
  ];
}

/// Moves [recipeId] into the book [bookId] — a cookbook's id, or
/// [myRecipesId] to take it out of every cookbook. A recipe is in one book
/// at a time.
Future<void> moveRecipeToBook(
  CollectionRepository repo,
  List<RecipeCollection> books,
  String recipeId,
  String bookId,
) async {
  for (final b in books) {
    if (b.id != bookId && b.recipeIds.contains(recipeId)) await repo.removeRecipeFromCollection(b.id, recipeId);
  }
  final target = books.where((b) => b.id == bookId).firstOrNull;
  if (bookId != myRecipesId && !(target?.recipeIds.contains(recipeId) ?? false)) {
    await repo.addRecipeToCollection(bookId, recipeId);
  }
}
