import 'dart:math' as math;

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

/// A book whose pages turn in 3D around the spine.
///
/// Single-page mode (phones) shows one page; turning lifts it off to the left
/// to reveal the next. Spread mode (tablets, desktop) shows facing pages and
/// turns the right-hand leaf over to the left, back side and all. Pages can be
/// turned by dragging horizontally or through the [controller].
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
    this.duration = const Duration(milliseconds: 520),
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
    await _anim.animateTo(1, curve: Curves.easeInOutCubic);
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
          final baseLeft = _page(flip.forward ? 2 * a : 2 * b);
          final baseRight = _page(flip.forward ? 2 * b + 1 : 2 * a + 1);
          final rightFace = _page(flip.forward ? 2 * a + 1 : 2 * b + 1);
          final leftFace = _page(flip.forward ? 2 * b : 2 * a);
          body = AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              final theta = math.pi * (flip.forward ? _anim.value : 1 - _anim.value);
              return _SpreadTurn(
                pageWidth: _pageWidth,
                theta: theta,
                baseLeft: baseLeft,
                baseRight: baseRight,
                rightFace: rightFace,
                leftFace: leftFace,
              );
            },
          );
        } else {
          final base = _page(flip.forward ? flip.to : flip.from);
          final leaf = _page(flip.forward ? flip.from : flip.to);
          body = AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              final theta = (math.pi / 2) * (flip.forward ? _anim.value : 1 - _anim.value);
              return _SingleTurn(pageWidth: _pageWidth, theta: theta, base: base, leaf: leaf);
            },
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

/// Perspective scaled to the page so turns look alike at every size.
Matrix4 _turnMatrix(double angle, double pageWidth) => Matrix4.identity()
  ..setEntry(3, 2, 0.25 / pageWidth.clamp(200.0, 2000.0))
  ..rotateY(angle);

class _SpreadTurn extends StatelessWidget {
  final double pageWidth;
  final double theta;
  final Widget baseLeft, baseRight, rightFace, leftFace;

  const _SpreadTurn({
    required this.pageWidth,
    required this.theta,
    required this.baseLeft,
    required this.baseRight,
    required this.rightFace,
    required this.leftFace,
  });

  @override
  Widget build(BuildContext context) {
    final lifted = math.sin(theta); // 0 flat … 1 upright
    final onRight = theta <= math.pi / 2;
    return Stack(
      children: [
        Row(
          children: [
            Expanded(child: baseLeft),
            Expanded(child: baseRight),
          ],
        ),
        const _SpineShade(),
        // Shadow the leaf casts on the page it is about to cover.
        Positioned(
          left: onRight ? pageWidth : 0,
          width: pageWidth,
          top: 0,
          bottom: 0,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: onRight ? Alignment.centerLeft : Alignment.centerRight,
                  end: onRight ? Alignment.centerRight : Alignment.centerLeft,
                  colors: [
                    Colors.black.withValues(alpha: 0.22 * lifted),
                    Colors.transparent,
                  ],
                  stops: [0, (0.15 + 0.85 * (1 - lifted)).clamp(0.15, 1.0)],
                ),
              ),
            ),
          ),
        ),
        if (onRight)
          Positioned(
            left: pageWidth,
            width: pageWidth,
            top: 0,
            bottom: 0,
            child: Transform(
              alignment: Alignment.centerLeft,
              transform: _turnMatrix(theta, pageWidth),
              child: _Shaded(darkness: 0.28 * lifted, fromLeft: true, child: rightFace),
            ),
          )
        else
          Positioned(
            left: 0,
            width: pageWidth,
            top: 0,
            bottom: 0,
            child: Transform(
              alignment: Alignment.centerRight,
              transform: _turnMatrix(theta - math.pi, pageWidth),
              child: _Shaded(darkness: 0.28 * lifted, fromLeft: false, child: leftFace),
            ),
          ),
      ],
    );
  }
}

class _SingleTurn extends StatelessWidget {
  final double pageWidth;
  final double theta;
  final Widget base, leaf;
  const _SingleTurn({required this.pageWidth, required this.theta, required this.base, required this.leaf});

  @override
  Widget build(BuildContext context) {
    final lifted = math.sin(theta);
    return Stack(
      children: [
        Positioned.fill(child: base),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.25 * lifted),
                    Colors.transparent,
                  ],
                  stops: [0, (0.1 + 0.9 * (1 - lifted)).clamp(0.1, 1.0)],
                ),
              ),
            ),
          ),
        ),
        if (theta < math.pi / 2 - 0.02)
          Positioned.fill(
            child: Transform(
              alignment: Alignment.centerLeft,
              transform: _turnMatrix(theta, pageWidth),
              child: _Shaded(darkness: 0.3 * lifted, fromLeft: true, child: leaf),
            ),
          ),
      ],
    );
  }
}

/// Darkens a turning leaf towards its free edge.
class _Shaded extends StatelessWidget {
  final double darkness;
  final bool fromLeft;
  final Widget child;
  const _Shaded({required this.darkness, required this.fromLeft, required this.child});

  @override
  Widget build(BuildContext context) {
    if (darkness <= 0.001) return child;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: fromLeft ? Alignment.centerLeft : Alignment.centerRight,
                  end: fromLeft ? Alignment.centerRight : Alignment.centerLeft,
                  colors: [
                    Colors.black.withValues(alpha: darkness * 0.35),
                    Colors.black.withValues(alpha: darkness),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
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
