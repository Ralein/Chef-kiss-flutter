import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Drives a [PageFlipBook]: current position plus animated page turns.
///
/// A *position* is one page in single-page mode and one two-page spread in
/// spread mode.
class PageFlipController extends ChangeNotifier {
  PageFlipController({int initialPosition = 0}) : _position = initialPosition;

  _PageFlipBookState? _book;
  int _position;

  int get position => _position;
  bool get isFlipping => _book?._flip != null;

  Future<void> next() => animateTo(_position + 1);
  Future<void> previous() => animateTo(_position - 1);

  /// Turns the pages to [position] (one animated turn, whatever the distance).
  Future<void> animateTo(int position) async {
    final book = _book;
    if (book == null) {
      _position = position;
      notifyListeners();
      return;
    }
    await book._animateTo(position);
  }

  /// Moves without animation.
  void jumpTo(int position) {
    final book = _book;
    if (book == null) {
      _position = position;
      notifyListeners();
    } else {
      book._commit(position);
    }
  }

  void _set(int position) {
    _position = position;
    notifyListeners();
  }
}

/// A book whose pages fold over like paper.
///
/// Single-page mode (phones) shows one page; turning peels it from the bottom
/// corner to reveal the next. Spread mode (tablets, desktop) shows facing
/// pages and folds the right-hand leaf over onto the left, with the next left
/// page printed on its back. Pages can be turned by dragging horizontally or
/// through the [controller].
class PageFlipBook extends StatefulWidget {
  final int pageCount;
  final Widget Function(BuildContext context, int pageIndex) pageBuilder;

  /// Stable identity for a page (for example `recipeId:side`), so a page
  /// keeps its state while it moves through a turn.
  final Object Function(int pageIndex)? pageIdentity;

  final bool spread;
  final PageFlipController controller;
  final ValueChanged<int>? onPositionChanged;

  /// Whether dragging turns pages (off while decorating).
  final bool interactive;

  /// Called when a drag tries to go past the first or last page.
  final VoidCallback? onEdgeReached;

  final Duration duration;

  /// Colour of the back of the paper (seen on a turning page in single-page
  /// mode).
  final Color backColor;

  const PageFlipBook({
    super.key,
    required this.pageCount,
    required this.pageBuilder,
    required this.controller,
    this.pageIdentity,
    this.spread = false,
    this.onPositionChanged,
    this.interactive = true,
    this.onEdgeReached,
    this.duration = const Duration(milliseconds: 620),
    this.backColor = const Color(0xFFF1EBE1),
  });

  int get positionCount => spread ? (pageCount / 2).ceil() : pageCount;

  @override
  State<PageFlipBook> createState() => _PageFlipBookState();
}

class _Flip {
  final int from;
  final int to;
  final bool byDrag;
  const _Flip(this.from, this.to, {this.byDrag = false});
  bool get forward => to > from;
}

