import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../library/presentation/widgets/library_books.dart' show kSerifFamily;

/// The welcome tour's evening kitchen: a warm near-black, cream type and a
/// gold accent (the gold of the book spines).
abstract final class TourColors {
  static const background = Color(0xFF12100E);
  static const cream = Color(0xFFF5EFE6);
  static const gold = Color(0xFFE3C77F);
  static const muted = Color(0xFFB5ABA0);
  static const tile = Color(0xFF1D1916);
  static const tileSelected = Color(0xFF2A231B);
  static const outline = Color(0xFF2E2823);
  static const ink = Color(0xFF1A1613);
}

/// A serif heading where `*starred words*` are set in gold italic, as in
/// "Welcome, *chef*".
class TourHeadline extends StatelessWidget {
  final String markup;
  final double size;
  final TextAlign align;
  const TourHeadline(this.markup, {super.key, this.size = 30, this.align = TextAlign.center});

  /// [text] made safe to place inside markup (no stray stars).
  static String plain(String text) => text.replaceAll('*', '');

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(fontFamily: kSerifFamily, fontSize: size, height: 1.18, color: TourColors.cream);
    final parts = markup.split('*');
    return Semantics(
      header: true,
      child: Text.rich(
        TextSpan(
          children: [
            for (final (i, part) in parts.indexed)
              if (part.isNotEmpty)
                TextSpan(
                  text: part,
                  style: i.isOdd ? base.copyWith(fontStyle: FontStyle.italic, color: TourColors.gold) : base,
                ),
          ],
        ),
        textAlign: align,
      ),
    );
  }
}

/// Supporting text under a heading.
class TourBody extends StatelessWidget {
  final String text;
  final TextAlign align;
  const TourBody(this.text, {super.key, this.align = TextAlign.center});

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: align,
    style: const TextStyle(fontSize: 15.5, height: 1.5, color: TourColors.muted),
  );
}

/// The tour's main button: a cream pill.
class TourButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailing;
  const TourButton({super.key, required this.label, required this.onPressed, this.trailing});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: TourColors.cream,
          foregroundColor: TourColors.ink,
          disabledBackgroundColor: TourColors.cream.withValues(alpha: 0.28),
          disabledForegroundColor: TourColors.ink.withValues(alpha: 0.55),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (trailing != null) ...[const SizedBox(width: 8), Icon(trailing, size: 18)],
          ],
        ),
      ),
    );
  }
}

/// A quiet text button under the main one ("Skip", "I'll add my own").
class TourTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const TourTextButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(foregroundColor: TourColors.muted, minimumSize: const Size(48, 44)),
    child: Text(label),
  );
}

