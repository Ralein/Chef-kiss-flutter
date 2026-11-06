import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Kitchen things for the library shelves: a stoneware crock of utensils, a
/// rail of hanging utensils, pantry jars, a cast-iron pot, a kettle, oil and
/// vinegar, a mortar and pestle and a pot of basil. Vector like the rest of
/// the shelf art, lit from the upper left, and drawn to fill whatever box
/// they are given.

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
const _beech = Color(0xFFCB9866);
const _olive = Color(0xFFB98A5A);

// --- Utensils ---------------------------------------------------------------------------
//
// Each tool is drawn along the y axis, from the end of its handle at 0 to the
// far end of its head at [d] × length: up (d = -1) standing in a crock, down
// (d = 1) hanging from a rail.

/// A rod tapering from [w0] at [y0] to [w1] at [y1], with rounded ends.
void _rod(Canvas canvas, double y0, double y1, double w0, double w1, Color color, {double light = 0.3}) {
  final half = math.max(w0, w1) / 2;
  final bounds = Rect.fromLTRB(-half, math.min(y0, y1), half, math.max(y0, y1));
  final paint = _round(bounds, color, light: light);
  canvas.drawPath(
    Path()
      ..moveTo(-w0 / 2, y0)
      ..lineTo(-w1 / 2, y1)
      ..lineTo(w1 / 2, y1)
      ..lineTo(w0 / 2, y0)
      ..close()
      ..addOval(Rect.fromCircle(center: Offset(0, y0), radius: w0 / 2))
      ..addOval(Rect.fromCircle(center: Offset(0, y1), radius: w1 / 2)),
    paint,
  );
}

/// The ring a hanging tool hangs by.
void _hangingHole(Canvas canvas, double u, Color around) {
  canvas.drawCircle(Offset(0, 3 * u), 1.4 * u, Paint()..color = Color.lerp(around, Colors.black, 0.65)!);
}

void _woodenSpoon(Canvas canvas, double length, double u, double d, {bool hanging = false}) {
  final neck = length - 18 * u;
  _rod(canvas, 0, d * neck, 4.8 * u, 3.4 * u, _beech, light: 0.2);
  // A darker grain line down the handle.
  canvas.drawLine(
    Offset(0.6 * u, d * 4 * u),
    Offset(0.3 * u, d * (neck - 2 * u)),
    Paint()
      ..color = const Color(0xFF9C6B40).withValues(alpha: 0.5)
      ..strokeWidth = 0.7 * u,
  );
  if (hanging) _hangingHole(canvas, u, _beech);
  final center = Offset(0, d * (length - 9 * u));
  final bowl = Rect.fromCenter(center: center, width: 12.5 * u, height: 18 * u);
  canvas.drawOval(bowl, _round(bowl, _beech, light: 0.2));
  // The hollow of the bowl, deeper towards the tip.
  canvas.drawOval(
    Rect.fromCenter(center: center.translate(0.5 * u, d * 1.2 * u), width: 8.4 * u, height: 12.6 * u),
    Paint()..color = const Color(0xFF8E5D35).withValues(alpha: 0.55),
  );
  canvas.drawOval(
    Rect.fromCenter(center: center.translate(-2.3 * u, d * 2 * u), width: 2 * u, height: 5.4 * u),
    Paint()..color = Colors.white.withValues(alpha: 0.32),
  );
}

