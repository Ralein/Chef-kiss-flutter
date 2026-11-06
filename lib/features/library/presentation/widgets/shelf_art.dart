import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/shelf_style.dart';

/// Painted art for the library: wall textures (kitchen surfaces among them),
/// shelf planks with LED glow, candles, potted plants, trailing ivy and vases
/// of flowers. Kitchen things live in kitchen_art.dart. Everything is
/// vector so it stays crisp at any size and follows the chosen style.

// --- Wall ----------------------------------------------------------------------------

class WallPainter extends CustomPainter {
  final WallStyle style;
  final Color tint;
  const WallPainter({required this.style, required this.tint});

  bool get _dark => tint.computeLuminance() < 0.25;

  Color _shade(Color c, double amount) =>
      amount >= 0 ? Color.lerp(c, Colors.white, amount)! : Color.lerp(c, Colors.black, -amount)!;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = tint);
    switch (style) {
      case WallStyle.subway:
        _subway(canvas, size);
      case WallStyle.zellige:
        _zellige(canvas, size);
      case WallStyle.steel:
        _steel(canvas, size);
      case WallStyle.fridge:
        _fridge(canvas, size);
      case WallStyle.pegboard:
        _pegboard(canvas, size);
      case WallStyle.chalkboard:
        _chalkboard(canvas, size);
      case WallStyle.plaster:
        _plaster(canvas, size);
      case WallStyle.brick:
        _brick(canvas, size);
      case WallStyle.panels:
        _panels(canvas, size);
      case WallStyle.linen:
        _linen(canvas, size);
    }
    // Vignette: darker corners, a softly lit middle.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.25),
          radius: 1.1,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: _dark ? 0.45 : 0.10),
          ],
          stops: const [0.45, 1],
        ).createShader(rect),
    );
  }

  /// Grout is lighter than dark tiles and darker than light ones.
  Color get _grout => _shade(tint, _dark ? 0.10 : -0.13);

  /// Classic kitchen backsplash: 2:1 bevelled tiles in a running bond.
  void _subway(Canvas canvas, Size size) {
    const tw = 58.0, th = 27.0, grout = 2.5;
    canvas.drawRect(Offset.zero & size, Paint()..color = _grout);
    final rnd = math.Random(23);
    final face = Paint();
    // One bevel shader in tile-local coordinates, reused for every tile.
    final local = Rect.fromLTWH(0, 0, tw - grout, th - grout);
    final bevel = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: _dark ? 0.10 : 0.55),
          Colors.white.withValues(alpha: 0),
          Colors.black.withValues(alpha: 0),
          Colors.black.withValues(alpha: _dark ? 0.32 : 0.10),
        ],
        stops: const [0, 0.22, 0.7, 1],
      ).createShader(local);
    final localTile = RRect.fromRectAndRadius(local, const Radius.circular(3));
    for (var row = 0; row * th < size.height + th; row++) {
      final offset = row.isOdd ? -tw / 2 : 0.0;
      for (var col = 0; col * tw + offset < size.width + tw; col++) {
        final left = col * tw + offset + grout / 2, top = row * th + grout / 2;
        face.color = _shade(tint, (_dark ? 0.05 : 0.03) + (rnd.nextDouble() - 0.5) * (_dark ? 0.05 : 0.025));
        canvas.save();
        canvas.translate(left, top);
        canvas.drawRRect(localTile, face);
        canvas.drawRRect(localTile, bevel);
        canvas.restore();
      }
    }
    _glaze(canvas, size, 0.05);
  }

  /// Hand-made square tiles: each glaze a little lighter or darker, warmer or
  /// cooler, with a soft shine.
  void _zellige(Canvas canvas, Size size) {
    const t = 34.0, grout = 2.0;
    canvas.drawRect(Offset.zero & size, Paint()..color = _grout);
    final rnd = math.Random(29);
    final face = Paint();
    final shine = Paint();
    const warm = Color(0xFF9A6E45), cool = Color(0xFF4B6E8E);
    for (var y = 0.0; y < size.height; y += t) {
      for (var x = 0.0; x < size.width; x += t) {
        final r = Rect.fromLTWH(x + grout / 2, y + grout / 2, t - grout, t - grout);
        final c = _shade(tint, (_dark ? 0.06 : 0.0) + (rnd.nextDouble() - 0.5) * (_dark ? 0.14 : 0.09));
        face.color = Color.lerp(c, rnd.nextBool() ? warm : cool, 0.03 + rnd.nextDouble() * 0.04)!;
        canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3.5)), face);
        // Glaze catches the light unevenly: a faint shine on some tiles only.
        final glint = rnd.nextDouble();
        if (glint < 0.55) {
          shine.color = Colors.white.withValues(alpha: (_dark ? 0.05 : 0.16) * (0.5 + glint));
          canvas.drawOval(
            Rect.fromLTWH(
              r.left + r.width * (0.1 + rnd.nextDouble() * 0.3),
              r.top + r.height * (0.08 + rnd.nextDouble() * 0.5),
              r.width * (0.25 + rnd.nextDouble() * 0.25),
              r.height * (0.12 + rnd.nextDouble() * 0.1),
            ),
            shine,
          );
        }
      }
    }
    _glaze(canvas, size, 0.04);
  }

  /// A broad diagonal sheen, as light catches glazed tiles.
  void _glaze(Canvas canvas, Size size, double strength) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: _dark ? strength : strength * 2),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0.25, 0.45, 0.65],
        ).createShader(rect),
    );
  }

  /// Brushed stainless panels, as on a freezer door or a restaurant kitchen
  /// wall, with screws at the corners.
  void _steel(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final metal = _dark
        ? Color.lerp(tint, const Color(0xFF7A8087), 0.26)!
        : Color.lerp(tint, const Color(0xFFC4C9CE), 0.6)!;
    canvas.drawRect(rect, Paint()..color = metal);
    // Brushing: broken horizontal hairlines.
    final rnd = math.Random(31);
    final hair = Paint()..strokeWidth = 1;
    for (var y = 0.5; y < size.height; y += 1.5) {
      var x = -rnd.nextDouble() * 120;
      while (x < size.width) {
        final length = 30 + rnd.nextDouble() * 200;
        final v = rnd.nextDouble() - 0.5;
        hair.color = (v > 0 ? Colors.white : Colors.black).withValues(alpha: v.abs() * (_dark ? 0.12 : 0.15));
        canvas.drawLine(Offset(x, y), Offset(x + length, y), hair);
        x += length + rnd.nextDouble() * 40;
      }
    }
    // Light sweeping across the metal.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: _dark ? 0.07 : 0.24),
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: _dark ? 0.04 : 0.14),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0.04, 0.27, 0.5, 0.74, 0.94],
        ).createShader(rect),
    );
    // Panel seams: a shadow line and a lit edge.
    const panelW = 168.0, panelH = 300.0;
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: _dark ? 0.55 : 0.24)
      ..strokeWidth = 1.5;
    final lit = Paint()
      ..color = Colors.white.withValues(alpha: _dark ? 0.08 : 0.55)
      ..strokeWidth = 1;
    for (var x = panelW; x < size.width; x += panelW) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), shadow);
      canvas.drawLine(Offset(x + 1.5, 0), Offset(x + 1.5, size.height), lit);
    }
    for (var y = panelH; y < size.height; y += panelH) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), shadow);
      canvas.drawLine(Offset(0, y + 1.5), Offset(size.width, y + 1.5), lit);
    }
    for (var left = 0.0; left < size.width; left += panelW) {
      for (var top = 0.0; top < size.height; top += panelH) {
        for (final c in [
          Offset(left + 10, top + 10),
          Offset(left + panelW - 10, top + 10),
          Offset(left + 10, top + panelH - 10),
          Offset(left + panelW - 10, top + panelH - 10),
        ]) {
          _screw(canvas, c, metal);
        }
      }
    }
  }

  void _screw(Canvas canvas, Offset c, Color metal) {
    const r = 2.6;
    canvas.drawCircle(c.translate(0.6, 0.8), r, Paint()..color = Colors.black.withValues(alpha: _dark ? 0.45 : 0.2));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          colors: [_shade(metal, 0.4), _shade(metal, -0.25)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawLine(
      c.translate(-1.6, 1.1),
      c.translate(1.6, -1.1),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..strokeWidth = 0.8,
    );
  }

  static const _magnetColors = [
    Color(0xFFD9483B),
    Color(0xFFE8B23A),
    Color(0xFF2F8F8A),
    Color(0xFF3B6CB5),
    Color(0xFF5AA05A),
  ];

  /// A retro fridge door: glossy enamel with a few magnets and notes on it.
  void _fridge(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = _shade(tint, _dark ? 0.05 : 0.03));
    // Gloss: soft vertical reflections in the enamel.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: _dark ? 0.07 : 0.42),
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: _dark ? 0.04 : 0.26),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0.06, 0.19, 0.33, 0.68, 0.79, 0.9],
        ).createShader(rect),
    );
    final rnd = math.Random(41);
    const cellW = 150.0, cellH = 210.0;
    for (var top = 0.0; top < size.height; top += cellH) {
      for (var left = 0.0; left < size.width; left += cellW) {
        final roll = rnd.nextDouble();
        final at = Offset(left + 22 + rnd.nextDouble() * (cellW - 44), top + 16 + rnd.nextDouble() * (cellH - 70));
        final color = _magnetColors[rnd.nextInt(_magnetColors.length)];
        if (roll < 0.3) {
          _note(canvas, at, color, rnd);
        } else if (roll < 0.55) {
          _magnet(canvas, at, color, 6 + rnd.nextDouble() * 2.5);
        }
      }
    }
  }

  /// A note held up by a magnet: a few lines of a shopping list.
  void _note(Canvas canvas, Offset at, Color magnet, math.Random rnd) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate((rnd.nextDouble() - 0.5) * 0.26);
    const paper = Rect.fromLTWH(-17, 0, 34, 42);
    canvas.drawRect(
      paper.shift(const Offset(1, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: _dark ? 0.4 : 0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    const papers = [Color(0xFFF7F1E3), Color(0xFFF3E6A6), Color(0xFFE3ECF0)];
    final color = papers[rnd.nextInt(papers.length)];
    canvas.drawRect(paper, Paint()..color = _dark ? Color.lerp(color, Colors.black, 0.3)! : color);
    final ink = Paint()
      ..color = const Color(0xFF5E5145).withValues(alpha: 0.6)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final y = 12.0 + i * 7;
      canvas.drawLine(Offset(-11, y), Offset(-11 + 10 + rnd.nextDouble() * 12, y), ink);
    }
    _magnet(canvas, const Offset(0, 2), magnet, 5.5);
    canvas.restore();
  }

  void _magnet(Canvas canvas, Offset c, Color color, double r) {
    canvas.drawCircle(
      c.translate(0.8, 1.8),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          colors: [Color.lerp(color, Colors.white, 0.45)!, color, Color.lerp(color, Colors.black, 0.3)!],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  /// Perforated hardboard, as hung over a workbench or a stove.
  void _pegboard(Canvas canvas, Size size) {
    const pitch = 22.0;
    canvas.drawRect(Offset.zero & size, Paint()..color = _shade(tint, _dark ? 0.05 : -0.02));
    final hole = Paint()..color = _shade(tint, _dark ? -0.6 : -0.4);
    final rim = Paint()
      ..color = Colors.white.withValues(alpha: _dark ? 0.08 : 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var y = pitch / 2; y < size.height; y += pitch) {
      for (var x = pitch / 2; x < size.width; x += pitch) {
        final c = Offset(x, y);
        canvas.drawCircle(c, 2.7, hole);
        // The lower edge of each hole catches the light.
        canvas.drawArc(Rect.fromCircle(center: c, radius: 3), 0.25, 2.2, false, rim);
      }
    }
  }

  /// A café chalkboard: clouds of chalk dust and the ghosts of old menus.
  void _chalkboard(Canvas canvas, Size size) {
    final chalk = _dark ? Colors.white : const Color(0xFF2E2B28);
    final rnd = math.Random(17);
    final clouds = (size.width * size.height / 26000).clamp(6, 60).toInt();
    for (var i = 0; i < clouds; i++) {
      final c = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
      canvas.drawOval(
        Rect.fromCenter(center: c, width: 120 + rnd.nextDouble() * 220, height: 36 + rnd.nextDouble() * 70),
        Paint()
          ..color = chalk.withValues(alpha: (_dark ? 0.03 : 0.035) + rnd.nextDouble() * 0.03)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
    }
    // Half-wiped writing: short wavy words in rows.
    final stroke = Paint()
      ..color = chalk.withValues(alpha: _dark ? 0.09 : 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final blocks = (size.width * size.height / 60000).clamp(3, 30).toInt();
    for (var b = 0; b < blocks; b++) {
      final origin = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
      for (var line = 0; line < 2 + rnd.nextInt(3); line++) {
        var x = origin.dx;
        final y = origin.dy + line * 18;
        for (var word = 0; word < 2 + rnd.nextInt(3); word++) {
          final length = 12 + rnd.nextDouble() * 30;
          final path = Path()..moveTo(x, y);
          for (var t = 4.0; t <= length; t += 4) {
            path.lineTo(x + t, y + math.sin(t * 0.9 + b) * 2.2);
          }
          canvas.drawPath(path, stroke);
          x += length + 8;
        }
      }
    }
  }

  void _plaster(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final light = Paint()..color = Colors.white.withValues(alpha: _dark ? 0.035 : 0.25);
    final dark = Paint()..color = Colors.black.withValues(alpha: _dark ? 0.12 : 0.035);
    final count = (size.width * size.height / 520).clamp(200, 6000).toInt();
    for (var i = 0; i < count; i++) {
      final p = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
      canvas.drawCircle(p, 0.6 + rnd.nextDouble() * 1.4, rnd.nextBool() ? light : dark);
    }
  }

  void _brick(Canvas canvas, Size size) {
    const bw = 74.0, bh = 26.0, mortar = 3.0;
    canvas.drawRect(Offset.zero & size, Paint()..color = _shade(tint, _dark ? -0.35 : -0.08));
    final rnd = math.Random(11);
    final brick = Paint();
    for (var row = 0; row * bh < size.height + bh; row++) {
      final offset = row.isOdd ? -bw / 2 : 0.0;
      for (var col = -1; col * bw + offset < size.width + bw; col++) {
        final r = Rect.fromLTWH(col * bw + offset + mortar / 2, row * bh + mortar / 2, bw - mortar, bh - mortar);
        brick.color = _shade(tint, (_dark ? 0.03 : 0.0) + (rnd.nextDouble() - 0.5) * (_dark ? 0.07 : 0.05));
        canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(2)), brick);
        // A faint top highlight gives each brick some depth.
        canvas.drawLine(
          r.topLeft + const Offset(2, 1),
          r.topRight + const Offset(-2, 1),
          Paint()
            ..color = Colors.white.withValues(alpha: _dark ? 0.04 : 0.2)
            ..strokeWidth = 1,
        );
      }
    }
  }

  void _panels(Canvas canvas, Size size) {
    const board = 56.0;
    final rnd = math.Random(5);
    for (var x = 0.0; x < size.width; x += board) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, board, size.height),
        Paint()..color = _shade(tint, (rnd.nextDouble() - 0.5) * (_dark ? 0.06 : 0.04)),
      );
      // Grain.
      final grain = Paint()
        ..color = (_dark ? Colors.black : Colors.brown).withValues(alpha: _dark ? 0.18 : 0.06)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      for (var g = 0; g < 4; g++) {
        final gx = x + 8 + rnd.nextDouble() * (board - 16);
        final path = Path()..moveTo(gx, 0);
        for (var y = 0.0; y < size.height; y += 40) {
          path.quadraticBezierTo(gx + (rnd.nextDouble() - 0.5) * 6, y + 20, gx + (rnd.nextDouble() - 0.5) * 3, y + 40);
        }
        canvas.drawPath(path, grain);
      }
      // Groove between boards.
      canvas.drawRect(
        Rect.fromLTWH(x, 0, 2, size.height),
        Paint()..color = Colors.black.withValues(alpha: _dark ? 0.45 : 0.12),
      );
      canvas.drawRect(
        Rect.fromLTWH(x + 2, 0, 1, size.height),
        Paint()..color = Colors.white.withValues(alpha: _dark ? 0.04 : 0.25),
      );
    }
  }

  void _linen(Canvas canvas, Size size) {
    final a = Paint()
      ..color = Colors.white.withValues(alpha: _dark ? 0.025 : 0.22)
      ..strokeWidth = 1;
    final b = Paint()
      ..color = Colors.black.withValues(alpha: _dark ? 0.10 : 0.035)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), y % 6 == 0 ? a : b);
    }
    for (var x = 0.0; x < size.width; x += 3) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), x % 6 == 0 ? b : a);
    }
  }

  @override
  bool shouldRepaint(WallPainter old) => old.style != style || old.tint != tint;
}