/// One answer to a question: an icon and a label; gold-edged when chosen.
class TourChoice extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Several answers can be chosen: shows a check box.
  final bool multi;

  const TourChoice({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.multi = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      checked: multi ? selected : null,
      inMutuallyExclusiveGroup: multi ? null : true,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? TourColors.tileSelected : TourColors.tile,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? TourColors.gold : TourColors.outline, width: selected ? 1.4 : 1),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: selected ? TourColors.gold : TourColors.muted),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        color: TourColors.cream.withValues(alpha: selected ? 1 : 0.88),
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (multi)
                    Icon(
                      selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                      size: 20,
                      color: selected ? TourColors.gold : TourColors.outline,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Faint gold sparkles over the evening sky. They twinkle for a while after
/// each change of [restartKey], then rest, so a still screen stays still.
class StarField extends StatefulWidget {
  final Object? restartKey;
  const StarField({super.key, this.restartKey});

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField> with SingleTickerProviderStateMixin {
  late final _twinkle = AnimationController(vsync: this, duration: const Duration(seconds: 14));
  static final _stars = _makeStars(70);

  static List<_Star> _makeStars(int n) {
    final rnd = math.Random(7);
    return [
      for (var i = 0; i < n; i++)
        _Star(
          Offset(rnd.nextDouble(), rnd.nextDouble()),
          size: 1.2 + rnd.nextDouble() * 2.6,
          phase: rnd.nextDouble() * math.pi * 2,
          speed: 0.6 + rnd.nextDouble() * 1.4,
          cross: rnd.nextDouble() < 0.35,
        ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restart();
  }

  @override
  void didUpdateWidget(StarField old) {
    super.didUpdateWidget(old);
    if (old.restartKey != widget.restartKey) _restart();
  }

  void _restart() {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _twinkle.value = 0;
    } else {
      _twinkle.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(painter: _StarPainter(_stars, _twinkle), size: Size.infinite),
    );
  }
}

class _Star {
  final Offset at;
  final double size;
  final double phase;
  final double speed;
  final bool cross;
  const _Star(this.at, {required this.size, required this.phase, required this.speed, required this.cross});
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final Animation<double> t;
  _StarPainter(this.stars, this.t) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    final time = t.value * 14;
    for (final s in stars) {
      // Fewer stars low down, where buttons sit.
      final y = s.at.dy * size.height * 0.85;
      final p = Offset(s.at.dx * size.width, y);
      final glow = 0.5 + 0.5 * math.sin(time * s.speed + s.phase);
      final alpha = (0.14 + 0.42 * glow) * (1 - s.at.dy * 0.6);
      final paint = Paint()
        ..color = TourColors.gold.withValues(alpha: alpha)
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round;
      if (s.cross) {
        final r = s.size * 1.6;
        canvas.drawLine(p.translate(-r, 0), p.translate(r, 0), paint);
        canvas.drawLine(p.translate(0, -r), p.translate(0, r), paint);
      } else {
        canvas.drawCircle(p, s.size * 0.42, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.stars != stars;
}

/// A burst of paper confetti that falls once.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key});

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> with SingleTickerProviderStateMixin {
  late final _fall = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));
  static final _pieces = _makePieces(90);

  static const _colors = [
    Color(0xFFE57A55),
    Color(0xFFF2B84B),
    Color(0xFF7FA98A),
    Color(0xFFF5EFE6),
    Color(0xFF8FB0C4),
    Color(0xFFD9B2A6),
  ];

  static List<_Piece> _makePieces(int n) {
    final rnd = math.Random(11);
    return [
      for (var i = 0; i < n; i++)
        _Piece(
          x: rnd.nextDouble(),
          delay: rnd.nextDouble() * 0.35,
          drift: (rnd.nextDouble() - 0.5) * 0.25,
          spin: (rnd.nextDouble() - 0.5) * 14,
          width: 5 + rnd.nextDouble() * 5,
          color: _colors[rnd.nextInt(_colors.length)],
        ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!(MediaQuery.maybeDisableAnimationsOf(context) ?? false) && _fall.isDismissed) _fall.forward();
  }

  @override
  void dispose() {
    _fall.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: _ConfettiPainter(_pieces, _fall), size: Size.infinite),
      ),
    );
  }
}

class _Piece {
  final double x;
  final double delay;
  final double drift;
  final double spin;
  final double width;
  final Color color;
  const _Piece({
    required this.x,
    required this.delay,
    required this.drift,
    required this.spin,
    required this.width,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final Animation<double> t;
  _ConfettiPainter(this.pieces, this.t) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    if (t.value == 0 || t.isCompleted) return;
    for (final p in pieces) {
      final local = ((t.value - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0 || local >= 1) continue;
      final y = -20 + Curves.easeIn.transform(local) * (size.height + 40);
      final x = (p.x + p.drift * local + math.sin(local * 9 + p.spin) * 0.02) * size.width;
      final fade = local > 0.8 ? (1 - local) / 0.2 : 1.0;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * local);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.width, height: p.width * 0.45),
          const Radius.circular(1),
        ),
        Paint()..color = p.color.withValues(alpha: fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}

/// Dinner plates stacking up, one for every new dish, as many as fit.
class PlateStack extends StatelessWidget {
  /// How many plates are stacked so far.
  final double plates;
  const PlateStack({super.key, required this.plates});

  @override
  Widget build(BuildContext context) =>
      ExcludeSemantics(child: CustomPaint(painter: _PlatePainter(plates), size: Size.infinite));
}

class _PlatePainter extends CustomPainter {
  final double plates;
  _PlatePainter(this.plates);

  @override
  void paint(Canvas canvas, Size size) {
    const plateH = 9.0;
    final width = math.min(size.width * 0.62, 230.0);
    final cx = size.width / 2;
    final fits = (size.height / plateH).floor() - 2;
    final count = math.min(plates, fits.toDouble());
    final whole = count.floor();
    for (var i = 0; i < whole + 1; i++) {
      final partial = i == whole ? count - whole : 1.0;
      if (partial <= 0) break;
      // The newest plate drops in from above.
      final drop = (1 - partial) * 40;
      final y = size.height - 4 - (i + 1) * plateH - drop;
      final wobble = math.sin(i * 1.7) * 3;
      final rect = Rect.fromCenter(center: Offset(cx + wobble, y), width: width, height: plateH * 2.1);
      final opacity = partial.clamp(0.0, 1.0);
      final shade = i.isEven ? const Color(0xFFEDE5D8) : const Color(0xFFE2D8C8);
      // Rim, then the well of the plate.
      canvas.drawOval(rect.shift(const Offset(0, 2)), Paint()..color = Colors.black.withValues(alpha: 0.35 * opacity));
      canvas.drawOval(rect, Paint()..color = shade.withValues(alpha: opacity));
      canvas.drawOval(
        rect.deflate(width * 0.12),
        Paint()
          ..color = const Color(0xFFC9BBA6).withValues(alpha: 0.55 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      canvas.drawOval(
        rect,
        Paint()
          ..color = TourColors.gold.withValues(alpha: 0.5 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(_PlatePainter old) => old.plates != plates;
}