void _whisk(Canvas canvas, double length, double u, double d, {bool hanging = false}) {
  final neck = length * 0.42;
  _rod(canvas, 0, d * neck, 5.4 * u, 4.6 * u, _steel, light: 0.45);
  if (hanging) _hangingHole(canvas, u, _steel);
  final tip = d * length;
  final from = d * (neck + 1.5 * u);
  final span = tip - from;
  final bw = 19.5 * u;
  // A faint body first, so the balloon reads as a shape at a glance.
  final outline = Path()
    ..moveTo(-1.8 * u, from)
    ..cubicTo(-bw * 0.62, from + span * 0.32, -bw * 0.55, tip - span * 0.02, 0, tip)
    ..cubicTo(bw * 0.55, tip - span * 0.02, bw * 0.62, from + span * 0.32, 1.8 * u, from)
    ..close();
  canvas.drawPath(outline, Paint()..color = const Color(0xFFDDE2E7).withValues(alpha: 0.16));
  final dark = Paint()
    ..color = const Color(0xFF5F666D)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5 * u;
  final bright = Paint()
    ..color = const Color(0xFFF4F6F8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.75 * u;
  for (final k in [1.0, 0.68, 0.34]) {
    final wire = Path()
      ..moveTo(-1.6 * u * k, from)
      ..cubicTo(-bw * 0.62 * k, from + span * 0.32, -bw * 0.55 * k, tip - span * 0.02, 0, tip)
      ..cubicTo(bw * 0.55 * k, tip - span * 0.02, bw * 0.62 * k, from + span * 0.32, 1.6 * u * k, from);
    canvas.drawPath(wire, dark);
    canvas.drawPath(wire, bright);
  }
  // The collar where the wires meet the handle.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, d * neck), width: 6.4 * u, height: 3.6 * u),
      Radius.circular(1.4 * u),
    ),
    _round(Rect.fromCenter(center: Offset(0, d * neck), width: 6.4 * u, height: 3.6 * u), _steel, light: 0.5),
  );
}

void _turner(Canvas canvas, double length, double u, double d, {bool hanging = false}) {
  final handleEnd = length * 0.5;
  _rod(canvas, 0, d * handleEnd, 5.6 * u, 5 * u, _blackHandle, light: 0.32);
  for (final y in [0.2, 0.36]) {
    canvas.drawCircle(Offset(0, d * length * y), 0.9 * u, Paint()..color = const Color(0xFFB9BEC3));
  }
  if (hanging) _hangingHole(canvas, u, _blackHandle);
  final headStart = length * 0.62;
  _rod(canvas, d * (handleEnd - 1 * u), d * (headStart + 1 * u), 2.6 * u, 3.4 * u, const Color(0xFFAEB4BA));
  // Head: wider at the working edge, with four slots.
  final near = d * headStart, far = d * length;
  final head = Path()
    ..moveTo(-6 * u, near)
    ..lineTo(-8.4 * u, far - d * 3 * u)
    ..quadraticBezierTo(-8.4 * u, far, -5.4 * u, far)
    ..lineTo(5.4 * u, far)
    ..quadraticBezierTo(8.4 * u, far, 8.4 * u, far - d * 3 * u)
    ..lineTo(6 * u, near)
    ..close();
  final bounds = Rect.fromLTRB(-8.4 * u, math.min(near, far), 8.4 * u, math.max(near, far));
  final slots = Path();
  final slotH = (far - near).abs() * 0.56;
  for (final x in [-4.5, -1.5, 1.5, 4.5]) {
    slots.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x * u * 1.02, (near + far) / 2 + d * 0.8 * u), width: 1.5 * u, height: slotH),
        Radius.circular(0.75 * u),
      ),
    );
  }
  canvas.drawPath(Path.combine(PathOperation.difference, head, slots), _round(bounds, _steel, light: 0.45, dark: 0.22));
  // The bevelled working edge catches the light.
  canvas.drawLine(
    Offset(-5.2 * u, far - d * 0.6 * u),
    Offset(5.2 * u, far - d * 0.6 * u),
    Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 0.8 * u,
  );
}