class _PageFlipBookState extends State<PageFlipBook> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this, duration: widget.duration);
  final Map<Object, GlobalKey> _keys = {};
  _Flip? _flip;
  double _dragDx = 0;
  bool _edgeReported = false;
  double _pageWidth = 1;

  int get _position => widget.controller._position;

  @override
  void initState() {
    super.initState();
    widget.controller._book = this;
    _clampPosition();
  }

  @override
  void didUpdateWidget(PageFlipBook old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      if (old.controller._book == this) old.controller._book = null;
      widget.controller._book = this;
    }
    _clampPosition();
  }

  void _clampPosition() {
    final max = math.max(0, widget.positionCount - 1);
    if (_position > max) widget.controller._position = max;
  }

  @override
  void dispose() {
    if (widget.controller._book == this) widget.controller._book = null;
    _anim.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  Future<void> _animateTo(int target) async {
    final t = target.clamp(0, math.max(0, widget.positionCount - 1)).toInt();
    if (t == _position || _flip != null) return;
    if (_reduceMotion) {
      _commit(t);
      return;
    }
    setState(() => _flip = _Flip(_position, t));
    _anim.value = 0;
    await _anim.animateTo(1, curve: Curves.easeInOut);
    if (mounted) _commit(t);
  }

  void _commit(int target) {
    final t = target.clamp(0, math.max(0, widget.positionCount - 1)).toInt();
    final changed = t != _position;
    setState(() => _flip = null);
    _anim.value = 0;
    if (changed) {
      widget.controller._set(t);
      widget.onPositionChanged?.call(t);
    }
  }

  // --- Dragging ---------------------------------------------------------------

  void _onDragStart(DragStartDetails _) {
    _dragDx = 0;
    _edgeReported = false;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    _dragDx += d.delta.dx;
    var flip = _flip;
    if (flip == null) {
      if (_dragDx.abs() < 8) return;
      final forward = _dragDx < 0;
      final target = _position + (forward ? 1 : -1);
      if (target < 0 || target >= widget.positionCount) {
        if (!_edgeReported) {
          _edgeReported = true;
          widget.onEdgeReached?.call();
        }
        return;
      }
      setState(() => _flip = flip = _Flip(_position, target, byDrag: true));
    }
    if (!flip!.byDrag) return;
    final travel = widget.spread ? _pageWidth * 1.4 : _pageWidth * 0.85;
    final progress = (flip!.forward ? -_dragDx : _dragDx) / travel;
    _anim.value = progress.clamp(0.0, 1.0);
  }

  Future<void> _onDragEnd(DragEndDetails d) async {
    final flip = _flip;
    if (flip == null || !flip.byDrag) return;
    final v = d.primaryVelocity ?? 0;
    final fling = flip.forward ? v < -350 : v > 350;
    final reverse = flip.forward ? v > 350 : v < -350;
    if (!reverse && (fling || _anim.value > 0.4)) {
      await _anim.animateTo(1, curve: Curves.easeOutCubic);
      if (mounted) _commit(flip.to);
    } else {
      await _anim.animateBack(0, curve: Curves.easeOutCubic);
      if (mounted) setState(() => _flip = null);
    }
  }

  void _onDragCancel() {
    final flip = _flip;
    if (flip == null || !flip.byDrag) return;
    _anim.animateBack(0).then((_) {
      if (mounted) setState(() => _flip = null);
    });
  }

  // --- Building -----------------------------------------------------------------

  Widget _page(int index) {
    if (index < 0 || index >= widget.pageCount) return const SizedBox.expand();
    final identity = widget.pageIdentity?.call(index) ?? index;
    final key = _keys.putIfAbsent(identity, GlobalKey.new);
    return KeyedSubtree(
      key: key,
      child: RepaintBoundary(child: widget.pageBuilder(context, index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        _pageWidth = widget.spread ? size.width / 2 : size.width;
        final flip = _flip;

        // Page widgets are built once per frame of state, not per animation
        // tick: the AnimatedBuilder below only moves them.
        final Widget body;
        if (flip == null) {
          body = widget.spread ? _spreadStatic(_position) : _page(_position);
        } else if (widget.spread) {
          final a = flip.from, b = flip.to;
          // Forward: the current right page folds over, showing the next left
          // page on its back. Backward is the same fold played in reverse.
          final base = Row(
            children: [
              Expanded(child: _page(flip.forward ? 2 * a : 2 * b)),
              Expanded(child: _page(flip.forward ? 2 * b + 1 : 2 * a + 1)),
            ],
          );
          final front = _page(flip.forward ? 2 * a + 1 : 2 * b + 1);
          final back = _page(flip.forward ? 2 * b : 2 * a);
          body = AnimatedBuilder(
            animation: _anim,
            builder: (context, _) => _FoldTurn(
              size: size,
              spread: true,
              t: flip.forward ? _anim.value : 1 - _anim.value,
              base: Stack(
                children: [
                  Positioned.fill(child: base),
                  const _SpineShade(),
                ],
              ),
              front: front,
              back: back,
              backColor: widget.backColor,
            ),
          );
        } else {
          final base = _page(flip.forward ? flip.to : flip.from);
          final front = _page(flip.forward ? flip.from : flip.to);
          body = AnimatedBuilder(
            animation: _anim,
            builder: (context, _) => _FoldTurn(
              size: size,
              spread: false,
              t: flip.forward ? _anim.value : 1 - _anim.value,
              base: base,
              front: front,
              back: null,
              backColor: widget.backColor,
            ),
          );
        }

        Widget book = IgnorePointer(ignoring: flip != null, child: body);
        if (widget.interactive) {
          book = GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            onHorizontalDragCancel: _onDragCancel,
            child: book,
          );
        }
        return ClipRect(
          child: SizedBox.fromSize(size: size, child: book),
        );
      },
    );
  }

  Widget _spreadStatic(int position) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(child: _page(2 * position)),
            Expanded(child: _page(2 * position + 1)),
          ],
        ),
        const _SpineShade(),
      ],
    );
  }
}

