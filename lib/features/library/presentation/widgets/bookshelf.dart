import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../../app/widgets/food_art.dart';
import '../../../../app/widgets/kitchen_format.dart';
import '../../../../app/widgets/recipe_image.dart';

/// Recipes as cloth-bound books standing on wooden shelves.
///
/// Books per shelf follow the available width; heights vary a little per
/// recipe (stable, from the id) so a shelf looks hand-arranged. Empty spots
/// on the last shelf hold a small doodle instead of a gap.
class BookshelfSliver extends StatelessWidget {
  final List<Recipe> recipes;
  final ValueChanged<Recipe> onOpen;
  final ValueChanged<Recipe>? onLongPress;

  const BookshelfSliver({super.key, required this.recipes, required this.onOpen, this.onLongPress});

  /// Three books on a phone; roomier books on wide screens.
  static int booksPerShelf(double width) =>
      width < 600 ? (width / 124).floor().clamp(2, 4) : (width / 165).floor().clamp(4, 7);

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final perShelf = booksPerShelf(constraints.crossAxisExtent);
        final shelves = (recipes.length / perShelf).ceil();
        return SliverList.builder(
          itemCount: shelves,
          itemBuilder: (context, row) {
            final start = row * perShelf;
            final books = recipes.sublist(start, (start + perShelf).clamp(0, recipes.length));
            return _Shelf(books: books, slots: perShelf, onOpen: onOpen, onLongPress: onLongPress, ornamentSeed: row);
          },
        );
      },
    );
  }
}

class _Shelf extends StatelessWidget {
  final List<Recipe> books;
  final int slots;
  final ValueChanged<Recipe> onOpen;
  final ValueChanged<Recipe>? onLongPress;
  final int ornamentSeed;

  const _Shelf({
    required this.books,
    required this.slots,
    required this.onOpen,
    required this.onLongPress,
    required this.ornamentSeed,
  });

  static const _ornaments = [
    'food-teapot',
    'food-basil',
    'food-coffee-cup',
    'food-lemon',
    'food-whisk',
    'food-wine-bottle',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < slots; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: AspectRatio(
                        aspectRatio: 0.66,
                        child: i < books.length
                            ? Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: 0.9 + (books[i].id.hashCode.abs() % 10) / 100,
                                  child: BookCover(
                                    recipe: books[i],
                                    onTap: () => onOpen(books[i]),
                                    onLongPress: onLongPress == null ? null : () => onLongPress!(books[i]),
                                  ),
                                ),
                              )
                            : (i == books.length
                                  ? Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FractionallySizedBox(
                                        widthFactor: 0.8,
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: FoodDoodle(id: _ornaments[ornamentSeed % _ornaments.length], size: 80),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink()),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const _Plank(),
        ],
      ),
    );
  }
}

class _Plank extends StatelessWidget {
  const _Plank();

  @override
  Widget build(BuildContext context) {
    final dark = context.chefColors.isDark;
    return Container(
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [Color(0xFF7A5A40), Color(0xFF5A3F2B), Color(0xFF3E2B1D)]
              : const [Color(0xFFD9B58C), Color(0xFFBF9468), Color(0xFF9C7149)],
          stops: const [0, 0.45, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.5 : 0.22),
            blurRadius: 10,
            offset: const Offset(0, 7),
          ),
        ],
      ),
    );
  }
}

/// One recipe as a book: cloth cover in the recipe's theme colour, a photo
/// window, a paper title label, and a ribbon bookmark for favorites.
class BookCover extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const BookCover({super.key, required this.recipe, required this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final cloth = Color.lerp(recipe.theme.accent(c), Colors.black, c.isDark ? 0.42 : 0.12)!;
    const labelPaper = Color(0xFFFBF6EC);
    const labelInk = Color(0xFF2C2623);
    const radius = BorderRadius.only(
      topLeft: Radius.circular(3),
      bottomLeft: Radius.circular(3),
      topRight: Radius.circular(9),
      bottomRight: Radius.circular(9),
    );

    return Semantics(
      button: true,
      label:
          '${recipe.title}. ${KitchenFormat.minutes(recipe.totalMinutes)}'
          '${recipe.isFavorite ? ', favorite' : ''}${recipe.status == RecipeStatus.draft ? ', draft' : ''}. Opens in the journal.',
      excludeSemantics: true,
      child: Material(
        color: cloth,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: const RoundedRectangleBorder(borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Spine: shadowed hinge and a stitched line.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withValues(alpha: 0.35), Colors.black.withValues(alpha: 0.0)],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 13,
                top: 0,
                bottom: 0,
                width: 1,
                child: ColoredBox(color: Colors.white.withValues(alpha: 0.18)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(19, 10, 9, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 11,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: RecipeImage(source: recipe.coverImage, theme: recipe.theme),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Expanded(
                      flex: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                        decoration: BoxDecoration(
                          color: labelPaper,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: LayoutBuilder(
                            builder: (context, box) {
                              final fontSize = (box.maxWidth / 8.2).clamp(9.5, 14.0);
                              return Text(
                                recipe.title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.25),
                                style: TextStyle(
                                  color: labelInk,
                                  fontWeight: FontWeight.w800,
                                  fontSize: fontSize,
                                  height: 1.15,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (recipe.isFavorite)
                Positioned(
                  top: 0,
                  right: 12,
                  child: CustomPaint(size: const Size(12, 30), painter: _RibbonPainter(c.accentTomato)),
                ),
              if (recipe.status == RecipeStatus.draft)
                Positioned(
                  left: 20,
                  top: 14,
                  child: Transform.rotate(
                    angle: -0.15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: labelPaper.withValues(alpha: 0.92),
                        border: Border.all(color: c.stateWarning, width: 1.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'DRAFT',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: c.stateWarning,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  final Color color;
  _RibbonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - 6)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawShadow(path, Colors.black, 2, false);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RibbonPainter old) => old.color != color;
}
