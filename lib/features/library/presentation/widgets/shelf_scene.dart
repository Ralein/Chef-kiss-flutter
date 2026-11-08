import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../domain/shelf_style.dart';
import 'library_bookcase.dart';
import 'shelf_art.dart';

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