// --- Shelf plank & light ---------------------------------------------------------------

/// A wooden shelf board with a lighter front lip and, optionally, an LED
/// strip glowing along its underside.
class ShelfPlank extends StatelessWidget {
  final ShelfWood wood;
  final ShelfGlow glow;
  final double height;
  const ShelfPlank({super.key, required this.wood, required this.glow, this.height = 14});

  @override
  Widget build(BuildContext context) {
    final light = glow.color;
    return SizedBox(
      height: height + 3,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            bottom: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.lerp(wood.grain[0], Colors.white, 0.12)!, ...wood.grain],
                  stops: const [0, 0.18, 0.6, 1],
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
            ),
          ),
          if (light != null)
            Positioned(
              left: 6,
              right: 6,
              bottom: 2,
              height: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.lerp(light, Colors.white, 0.5),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(color: light.withValues(alpha: 0.85), blurRadius: 8, spreadRadius: 1),
                    BoxShadow(color: light.withValues(alpha: 0.35), blurRadius: 22, spreadRadius: 4),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The soft pool of light an LED strip throws onto the wall below a shelf.
class LightWash extends StatelessWidget {
  final ShelfGlow glow;
  final double height;
  const LightWash({super.key, required this.glow, this.height = 90});

  @override
  Widget build(BuildContext context) {
    final light = glow.color;
    if (light == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: SizedBox(
        height: height,
        // Fade the sides too, so the wash reads as light rather than a panel.
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) => const LinearGradient(
            colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
            stops: [0, 0.14, 0.86, 1],
          ).createShader(rect),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [light.withValues(alpha: 0.20), light.withValues(alpha: 0.06), Colors.transparent],
                stops: const [0, 0.35, 1],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Candles -----------------------------------------------------------------------------

enum CandleKind { pillar, tall, taper }

/// A candle with a warm glow on its surroundings. The flame flickers as the
/// candle comes into view, then settles: a library left open shouldn't keep
/// the screen redrawing. Still from the start when animations are off.
class Candle extends StatefulWidget {
  final CandleKind kind;
  final int seed;
  const Candle({super.key, required this.kind, this.seed = 0});

  static Size sizeOf(CandleKind kind, double scale) => switch (kind) {
    CandleKind.pillar => Size(22 * scale, 40 * scale),
    CandleKind.tall => Size(24 * scale, 62 * scale),
    CandleKind.taper => Size(11 * scale, 74 * scale),
  };

  @override
  State<Candle> createState() => _CandleState();
}

/// A taper and a pillar candle side by side, filling their box.
class CandlePair extends StatelessWidget {
  final int seed;
  const CandlePair({super.key, this.seed = 0});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: box.maxWidth * 0.25,
          height: box.maxHeight,
          child: Candle(kind: CandleKind.taper, seed: seed * 3 + 1),
        ),
        SizedBox(
          width: box.maxWidth * 0.5,
          height: box.maxHeight * 0.54,
          child: Candle(kind: CandleKind.pillar, seed: seed * 3 + 2),
        ),
      ],
    ),
  );
}

