import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../domain/shelf_style.dart';
import 'kitchen_art.dart';
import 'library_books.dart';
import 'shelf_art.dart';

/// Something standing on a shelf.
sealed class _ShelfItem {
  const _ShelfItem(this.width);
  final double width;
}

class _BookItem extends _ShelfItem {
  final Recipe recipe;
  final bool faceOut;
  final double height;
  const _BookItem(this.recipe, {required this.faceOut, required double width, required this.height}) : super(width);
}

enum _DecorKind { plant, flowers, candle, candlePair, crock, jars, pot, board }

class _DecorItem extends _ShelfItem {
  final _DecorKind kind;
  final double height;
  final int seed;
  const _DecorItem(this.kind, double width, this.height, this.seed) : super(width);
}

/// What hangs from the shelf above a row.
enum _Hanging { none, ivy, rail }

/// One shelf: decor then books from the left end, an optional piece in the
/// middle when there's room, and decor at the right end.
class _Row {
  final List<_ShelfItem> start;
  final _DecorItem? middle;
  final List<_ShelfItem> end;
  final _Hanging hanging;
  const _Row({required this.start, this.middle, required this.end, this.hanging = _Hanging.none});
}

/// Space between neighbours: spines stand close, covers and decor get air.
double _spacing(_ShelfItem a, _ShelfItem b) {
  if (a is _BookItem && b is _BookItem) return a.faceOut || b.faceOut ? 8 : LibraryBookcase._bookGap;
  return 10;
}

double _span(List<_ShelfItem> items) {
  var total = 0.0;
  for (var i = 0; i < items.length; i++) {
    total += items[i].width;
    if (i > 0) total += _spacing(items[i - 1], items[i]);
  }
  return total;
}

/// The library as floating kitchen shelves on a wall: books spine-out (and a
/// few face-out) between crocks of utensils, pantry jars, pots, candles,
/// plants and flowers; LED strips glowing under each shelf; ivy or a utensil
/// rail hanging into the gaps below.
///
/// The wall itself is painted by the screen behind the scroll view.
class LibraryBookcase extends StatelessWidget {
  final List<Recipe> recipes;
  final ShelfStyle style;
  final ValueChanged<Recipe> onOpen;
  final ValueChanged<Recipe>? onLongPress;

  const LibraryBookcase({
    super.key,
    required this.recipes,
    required this.style,
    required this.onOpen,
    this.onLongPress,
  });

  static const _bookGap = 3.0;
  static const _inset = 14.0;

  /// Even a small library fills a few shelves, so the wall reads as a
  /// bookcase rather than one crowded plank.
  static const minShelves = 3;