void _siliconeSpatula(Canvas canvas, double length, double u, double d, Color head) {
  final neck = length * 0.62;
  _rod(canvas, 0, d * neck, 4.6 * u, 3.8 * u, _olive, light: 0.2);
  final near = d * (neck - 3 * u), far = d * length;
  final blade = RRect.fromRectAndCorners(
    Rect.fromLTRB(-6.4 * u, math.min(near, far), 6.4 * u, math.max(near, far)),
    topLeft: Radius.circular((d < 0 ? 6 : 2.5) * u),
    topRight: Radius.circular((d < 0 ? 3 : 2.5) * u),
    bottomLeft: Radius.circular((d < 0 ? 2.5 : 6) * u),
    bottomRight: Radius.circular((d < 0 ? 2.5 : 3) * u),
  );
  canvas.drawRRect(blade, _round(blade.outerRect, head, light: 0.18, dark: 0.22));
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(-4.2 * u, blade.top + 3 * u, 1.6 * u, blade.height - 6 * u),
      Radius.circular(0.8 * u),
    ),
    Paint()..color = Colors.white.withValues(alpha: 0.22),
  );
}

/// A ladle hanging by its hooked end: long handle, deep round bowl.
void _ladle(Canvas canvas, double length, double u) {
  final bowlDepth = 12 * u, bowlW = 22 * u;
  final rimY = length - bowlDepth;
  _rod(canvas, 0, rimY - 1 * u, 4.4 * u, 3.6 * u, _steel, light: 0.45);
  _hangingHole(canvas, u, _steel);
  final bowl = Rect.fromLTRB(-bowlW / 2, rimY - bowlDepth, bowlW / 2, length);
  canvas.drawPath(Path()..addArc(bowl, 0, math.pi), _round(bowl, _steel, light: 0.5, dark: 0.26));
  // Looking slightly down into it: the inside, then the rolled rim.
  final rim = Rect.fromCenter(center: Offset(0, rimY), width: bowlW, height: 6 * u);
  canvas.drawOval(rim, Paint()..color = const Color(0xFF7D848B));
  canvas.drawOval(
    rim.deflate(1.2 * u),
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF5B6168), Color(0xFFB4BAC0)],
      ).createShader(rim),
  );
  canvas.drawOval(
    rim,
    Paint()
      ..color = const Color(0xFFE9ECEF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9 * u,
  );
  canvas.drawArc(
    bowl.deflate(3 * u),
    math.pi * 0.62,
    math.pi * 0.22,
    false,
    Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * u
      ..strokeCap = StrokeCap.round,
  );
}

// --- Utensil crock ----------------------------------------------------------------------

/// A stoneware crock holding a wooden spoon, a balloon whisk, a slotted
/// turner and a silicone spatula.
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
  static const _silicone = [Color(0xFFD0503C), Color(0xFF3E8F8B), Color(0xFFE0A53A)];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final u = w / 54;
    final glaze = _glazes[seed % _glazes.length];
    final crockW = 44 * u, crockH = 46 * u;
    final cx = w / 2;
    final top = h - crockH;
    final rimH = 8 * u;
    final base = top + 10 * u;

    _contactShadow(canvas, Offset(cx, h - 1), crockW * 0.95, u);
    // Inside the mouth, behind the utensils.
    final mouth = Rect.fromCenter(center: Offset(cx, top), width: crockW * 0.94, height: rimH);
    canvas.drawOval(
      mouth,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(glaze.body, Colors.black, 0.45)!, Color.lerp(glaze.body, Colors.black, 0.8)!],
        ).createShader(mouth),
    );

    void stand(double dx, double angle, void Function() draw) {
      canvas.save();
      canvas.translate(cx + dx * u, base);
      canvas.rotate(angle);
      draw();
      canvas.restore();
    }

    // Back to front.
    stand(-1, -0.03, () => _whisk(canvas, base - 2 * u, u, -1));
    stand(4, 0.14, () => _turner(canvas, base - 13 * u, u, -1));
    stand(-8, -0.17, () => _woodenSpoon(canvas, base - 7 * u, u, -1));
    stand(10, 0.22, () => _siliconeSpatula(canvas, base - 25 * u, u, -1, _silicone[seed % _silicone.length]));

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
    for (final f in [0.22, 0.31]) {
      final y = top + crockH * f;
      canvas.drawLine(Offset(bodyRect.left, y), Offset(bodyRect.right, y), band);
    }
    // Glaze shine.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - crockW * 0.33, top + crockH * 0.42, crockW * 0.08, crockH * 0.4),
        Radius.circular(3 * u),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.24),
    );
    canvas.restore();
    // The rolled front lip.
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, top), width: crockW, height: rimH),
      0,
      math.pi,
      false,
      Paint()
        ..color = Color.lerp(glaze.body, Colors.white, 0.35)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * u,
    );
  }

  @override
  bool shouldRepaint(_CrockPainter old) => old.seed != seed;
}

