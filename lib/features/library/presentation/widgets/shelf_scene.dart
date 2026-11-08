import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../domain/shelf_style.dart';
import 'decor_art.dart';
import 'library_bookcase.dart';
import 'shelf_art.dart';
import 'shelf_layout.dart';

/// A still bookcase for previews: [style]'s wall, shelves and decorations
/// with [books] standing on them, laid out exactly as the library lays them
/// out. It fills the space it's given; shelves past the bottom are cut off.
class ShelfScene extends StatelessWidget {
  final ShelfStyle style;
  final List<Recipe> books;

  /// Wall showing above the top shelf.
  final double topPadding;

  const ShelfScene({super.key, required this.style, this.books = const [], this.topPadding = 0});

  @override
  Widget build(BuildContext context) {
    // Wall textures are drawn tile by tile past their edges; a scene keeps to its box.
    return IgnorePointer(
      child: ExcludeSemantics(
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: CustomPaint(painter: WallPainter(style: style.wall, tint: style.wallColor)),
              ),
              CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: topPadding)),
                  LibraryBookcase(recipes: books, style: style, onOpen: (_) {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A ready-made room in miniature: its wall, two shelves and their decor.
class ShelfMiniRoom extends StatelessWidget {
  final ShelfStyle style;
  const ShelfMiniRoom(this.style, {super.key});

  static const _width = 390.0;

  @override
  Widget build(BuildContext context) {
    final m = ShelfMetrics.forWidth(_width);
    final children = <Widget>[
      Positioned.fill(
        child: CustomPaint(
          painter: WallPainter(style: style.wall, tint: style.wallColor),
        ),
      ),
    ];
    var top = 8.0;
    Widget plank(double height) => ShelfPlank(wood: style.wood, glow: style.glow, height: height);
    children.add(Positioned(left: 4, right: 4, top: top, child: plank(10)));
    top += 13;
    for (var shelf = 0; shelf < 2; shelf++) {
      for (final d in style.pieces.where((p) => p.shelf == shelf)) {
        final size = m.sizeOf(d);
        children.add(
          Positioned(
            left: ShelfMetrics.inset + m.leftOf(d),
            top: d.piece.hangs ? top : top + m.room - size.height,
            width: size.width,
            height: size.height,
            child: DecorArt(d.piece, seed: d.seed, flipped: d.flipped),
          ),
        );
      }
      top += m.room;
      children.add(Positioned(left: 4, right: 4, top: top, child: plank(m.plank)));
      top += m.plank + 3;
    }
    return IgnorePointer(
      child: FittedBox(
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _width,
          height: top,
          child: Stack(children: children),
        ),
      ),
    );
  }
}
