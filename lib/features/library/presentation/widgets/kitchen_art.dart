import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Kitchen things for the library shelves: a stoneware crock of spatulas,
/// whisks and spoons, a rail of hanging utensils, pantry jars, a cast-iron pot
/// and a cutting board. Vector like the rest of the shelf art, lit from the
/// upper left, and drawn to fill whatever box they are given.

/// Shading across something round: dark edges, a highlight left of centre.
Paint _round(Rect r, Color base, {double light = 0.22, double dark = 0.3}) => Paint()
  ..shader = LinearGradient(
    colors: [
      Color.lerp(base, Colors.black, dark)!,
      Color.lerp(base, Colors.white, light)!,
      base,
      Color.lerp(base, Colors.black, dark * 1.2)!,
    ],
    stops: const [0, 0.3, 0.62, 1],
  ).createShader(r);

void _contactShadow(Canvas canvas, Offset center, double width, double u) {
  canvas.drawOval(
    Rect.fromCenter(center: center, width: width, height: 4.5 * u),
    Paint()
      ..color = Colors.black.withValues(alpha: 0.38)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.6 * u),
  );
}

const _steel = Color(0xFFC3C8CD);
const _blackHandle = Color(0xFF2B2B2E);

// --- Utensil crock ----------------------------------------------------------------------

/// A stoneware crock holding a wooden spoon, a whisk, a slotted turner and a
/// wooden spatula.
class UtensilCrock extends StatelessWidget {
  final int seed;
  const UtensilCrock({super.key, this.seed = 0});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: CustomPaint(painter: _CrockPainter(seed)));
}

class _CrockPainter extends CustomPainter {
  final int seed;
  _CrockPainter(this.seed);

  static const _glazes = [
    (body: Color(0xFFE8E0CF), band: Color(0xFF3E5C7A)), // cream with blue bands
    (body: Color(0xFF8FA58E), band: Color(0xFF55705A)), // sage
    (body: Color(0xFFB8664A), band: Color(0xFF8A4632)), // terracotta
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final u = w / 54;
    final glaze = _glazes[seed % _glazes.length];
    final crockW = w * 0.8, crockH = h * 0.4;
    final cx = w / 2;
    final top = h - crockH;
    final rimH = crockW * 0.16;

    _contactShadow(canvas, Offset(cx, h - 1), crockW * 0.95, u);
    // The opening, behind the utensils.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, top), width: crockW * 0.94, height: rimH),
      Paint()..color = Color.lerp(glaze.body, Colors.black, 0.7)!,
    );

    final reach = top - h * 0.01;
    _woodenSpoon(canvas, Offset(cx - crockW * 0.2, top + 8 * u), -0.27, reach * 0.97, u);
    _whisk(canvas, Offset(cx - crockW * 0.05, top + 8 * u), -0.07, reach * 0.93, u);
    _turner(canvas, Offset(cx + crockW * 0.1, top + 8 * u), 0.13, reach * 0.88, u);
    _paddle(canvas, Offset(cx + crockW * 0.24, top + 8 * u), 0.3, reach * 0.8, u);

