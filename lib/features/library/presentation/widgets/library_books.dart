import 'dart:math' as math;

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../../app/widgets/kitchen_format.dart';
import '../../../../app/widgets/recipe_image.dart';
import '../../domain/cookbook.dart';

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

  /// What a printed pattern is drawn in.
  final Color accent;

  /// Varies a printed pattern from book to book.
  final int seed;

  const BookLook({
    required this.cloth,
    required this.ink,
    required this.title,
    required this.pattern,
    required this.accent,
    this.seed = 0,
  });

  /// Leaves, flowers, stripes…: a pattern printed over the whole cloth, with
  /// the title on a label.
  bool get printed => SpinePattern.printed.contains(pattern);

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
    return BookLook(
      cloth: cloth,
      ink: ink,
      title: title,
      pattern: style.pattern,
      // Without an accent of its own a pattern is printed a shade lighter.
      accent: _hex(style.accentColor) ?? Color.lerp(cloth, Colors.white, 0.32)!,
      seed: recipe.id.hashCode,
    );
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
    // A cookbook holds many recipes: the thickest book on the shelf.
    if (Cookbook.isCookbook(r)) return 54 * scale;
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
      label: Cookbook.isCookbook(r)
          ? '${r.title}, cookbook, ${r.summary}. Opens the book.'
          : '${r.title}. ${KitchenFormat.minutes(r.totalMinutes)}${r.isFavorite ? ', favorite' : ''}. Opens in the cookbook.',
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
        // The title runs between the bands, nearly end to end on a plain
        // spine, or on a label in the middle of a printed one.
        final titleInset = look.printed ? h * 0.27 : (look.pattern == SpinePattern.plain ? 10.0 : margin + 1);
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
                CustomPaint(size: Size(w, h), painter: _SpinePatternPainter(look, margin)),
                if (look.printed) ...[
                  Positioned(
                    left: 3,
                    right: 3,
                    top: h * 0.24,
                    bottom: h * 0.24,
                    child: _Label(look: look),
                  ),
                  // The spine's curve, over the print.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.24),
                            Colors.white.withValues(alpha: 0.06),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.26),
                          ],
                          stops: const [0, 0.32, 0.66, 1],
                        ),
                      ),
                    ),
                  ),
                ],
                Positioned.fill(
                  top: titleInset,
                  bottom: titleInset,
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SizedBox(
                        width: math.max(10, h - 2 * titleInset),
                        height: math.max(8, w - 5),
                        child: SpineTitle(
                          // Italic reads best in title case; the others are set in capitals.
                          text: recipe.bookStyle.font == SpineFont.serifItalic
                              ? BookLook.spineTitle(recipe)
                              : BookLook.spineTitle(recipe).toUpperCase(),
                          style: look.title,
                          textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.15),
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

/// How a spine title is set: the lines, and their font size.
typedef SpineFit = ({List<String> lines, double size});

/// A spine title as large as the spine allows: one line, shrunk a little if
/// need be; else two balanced lines when the spine is thick enough; else one
/// small line. A line that still doesn't fit ends in an ellipsis. Lay it out
/// unrotated: width is the spine's length, height its thickness.
class SpineTitle extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextScaler textScaler;

  const SpineTitle({super.key, required this.text, required this.style, this.textScaler = TextScaler.noScaling});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final f = fit(text, style, textScaler, length: box.maxWidth, thickness: box.maxHeight);
        final lineStyle = _sized(style, f.size).copyWith(height: f.lines.length > 1 ? _twoLineHeight : style.height);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final line in f.lines)
              Text(
                line,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                textScaler: textScaler,
                style: lineStyle,
              ),
          ],
        );
      },
    );
  }

  static const _twoLineHeight = 1.08;

  /// Letter spacing shrinks with the type, so the title keeps its texture.
  static TextStyle _sized(TextStyle style, double size) {
    final base = style.fontSize ?? 13;
    return style.copyWith(fontSize: size, letterSpacing: (style.letterSpacing ?? 0) * size / base);
  }

  static final _widths = <String, double>{};

  static double _width(String s, TextStyle style, TextScaler scaler, double size) {
    final key =
        '${style.fontFamily}|${style.fontStyle}|${style.fontWeight}|${style.letterSpacing}|${style.fontSize}|'
        '${scaler.scale(100)}|$size|$s';
    final cached = _widths[key];
    if (cached != null) return cached;
    if (_widths.length > 800) _widths.clear();
    final painter = TextPainter(
      text: TextSpan(text: s, style: _sized(style, size)),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return _widths[key] = width;
  }

  /// The largest size up to [cap] at which [s] fits [length] on one line.
  static double _fitLine(String s, TextStyle style, TextScaler scaler, double cap, double length) {
    final w = _width(s, style, scaler, cap);
    if (w <= length) return cap;
    // Width grows linearly with size; settle on a quarter point just inside.
    return (cap * length / w * 4).floorToDouble() / 4;
  }

  static SpineFit fit(
    String text,
    TextStyle style,
    TextScaler scaler, {
    required double length,
    required double thickness,
  }) {
    final base = style.fontSize ?? 13;
    final floor = math.max(7.5, base * 0.62);
    final perPixel = scaler.scale(1);
    final oneCap = math.min(base, (thickness - 2) / (perPixel * (style.height ?? 1.2)));
    final one = _fitLine(text, style, scaler, oneCap, length);
    if (one >= base * 0.86) return (lines: [text], size: one);

    final words = text.split(' ');
    final twoCap = math.min(base, (thickness - 2) / (2 * _twoLineHeight * perPixel));
    if (words.length > 1 && twoCap >= floor) {
      var split = 1;
      var best = double.infinity;
      for (var i = 1; i < words.length; i++) {
        final longer = math.max(
          _width(words.take(i).join(' '), style, scaler, base),
          _width(words.skip(i).join(' '), style, scaler, base),
        );
        if (longer < best) {
          best = longer;
          split = i;
        }
      }
      final a = words.take(split).join(' '), b = words.skip(split).join(' ');
      final two = math.min(_fitLine(a, style, scaler, twoCap, length), _fitLine(b, style, scaler, twoCap, length));
      // Two lines show more of the title, even when one has to be trimmed.
      if (two > one || one < floor) return (lines: [a, b], size: math.max(two, floor));
    }
    return (lines: [text], size: math.max(one, floor));
  }
}