class _CandleState extends State<Candle> with SingleTickerProviderStateMixin {
  static const _burn = Duration(seconds: 6);
  late final AnimationController _flicker = AnimationController(vsync: this, duration: _burn);

  /// Flicker cycles over the burn; each candle keeps its own rhythm.
  late final double _cycles = _burn.inMilliseconds / (1700 + widget.seed % 5 * 230);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still) {
      _flicker.value = 1;
    } else if (_flicker.isDismissed) {
      _flicker.forward();
    }
  }

  @override
  void dispose() {
    _flicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _flicker,
          builder: (context, _) {
            final v = _flicker.value;
            // Full flicker for most of the burn, easing to a steady flame.
            final amp = 1 - Curves.easeIn.transform(((v - 0.55) / 0.45).clamp(0.0, 1.0));
            return CustomPaint(
              painter: _CandlePainter(kind: widget.kind, t: v * _cycles, amp: amp, phase: widget.seed * 0.37),
            );
          },
        ),
      ),
    );
  }
}

class _CandlePainter extends CustomPainter {
  final CandleKind kind;
  final double t;
  final double amp;
  final double phase;
  _CandlePainter({required this.kind, required this.t, required this.amp, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final bodyH = switch (kind) {
      CandleKind.pillar => h * 0.62,
      CandleKind.tall => h * 0.74,
      CandleKind.taper => h * 0.80,
    };
    final body = Rect.fromLTWH(0, h - bodyH, w, bodyH);
    final wave = math.sin((t + phase) * math.pi * 2) * amp;
    final wave2 = math.sin((t * 2.3 + phase) * math.pi * 2) * amp;
    final flameH = (kind == CandleKind.taper ? h * 0.15 : h * 0.24) * (1 + 0.08 * wave);
    final flameW = math.min(w * 0.42, 9.0) * (1 + 0.05 * wave2);
    final flameBase = Offset(w / 2 + wave2 * 0.6, body.top - 2);

    // Glow on everything around.
    final glowRadius = 46.0 + 4 * wave;
    canvas.drawCircle(
      flameBase.translate(0, -flameH * 0.5),
      glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFC46B).withValues(alpha: 0.32 + 0.04 * wave),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: flameBase.translate(0, -flameH * 0.5), radius: glowRadius)),
    );

    // Wax body: cylinder shading.
    final radius = kind == CandleKind.taper ? Radius.circular(w / 2) : const Radius.circular(3);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        body,
        topLeft: radius,
        topRight: radius,
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFCFC3AE), Color(0xFFF7F0E3), Color(0xFFE9DFCC), Color(0xFFC1B49D)],
          stops: [0, 0.35, 0.7, 1],
        ).createShader(body),
    );
    // Warm light falling on the top of the wax.
    canvas.drawRect(
      Rect.fromLTWH(body.left, body.top, body.width, math.min(10, bodyH * 0.3)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFFFE2B0).withValues(alpha: 0.75), Colors.transparent],
        ).createShader(Rect.fromLTWH(body.left, body.top, body.width, 10)),
    );
    if (kind != CandleKind.taper) {
      // Melted pool.
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w / 2, body.top + 1.5), width: w * 0.8, height: 3.5),
        Paint()..color = const Color(0xFFFFF6E3),
      );
    }
    // Wick.
    canvas.drawLine(
      Offset(w / 2, body.top + 1),
      Offset(w / 2, body.top - 3),
      Paint()
        ..color = const Color(0xFF2A1E14)
        ..strokeWidth = 1.2,
    );

    // Flame: a teardrop with a hot core.
    final flame = Path()
      ..moveTo(flameBase.dx, flameBase.dy)
      ..cubicTo(
        flameBase.dx - flameW,
        flameBase.dy - flameH * 0.35,
        flameBase.dx - flameW * 0.25,
        flameBase.dy - flameH * 0.8,
        flameBase.dx + wave * 0.8,
        flameBase.dy - flameH,
      )
      ..cubicTo(
        flameBase.dx + flameW * 0.25,
        flameBase.dy - flameH * 0.8,
        flameBase.dx + flameW,
        flameBase.dy - flameH * 0.35,
        flameBase.dx,
        flameBase.dy,
      )
      ..close();
    final flameRect = Rect.fromCenter(
      center: flameBase.translate(0, -flameH * 0.45),
      width: flameW * 2,
      height: flameH,
    );
    canvas.drawPath(
      flame,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, 0.45),
          radius: 0.9,
          colors: [Color(0xFFFFFFF2), Color(0xFFFFE08A), Color(0xFFFFA43A), Color(0x00FF7A00)],
          stops: [0, 0.35, 0.75, 1],
        ).createShader(flameRect),
    );
  }

  @override
  bool shouldRepaint(_CandlePainter old) => old.t != t || old.amp != amp || old.kind != kind;
}