    // Body: slightly barrel-shaped.
    final body = Path()
      ..moveTo(cx - crockW / 2, top)
      ..cubicTo(cx - crockW * 0.56, top + crockH * 0.45, cx - crockW * 0.52, h - 2, cx - crockW * 0.42, h)
      ..lineTo(cx + crockW * 0.42, h)
      ..cubicTo(cx + crockW * 0.52, h - 2, cx + crockW * 0.56, top + crockH * 0.45, cx + crockW / 2, top)
      ..close();
    final bodyRect = Rect.fromLTWH(cx - crockW * 0.56, top, crockW * 1.12, crockH);
    canvas.drawPath(body, _round(bodyRect, glaze.body));
    canvas.save();
    canvas.clipPath(body);
    final band = Paint()
      ..color = glaze.band
      ..strokeWidth = math.max(1.2, crockH * 0.045);
    for (final f in [0.2, 0.29]) {
      final y = top + crockH * f;
      canvas.drawLine(Offset(bodyRect.left, y), Offset(bodyRect.right, y), band);
    }
    // Gloss.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - crockW * 0.31, top + crockH * 0.4, crockW * 0.08, crockH * 0.42),
        Radius.circular(3 * u),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
    canvas.restore();
    // Front lip of the rim.
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, top), width: crockW, height: rimH),
      0,
      math.pi,
      false,
      Paint()
        ..color = Color.lerp(glaze.body, Colors.white, 0.35)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * u,
    );
  }

  /// Draws [draw] in a frame standing at [base], leaning by [angle]; up is -y.
  void _leaning(Canvas canvas, Offset base, double angle, VoidCallback draw) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);
    draw();
    canvas.restore();
  }

  void _woodenSpoon(Canvas canvas, Offset base, double angle, double length, double u) {
    _leaning(canvas, base, angle, () {
      final neck = -length * 0.72;
      final hw = 4.2 * u;
      final handle = Rect.fromLTRB(-hw / 2, neck, hw / 2, 0);
      const wood = Color(0xFFC4925F);
      canvas.drawRRect(RRect.fromRectAndRadius(handle, Radius.circular(hw / 2)), _round(handle, wood));
      final bowl = Rect.fromCenter(center: Offset(0, neck - 8 * u), width: 12 * u, height: 19 * u);
      canvas.drawOval(bowl, _round(bowl, wood));
      canvas.drawOval(bowl.deflate(2.4 * u), Paint()..color = const Color(0xFF9E6E43).withValues(alpha: 0.5));
    });
  }

  void _whisk(Canvas canvas, Offset base, double angle, double length, double u) {
    _leaning(canvas, base, angle, () {
      final neck = -length * 0.46;
      final hw = 4.6 * u;
      final handle = Rect.fromLTRB(-hw / 2, neck, hw / 2, 0);
      canvas.drawRRect(RRect.fromRectAndRadius(handle, Radius.circular(hw / 2)), _round(handle, _steel, light: 0.4));
      _whiskWires(canvas, neck, -length, hw, u);
    });
  }

  void _turner(Canvas canvas, Offset base, double angle, double length, double u) {
    _leaning(canvas, base, angle, () {
      final neck = -length * 0.56;
      final hw = 4.8 * u;
      final handle = Rect.fromLTRB(-hw / 2, neck, hw / 2, 0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(handle, Radius.circular(hw / 2)),
        _round(handle, _blackHandle, light: 0.3),
      );
      final headBottom = neck - length * 0.08;
      canvas.drawRect(Rect.fromLTRB(-1.2 * u, headBottom, 1.2 * u, neck + 1), Paint()..color = const Color(0xFFAEB4BA));
      _slottedHead(canvas, Rect.fromLTRB(-8.5 * u, -length, 8.5 * u, headBottom), u, flip: false);
    });
  }

  void _paddle(Canvas canvas, Offset base, double angle, double length, double u) {
    _leaning(canvas, base, angle, () {
      final neck = -length * 0.66;
      final hw = 4.0 * u;
      const wood = Color(0xFFD8B184);
      final handle = Rect.fromLTRB(-hw / 2, neck, hw / 2, 0);
      canvas.drawRRect(RRect.fromRectAndRadius(handle, Radius.circular(hw / 2)), _round(handle, wood));
      final head = Path()
        ..moveTo(-hw / 2, neck + 2 * u)
        ..lineTo(-6.5 * u, neck - 6 * u)
        ..lineTo(-6.5 * u, -length + 3.5 * u)
        ..lineTo(6.5 * u, -length)
        ..lineTo(6.5 * u, neck - 6 * u)
        ..lineTo(hw / 2, neck + 2 * u)
        ..close();
      canvas.drawPath(head, _round(Rect.fromLTRB(-6.5 * u, -length, 6.5 * u, neck), wood));
    });
  }

  @override
  bool shouldRepaint(_CrockPainter old) => old.seed != seed;
}

/// Balloon whisk wires from [neck] to [tip] (either direction along y).
void _whiskWires(Canvas canvas, double neck, double tip, double handleWidth, double u) {
  final span = tip - neck; // negative when the whisk points up
  final bw = 10 * u;
  final dark = Paint()
    ..color = const Color(0xFF6E747B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4 * u;
  final light = Paint()
    ..color = const Color(0xFFF1F3F5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7 * u;
  for (final k in [1.0, 0.62, 0.26]) {
    final wire = Path()
      ..moveTo(-handleWidth * 0.3, neck)
      ..cubicTo(-bw * k * 1.15, neck + span * 0.38, -bw * k, tip - span * 0.04, 0, tip)
      ..cubicTo(bw * k, tip - span * 0.04, bw * k * 1.15, neck + span * 0.38, handleWidth * 0.3, neck);
    canvas.drawPath(wire, dark);
    canvas.drawPath(wire, light);
  }
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, neck), width: handleWidth * 1.3, height: 4 * u),
      Radius.circular(1.5 * u),
    ),
    Paint()..color = const Color(0xFF9DA3AA),
  );
}

