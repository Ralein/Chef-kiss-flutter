import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../domain/shelf_style.dart';
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

enum _DecorKind { plant, flowers, candlePair, candle }

class _DecorItem extends _ShelfItem {
  final _DecorKind kind;
  final int seed;
  const _DecorItem(this.kind, double width, this.seed) : super(width);
}

class _Row {
  final List<_ShelfItem> items;
  const _Row(this.items);
}

/// The library as floating wooden shelves on a wall: books spine-out (and a
/// few face-out), candles, plants and flowers between them, LED strips
/// glowing under each shelf and ivy trailing over the books below.
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

  static const _gap = 3.0;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final scale = width < 600 ? 1.0 : 1.18;
        final shelfHeight = 168 * scale;
        final rows = _layout(width - 28, shelfHeight, scale);
        return SliverList.builder(
          itemCount: rows.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              // The top shelf edge: lights the first row and holds its ivy.
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

  List<_Row> _layout(double available, double shelfHeight, double scale) {
    final rows = <_Row>[];
    var next = 0;
    var r = 0;
    while (next < recipes.length) {
      final left = <_ShelfItem>[];
      final right = <_ShelfItem>[];
      // Decor alternates between the ends so shelves don't look stamped.
      if (style.greenery.hasPots && r % 2 == 0) right.add(_DecorItem(_DecorKind.plant, 64 * scale, r));
      if (style.flowers != FlowerKind.none && r % 2 == 1) right.add(_DecorItem(_DecorKind.flowers, 58 * scale, r));
      switch (style.candles) {
        case CandleAmount.none:
          break;
        case CandleAmount.few:
          if (r % 2 == 1) left.add(_DecorItem(_DecorKind.candle, 26 * scale, r));
        case CandleAmount.many:
          left.add(_DecorItem(_DecorKind.candlePair, 44 * scale, r));
          if (right.isEmpty) right.add(_DecorItem(_DecorKind.candle, 26 * scale, r + 7));
      }
      var room = available - [...left, ...right].fold(0.0, (s, it) => s + it.width + 10);
      final books = <_ShelfItem>[];
      var faceOutUsed = false;
      while (next < recipes.length) {
        final recipe = recipes[next];
        final display = recipe.bookStyle.display;
        final wantsCover =
            display == BookDisplay.cover ||
            (display == BookDisplay.auto &&
                recipe.isFavorite &&
                !faceOutUsed &&
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
        final need = item.width + (item.faceOut ? 8 : _gap);
        if (need > room && books.isNotEmpty) break;
        books.add(item);
        room -= need;
        if (item.faceOut && display == BookDisplay.auto) faceOutUsed = true;
        next++;
      }
      rows.add(_Row([...left, ...books, ...right]));
      r++;
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

  /// Ivy hangs from every other shelf edge, at a different spot each time.
  bool get _ivyAbove => style.greenery.hasIvy && index % 2 == 0;

  @override
  Widget build(BuildContext context) {
    final plank = 14 * scale;
    final topSpace = 22 * scale;
    final items = <Widget>[];
    for (final (i, item) in row.items.indexed) {
      if (i > 0) {
        final prev = row.items[i - 1];
        final tight = item is _BookItem && prev is _BookItem && !item.faceOut && !prev.faceOut;
        items.add(SizedBox(width: tight ? LibraryBookcase._gap : 10));
      }
      items.add(_build(item));
    }
    return LayoutBuilder(
      builder: (context, box) => SizedBox(
        height: topSpace + shelfHeight + plank + 3,
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
              left: 14,
              right: 14,
              bottom: plank + 3,
              height: shelfHeight,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: items),
            ),
            if (_ivyAbove)
              Positioned(
                top: 0,
                left: 20 + (index * 37 % 10) / 10 * (box.maxWidth - 150 * scale).clamp(0, double.infinity),
                width: 104 * scale,
                height: 96 * scale,
                child: TrailingIvy(seed: index),
              ),
            Positioned(
              left: 4,
              right: 4,
              bottom: 0,
              child: ShelfPlank(wood: style.wood, glow: style.glow, height: plank),
            ),
          ],
        ),
      ),
    );
  }

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
        return SizedBox(
          width: item.width,
          height: 92 * scale,
          child: PottedPlant(seed: item.seed),
        );
      case _DecorItem(kind: _DecorKind.flowers):
        return SizedBox(
          width: item.width,
          height: 96 * scale,
          child: FlowerVase(kind: style.flowers, seed: item.seed),
        );
      case _DecorItem(kind: _DecorKind.candle):
        final size = Candle.sizeOf(item.seed.isEven ? CandleKind.pillar : CandleKind.tall, scale);
        return SizedBox(
          width: item.width,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox.fromSize(
              size: size,
              child: Candle(kind: item.seed.isEven ? CandleKind.pillar : CandleKind.tall, seed: item.seed),
            ),
          ),
        );
      case _DecorItem(kind: _DecorKind.candlePair):
        final tall = Candle.sizeOf(CandleKind.taper, scale);
        final short = Candle.sizeOf(CandleKind.pillar, scale);
        return SizedBox(
          width: item.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox.fromSize(
                size: tall,
                child: Candle(kind: CandleKind.taper, seed: item.seed * 3 + 1),
              ),
              SizedBox.fromSize(
                size: short,
                child: Candle(kind: CandleKind.pillar, seed: item.seed * 3 + 2),
              ),
            ],
          ),
        );
    }
  }
}
