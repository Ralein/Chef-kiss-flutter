import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../../app/widgets/food_art.dart';
import '../../../../app/widgets/kitchen_format.dart';
import '../../../../app/widgets/recipe_image.dart';

/// Wood and paneling colours for the bookcase, per light/dark mode.
class _Wood {
  final List<Color> plank;
  final List<Color> post;
  final Color back;
  final Color seam;
  final Color brass;
  final Color brassInk;

  const _Wood({
    required this.plank,
    required this.post,
    required this.back,
    required this.seam,
    required this.brass,
    required this.brassInk,
  });

  static _Wood of(BuildContext context) => context.chefColors.isDark
      ? const _Wood(
          plank: [Color(0xFF7A5A40), Color(0xFF5A3F2B), Color(0xFF3E2B1D)],
          post: [Color(0xFF4A3424), Color(0xFF654832), Color(0xFF4A3424)],
          back: Color(0xFF231D18),
          seam: Color(0xFF2E2620),
          brass: Color(0xFFB9935A),
          brassInk: Color(0xFF2A1F12),
        )
      : const _Wood(
          plank: [Color(0xFFD9B58C), Color(0xFFBF9468), Color(0xFF9C7149)],
          post: [Color(0xFFA67C54), Color(0xFFC49A6E), Color(0xFFA67C54)],
          back: Color(0xFFF1E6D6),
          seam: Color(0xFFE6D7C2),
          brass: Color(0xFFD7B67A),
          brassInk: Color(0xFF4A3516),
        );
}

/// Recipes as cloth-bound books standing in a wooden bookcase.
///
/// Books per shelf follow the available width; heights vary a little per
/// recipe (stable, from the id) so a shelf looks hand-arranged. An empty spot
/// on the last shelf holds a single doodle instead of a gap.
class BookshelfSliver extends StatelessWidget {
  final List<Recipe> recipes;
  final ValueChanged<Recipe> onOpen;
  final ValueChanged<Recipe>? onLongPress;

  /// Shown on the brass plate at the top of the bookcase.
  final String? title;

  const BookshelfSliver({super.key, required this.recipes, required this.onOpen, this.onLongPress, this.title});

  /// Three books on a phone; roomier books on wide screens.
  static int booksPerShelf(double width) =>
      width < 600 ? (width / 112).floor().clamp(2, 4) : (width / 165).floor().clamp(4, 7);

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        // The cabinet's side posts take a little width from the books.
        final perShelf = booksPerShelf(constraints.crossAxisExtent - 2 * _Cabinet.post);
        final shelves = (recipes.length / perShelf).ceil();
        return SliverList.builder(
          itemCount: shelves,
          itemBuilder: (context, row) {
            final start = row * perShelf;
            final books = recipes.sublist(start, (start + perShelf).clamp(0, recipes.length));
            return _Cabinet(
              isTop: row == 0,
              isBottom: row == shelves - 1,
              plate: row == 0 ? (title ?? '${recipes.length} book${recipes.length == 1 ? '' : 's'}') : null,
              child: _Shelf(books: books, slots: perShelf, onOpen: onOpen, onLongPress: onLongPress, ornamentSeed: row),
            );
          },
        );
      },
    );
  }
}

/// One horizontal slice of the bookcase: side posts and back paneling, plus
/// the crown (with a brass name plate) on the first slice and the plinth on
/// the last.
class _Cabinet extends StatelessWidget {
  static const post = 10.0;
  final bool isTop;
  final bool isBottom;
  final String? plate;
  final Widget child;

  const _Cabinet({required this.isTop, required this.isBottom, required this.plate, required this.child});

  @override
  Widget build(BuildContext context) {
    final wood = _Wood.of(context);
    final postDecoration = BoxDecoration(gradient: LinearGradient(colors: wood.post));
    return Column(
      children: [
        if (isTop) _Crown(wood: wood, plate: plate),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DecoratedBox(decoration: postDecoration, child: const SizedBox(width: post)),
              Expanded(
                child: CustomPaint(
                  painter: _PanelPainter(back: wood.back, seam: wood.seam),
                  child: Padding(padding: const EdgeInsets.only(top: 14), child: child),
                ),
              ),
              DecoratedBox(decoration: postDecoration, child: const SizedBox(width: post)),
            ],
          ),
        ),
        if (isBottom) _Plinth(wood: wood),
      ],
    );
  }
}

class _Crown extends StatelessWidget {
  final _Wood wood;
  final String? plate;
  const _Crown({required this.wood, required this.plate});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: wood.plank),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      alignment: Alignment.center,
      child: plate == null
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(wood.brass, Colors.white, 0.35)!,
                    wood.brass,
                    Color.lerp(wood.brass, Colors.black, 0.15)!,
                  ],
                ),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 2, offset: const Offset(0, 1))],
              ),
              child: Text(
                plate!.toUpperCase(),
                textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.2),
                style: TextStyle(color: wood.brassInk, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.4),
              ),
            ),
    );
  }
}

class _Plinth extends StatelessWidget {
  final _Wood wood;
  const _Plinth({required this.wood});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: wood.post),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 6))],
      ),
    );
  }
}