  /// What each shelf wants at its ends and, room permitting, in the middle;
  /// the first enabled wish wins. Rotates so neighbouring shelves differ.
  static const _plan = <({List<_DecorKind> left, List<_DecorKind> middle, List<_DecorKind> right})>[
    (
      left: [_DecorKind.crock, _DecorKind.plant],
      middle: [_DecorKind.jars, _DecorKind.flowers],
      right: [_DecorKind.plant, _DecorKind.pot, _DecorKind.flowers],
    ),
    (
      left: [_DecorKind.jars],
      middle: [_DecorKind.pot, _DecorKind.plant],
      right: [_DecorKind.flowers, _DecorKind.crock, _DecorKind.plant],
    ),
    (
      left: [_DecorKind.board],
      middle: [_DecorKind.crock, _DecorKind.flowers],
      right: [_DecorKind.pot, _DecorKind.plant, _DecorKind.jars],
    ),
    (
      left: [],
      middle: [_DecorKind.flowers, _DecorKind.jars],
      right: [_DecorKind.jars, _DecorKind.plant, _DecorKind.crock],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final scale = width < 600 ? 1.0 : 1.18;
        final shelfHeight = 168 * scale;
        final rows = _layout(width - 2 * _inset, shelfHeight, scale);
        return SliverList.builder(
          itemCount: rows.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              // The top shelf edge: lights the first row and holds what hangs into it.
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ShelfPlank(wood: style.wood, glow: style.glow, height: 10 * scale),
              );
            }
            final r = i - 1;
            return _ShelfRow(
              row: rows[r],
              index: r,
              style: style,
              scale: scale,
              shelfHeight: shelfHeight,
              onOpen: onOpen,
              onLongPress: onLongPress,
            );
          },
        );
      },
    );
  }

  bool _enabled(_DecorKind k) => switch (k) {
    _DecorKind.plant => style.greenery.hasPots,
    _DecorKind.flowers => style.flowers != FlowerKind.none,
    _DecorKind.crock => style.kitchen.hasUtensils,
    _DecorKind.jars => style.kitchen.hasPantry,
    _DecorKind.pot || _DecorKind.board => style.kitchen.hasCookware,
    _DecorKind.candle || _DecorKind.candlePair => style.candles != CandleAmount.none,
  };

  static _DecorItem _decor(_DecorKind k, double s, int seed) => switch (k) {
    _DecorKind.plant => _DecorItem(k, 64 * s, 92 * s, seed),
    _DecorKind.flowers => _DecorItem(k, 58 * s, 96 * s, seed),
    _DecorKind.candle => _DecorItem(k, 26 * s, 62 * s, seed),
    _DecorKind.candlePair => _DecorItem(k, 44 * s, 74 * s, seed),
    _DecorKind.crock => _DecorItem(k, 54 * s, 116 * s, seed),
    _DecorKind.jars => _DecorItem(k, 80 * s, 86 * s, seed),
    _DecorKind.pot => _DecorItem(k, 92 * s, 62 * s, seed),
    _DecorKind.board => _DecorItem(k, 48 * s, 132 * s, seed),
  };

  List<_Row> _layout(double available, double shelfHeight, double scale) {
    final rows = <_Row>[];
    var next = 0;
    for (var r = 0; next < recipes.length || r < minShelves; r++) {
      final plan = _plan[r % _plan.length];
      final used = <_DecorKind>{};
      _DecorItem? pick(List<_DecorKind> wishes, int seed) {
        for (final k in wishes) {
          if (!used.contains(k) && _enabled(k)) {
            used.add(k);
            return _decor(k, scale, seed);
          }
        }
        return null;
      }

      final left = <_ShelfItem>[?pick(plan.left, r)];
      final right = <_ShelfItem>[?pick(plan.right, r + 3)];
      switch (style.candles) {
        case CandleAmount.none:
          break;
        case CandleAmount.few:
          if (r.isOdd) left.add(_decor(_DecorKind.candle, scale, r));
        case CandleAmount.many:
          left.add(_decor(_DecorKind.candlePair, scale, r));
          if (r.isEven) right.add(_decor(_DecorKind.candle, scale, r + 7));
      }

      // Spread what's left evenly over the shelves still to fill.
      final cap = ((recipes.length - next) / math.max(1, minShelves - r)).ceil();
      var room = available - _span(left) - _span(right) - (left.isEmpty ? 0 : 10) - (right.isEmpty ? 0 : 10);
      final books = <_BookItem>[];
      var faceOutUsed = false;
      while (next < recipes.length && books.length < cap) {
        final recipe = recipes[next];
        final display = recipe.bookStyle.display;
        // Automatic covers: one favorite with art, on every other shelf.
        final wantsCover =
            display == BookDisplay.cover ||
            (display == BookDisplay.auto &&
                r.isEven &&
                !faceOutUsed &&
                recipe.isFavorite &&
                (recipe.coverImage?.isNotEmpty ?? false));
        final item = wantsCover
            ? _BookItem(
                recipe,
                faceOut: true,
                width: BookMetrics.coverWidth(shelfHeight),
                height: BookMetrics.coverHeight(shelfHeight),
              )
            : _BookItem(
                recipe,
                faceOut: false,
                width: BookMetrics.spineWidth(recipe, scale),
                height: BookMetrics.spineHeight(recipe, shelfHeight),
              );
        final need = item.width + (books.isEmpty ? 0 : _spacing(books.last, item));
        if (need > room && books.isNotEmpty) break;
        books.add(item);
        room -= need;
        if (item.faceOut && display == BookDisplay.auto) faceOutUsed = true;
        next++;
      }

      final wish = pick(plan.middle, r + 11);
      final middle = wish != null && room >= wish.width + 72 * scale ? wish : null;
      rows.add(
        _Row(
          start: [...left, ...books],
          middle: middle,
          end: right,
          hanging: style.greenery.hasIvy && r.isEven
              ? _Hanging.ivy
              : (style.kitchen.hasUtensils && r.isOdd ? _Hanging.rail : _Hanging.none),
        ),
      );
    }
    return rows;
  }
}

class _ShelfRow extends StatelessWidget {
  final _Row row;
  final int index;
  final ShelfStyle style;
  final double scale;
  final double shelfHeight;
  final ValueChanged<Recipe> onOpen;
  final ValueChanged<Recipe>? onLongPress;