// --- Page fold --------------------------------------------------------------------
//
// A turning page is modelled as a sheet folded along a straight crease. The
// page's outer bottom corner C travels on an arc around the bottom of the
// spine (so the paper never stretches) to its mirror image across the spine.
// The crease is the perpendicular bisector of C and the corner's current
// position P: everything on C's side of it is folded over, i.e. reflected
// across the crease, and shows the back of the sheet.

/// Geometry of one moment of a page turn, in book coordinates.
class _Fold {
  final List<Offset> visible; // the part of the page still lying flat
  final List<Offset> revealed; // where the page used to be: shows what's underneath
  final List<Offset> flap; // the folded-over part, back side up
  final Offset crease; // a point on the crease
  final Offset normal; // unit normal of the crease, pointing at the corner's start
  final Offset corner; // where the corner is now
  final Matrix4 reflect; // reflection across the crease

  const _Fold({
    required this.visible,
    required this.revealed,
    required this.flap,
    required this.crease,
    required this.normal,
    required this.corner,
    required this.reflect,
  });

  /// [page] is the turning page, hinged at [spineX]; [t] runs 0 (flat) to 1
  /// (turned). Returns null when the page is (all but) flat.
  static _Fold? at(Rect page, double spineX, double t) {
    if (t <= 0.002) return null;
    final w = page.width;
    final c = Offset(spineX + w, page.bottom);
    final angle = math.pi * t.clamp(0.0, 1.0);
    final p = Offset(spineX + w * math.cos(angle), page.bottom - w * 0.28 * math.sin(angle));
    final d = c - p;
    if (d.distance < 0.5) return null;
    final n = d / d.distance;
    final m = (c + p) / 2;
    final corners = [page.topLeft, page.topRight, page.bottomRight, page.bottomLeft];
    final visible = _clip(corners, m, n, keepFolded: false);
    final folded = _clip(corners, m, n, keepFolded: true);
    final reflect = _reflection(m, n);
    return _Fold(
      visible: visible,
      revealed: folded,
      flap: [for (final v in folded) _apply(reflect, v)],
      crease: m,
      normal: n,
      corner: p,
      reflect: reflect,
    );
  }

  /// One-plane Sutherland–Hodgman: keeps the side where (x - m)·n > 0
  /// (folded) or <= 0 (visible).
  static List<Offset> _clip(List<Offset> poly, Offset m, Offset n, {required bool keepFolded}) {
    double side(Offset x) => ((x - m).dx * n.dx + (x - m).dy * n.dy) * (keepFolded ? 1 : -1);
    final out = <Offset>[];
    for (var i = 0; i < poly.length; i++) {
      final a = poly[i], b = poly[(i + 1) % poly.length];
      final sa = side(a), sb = side(b);
      if (sa >= 0) out.add(a);
      if ((sa >= 0) != (sb >= 0)) {
        final k = sa / (sa - sb);
        out.add(a + (b - a) * k);
      }
    }
    return out;
  }

  static Matrix4 _reflection(Offset m, Offset n) {
    final a = 1 - 2 * n.dx * n.dx, b = -2 * n.dx * n.dy, d = 1 - 2 * n.dy * n.dy;
    final k = 2 * (m.dx * n.dx + m.dy * n.dy);
    return Matrix4(a, b, 0, 0, b, d, 0, 0, 0, 0, 1, 0, k * n.dx, k * n.dy, 0, 1);
  }

  static Offset _apply(Matrix4 m, Offset v) => Offset(
    m.storage[0] * v.dx + m.storage[4] * v.dy + m.storage[12],
    m.storage[1] * v.dx + m.storage[5] * v.dy + m.storage[13],
  );

  static Path path(List<Offset> poly) => poly.isEmpty ? Path() : (Path()..addPolygon(poly, true));
}

class _PolyClipper extends CustomClipper<Path> {
  final List<Offset> poly;
  _PolyClipper(this.poly);

  @override
  Path getClip(Size size) => _Fold.path(poly);

  @override
  bool shouldReclip(_PolyClipper old) => true;
}