// --- Plants ---------------------------------------------------------------------------------

/// A potted plant: ceramic pot and a fan of leaves. [seed] varies the leaves.
class PottedPlant extends StatelessWidget {
  final int seed;
  const PottedPlant({super.key, this.seed = 0});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: CustomPaint(painter: _PlantPainter(seed)));
}

class _PlantPainter extends CustomPainter {
  final int seed;
  _PlantPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rnd = math.Random(seed * 31 + 3);
    final potH = h * 0.32, potTop = h - potH;
    final potW = w * 0.62;
    final cx = w / 2;
    final soil = Offset(cx, potTop + 2);

    // Leaves (drawn first so the pot sits in front).
    const greens = [Color(0xFF3F6B35), Color(0xFF4F7F3F), Color(0xFF6A9A4D), Color(0xFF345C2D)];
    final leaves = 9 + rnd.nextInt(3);
    for (var i = 0; i < leaves; i++) {
      final spread = (i / (leaves - 1)) - 0.5; // -0.5 … 0.5
      final angle = -math.pi / 2 + spread * 2.1 + (rnd.nextDouble() - 0.5) * 0.25;
      final length = h * (0.42 + rnd.nextDouble() * 0.24) * (1 - spread.abs() * 0.35);
      final width = length * (0.26 + rnd.nextDouble() * 0.08);
      canvas.save();
      canvas.translate(soil.dx, soil.dy);
      canvas.rotate(angle + math.pi / 2);
      final leaf = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(width, -length * 0.45, 0, -length)
        ..quadraticBezierTo(-width, -length * 0.45, 0, 0)
        ..close();
      final color = greens[(i + seed) % greens.length];
      canvas.drawPath(
        leaf,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color.lerp(color, Colors.black, 0.25)!, color, Color.lerp(color, Colors.white, 0.15)!],
          ).createShader(Rect.fromLTWH(-width, -length, width * 2, length)),
      );
      canvas.drawLine(
        Offset.zero,
        Offset(0, -length * 0.9),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.18)
          ..strokeWidth = 0.8,
      );
      canvas.restore();
    }

    // Pot: tapered ceramic with a rim.
    final pot = Path()
      ..moveTo(cx - potW / 2, potTop)
      ..lineTo(cx + potW / 2, potTop)
      ..lineTo(cx + potW * 0.38, h)
      ..lineTo(cx - potW * 0.38, h)
      ..close();
    final potRect = Rect.fromLTWH(cx - potW / 2, potTop, potW, potH);
    canvas.drawPath(
      pot,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFBDB9B0), Color(0xFFF2F0EA), Color(0xFFDAD7CF), Color(0xFFA9A59C)],
          stops: [0, 0.38, 0.7, 1],
        ).createShader(potRect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - potW / 2 - 1.5, potTop - 1, potW + 3, 5), const Radius.circular(2)),
      Paint()..color = const Color(0xFFE9E6DF),
    );
  }

  @override
  bool shouldRepaint(_PlantPainter old) => old.seed != seed;
}