  const _ShelfRow({
    required this.row,
    required this.index,
    required this.style,
    required this.scale,
    required this.shelfHeight,
    required this.onOpen,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final plank = 14 * scale;
    final above = 22 * scale + shelfHeight;
    const inset = LibraryBookcase._inset;
    return LayoutBuilder(
      builder: (context, box) {
        final hang = _hangingRect(box.maxWidth - 2 * inset, above);
        return SizedBox(
          height: above + plank + 3,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 8,
                right: 8,
                child: LightWash(glow: style.glow, height: 110 * scale),
              ),
              Positioned(
                left: inset,
                right: inset,
                bottom: plank + 3,
                height: shelfHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ..._sequence(row.start),
                    const Spacer(),
                    if (row.middle case final middle?) ...[_build(middle), const Spacer()],
                    ..._sequence(row.end),
                  ],
                ),
              ),
              if (hang != null)
                Positioned.fromRect(
                  rect: hang,
                  child: row.hanging == _Hanging.ivy ? TrailingIvy(seed: index) : HangingUtensils(seed: index),
                ),
              Positioned(
                left: 4,
                right: 4,
                bottom: 0,
                child: ShelfPlank(wood: style.wood, glow: style.glow, height: plank),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Where the ivy or utensil rail hangs: centred over the widest empty
  /// stretch of shelf, else above short decor at the right end. Never over
  /// a book, so titles stay readable.
  Rect? _hangingRect(double inner, double above) {
    if (row.hanging == _Hanging.none) return null;
    final ivy = row.hanging == _Hanging.ivy;
    final w = (ivy ? 104 : 128) * scale;
    final h = (ivy ? 96 : 100) * scale;
    const inset = LibraryBookcase._inset;
    final startEnd = inset + _span(row.start);
    final endStart = inset + inner - _span(row.end);
    final from = startEnd + (row.start.isEmpty ? 0 : 10);
    final to = endStart - (row.end.isEmpty ? 0 : 10);
    final gaps = <(double, double)>[];
    if (row.middle case final m?) {
      final mid = (startEnd + endStart) / 2;
      gaps
        ..add((from, mid - m.width / 2 - 10))
        ..add((mid + m.width / 2 + 10, to));
    } else {
      gaps.add((from, to));
    }
    final widest = gaps.reduce((a, b) => a.$2 - a.$1 >= b.$2 - b.$1 ? a : b);
    final room = widest.$2 - widest.$1;
    if (room >= w * 0.8) {
      final width = math.min(w, room);
      return Rect.fromLTWH((widest.$1 + widest.$2 - width) / 2, 0, width, h);
    }
    final decor = row.end.whereType<_DecorItem>();
    if (decor.isEmpty) return null;
    final clear = above - decor.map((d) => d.height).reduce(math.max) - 6;
    if (clear < 56 * scale) return null;
    final width = math.min(w, _span(row.end) + 20);
    return Rect.fromLTWH(inset + inner - width, 0, width, math.min(h, clear));
  }

  List<Widget> _sequence(List<_ShelfItem> items) => [
    for (final (i, item) in items.indexed) ...[
      if (i > 0) SizedBox(width: _spacing(items[i - 1], item)),
      _build(item),
    ],
  ];

  Widget _build(_ShelfItem item) {
    switch (item) {
      case _BookItem():
        return ShelfBook(
          key: ValueKey(item.recipe.id),
          recipe: item.recipe,
          faceOut: item.faceOut,
          width: item.width,
          height: item.height,
          scale: scale,
          onTap: () => onOpen(item.recipe),
          onLongPress: onLongPress == null ? null : () => onLongPress!(item.recipe),
        );
      case _DecorItem(kind: _DecorKind.plant):
        return SizedBox(width: item.width, height: item.height, child: PottedPlant(seed: item.seed));
      case _DecorItem(kind: _DecorKind.flowers):
        return SizedBox(
          width: item.width,
          height: item.height,
          child: FlowerVase(kind: style.flowers, seed: item.seed),
        );
      case _DecorItem(kind: _DecorKind.crock):
        return SizedBox(width: item.width, height: item.height, child: UtensilCrock(seed: item.seed));
      case _DecorItem(kind: _DecorKind.jars):
        return SizedBox(width: item.width, height: item.height, child: PantryJars(seed: item.seed));
      case _DecorItem(kind: _DecorKind.pot):
        return SizedBox(width: item.width, height: item.height, child: DutchOven(seed: item.seed));
      case _DecorItem(kind: _DecorKind.board):
        return SizedBox(width: item.width, height: item.height, child: CuttingBoard(seed: item.seed));
      case _DecorItem(kind: _DecorKind.candle):
        final kind = item.seed.isEven ? CandleKind.pillar : CandleKind.tall;
        return SizedBox(
          width: item.width,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox.fromSize(
              size: Candle.sizeOf(kind, scale),
              child: Candle(kind: kind, seed: item.seed),
            ),
          ),
        );
      case _DecorItem(kind: _DecorKind.candlePair):
        return SizedBox(
          width: item.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox.fromSize(
                size: Candle.sizeOf(CandleKind.taper, scale),
                child: Candle(kind: CandleKind.taper, seed: item.seed * 3 + 1),
              ),
              SizedBox.fromSize(
                size: Candle.sizeOf(CandleKind.pillar, scale),
                child: Candle(kind: CandleKind.pillar, seed: item.seed * 3 + 2),
              ),
            ],
          ),
        );
    }
  }
}