/// Vertical back boards with seams, darkening slightly under each shelf.
class _PanelPainter extends CustomPainter {
  final Color back;
  final Color seam;
  _PanelPainter({required this.back, required this.seam});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = back);
    final line = Paint()
      ..color = seam
      ..strokeWidth = 1.5;
    for (var x = 72.0; x < size.width; x += 72) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    // Shadow cast by the shelf above.
    final top = Rect.fromLTWH(0, 0, size.width, 18);
    canvas.drawRect(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.12), Colors.transparent],
        ).createShader(top),
    );
  }

  @override
  bool shouldRepaint(_PanelPainter old) => old.back != back || old.seam != seam;
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

  static const _ornaments = ['food-teapot', 'food-basil', 'food-coffee-cup', 'food-lemon', 'food-whisk', 'food-wine-bottle'];

  @override
  Widget build(BuildContext context) {
    final wood = _Wood.of(context);
    return Column(
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
                                      widthFactor: 0.78,
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
        // The shelf board, with a lighter front edge.
        Container(
          height: 16,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: wood.plank,
              stops: const [0, 0.45, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: context.chefColors.isDark ? 0.45 : 0.18),
                blurRadius: 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(height: 2, color: Colors.white.withValues(alpha: 0.18)),
          ),
        ),
      ],
    );
  }
}

/// One recipe as a book: cloth cover in the recipe's theme colour, a gilt
/// photo window, a paper title label, page edges showing on the side, and a
/// ribbon bookmark for favorites. Lifts slightly when pressed or hovered.
class BookCover extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const BookCover({super.key, required this.recipe, required this.onTap, this.onLongPress});

  @override
  State<BookCover> createState() => _BookCoverState();
}

class _BookCoverState extends State<BookCover> {
  bool _lifted = false;

  void _lift(bool value) {
    if (_lifted != value) setState(() => _lifted = value);
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final c = context.chefColors;
    final cloth = Color.lerp(recipe.theme.accent(c), Colors.black, c.isDark ? 0.42 : 0.12)!;
    const labelPaper = Color(0xFFFBF6EC);
    const labelInk = Color(0xFF2C2623);
    const gilt = Color(0xFFD9B66F);
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
      child: MouseRegion(
        onEnter: (_) => _lift(true),
        onExit: (_) => _lift(false),
        child: AnimatedSlide(
          duration: ChefMotion.quick,
          curve: ChefMotion.easeExit,
          offset: _lifted ? const Offset(0, -0.04) : Offset.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Page block peeking out on the fore-edge.
              Positioned(right: 0, top: 5, bottom: 3, width: 10, child: CustomPaint(painter: _PageBlockPainter())),
              Positioned.fill(
                right: 4,
                child: Material(
                  color: cloth,
                  elevation: _lifted ? 8 : 4,
                  shadowColor: Colors.black.withValues(alpha: 0.5),
                  shape: const RoundedRectangleBorder(borderRadius: radius),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: widget.onTap,
                    onLongPress: widget.onLongPress,
                    onHighlightChanged: _lift,
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
                                    border: Border.all(color: gilt, width: 1.6),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: RecipeImage(source: recipe.coverImage, theme: recipe.theme),
                                    ),
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
                                    border: Border.all(color: gilt.withValues(alpha: 0.7)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, box) => _BookLabel(recipe: recipe, box: box, ink: labelInk),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Title (and, when there's room, cooking time) on the book's paper label.
class _BookLabel extends StatelessWidget {
  final Recipe recipe;
  final BoxConstraints box;
  final Color ink;
  const _BookLabel({required this.recipe, required this.box, required this.ink});

  @override
  Widget build(BuildContext context) {
    final fontSize = (box.maxWidth / 8.2).clamp(9.5, 14.0);
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.25);
    // Room for three title lines plus the time line; otherwise the title wins.
    final roomForMeta = recipe.totalMinutes > 0 && box.maxHeight >= scaler.scale(fontSize) * 5.6;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            recipe.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            textScaler: scaler,
            style: TextStyle(color: ink, fontWeight: FontWeight.w800, fontSize: fontSize, height: 1.15),
          ),
        ),
        if (roomForMeta) ...[
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.clock, size: fontSize * 0.8, color: ink.withValues(alpha: 0.6)),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  KitchenFormat.minutes(recipe.totalMinutes),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaler: scaler,
                  style: TextStyle(color: ink.withValues(alpha: 0.7), fontSize: fontSize * 0.78, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Stacked page edges seen beside the cover.
class _PageBlockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndCorners(
      Offset.zero & size,
      topRight: const Radius.circular(3),
      bottomRight: const Radius.circular(3),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xFFF4EDE0));
    final line = Paint()
      ..color = const Color(0xFFD9CDB8)
      ..strokeWidth = 0.8;
    for (var y = 3.0; y < size.height - 2; y += 3) {
      canvas.drawLine(Offset(2, y), Offset(size.width - 1, y), line);
    }
  }

  @override
  bool shouldRepaint(_PageBlockPainter old) => false;
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