/// Ivy trailing down from the front of a shelf. Drawn from the top edge.
class TrailingIvy extends StatelessWidget {
  final int seed;
  const TrailingIvy({super.key, this.seed = 0});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(child: CustomPaint(painter: _IvyPainter(seed))),
  );
}

class _IvyPainter extends CustomPainter {
  final int seed;
  _IvyPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed * 17 + 1);
    const greens = [Color(0xFF3E6B33), Color(0xFF527F3E), Color(0xFF2F5628), Color(0xFF66914A)];
    final vines = 4 + rnd.nextInt(3);
    for (var v = 0; v < vines; v++) {
      final x0 = size.width * (0.1 + 0.8 * rnd.nextDouble());
      final length = size.height * (0.45 + rnd.nextDouble() * 0.55);
      final sway = (rnd.nextDouble() - 0.5) * 18;
      final vine = Path()
        ..moveTo(x0, 0)
        ..quadraticBezierTo(x0 + sway, length * 0.5, x0 + sway * 0.4, length);
      canvas.drawPath(
        vine,
        Paint()
          ..color = const Color(0xFF3B5A2C)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );
      // Leaves along the vine, alternating sides, smaller towards the tip.
      final metrics = vine.computeMetrics().first;
      for (var d = 4.0; d < metrics.length; d += 7 + rnd.nextDouble() * 4) {
        final tangent = metrics.getTangentForOffset(d)!;
        final side = (d ~/ 7).isEven ? 1.0 : -1.0;
        final s = 7.5 * (1 - d / metrics.length * 0.55) + rnd.nextDouble() * 2;
        canvas.save();
        canvas.translate(tangent.position.dx, tangent.position.dy);
        canvas.rotate(side * (0.7 + rnd.nextDouble() * 0.5));
        final leaf = Path()
          ..moveTo(0, 0)
          ..cubicTo(s * 0.9, s * 0.1, s * 0.9, s * 1.0, 0, s * 1.25)
          ..cubicTo(-s * 0.9, s * 1.0, -s * 0.9, s * 0.1, 0, 0)
          ..close();
        canvas.drawPath(leaf, Paint()..color = greens[(d ~/ 7 + v) % greens.length]);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_IvyPainter old) => old.seed != seed;
}

