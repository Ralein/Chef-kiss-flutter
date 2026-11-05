import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../../app/widgets/kitchen_format.dart';
import '../../../../app/widgets/recipe_image.dart';

/// Bundled serif (DM Serif Display) for spines and journal headings.
const kSerifFamily = 'DMSerifDisplay';

/// Cloth colours offered for spines.
const spineCloths = <({String name, String hex})>[
  (name: 'Oxblood', hex: '#7A2E2A'),
  (name: 'Terracotta', hex: '#A04E3B'),
  (name: 'Mustard', hex: '#B8862D'),
  (name: 'Forest', hex: '#2F4A3A'),
  (name: 'Teal', hex: '#2F5E61'),
  (name: 'Navy', hex: '#273A5C'),
  (name: 'Plum', hex: '#5B3A6B'),
  (name: 'Tan', hex: '#8C6B47'),
  (name: 'Ivory', hex: '#E8DFCF'),
  (name: 'Black', hex: '#1F1F22'),
];

/// Ink colours offered for spine titles.
const spineInks = <({String name, String hex})>[
  (name: 'Gold', hex: '#E3C77F'),
  (name: 'Cream', hex: '#F3EBDD'),
  (name: 'Blush', hex: '#D9B2A6'),
  (name: 'Silver', hex: '#C9CDD2'),
  (name: 'Ink', hex: '#1E1A18'),
];

Color? _hex(String? hex) {
  if (hex == null || hex.length != 7) return null;
  final v = int.tryParse(hex.substring(1), radix: 16);
  return v == null ? null : Color(0xFF000000 | v);
}

String colorToHex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// The resolved look of one book.
class BookLook {
  final Color cloth;
  final Color ink;
  final TextStyle title;
  final SpinePattern pattern;

  const BookLook({required this.cloth, required this.ink, required this.title, required this.pattern});

  static const _themeCloth = {
    ScrapbookTheme.terracottaClassic: Color(0xFF7E3324),
    ScrapbookTheme.matchaSage: Color(0xFF2F4A3A),
    ScrapbookTheme.artisanKraft: Color(0xFF6E5034),
    ScrapbookTheme.nordicSlate: Color(0xFF2C3E4A),
  };

  /// [baseSize] is the medium title size for the current shelf scale.
  factory BookLook.of(Recipe recipe, {double baseSize = 13}) {
    final style = recipe.bookStyle;
    final custom = _hex(style.spineColor);
    final Color cloth;
    if (custom != null) {
      cloth = custom;
    } else {
      // Theme colour, nudged per recipe so a shelf isn't monotone.
      final jitter = ((recipe.id.hashCode.abs() % 7) - 3) * 0.045;
      final base = _themeCloth[recipe.theme]!;
      cloth = jitter >= 0 ? Color.lerp(base, Colors.white, jitter)! : Color.lerp(base, Colors.black, -jitter)!;
    }
    final ink =
        _hex(style.textColor) ?? (cloth.computeLuminance() > 0.45 ? const Color(0xFF2A221C) : const Color(0xFFE3C77F));
    final size =
        baseSize *
        switch (style.textSize) {
          SpineScale.small => 0.85,
          SpineScale.medium => 1.0,
          SpineScale.large => 1.18,
        };
    final title = switch (style.font) {
      SpineFont.serif => TextStyle(fontFamily: kSerifFamily, fontSize: size, color: ink, letterSpacing: 1.1, height: 1),
      SpineFont.serifItalic => TextStyle(
        fontFamily: kSerifFamily,
        fontStyle: FontStyle.italic,
        fontSize: size * 1.05,
        color: ink,
        letterSpacing: 0.3,
        height: 1,
      ),
      SpineFont.sans => TextStyle(
        fontSize: size * 0.82,
        color: ink,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        height: 1,
      ),
    };
    return BookLook(cloth: cloth, ink: ink, title: title, pattern: style.pattern);
  }

  /// "Tokyo Shoyu Craft Ramen with Ajitsuke Egg" → "Tokyo Shoyu Craft Ramen":
  /// spines carry the short title.
  static String spineTitle(Recipe recipe) {
    var t = recipe.title.trim();
    if (t.length > 22) {
      for (final cut in [' with ', ' & ', ' and ', ': ', ' (']) {
        final i = t.indexOf(cut);
        if (i >= 8) {
          t = t.substring(0, i);
          break;
        }
      }
    }
    return t;
  }
}

/// Book proportions on a shelf whose books are at most [shelfHeight] tall.
class BookMetrics {
  BookMetrics._();

  static double spineHeight(Recipe r, double shelfHeight) {
    final base = switch (r.bookStyle.height) {
      SpineScale.small => 0.72,
      SpineScale.medium => 0.84,
      SpineScale.large => 0.95,
    };
    final jitter = r.bookStyle.height == SpineScale.medium ? ((r.id.hashCode.abs() % 5) - 2) * 0.02 : 0.0;
    return shelfHeight * (base + jitter).clamp(0.6, 0.97);
  }

  static double spineWidth(Recipe r, double scale) {
    final base = switch (r.bookStyle.width) {
      SpineScale.small => 24.0,
      SpineScale.medium => 32.0,
      SpineScale.large => 42.0,
    };
    return (base + (r.ingredients.length > 10 ? 4 : 0)) * scale;
  }

  static double coverHeight(double shelfHeight) => shelfHeight * 0.9;
  static double coverWidth(double shelfHeight) => coverHeight(shelfHeight) * 0.7;
}