class _SpinePatternPainter extends CustomPainter {
  final BookLook look;
  final double margin;
  _SpinePatternPainter(this.look, this.margin);

  @override
  void paint(Canvas canvas, Size size) => paintBookPattern(canvas, size, look, margin: margin);

  @override
  bool shouldRepaint(_SpinePatternPainter old) =>
      old.look.pattern != look.pattern ||
      old.look.ink != look.ink ||
      old.look.cloth != look.cloth ||
      old.look.accent != look.accent ||
      old.look.seed != look.seed ||
      old.margin != margin;
}

/// Draws [look]'s pattern over a spine or a cover of [size]: gilt bands,
/// raised ribs, or a pattern printed in the accent colour.
void paintBookPattern(Canvas canvas, Size size, BookLook look, {required double margin}) {
  final w = size.width, h = size.height;
  final rnd = math.Random(look.seed);
  final fill = Paint()..color = look.accent.withValues(alpha: 0.82);
  final line = Paint()
    ..color = look.accent.withValues(alpha: 0.75)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  // A print is sized to a spine, so a cover gets more of it, not a bigger one.
  final unit = math.max(18.0, math.min(w, 34.0));
  canvas.save();
  canvas.clipRect(Offset.zero & size);
  switch (look.pattern) {
    case SpinePattern.plain:
      break;
    case SpinePattern.bands:
      final p = Paint()
        ..color = look.ink.withValues(alpha: 0.85)
        ..strokeWidth = 1.1;
      for (final y in [margin * 0.55, margin * 0.55 + 4, h - margin * 0.55, h - margin * 0.55 - 4]) {
        canvas.drawLine(Offset(3, y), Offset(w - 3, y), p);
      }
    case SpinePattern.ribs:
      for (final y in [margin * 0.4, margin * 0.85, h - margin * 0.85, h - margin * 0.4]) {
        canvas.drawRect(Rect.fromLTWH(0, y - 2, w, 3), Paint()..color = Colors.black.withValues(alpha: 0.28));
        canvas.drawRect(Rect.fromLTWH(0, y - 2, w, 1), Paint()..color = Colors.white.withValues(alpha: 0.18));
      }
    case SpinePattern.leaves:
      // Leaves at a slant, each with a vein, in staggered rows.
      final vein = Paint()
        ..color = look.cloth.withValues(alpha: 0.55)
        ..strokeWidth = math.max(0.6, unit * 0.025);
      final step = unit * 0.55;
      for (var row = 0; row * step * 0.7 < h + step; row++) {
        for (var x = row.isOdd ? step * 0.5 : 0.0; x < w + step; x += step) {
          final len = unit * (0.34 + rnd.nextDouble() * 0.1);
          canvas.save();
          canvas.translate(x + (rnd.nextDouble() - 0.5) * step * 0.2, row * step * 0.7);
          canvas.rotate((row.isOdd ? 0.7 : -0.7) + (rnd.nextDouble() - 0.5) * 0.5);
          final leaf = Path()
            ..moveTo(0, len * 0.5)
            ..quadraticBezierTo(len * 0.34, 0, 0, -len * 0.5)
            ..quadraticBezierTo(-len * 0.34, 0, 0, len * 0.5)
            ..close();
          canvas.drawPath(leaf, fill);
          canvas.drawLine(Offset(0, len * 0.42), Offset(0, -len * 0.36), vein);
          canvas.restore();
        }
      }
    case SpinePattern.florals:
      // Five-petal flowers with a darker heart.
      final heart = Paint()..color = Color.lerp(look.accent, look.cloth, 0.55)!;
      final step = unit * 0.62;
      for (var row = 0; row * step * 0.78 < h + step; row++) {
        for (var x = row.isOdd ? step * 0.5 : 0.0; x < w + step; x += step) {
          final c = Offset(x + (rnd.nextDouble() - 0.5) * step * 0.2, row * step * 0.78);
          final r = unit * (0.1 + rnd.nextDouble() * 0.03);
          final turn = rnd.nextDouble() * math.pi;
          for (var k = 0; k < 5; k++) {
            final a = turn + k * math.pi * 2 / 5;
            canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * r, r * 0.72, fill);
          }
          canvas.drawCircle(c, r * 0.5, heart);
        }
      }
    case SpinePattern.stripes:
      // Bold diagonal stripes.
      line
        ..strokeWidth = unit * 0.13
        ..strokeCap = StrokeCap.butt;
      for (var y = -w; y < h + w; y += unit * 0.36) {
        canvas.drawLine(Offset(0, y), Offset(w, y + w * 0.75), line);
      }
    case SpinePattern.waves:
      line.strokeWidth = math.max(1.2, unit * 0.06);
      final gap = unit * 0.3;
      for (var y = gap * 0.5; y < h + gap; y += gap) {
        final wave = Path()..moveTo(0, y);
        for (var x = 0.0; x <= w + 2; x += 1.5) {
          wave.lineTo(x, y + math.sin(x / unit * math.pi * 2.4) * unit * 0.07);
        }
        canvas.drawPath(wave, line);
      }
    case SpinePattern.dots:
      final gap = unit * 0.34;
      for (var row = 0; row * gap * 0.87 < h + gap; row++) {
        for (var x = row.isOdd ? gap / 2 : gap * 0.1; x < w + gap; x += gap) {
          canvas.drawCircle(Offset(x, row * gap * 0.87), unit * 0.08, fill);
        }
      }
    case SpinePattern.chevrons:
      line
        ..strokeWidth = math.max(1.4, unit * 0.075)
        ..strokeJoin = StrokeJoin.miter;
      final gap = unit * 0.32, rise = unit * 0.14, run = unit * 0.2;
      for (var y = gap * 0.6; y < h + gap; y += gap) {
        final zig = Path()..moveTo(-run, y);
        var up = true;
        for (var x = 0.0; x <= w + run; x += run) {
          zig.lineTo(x, up ? y - rise : y);
          up = !up;
        }
        canvas.drawPath(zig, line);
      }
  }
  canvas.restore();
}