// --- Flowers --------------------------------------------------------------------------------

class FlowerVase extends StatelessWidget {
  final FlowerKind kind;
  final int seed;
  const FlowerVase({super.key, required this.kind, this.seed = 0});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: CustomPaint(painter: _FlowerPainter(kind, seed)));
}

class _FlowerPainter extends CustomPainter {
  final FlowerKind kind;
  final int seed;
  _FlowerPainter(this.kind, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rnd = math.Random(seed * 13 + kind.index);
    final vaseH = h * 0.38, vaseTop = h - vaseH, cx = w / 2;
    final vaseW = w * (kind == FlowerKind.daisies ? 0.5 : 0.46);
    final neck = Offset(cx, vaseTop + 4);

    // Stems and blooms.
    final blooms = switch (kind) {
      FlowerKind.hydrangeas => 3,
      FlowerKind.sunflowers => 3,
      _ => 6,
    };
    final heads = <Offset>[];
    for (var i = 0; i < blooms; i++) {
      final spread = blooms == 1 ? 0.0 : i / (blooms - 1) - 0.5;
      final head = Offset(
        cx + spread * w * 0.75 + (rnd.nextDouble() - 0.5) * 6,
        vaseTop - h * (0.28 + rnd.nextDouble() * 0.22) * (1 - spread.abs() * 0.4),
      );
      heads.add(head);
      canvas.drawPath(
        Path()
          ..moveTo(neck.dx + spread * 4, neck.dy)
          ..quadraticBezierTo(neck.dx + spread * w * 0.2, (neck.dy + head.dy) / 2, head.dx, head.dy),
        Paint()
          ..color = const Color(0xFF4C7A3A)
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke,
      );
    }
    for (final (i, head) in heads.indexed) {
      switch (kind) {
        case FlowerKind.roses:
          _rose(canvas, head, 7 + rnd.nextDouble() * 2, i);
        case FlowerKind.sunflowers:
          _sunflower(canvas, head, 10 + rnd.nextDouble() * 2);
        case FlowerKind.hydrangeas:
          _hydrangea(canvas, head, 12 + rnd.nextDouble() * 3, rnd);
        case FlowerKind.daisies:
          _daisy(canvas, head, 6 + rnd.nextDouble() * 1.5);
      }
    }

    // Glass vase (daisies get a jar).
    final vase = kind == FlowerKind.daisies
        ? (Path()..addRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(cx - vaseW / 2, vaseTop, vaseW, vaseH), const Radius.circular(4)),
          ))
        : (Path()
            ..moveTo(cx - vaseW * 0.22, vaseTop)
            ..lineTo(cx + vaseW * 0.22, vaseTop)
            ..quadraticBezierTo(cx + vaseW * 0.25, vaseTop + vaseH * 0.25, cx + vaseW / 2, vaseTop + vaseH * 0.55)
            ..quadraticBezierTo(cx + vaseW * 0.55, h, cx + vaseW * 0.3, h)
            ..lineTo(cx - vaseW * 0.3, h)
            ..quadraticBezierTo(cx - vaseW * 0.55, h, cx - vaseW / 2, vaseTop + vaseH * 0.55)
            ..quadraticBezierTo(cx - vaseW * 0.25, vaseTop + vaseH * 0.25, cx - vaseW * 0.22, vaseTop)
            ..close());
    final vaseRect = Rect.fromLTWH(cx - vaseW / 2, vaseTop, vaseW, vaseH);
    canvas.drawPath(
      vase,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFDDEBF0).withValues(alpha: 0.55),
            const Color(0xFFFFFFFF).withValues(alpha: 0.85),
            const Color(0xFFCADDE4).withValues(alpha: 0.6),
          ],
        ).createShader(vaseRect),
    );
    // Water line.
    canvas.drawLine(
      Offset(cx - vaseW * 0.36, vaseTop + vaseH * 0.5),
      Offset(cx + vaseW * 0.36, vaseTop + vaseH * 0.5),
      Paint()
        ..color = const Color(0xFF9FC3CC).withValues(alpha: 0.6)
        ..strokeWidth = 1,
    );
  }

  void _rose(Canvas canvas, Offset c, double r, int i) {
    final reds = [const Color(0xFFB3202E), const Color(0xFF8E1424), const Color(0xFFC52F3A)];
    canvas.drawCircle(c, r, Paint()..color = reds[i % reds.length]);
    final swirl = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 0.65), 0.4, 4.2, false, swirl);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 0.32), 2.0, 4.0, false, swirl);
  }

  void _sunflower(Canvas canvas, Offset c, double r) {
    final petal = Paint()..color = const Color(0xFFF2B51F);
    for (var a = 0.0; a < math.pi * 2; a += math.pi / 7) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(a);
      canvas.drawOval(Rect.fromCenter(center: Offset(r * 0.62, 0), width: r * 0.75, height: r * 0.32), petal);
      canvas.restore();
    }
    canvas.drawCircle(c, r * 0.42, Paint()..color = const Color(0xFF5A3A1E));
  }

  void _hydrangea(Canvas canvas, Offset c, double r, math.Random rnd) {
    const tones = [Color(0xFF7E95D6), Color(0xFF9C8BD8), Color(0xFFA9C1EC), Color(0xFF8AA3E0)];
    for (var i = 0; i < 26; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final d = math.sqrt(rnd.nextDouble()) * r;
      canvas.drawCircle(
        c + Offset(math.cos(a) * d, math.sin(a) * d * 0.85),
        2.6,
        Paint()..color = tones[i % tones.length],
      );
    }
  }

  void _daisy(Canvas canvas, Offset c, double r) {
    final petal = Paint()..color = const Color(0xFFF8F6F0);
    for (var a = 0.0; a < math.pi * 2; a += math.pi / 6) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(a);
      canvas.drawOval(Rect.fromCenter(center: Offset(r * 0.6, 0), width: r * 0.8, height: r * 0.3), petal);
      canvas.restore();
    }
    canvas.drawCircle(c, r * 0.32, Paint()..color = const Color(0xFFF2C53D));
  }

  @override
  bool shouldRepaint(_FlowerPainter old) => old.kind != kind || old.seed != seed;
}