/// One book standing on a shelf, spine-out or face-out. Lifts when pressed.
class ShelfBook extends StatefulWidget {
  final Recipe recipe;
  final bool faceOut;
  final double height;
  final double width;
  final double scale;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ShelfBook({
    super.key,
    required this.recipe,
    required this.faceOut,
    required this.height,
    required this.width,
    required this.scale,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<ShelfBook> createState() => _ShelfBookState();
}

class _ShelfBookState extends State<ShelfBook> {
  bool _lifted = false;

  void _lift(bool v) {
    if (v != _lifted) setState(() => _lifted = v);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    return Semantics(
      button: true,
      label:
          '${r.title}. ${KitchenFormat.minutes(r.totalMinutes)}${r.isFavorite ? ', favorite' : ''}. Opens in the journal.',
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _lift(true),
        onExit: (_) => _lift(false),
        child: GestureDetector(
          onTapDown: (_) => _lift(true),
          onTapCancel: () => _lift(false),
          onTapUp: (_) => _lift(false),
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: AnimatedContainer(
            duration: ChefMotion.quick,
            curve: ChefMotion.easeExit,
            transform: Matrix4.translationValues(0, _lifted ? -8 * widget.scale : 0, 0),
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _lifted ? 0.55 : 0.42),
                  blurRadius: _lifted ? 12 : 6,
                  offset: Offset(2, _lifted ? 6 : 2),
                ),
              ],
            ),
            child: widget.faceOut ? BookCoverFace(recipe: r) : BookSpine(recipe: r, scale: widget.scale),
          ),
        ),
      ),
    );
  }
}

/// A cloth spine with the title running upwards, as on a real bookshelf.
class BookSpine extends StatelessWidget {
  final Recipe recipe;
  final double scale;
  const BookSpine({super.key, required this.recipe, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    final look = BookLook.of(recipe, baseSize: 12.5 * scale);
    final cloth = look.cloth;
    return LayoutBuilder(
      builder: (context, box) {
        final h = box.maxHeight;
        final w = box.maxWidth;
        final margin = h * 0.13;
        return ClipRRect(
          borderRadius: BorderRadius.circular(2.5),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(cloth, Colors.black, 0.32)!,
                  Color.lerp(cloth, Colors.white, 0.10)!,
                  cloth,
                  Color.lerp(cloth, Colors.black, 0.38)!,
                ],
                stops: const [0, 0.32, 0.66, 1],
              ),
            ),
            child: Stack(
              children: [
                // Page tops peeking above the cloth.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 2,
                  child: ColoredBox(color: Colors.white.withValues(alpha: 0.12)),
                ),
                CustomPaint(size: Size(w, h), painter: _SpinePatternPainter(look.pattern, look.ink, margin)),
                Positioned.fill(
                  top: margin + 6,
                  bottom: margin + 6,
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SizedBox(
                        width: (h - 2 * margin - 12).clamp(10, double.infinity),
                        child: Text(
                          // Italic reads best in title case; the others are set in capitals.
                          recipe.bookStyle.font == SpineFont.serifItalic
                              ? BookLook.spineTitle(recipe)
                              : BookLook.spineTitle(recipe).toUpperCase(),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.15),
                          style: look.title,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpinePatternPainter extends CustomPainter {
  final SpinePattern pattern;
  final Color ink;
  final double margin;
  _SpinePatternPainter(this.pattern, this.ink, this.margin);

  @override
  void paint(Canvas canvas, Size size) {
    switch (pattern) {
      case SpinePattern.plain:
        return;
      case SpinePattern.bands:
        final p = Paint()
          ..color = ink.withValues(alpha: 0.85)
          ..strokeWidth = 1.1;
        for (final y in [
          margin * 0.55,
          margin * 0.55 + 4,
          size.height - margin * 0.55,
          size.height - margin * 0.55 - 4,
        ]) {
          canvas.drawLine(Offset(3, y), Offset(size.width - 3, y), p);
        }
      case SpinePattern.ribs:
        for (final y in [margin * 0.4, margin * 0.85, size.height - margin * 0.85, size.height - margin * 0.4]) {
          canvas.drawRect(
            Rect.fromLTWH(0, y - 2, size.width, 3),
            Paint()..color = Colors.black.withValues(alpha: 0.28),
          );
          canvas.drawRect(
            Rect.fromLTWH(0, y - 2, size.width, 1),
            Paint()..color = Colors.white.withValues(alpha: 0.18),
          );
        }
    }
  }

  @override
  bool shouldRepaint(_SpinePatternPainter old) => old.pattern != pattern || old.ink != ink || old.margin != margin;
}

/// A face-out book: the recipe's cover art, or a cloth cover with the title.
class BookCoverFace extends StatelessWidget {
  final Recipe recipe;
  const BookCoverFace({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final look = BookLook.of(recipe);
    final hasArt = recipe.coverImage?.isNotEmpty ?? false;
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(2), right: Radius.circular(4)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasArt)
            RecipeImage(source: recipe.coverImage, theme: recipe.theme)
          else
            ColoredBox(
              color: look.cloth,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: DecoratedBox(
                  decoration: BoxDecoration(border: Border.all(color: look.ink.withValues(alpha: 0.7), width: 0.8)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(
                        recipe.title,
                        textAlign: TextAlign.center,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: kSerifFamily, color: look.ink, fontSize: 13, height: 1.15),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Hinge shadow along the spine edge.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.45), Colors.black.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