// --- Hanging rail -----------------------------------------------------------------------

/// A steel rail screwed under a shelf, with a ladle, a slotted turner, a
/// whisk and a wooden spoon hanging from S-hooks.
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
    final w = size.width;
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

    // Each tool with how far it hangs below its hook.
    // A little chunkier than life, so each tool reads at shelf size.
    final k = u * 1.25;
    final tools = <(void Function(double), double)>[
      ((l) => _ladle(canvas, l, k), 59 * k),
      ((l) => _turner(canvas, l, k, 1, hanging: true), 51 * k),
      ((l) => _whisk(canvas, l, k, 1, hanging: true), 46 * k),
      ((l) => _woodenSpoon(canvas, l, k, 1, hanging: true), 51 * k),
    ];
    final start = seed % tools.length;
    final rnd = math.Random(seed * 7 + 5);
    final hook = Paint()
      ..color = const Color(0xFF4A4E53)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * u
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < tools.length; i++) {
      final x = w * (0.16 + 0.69 * i / (tools.length - 1));
      final hookBottom = railY + 9 * u;
      // S-hook: over the rail, down, and a curl the tool hangs from.
      canvas.drawPath(
        Path()
          ..moveTo(x + 2.5 * u, railY + 1.5 * u)
          ..quadraticBezierTo(x + 2.5 * u, railY - 3.5 * u, x, railY - 3.5 * u)
          ..quadraticBezierTo(x - 2.5 * u, railY - 3.5 * u, x - 1 * u, railY + 1 * u)
          ..lineTo(x, hookBottom - 1 * u)
          ..quadraticBezierTo(x, hookBottom + 2 * u, x + 2.5 * u, hookBottom + 0.5 * u),
        hook,
      );
      final (draw, length) = tools[(start + i) % tools.length];
      canvas.save();
      canvas.translate(x, hookBottom - 2 * u);
      canvas.rotate((rnd.nextDouble() - 0.5) * 0.08);
      draw(length);
      canvas.restore();
    }
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

    final inside = Rect.fromLTRB(
      body.left + 2 * u,
      body.bottom - body.height * fill,
      body.right - 2 * u,
      body.bottom - 2 * u,
    );
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

// --- Kettle -----------------------------------------------------------------------------

/// A stovetop kettle: an enamel dome with a spout and a bakelite handle.
class Kettle extends StatelessWidget {
  final int seed;
  const Kettle({super.key, this.seed = 0});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: CustomPaint(painter: _KettlePainter(seed)));
}

class _KettlePainter extends CustomPainter {
  final int seed;
  _KettlePainter(this.seed);

  static const _enamels = [Color(0xFFC8382C), Color(0xFF2F7F7A), Color(0xFFB9BFC5), Color(0xFFEDE3CC)];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final u = w / 72;
    final enamel = _enamels[seed % _enamels.length];
    final cx = 33 * u;
    _contactShadow(canvas, Offset(cx, h - 1 * u), 56 * u, u);

