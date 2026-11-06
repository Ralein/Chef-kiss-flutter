import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../domain/shelf_style.dart';
import 'library_books.dart';

/// Sizes on a bookcase of a given width.
@immutable
class ShelfMetrics {
  /// Usable width of a shelf, between its ends.
  final double inner;

  /// 1 on phones; things grow a little on wide screens.
  final double scale;

  const ShelfMetrics({required this.inner, required this.scale});

  factory ShelfMetrics.forWidth(double width) =>
      ShelfMetrics(inner: math.max(0, width - 2 * inset), scale: width < 600 ? 1.0 : 1.18);

  /// From the screen edge to the end of a shelf.
  static const inset = 14.0;

  /// Even a small library fills a few shelves, so the wall reads as a
  /// bookcase rather than one crowded plank.
  static const minShelves = 3;

  /// Books stand at most this tall.
  double get shelfHeight => 168 * scale;

  /// Space between one plank and the next: the tallest book plus headroom.
  double get room => 22 * scale + shelfHeight;
  double get plank => 14 * scale;

  /// A whole shelf: the space above the plank, the plank and its shadow.
  double get rowHeight => room + plank + 3;

  /// A decoration's size on screen; never taller than a shelf has room for.
  Size sizeOf(PlacedDecor d) {
    final natural = d.piece.size * (scale * d.size);
    return natural * math.min(1.0, (room - 4) / natural.height);
  }

  /// From the left end of the shelf to the decoration's left edge.
  double leftOf(PlacedDecor d) => d.x * math.max(0.0, inner - sizeOf(d).width);

  /// The [PlacedDecor.x] that puts something [width] wide at [left].
  double xFor(double left, double width) => inner <= width ? 0 : (left / (inner - width)).clamp(0.0, 1.0);
}

/// A book's place on its shelf, measured from the shelf's left end.
@immutable
class BookSpot {
  final Recipe recipe;
  final bool faceOut;
  final double left;
  final double width;
  final double height;
  const BookSpot(this.recipe, {required this.faceOut, required this.left, required this.width, required this.height});
}

/// A decoration's place on its shelf, measured from the shelf's left end.
@immutable
class DecorSpot {
  final PlacedDecor decor;
  final double left;
  final Size size;
  const DecorSpot(this.decor, {required this.left, required this.size});

  bool get hangs => decor.piece.hangs;
  double get right => left + size.width;
}

/// What stands on one shelf, and what hangs into it from the shelf above.
@immutable
class ShelfRowPlan {
  final int index;
  final List<BookSpot> books;
  final List<DecorSpot> decor;
  const ShelfRowPlan(this.index, {required this.books, required this.decor});
}

/// Spines stand close; a face-out cover gets a little air.
const _bookGap = 3.0;
const _coverGap = 8.0;

/// Books keep this clear of decorations, standing or hanging.
const _clearance = 8.0;

/// Fills the shelves with [recipes] in order, flowing around [decor]: books
/// take the gaps left to right, never standing under or behind a decoration.
/// A small library spreads over [ShelfMetrics.minShelves] shelves rather
/// than crowding the first, and there are always enough shelves for every
/// decoration.
List<ShelfRowPlan> layoutShelves(List<Recipe> recipes, List<PlacedDecor> decor, ShelfMetrics m) {
  final rows = <ShelfRowPlan>[];
  final lastDecorated = decor.fold(-1, (last, d) => math.max(last, d.shelf));
  var next = 0;
  for (var r = 0; next < recipes.length || r < ShelfMetrics.minShelves || r <= lastDecorated; r++) {
    final spots = [
      for (final d in decor)
        if (d.shelf == r) DecorSpot(d, left: m.leftOf(d), size: m.sizeOf(d)),
    ];
    final free = _gaps([for (final s in spots) (s.left - _clearance, s.right + _clearance)], m.inner);

    final remaining = recipes.length - next;
    final cap = r < ShelfMetrics.minShelves ? (remaining / (ShelfMetrics.minShelves - r)).ceil() : remaining;
    final books = <BookSpot>[];
    var faceOutUsed = false;
    for (final (start, end) in free) {
      var x = start;
      BookSpot? previous;
      while (next < recipes.length && books.length < cap) {
        final recipe = recipes[next];
        final display = recipe.bookStyle.display;
        // Automatic covers: one favorite with art, on every other shelf.
        final faceOut =
            display == BookDisplay.cover ||
            (display == BookDisplay.auto &&
                r.isEven &&
                !faceOutUsed &&
                recipe.isFavorite &&
                (recipe.coverImage?.isNotEmpty ?? false));
        final width = faceOut ? BookMetrics.coverWidth(m.shelfHeight) : BookMetrics.spineWidth(recipe, m.scale);
        final gap = previous == null ? 0.0 : (previous.faceOut || faceOut ? _coverGap : _bookGap);
        // A shelf with nothing on it takes the next book even if it's too
        // wide, so there is always a shelf for every book.
        final bare = spots.isEmpty && books.isEmpty;
        if (x + gap + width > end && !bare) break;
        final spot = BookSpot(
          recipe,
          faceOut: faceOut,
          left: x + gap,
          width: width,
          height: faceOut ? BookMetrics.coverHeight(m.shelfHeight) : BookMetrics.spineHeight(recipe, m.shelfHeight),
        );
        books.add(spot);
        previous = spot;
        x = spot.left + width;
        next++;
        if (faceOut && display == BookDisplay.auto) faceOutUsed = true;
      }
      if (next >= recipes.length || books.length >= cap) break;
    }
    rows.add(ShelfRowPlan(r, books: books, decor: spots));
  }
  return rows;
}

/// The stretches of [0, length] not covered by [taken].
List<(double, double)> _gaps(List<(double, double)> taken, double length) {
  taken.sort((a, b) => a.$1.compareTo(b.$1));
  final gaps = <(double, double)>[];
  var from = 0.0;
  for (final (a, b) in taken) {
    if (a > from) gaps.add((from, math.min(a, length)));
    from = math.max(from, b);
  }
  if (from < length) gaps.add((from, length));
  return gaps;
}

/// Where a decoration [width] wide fits on [shelf] without covering another:
/// the gap nearest [near] (an x position) or else the widest, with its x.
/// Null when the shelf is full.
double? freeSpotOn(int shelf, double width, List<PlacedDecor> decor, ShelfMetrics m, {double? near}) {
  final taken = [
    for (final d in decor)
      if (d.shelf == shelf) (m.leftOf(d) - 6, m.leftOf(d) + m.sizeOf(d).width + 6),
  ];
  final fits = _gaps(taken, m.inner).where((g) => g.$2 - g.$1 >= width).toList();
  if (fits.isEmpty) return null;
  if (near == null) {
    final widest = fits.reduce((a, b) => a.$2 - a.$1 >= b.$2 - b.$1 ? a : b);
    return m.xFor((widest.$1 + widest.$2 - width) / 2, width);
  }
  // As close to [near] as the gaps allow.
  final want = near * math.max(0.0, m.inner - width);
  var best = 0.0, bestDistance = double.infinity;
  for (final (a, b) in fits) {
    final left = want.clamp(a, b - width);
    final distance = (left - want).abs();
    if (distance < bestDistance) (best, bestDistance) = (left, distance);
  }
  return m.xFor(best, width);
}