/// A stainless turner head with three slots.
void _slottedHead(Canvas canvas, Rect head, double u, {required bool flip}) {
  final big = Radius.circular(5 * u), small = Radius.circular(3 * u);
  canvas.drawRRect(
    RRect.fromRectAndCorners(
      head,
      topLeft: flip ? big : small,
      topRight: flip ? big : small,
      bottomLeft: flip ? small : big,
      bottomRight: flip ? small : big,
    ),
    _round(head, _steel, light: 0.4, dark: 0.25),
  );
  final slot = Paint()..color = const Color(0xFF5E646B);
  for (final x in [-4.0, 0.0, 4.0]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x * u, head.center.dy), width: 1.6 * u, height: head.height * 0.55),
        Radius.circular(0.8 * u),
      ),
      slot,
    );
  }
}

// --- Hanging rail -----------------------------------------------------------------------

/// A steel rail screwed under a shelf, with a ladle, a turner, a whisk and a
/// wooden spoon hanging from S-hooks.
class HangingUtensils extends StatelessWidget {
  final int seed;
  const HangingUtensils({super.key, this.seed = 0});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(child: CustomPaint(painter: _RailPainter(seed))),
  );
}

class _RailPainter extends CustomPainter {
  final int seed;
  _RailPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final u = w / 128;
    final railY = 7 * u;
    final bracket = Paint()..color = const Color(0xFF3A3A3D);
    for (final x in [9 * u, w - 9 * u]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, railY / 2), width: 3.5 * u, height: railY + 2 * u),
          Radius.circular(1.5 * u),
        ),
        bracket,
      );
    }
    final rail = Rect.fromLTRB(4 * u, railY - 1.8 * u, w - 4 * u, railY + 1.8 * u);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rail, Radius.circular(1.8 * u)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0F2F4), Color(0xFF9EA4AA), Color(0xFF6C7278)],
        ).createShader(rail),
    );

    final rnd = math.Random(seed * 7 + 5);
    final tools = <void Function(Canvas, double, double)>[_ladle, _turner, _whisk, _spoon];
    final start = seed % tools.length;
    final hook = Paint()
      ..color = const Color(0xFF4A4E53)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3 * u
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < tools.length; i++) {
      final x = w * (0.17 + 0.66 * i / (tools.length - 1));
      final hookBottom = railY + 10 * u;
      // S-hook: over the rail, down, and a curl to hang from.
      canvas.drawPath(
        Path()
          ..moveTo(x + 2.5 * u, railY + 1.5 * u)
          ..quadraticBezierTo(x + 2.5 * u, railY - 3.5 * u, x, railY - 3.5 * u)
          ..quadraticBezierTo(x - 2.5 * u, railY - 3.5 * u, x - 1 * u, railY + 1 * u)
          ..lineTo(x, hookBottom - 2 * u)
          ..quadraticBezierTo(x, hookBottom + 1 * u, x + 2.5 * u, hookBottom),
        hook,
      );
      canvas.save();
      canvas.translate(x, hookBottom - 1 * u);
      canvas.rotate((rnd.nextDouble() - 0.5) * 0.12);
      tools[(start + i) % tools.length](canvas, h - hookBottom - 1 * u, u);
      canvas.restore();
    }
  }

  void _ladle(Canvas canvas, double length, double u) {
    final handle = Rect.fromLTRB(-1.7 * u, 0, 1.7 * u, length * 0.76);
    canvas.drawRRect(RRect.fromRectAndRadius(handle, Radius.circular(1.7 * u)), _round(handle, _steel, light: 0.4));
    canvas.drawCircle(Offset(0, 2.6 * u), 1 * u, Paint()..color = const Color(0xFF3E4246));
    final bowl = Rect.fromCenter(center: Offset(0, length * 0.76), width: 21 * u, height: 22 * u);
    canvas.drawPath(Path()..addArc(bowl, 0, math.pi), _round(bowl, _steel, light: 0.45));
    canvas.drawLine(
      Offset(bowl.left, bowl.center.dy),
      Offset(bowl.right, bowl.center.dy),
      Paint()
        ..color = const Color(0xFF8C9298)
        ..strokeWidth = 1.4 * u,
    );
  }

  void _turner(Canvas canvas, double length, double u) {
    final handleEnd = length * 0.52;
    final handle = Rect.fromLTRB(-2.4 * u, 0, 2.4 * u, handleEnd);
    canvas.drawRRect(RRect.fromRectAndRadius(handle, Radius.circular(2.4 * u)), _round(handle, _blackHandle, light: 0.3));
    canvas.drawCircle(Offset(0, 3 * u), 1.1 * u, Paint()..color = const Color(0xFF0E0E0F));
    final neckEnd = length * 0.6;
    canvas.drawRect(Rect.fromLTRB(-1.1 * u, handleEnd - 1, 1.1 * u, neckEnd + 1), Paint()..color = const Color(0xFFAEB4BA));
    _slottedHead(canvas, Rect.fromLTRB(-9 * u, neckEnd, 9 * u, length * 0.96), u, flip: true);
  }

  void _whisk(Canvas canvas, double length, double u) {
    final neck = length * 0.4;
    final hw = 4.4 * u;
    final handle = Rect.fromLTRB(-hw / 2, 0, hw / 2, neck);
    canvas.drawRRect(RRect.fromRectAndRadius(handle, Radius.circular(hw / 2)), _round(handle, _steel, light: 0.4));
    canvas.drawCircle(Offset(0, 2.6 * u), 1 * u, Paint()..color = const Color(0xFF3E4246));
    _whiskWires(canvas, neck, length * 0.95, hw, u);
  }

  void _spoon(Canvas canvas, double length, double u) {
    const wood = Color(0xFFC4925F);
    final neck = length * 0.7;
    final handle = Rect.fromLTRB(-2.1 * u, 0, 2.1 * u, neck);
    canvas.drawRRect(RRect.fromRectAndRadius(handle, Radius.circular(2.1 * u)), _round(handle, wood));
    canvas.drawCircle(Offset(0, 3 * u), 1 * u, Paint()..color = const Color(0xFF5A3A22));
    final bowl = Rect.fromCenter(center: Offset(0, neck + 8 * u), width: 12 * u, height: 18 * u);
    canvas.drawOval(bowl, _round(bowl, wood));
    canvas.drawOval(bowl.deflate(2.4 * u), Paint()..color = const Color(0xFF9E6E43).withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(_RailPainter old) => old.seed != seed;
}

// --- Pantry jars ------------------------------------------------------------------------

/// Three glass jars with wooden lids: pasta, red lentils and flour.
class PantryJars extends StatelessWidget {
  final int seed;
  const PantryJars({super.key, this.seed = 0});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: CustomPaint(painter: _JarsPainter(seed)));
}