    // Spout, behind the body: a tapering tube rising to the right.
    final spout = Path()
      ..moveTo(52 * u, h - 24 * u)
      ..quadraticBezierTo(60 * u, h - 30 * u, 66 * u, h - 46 * u)
      ..lineTo(71 * u, h - 46 * u)
      ..quadraticBezierTo(66 * u, h - 26 * u, 56 * u, h - 12 * u)
      ..close();
    canvas.drawPath(spout, _round(Rect.fromLTRB(52 * u, h - 46 * u, 71 * u, h - 12 * u), enamel, light: 0.25));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(64.5 * u, h - 49 * u, 72 * u, h - 45 * u), Radius.circular(1.5 * u)),
      Paint()..color = const Color(0xFF26262A),
    );

    // Handle: a bakelite grip on a steel arch.
    final arch = Paint()
      ..color = const Color(0xFF9AA0A6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * u
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(16 * u, h - 38 * u)
        ..cubicTo(14 * u, h - 66 * u, 52 * u, h - 66 * u, 50 * u, h - 38 * u),
      arch,
    );
    final grip = Rect.fromLTRB(21 * u, h - 62.5 * u, 45 * u, h - 55.5 * u);
    canvas.drawRRect(RRect.fromRectAndRadius(grip, Radius.circular(3.5 * u)), _round(grip, _blackHandle));

    // Body: wide at the base, sloping shoulders.
    final top = h - 44 * u;
    final body = Path()
      ..moveTo(cx - 12 * u, top)
      ..cubicTo(cx - 22 * u, top + 6 * u, cx - 30 * u, h - 16 * u, cx - 29 * u, h - 5 * u)
      ..quadraticBezierTo(cx - 28 * u, h - 1 * u, cx - 24 * u, h - 1 * u)
      ..lineTo(cx + 24 * u, h - 1 * u)
      ..quadraticBezierTo(cx + 28 * u, h - 1 * u, cx + 29 * u, h - 5 * u)
      ..cubicTo(cx + 30 * u, h - 16 * u, cx + 22 * u, top + 6 * u, cx + 12 * u, top)
      ..close();
    final bounds = Rect.fromLTRB(cx - 30 * u, top, cx + 30 * u, h);
    canvas.drawPath(body, _round(bounds, enamel, light: 0.3));
    // A dark base band and a shine down the left shoulder.
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(
      Rect.fromLTRB(bounds.left, h - 5 * u, bounds.right, h),
      Paint()..color = Color.lerp(enamel, Colors.black, 0.4)!,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx - 14 * u, top + 6 * u)
        ..quadraticBezierTo(cx - 24 * u, top + 16 * u, cx - 24 * u, h - 12 * u),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * u
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
    // Lid and knob.
    final lid = Rect.fromLTRB(cx - 13 * u, top - 5 * u, cx + 13 * u, top + 2 * u);
    canvas.drawOval(lid, _round(lid, Color.lerp(enamel, Colors.white, 0.08)!, light: 0.35));
    final knob = Rect.fromLTRB(cx - 4 * u, top - 10 * u, cx + 4 * u, top - 3 * u);
    canvas.drawRRect(RRect.fromRectAndRadius(knob, Radius.circular(3 * u)), _round(knob, _blackHandle));
  }

  @override
  bool shouldRepaint(_KettlePainter old) => old.seed != seed;
}

// --- Oil & vinegar ----------------------------------------------------------------------

/// A tall bottle of olive oil with a pourer and a round bottle of balsamic.
class OilBottles extends StatelessWidget {
  final int seed;
  const OilBottles({super.key, this.seed = 0});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: CustomPaint(painter: _BottlesPainter(seed)));
}