/// The cloth label a printed spine's title sits on.
class _Label extends StatelessWidget {
  final BookLook look;
  const _Label({required this.look});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: look.cloth,
      borderRadius: BorderRadius.circular(2.5),
      border: Border.all(color: look.ink.withValues(alpha: 0.55), width: 0.8),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 2, offset: const Offset(0, 0.5))],
    ),
  );
}

/// A face-out book: cloth printed like its spine, with its photo framed on
/// the front above the title, or the title alone in a frame.
class BookCoverFace extends StatelessWidget {
  final Recipe recipe;
  const BookCoverFace({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final look = BookLook.of(recipe);
    final photo = recipe.coverImage;
    final hasArt = photo != null && photo.isNotEmpty;
    final frame = Border.all(color: look.ink.withValues(alpha: 0.7), width: 0.8);
    final title = Text(
      recipe.title,
      textAlign: TextAlign.center,
      maxLines: hasArt ? 2 : (look.printed ? 3 : 5),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontFamily: kSerifFamily, color: look.ink, fontSize: hasArt ? 11 : 13, height: 1.15),
    );
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(2), right: Radius.circular(4)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: look.cloth),
          if (look.printed) CustomPaint(painter: _SpinePatternPainter(look, 0)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 9, 9),
            child: hasArt
                ? Column(
                    children: [
                      Expanded(
                        child: DecoratedBox(
                          position: DecorationPosition.foreground,
                          decoration: BoxDecoration(border: frame),
                          child: SizedBox.expand(
                            child: RecipeImage(source: photo, theme: recipe.theme),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      DecoratedBox(
                        decoration: BoxDecoration(color: look.cloth, border: frame),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                          child: SizedBox(width: double.infinity, child: title),
                        ),
                      ),
                    ],
                  )
                : look.printed
                // The print shows all round a label in the middle.
                ? Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.82,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: look.cloth,
                          borderRadius: BorderRadius.circular(3),
                          border: frame,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12), child: title),
                      ),
                    ),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(border: frame),
                    child: Center(
                      child: Padding(padding: const EdgeInsets.all(6), child: title),
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