class _JarsPainter extends CustomPainter {
  final int seed;
  _JarsPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final u = w / 80;
    final jars = [
      (left: 0.0, width: 25 * u, height: h * 0.97, fill: 0.78),
      (left: 27.5 * u, width: 29 * u, height: h * 0.68, fill: 0.7),
      (left: 59 * u, width: 21 * u, height: h * 0.5, fill: 0.84),
    ];
    for (final (i, j) in jars.indexed) {
      _jar(canvas, Rect.fromLTWH(j.left, h - j.height, j.width, j.height), j.fill, (i + seed) % 3, u);
    }
  }

  void _jar(Canvas canvas, Rect r, double fill, int contents, double u) {
    final lidH = math.min(9 * u, r.height * 0.14);
    final body = Rect.fromLTRB(r.left, r.top + lidH, r.right, r.bottom);
    final glass = RRect.fromRectAndRadius(body, Radius.circular(4 * u));
    _contactShadow(canvas, Offset(r.center.dx, r.bottom - 0.5 * u), r.width * 1.05, u);

    final inside = Rect.fromLTRB(body.left + 2 * u, body.bottom - body.height * fill, body.right - 2 * u, body.bottom - 2 * u);
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(inside, Radius.circular(2.5 * u)));
    switch (contents) {
      case 0:
        _pasta(canvas, inside, u);
      case 1:
        _lentils(canvas, inside, u);
      default:
        _flour(canvas, inside, u);
    }
    canvas.restore();

    // Glass: a faint body, an outline and a highlight streak.
    canvas.drawRRect(glass, Paint()..color = Colors.white.withValues(alpha: 0.07));
    canvas.drawRRect(
      glass,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 * u,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(body.left + body.width * 0.16, body.top + 4 * u, 2.4 * u, body.height * 0.7),
        Radius.circular(1.2 * u),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.42),
    );
    // A kraft label on the taller jars.
    if (body.height > 42 * u) {
      final label = Rect.fromCenter(
        center: Offset(body.center.dx, body.top + body.height * 0.34),
        width: body.width * 0.62,
        height: math.min(11 * u, body.height * 0.18),
      );
      canvas.drawRect(label, Paint()..color = const Color(0xFFE4D3B5));
      canvas.drawLine(
        Offset(label.left + 3 * u, label.center.dy),
        Offset(label.right - 3 * u, label.center.dy),
        Paint()
          ..color = const Color(0xFF7A6348)
          ..strokeWidth = 1 * u,
      );
    }
    // Wooden lid.
    final lid = Rect.fromLTRB(r.left - 0.5 * u, r.top, r.right + 0.5 * u, r.top + lidH);
    canvas.drawRRect(RRect.fromRectAndRadius(lid, Radius.circular(2.5 * u)), _round(lid, const Color(0xFFC59A6B)));
  }

  void _pasta(Canvas canvas, Rect r, double u) {
    canvas.drawRect(r, Paint()..color = const Color(0xFFE2BC63));
    final rnd = math.Random(3);
    final tube = Paint()
      ..color = const Color(0xFFBF913A)
      ..strokeWidth = 1.5 * u
      ..strokeCap = StrokeCap.round;
    final count = (r.width * r.height / (26 * u * u)).round();
    for (var i = 0; i < count; i++) {
      final p = Offset(r.left + rnd.nextDouble() * r.width, r.top + rnd.nextDouble() * r.height);
      final a = rnd.nextDouble() * math.pi;
      final d = Offset(math.cos(a), math.sin(a)) * 3.2 * u;
      canvas.drawLine(p - d, p + d, tube);
    }
  }

  void _lentils(Canvas canvas, Rect r, double u) {
    canvas.drawRect(r, Paint()..color = const Color(0xFFB2552F));
    final rnd = math.Random(4);
    final light = Paint()..color = const Color(0xFFD27A4A);
    final dark = Paint()..color = const Color(0xFF8A3E22);
    final count = (r.width * r.height / (7 * u * u)).round();
    for (var i = 0; i < count; i++) {
      canvas.drawCircle(
        Offset(r.left + rnd.nextDouble() * r.width, r.top + rnd.nextDouble() * r.height),
        1.1 * u,
        rnd.nextBool() ? light : dark,
      );
    }
  }

  void _flour(Canvas canvas, Rect r, double u) {
    canvas.drawRect(r, Paint()..color = const Color(0xFFEDE7DB));
    canvas.drawRect(Rect.fromLTWH(r.left, r.top, r.width, 4 * u), Paint()..color = const Color(0xFFFAF7F1));
  }

  @override
  bool shouldRepaint(_JarsPainter old) => old.seed != seed;
}