class _BottlesPainter extends CustomPainter {
  final int seed;
  _BottlesPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final u = w / 46;
    _contactShadow(canvas, Offset(w / 2, h - 1 * u), w * 0.95, u);
    // Olive oil: square shoulders, a long neck and a steel pourer.
    _bottle(
      canvas,
      u,
      left: 1 * u,
      right: 24 * u,
      bottom: h,
      shoulder: h - 66 * u,
      neckTop: h - 90 * u,
      neckW: 7 * u,
      liquid: const Color(0xFFB7A43C),
      fill: 0.82,
      label: const Color(0xFF2F4A2A),
    );
    final pourer = Path()
      ..moveTo(12.5 * u - 2.6 * u, h - 90 * u)
      ..lineTo(12.5 * u - 1.2 * u, h - 101 * u)
      ..lineTo(12.5 * u + 3.5 * u, h - 104 * u)
      ..lineTo(12.5 * u + 1.6 * u, h - 90 * u)
      ..close();
    canvas.drawPath(pourer, _round(Rect.fromLTRB(9 * u, h - 104 * u, 17 * u, h - 90 * u), _steel, light: 0.5));
    // Balsamic: round, darker, in front.
    _bottle(
      canvas,
      u,
      left: 23 * u,
      right: 45 * u,
      bottom: h,
      shoulder: h - 40 * u,
      neckTop: h - 60 * u,
      neckW: 6 * u,
      liquid: const Color(0xFF4A1A16),
      fill: 0.72,
      label: const Color(0xFFE8DCC4),
      round: true,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(30.5 * u, h - 66 * u, 37.5 * u, h - 59 * u), Radius.circular(1.5 * u)),
      _round(Rect.fromLTRB(30.5 * u, h - 66 * u, 37.5 * u, h - 59 * u), _blackHandle),
    );
  }

  void _bottle(
    Canvas canvas,
    double u, {
    required double left,
    required double right,
    required double bottom,
    required double shoulder,
    required double neckTop,
    required double neckW,
    required Color liquid,
    required double fill,
    required Color label,
    bool round = false,
  }) {
    final cx = (left + right) / 2;
    final neckBase = shoulder - (round ? 10 : 7) * u;
    final shape = Path()
      ..moveTo(cx - neckW / 2, neckTop)
      ..lineTo(cx - neckW / 2, neckBase)
      ..quadraticBezierTo(left, neckBase + (round ? 2 : 3) * u, left, shoulder + (round ? 8 : 2) * u)
      ..lineTo(left, bottom - 3 * u)
      ..quadraticBezierTo(left, bottom, left + 3 * u, bottom)
      ..lineTo(right - 3 * u, bottom)
      ..quadraticBezierTo(right, bottom, right, bottom - 3 * u)
      ..lineTo(right, shoulder + (round ? 8 : 2) * u)
      ..quadraticBezierTo(right, neckBase + (round ? 2 : 3) * u, cx + neckW / 2, neckBase)
      ..lineTo(cx + neckW / 2, neckTop)
      ..close();
    final bounds = Rect.fromLTRB(left, neckTop, right, bottom);
    canvas.save();
    canvas.clipPath(shape);
    final level = bottom - (bottom - shoulder) * fill - 2 * u;
    canvas.drawRect(Rect.fromLTRB(left, level, right, bottom), _round(bounds, liquid, light: 0.18, dark: 0.35));
    canvas.restore();
    canvas.drawPath(shape, Paint()..color = Colors.white.withValues(alpha: 0.08));
    canvas.drawPath(
      shape,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9 * u,
    );
    final tag = Rect.fromLTRB(left + 3 * u, bottom - (bottom - shoulder) * 0.62, right - 3 * u, bottom - 8 * u);
    canvas.drawRRect(RRect.fromRectAndRadius(tag, Radius.circular(1.5 * u)), Paint()..color = label);
    final ink = label.computeLuminance() > 0.4 ? const Color(0xFF5A4630) : const Color(0xFFE3C77F);
    for (final f in [0.38, 0.6]) {
      canvas.drawLine(
        Offset(tag.left + 2.5 * u, tag.top + tag.height * f),
        Offset(tag.right - 2.5 * u - (f > 0.5 ? 3 * u : 0), tag.top + tag.height * f),
        Paint()
          ..color = ink
          ..strokeWidth = 1 * u,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 2.2 * u, shoulder + 4 * u, 1.8 * u, (bottom - shoulder) * 0.5),
        Radius.circular(0.9 * u),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(_BottlesPainter old) => old.seed != seed;
}

// --- Mortar & pestle --------------------------------------------------------------------

/// A stone mortar on a low foot, its pestle leaning out to the right.
class MortarAndPestle extends StatelessWidget {
  final int seed;
  const MortarAndPestle({super.key, this.seed = 0});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: CustomPaint(painter: _MortarPainter(seed)));
}