/// One frame of a page turn.
///
/// [base] is what lies underneath (the destination spread or page); [front]
/// is the turning page; [back] is what's printed on its other side (the next
/// left page in a spread) or null for plain paper.
class _FoldTurn extends StatelessWidget {
  final Size size;
  final bool spread;
  final double t;
  final Widget base;
  final Widget front;
  final Widget? back;
  final Color backColor;

  const _FoldTurn({
    required this.size,
    required this.spread,
    required this.t,
    required this.base,
    required this.front,
    required this.back,
    required this.backColor,
  });

  @override
  Widget build(BuildContext context) {
    final w = spread ? size.width / 2 : size.width;
    final spineX = spread ? size.width / 2 : 0.0;
    final page = Rect.fromLTWH(spineX, 0, w, size.height);
    final fold = _Fold.at(page, spineX, t);
    final frontPage = Positioned(left: spineX, top: 0, width: w, height: size.height, child: front);
    if (fold == null) {
      return Stack(
        children: [
          Positioned.fill(child: base),
          frontPage,
        ],
      );
    }
    // The back side: the next left page, mirrored onto the flap by the
    // spine and crease reflections (two mirrors = upright, readable).
    final spineMirror = _Fold._reflection(Offset(spineX, 0), const Offset(1, 0));
    final toFlap = fold.reflect.clone()..multiply(spineMirror);

    return Stack(
      children: [
        Positioned.fill(child: base),
        // Shadow the lifted sheet casts on what it reveals.
        Positioned.fill(
          child: IgnorePointer(
            child: ClipPath(
              clipper: _PolyClipper(fold.revealed),
              child: CustomPaint(painter: _CreaseShade(fold, strength: 0.32, width: 70, towardCorner: true)),
            ),
          ),
        ),
        // The flat part of the turning page, darkening where it starts to lift.
        Positioned.fill(
          child: ClipPath(
            clipper: _PolyClipper(fold.visible),
            child: Stack(
              children: [
                frontPage,
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _CreaseShade(fold, strength: 0.10, width: 26, towardCorner: false)),
                  ),
                ),
              ],
            ),
          ),
        ),
        // The flap: drop shadow, paper back (or the next page), shading.
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _FlapShadow(fold.flap))),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: ClipPath(
              clipper: _PolyClipper(fold.flap),
              child: Stack(
                children: [
                  Positioned.fill(child: ColoredBox(color: backColor)),
                  if (back != null)
                    Positioned(
                      left: 0,
                      top: 0,
                      width: w,
                      height: size.height,
                      child: Transform(transform: toFlap, child: back),
                    ),
                  Positioned.fill(child: CustomPaint(painter: _FlapShade(fold))),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A soft shadow band along the crease.
class _CreaseShade extends CustomPainter {
  final _Fold fold;
  final double strength;
  final double width;
  final bool towardCorner;
  _CreaseShade(this.fold, {required this.strength, required this.width, required this.towardCorner});

  @override
  void paint(Canvas canvas, Size size) {
    final dir = towardCorner ? fold.normal : -fold.normal;
    final start = fold.crease;
    final end = start + dir * width;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = ui.Gradient.linear(start, end, [Colors.black.withValues(alpha: strength), Colors.transparent]),
    );
  }

  @override
  bool shouldRepaint(_CreaseShade old) => true;
}

class _FlapShadow extends CustomPainter {
  final List<Offset> flap;
  _FlapShadow(this.flap);

  @override
  void paint(Canvas canvas, Size size) {
    if (flap.length < 3) return;
    canvas.drawShadow(_Fold.path(flap), Colors.black, 6, false);
  }

  @override
  bool shouldRepaint(_FlapShadow old) => true;
}

/// Shading on the folded-over paper: darkest in the crease, a highlight
/// where the paper bends, lighter towards the free corner.
class _FlapShade extends CustomPainter {
  final _Fold fold;
  _FlapShade(this.fold);

  @override
  void paint(Canvas canvas, Size size) {
    final start = fold.crease;
    final end = fold.corner;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          start,
          end,
          [
            Colors.black.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.10),
            Colors.black.withValues(alpha: 0.02),
            Colors.black.withValues(alpha: 0.08),
          ],
          const [0, 0.12, 0.6, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(_FlapShade old) => true;
}

/// The soft valley between facing pages.
class _SpineShade extends StatelessWidget {
  const _SpineShade();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.06,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.35, 0.5, 0.65, 1],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