// --- Cast-iron pot ----------------------------------------------------------------------

/// An enamelled cast-iron pot with its lid on.
class DutchOven extends StatelessWidget {
  final int seed;
  const DutchOven({super.key, this.seed = 0});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: CustomPaint(painter: _PotPainter(seed)));
}

class _PotPainter extends CustomPainter {
  final int seed;
  _PotPainter(this.seed);

  static const _enamels = [Color(0xFFD9542B), Color(0xFFB32A30), Color(0xFF5F7F6A), Color(0xFF2F4B6E)];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final u = w / 92;
    final enamel = _enamels[seed % _enamels.length];
    final deep = Color.lerp(enamel, Colors.black, 0.35)!;
    _contactShadow(canvas, Offset(w / 2, h - 1 * u), w * 0.86, u);

    final bodyTop = h * 0.44;
    for (final x in [1 * u, w - 13 * u]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, bodyTop + 3 * u, 12 * u, 7 * u), Radius.circular(3.5 * u)),
        Paint()..color = deep,
      );
    }
    final body = Rect.fromLTRB(8 * u, bodyTop, w - 8 * u, h - 1 * u);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        body,
        topLeft: Radius.circular(3 * u),
        topRight: Radius.circular(3 * u),
        bottomLeft: Radius.circular(12 * u),
        bottomRight: Radius.circular(12 * u),
      ),
      _round(body, enamel, light: 0.28),
    );
    canvas.drawRect(Rect.fromLTRB(body.left, bodyTop, body.right, bodyTop + 4 * u), Paint()..color = deep);

    // Lid: a low dome with a steel knob.
    final lidRect = Rect.fromLTRB(7 * u, h * 0.22, w - 7 * u, bodyTop + 1 * u);
    final lid = Path()
      ..moveTo(lidRect.left, lidRect.bottom)
      ..quadraticBezierTo(lidRect.left + 2 * u, lidRect.top + 2 * u, w / 2, lidRect.top)
      ..quadraticBezierTo(lidRect.right - 2 * u, lidRect.top + 2 * u, lidRect.right, lidRect.bottom)
      ..close();
    canvas.drawPath(lid, _round(lidRect, enamel, light: 0.3));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(lidRect.left - 1 * u, lidRect.bottom - 3 * u, lidRect.right + 1 * u, lidRect.bottom + 1 * u),
        Radius.circular(2 * u),
      ),
      Paint()..color = Color.lerp(enamel, Colors.black, 0.2)!,
    );
    final knob = Rect.fromCenter(center: Offset(w / 2, lidRect.top - 2.5 * u), width: 14 * u, height: 7 * u);
    canvas.drawRRect(RRect.fromRectAndRadius(knob, Radius.circular(3 * u)), _round(knob, _steel, light: 0.45));
    canvas.drawArc(
      Rect.fromLTRB(lidRect.left + 10 * u, lidRect.top + 3 * u, lidRect.right - 10 * u, lidRect.bottom + 16 * u),
      math.pi * 1.12,
      math.pi * 0.3,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * u
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_PotPainter old) => old.seed != seed;
}