class _MortarPainter extends CustomPainter {
  final int seed;
  _MortarPainter(this.seed);

  static const _stones = [Color(0xFF8E8A84), Color(0xFFE4E0D9), Color(0xFF55585C)];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final u = w / 60;
    final stone = _stones[seed % _stones.length];
    final cx = 26 * u;
    final rimY = h - 34 * u;
    _contactShadow(canvas, Offset(cx, h - 1 * u), 34 * u, u);

    // The mouth, then the pestle resting in it.
    final mouth = Rect.fromCenter(center: Offset(cx, rimY), width: 44 * u, height: 9 * u);
    canvas.drawOval(mouth, Paint()..color = Color.lerp(stone, Colors.black, 0.55)!);
    canvas.save();
    canvas.translate(cx + 4 * u, rimY + 2 * u);
    canvas.rotate(0.62);
    _rodStone(canvas, stone, u);
    canvas.restore();

    // Bowl and foot.
    final foot = Rect.fromLTRB(cx - 15 * u, h - 6 * u, cx + 15 * u, h - 0.5 * u);
    canvas.drawRRect(RRect.fromRectAndRadius(foot, Radius.circular(2 * u)), _round(foot, stone, light: 0.2));
    final bowl = Path()
      ..moveTo(cx - 22 * u, rimY)
      ..cubicTo(cx - 22 * u, rimY + 18 * u, cx - 14 * u, h - 6 * u, cx, h - 6 * u)
      ..cubicTo(cx + 14 * u, h - 6 * u, cx + 22 * u, rimY + 18 * u, cx + 22 * u, rimY)
      ..close();
    final bounds = Rect.fromLTRB(cx - 22 * u, rimY, cx + 22 * u, h - 6 * u);
    canvas.drawPath(bowl, _round(bounds, stone, light: 0.25));
    // Speckled stone.
    canvas.save();
    canvas.clipPath(bowl);
    final rnd = math.Random(seed + 9);
    final fleck = Paint();
    for (var i = 0; i < 70; i++) {
      fleck.color = (rnd.nextBool() ? Colors.black : Colors.white).withValues(alpha: 0.12 + rnd.nextDouble() * 0.1);
      canvas.drawCircle(
        Offset(bounds.left + rnd.nextDouble() * bounds.width, bounds.top + rnd.nextDouble() * bounds.height),
        (0.4 + rnd.nextDouble() * 0.6) * u,
        fleck,
      );
    }
    canvas.restore();
    canvas.drawArc(
      mouth,
      0,
      math.pi,
      false,
      Paint()
        ..color = Color.lerp(stone, Colors.white, 0.3)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * u,
    );
  }

  /// The pestle: club-shaped, its heavy end down in the bowl.
  void _rodStone(Canvas canvas, Color stone, double u) {
    final shape = Path()
      ..moveTo(-5 * u, 4 * u)
      ..quadraticBezierTo(-4.6 * u, -14 * u, -3 * u, -30 * u)
      ..quadraticBezierTo(0, -35 * u, 3 * u, -30 * u)
      ..quadraticBezierTo(4.6 * u, -14 * u, 5 * u, 4 * u)
      ..close();
    canvas.drawPath(shape, _round(Rect.fromLTRB(-5 * u, -34 * u, 5 * u, 4 * u), stone, light: 0.3));
  }

  @override
  bool shouldRepaint(_MortarPainter old) => old.seed != seed;
}