// --- Cutting board ----------------------------------------------------------------------

/// A wooden cutting board leaning against the wall.
class CuttingBoard extends StatelessWidget {
  final int seed;
  const CuttingBoard({super.key, this.seed = 0});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: CustomPaint(painter: _BoardPainter(seed)));
}

class _BoardPainter extends CustomPainter {
  final int seed;
  _BoardPainter(this.seed);

  static const _woods = [Color(0xFFC9A06A), Color(0xFF8A5C3A)];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final u = w / 48;
    final wood = _woods[seed % _woods.length];
    _contactShadow(canvas, Offset(w / 2, h - 1 * u), w * 0.8, u);

    canvas.save();
    canvas.translate(w / 2, h);
    canvas.rotate(-0.07); // leaning back against the wall
    final bw = w * 0.78, boardH = h * 0.96;
    final handleW = bw * 0.42, handleH = boardH * 0.22;
    final board = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-bw / 2, -boardH + handleH * 0.85, bw, boardH - handleH * 0.85),
          Radius.circular(7 * u),
        ),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-handleW / 2, -boardH, handleW, handleH + 4 * u),
          Radius.circular(handleW / 2),
        ),
      );
    final hole = Path()..addOval(Rect.fromCircle(center: Offset(0, -boardH + handleH * 0.42), radius: handleW * 0.2));
    final shape = Path.combine(PathOperation.difference, board, hole);
    final bounds = Rect.fromLTWH(-bw / 2, -boardH, bw, boardH);
    canvas.drawPath(shape, _round(bounds, wood, light: 0.18, dark: 0.22));

    canvas.save();
    canvas.clipPath(shape);
    final rnd = math.Random(seed * 3 + 1);
    final grain = Paint()
      ..color = Color.lerp(wood, Colors.black, 0.35)!.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * u;
    for (var i = 0; i < 6; i++) {
      final x = -bw / 2 + bw * (0.12 + 0.76 * i / 5);
      double sway() => (rnd.nextDouble() - 0.5) * 6 * u;
      canvas.drawPath(
        Path()
          ..moveTo(x, -boardH)
          ..cubicTo(x + sway(), -boardH * 0.66, x + sway(), -boardH * 0.33, x + sway() / 2, 0),
        grain,
      );
    }
    canvas.restore();
    canvas.drawPath(
      shape,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 * u,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BoardPainter old) => old.seed != seed;
}