// --- Basil pot --------------------------------------------------------------------------

/// A terracotta pot of bushy basil.
class HerbPot extends StatelessWidget {
  final int seed;
  const HerbPot({super.key, this.seed = 0});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: CustomPaint(painter: _HerbPainter(seed)));
}

class _HerbPainter extends CustomPainter {
  final int seed;
  _HerbPainter(this.seed);

  static const _greens = [Color(0xFF4E9A3A), Color(0xFF66B04A), Color(0xFF3D7F2E), Color(0xFF7CC25B)];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final u = w / 54;
    final cx = w / 2;
    final potTop = h - 28 * u;
    _contactShadow(canvas, Offset(cx, h - 1 * u), 30 * u, u);

    // Soil and stems, then a dome of leaves: back layer first, each leaf
    // turned away from the middle, the lowest drooping over the rim.
    final rnd = math.Random(seed * 5 + 2);
    final center = Offset(cx, potTop - 8 * u);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, potTop + 3 * u), width: 32 * u, height: 5 * u),
      Paint()..color = const Color(0xFF4A3426),
    );
    final stem = Paint()
      ..color = const Color(0xFF3F7A2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3 * u;
    for (final dx in [-8.0, -3.0, 2.0, 7.0]) {
      canvas.drawLine(Offset(cx + dx * u, potTop + 3 * u), center + Offset(dx * 1.6 * u, -8 * u), stem);
    }
    for (var layer = 0; layer < 3; layer++) {
      final count = 9 - layer * 2;
      final reach = (20 - layer * 7) * u;
      for (var i = 0; i < count; i++) {
        final a = math.pi * (0.96 + 1.08 * i / math.max(1, count - 1)) + (rnd.nextDouble() - 0.5) * 0.22;
        final p = center + Offset(math.cos(a) * reach, math.sin(a) * reach * 0.9);
        final len = (9 + rnd.nextDouble() * 3) * u;
        canvas.save();
        canvas.translate(p.dx, p.dy);
        canvas.rotate(a + math.pi / 2);
        final leaf = Path()
          ..moveTo(0, len * 0.5)
          ..cubicTo(len * 0.5, len * 0.3, len * 0.42, -len * 0.42, 0, -len * 0.55)
          ..cubicTo(-len * 0.42, -len * 0.42, -len * 0.5, len * 0.3, 0, len * 0.5)
          ..close();
        final color = _greens[(i + layer + seed) % _greens.length];
        canvas.drawPath(
          leaf,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color.lerp(color, Colors.black, 0.2)!, Color.lerp(color, Colors.white, 0.12)!],
            ).createShader(Rect.fromLTRB(-len / 2, -len / 2, len / 2, len / 2)),
        );
        canvas.drawLine(
          Offset(0, len * 0.42),
          Offset(0, -len * 0.4),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.22)
            ..strokeWidth = 0.6 * u,
        );
        canvas.restore();
      }
    }

    // Terracotta pot with a rolled rim.
    final pot = Path()
      ..moveTo(cx - 17 * u, potTop + 5 * u)
      ..lineTo(cx + 17 * u, potTop + 5 * u)
      ..lineTo(cx + 13 * u, h - 1 * u)
      ..lineTo(cx - 13 * u, h - 1 * u)
      ..close();
    const clay = Color(0xFFBF6A45);
    canvas.drawPath(pot, _round(Rect.fromLTRB(cx - 17 * u, potTop, cx + 17 * u, h), clay));
    final rim = Rect.fromLTRB(cx - 19 * u, potTop, cx + 19 * u, potTop + 6.5 * u);
    canvas.drawRRect(RRect.fromRectAndRadius(rim, Radius.circular(1.5 * u)), _round(rim, clay, light: 0.28));
  }

  @override
  bool shouldRepaint(_HerbPainter old) => old.seed != seed;
}
