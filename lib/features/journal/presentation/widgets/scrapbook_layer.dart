import 'dart:math' as math;

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:recipe_domain/recipe_domain.dart';

import 'sticker_art.dart';

/// Stickers and washi tape placed freely on a journal page.
///
/// Positions are the item's centre as a percentage (0–100) of the page, so a
/// layout survives different screen sizes; rotation is in degrees.
///
/// When [editable], one finger drags an item and two fingers pinch/rotate it.
/// Only touches that start on an item (or a second finger while one is held)
/// are claimed, so the page underneath still scrolls and its buttons work.
class ScrapbookLayer extends StatefulWidget {
  final List<ScrapbookSticker> stickers;
  final List<WashiTapeDecoration> tapes;
  final bool editable;
  final String? selectedId;
  final ValueChanged<String?>? onSelect;
  final ValueChanged<ScrapbookSticker>? onStickerChanged;
  final ValueChanged<WashiTapeDecoration>? onTapeChanged;
  final ValueChanged<String>? onRemove;
  final ValueChanged<String>? onBringToFront;

  const ScrapbookLayer({
    super.key,
    required this.stickers,
    required this.tapes,
    this.editable = false,
    this.selectedId,
    this.onSelect,
    this.onStickerChanged,
    this.onTapeChanged,
    this.onRemove,
    this.onBringToFront,
  });

  @override
  State<ScrapbookLayer> createState() => _ScrapbookLayerState();
}

/// Geometry of one placed item in layer coordinates.
class _Placed {
  final String id;
  final bool isTape;
  final Offset center;
  final Size size;
  final double rotationDeg;
  const _Placed(this.id, this.isTape, this.center, this.size, this.rotationDeg);

  bool contains(Offset p) {
    // Rotate the point into the item's frame, then test its box (with a
    // little slack so thin tapes are easy to grab).
    final d = p - center;
    final a = -degToRad(rotationDeg);
    final local = Offset(d.dx * math.cos(a) - d.dy * math.sin(a), d.dx * math.sin(a) + d.dy * math.cos(a));
    final slack = isTape ? 10.0 : 4.0;
    return local.dx.abs() <= size.width / 2 + slack && local.dy.abs() <= size.height / 2 + slack;
  }
}

class _LiveEdit {
  final Offset center;
  final double scale;
  final double rotationDeg;
  const _LiveEdit(this.center, this.scale, this.rotationDeg);
}

class _ScrapbookLayerState extends State<ScrapbookLayer> {
  final _layerKey = GlobalKey();
  Size _size = Size.zero;

  /// Edits that were committed but not yet echoed back by the database, so
  /// an item doesn't jump back for a frame after it is dropped.
  final Map<String, Object> _optimistic = {};

  String? _target;
  Offset _startFocal = Offset.zero;
  Offset _startCenter = Offset.zero;
  double _startScale = 1;
  double _startRotation = 0;
  _LiveEdit? _live;
  bool _moved = false;

  List<ScrapbookSticker> get _stickers =>
      [for (final s in widget.stickers) (_optimistic[s.id] as ScrapbookSticker?) ?? s]
        ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

  List<WashiTapeDecoration> get _tapes => [
    for (final t in widget.tapes) (_optimistic[t.id] as WashiTapeDecoration?) ?? t,
  ];

  @override
  void didUpdateWidget(ScrapbookLayer old) {
    super.didUpdateWidget(old);
    // Drop optimistic copies once the saved version arrives (or the item is gone).
    _optimistic.removeWhere((id, pending) {
      for (final s in widget.stickers) {
        if (s.id == id) return pending is ScrapbookSticker && _sameSticker(s, pending);
      }
      for (final t in widget.tapes) {
        if (t.id == id) return pending is WashiTapeDecoration && _sameTape(t, pending);
      }
      return true;
    });
  }

  static bool _close(double a, double b) => (a - b).abs() < 0.01;
  static bool _sameSticker(ScrapbookSticker a, ScrapbookSticker b) =>
      _close(a.x, b.x) &&
      _close(a.y, b.y) &&
      _close(a.scale, b.scale) &&
      _close(a.rotation, b.rotation) &&
      a.zIndex == b.zIndex;
  static bool _sameTape(WashiTapeDecoration a, WashiTapeDecoration b) =>
      _close(a.x, b.x) && _close(a.y, b.y) && _close(a.width, b.width) && _close(a.rotation, b.rotation);

  List<_Placed> _placements() {
    final w = _size.width;
    final h = _size.height;
    Offset at(double x, double y) => Offset(w * x.clamp(0, 100) / 100, h * y.clamp(0, 100) / 100);
    return [
      for (final t in _tapes) _Placed(t.id, true, at(t.x, t.y), tapeBoxSize(t, w), t.rotation),
      for (final s in _stickers) _Placed(s.id, false, at(s.x, s.y), stickerBoxSize(s, w), s.rotation),
    ];
  }

  /// Top-most item under [global], or null.
  String? _hit(Offset global) {
    final box = _layerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final p = box.globalToLocal(global);
    final placed = _placements();
    for (var i = placed.length - 1; i >= 0; i--) {
      if (placed[i].contains(p)) return placed[i].id;
    }
    return null;
  }

  bool _allowPointer(PointerDownEvent e) {
    if (!widget.editable) return false;
    if (_target != null) return true; // second finger of a pinch, anywhere
    final id = _hit(e.position);
    if (id == null) return false;
    _target = id;
    return true;
  }

  Offset _local(Offset global) {
    final box = _layerKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.globalToLocal(global) ?? global;
  }

  void _onStart(ScaleStartDetails d) {
    final id = _target;
    if (id == null) return;
    final placed = _placements().firstWhere((p) => p.id == id);
    _startFocal = _local(d.focalPoint);
    _startCenter = placed.center;
    _startRotation = placed.rotationDeg;
    _startScale = 1;
    for (final s in _stickers) {
      if (s.id == id) _startScale = s.scale;
    }
    for (final t in _tapes) {
      if (t.id == id) _startScale = t.width;
    }
    _moved = false;
    setState(() => _live = _LiveEdit(_startCenter, _startScale, _startRotation));
  }

  void _onUpdate(ScaleUpdateDetails d) {
    if (_target == null) return;
    final delta = _local(d.focalPoint) - _startFocal;
    if (delta.distance > 4 || (d.scale - 1).abs() > 0.02 || d.rotation.abs() > 0.02) _moved = true;
    final center = Offset(
      (_startCenter.dx + delta.dx).clamp(0, _size.width),
      (_startCenter.dy + delta.dy).clamp(0, _size.height),
    );
    setState(() => _live = _LiveEdit(center, _startScale * d.scale, _startRotation + d.rotation * 180 / math.pi));
  }

  void _onEnd(ScaleEndDetails _) {
    final id = _target;
    final live = _live;
    _target = null;
    _live = null;
    if (id == null) return;
    if (!_moved || live == null) {
      // A tap: select, or deselect if already selected.
      widget.onSelect?.call(widget.selectedId == id ? null : id);
      setState(() {});
      return;
    }
    final x = _size.width <= 0 ? 50.0 : (live.center.dx / _size.width * 100).clamp(0.0, 100.0);
    final y = _size.height <= 0 ? 50.0 : (live.center.dy / _size.height * 100).clamp(0.0, 100.0);
    final rotation = _normalizeDegrees(live.rotationDeg);
    for (final s in _stickers) {
      if (s.id == id) {
        final next = s.copyWith(x: x, y: y, scale: live.scale.clamp(0.35, 3.0), rotation: rotation);
        _optimistic[id] = next;
        widget.onStickerChanged?.call(next);
      }
    }
    for (final t in _tapes) {
      if (t.id == id) {
        final next = t.copyWith(x: x, y: y, width: live.scale.clamp(36.0, 420.0), rotation: rotation);
        _optimistic[id] = next;
        widget.onTapeChanged?.call(next);
      }
    }
    if (widget.selectedId != id) widget.onSelect?.call(id);
    setState(() {});
  }

  static double _normalizeDegrees(double d) {
    var r = d % 360;
    if (r > 180) r -= 360;
    if (r <= -180) r += 360;
    return r;
  }

  /// Toolbar actions on the selected item (buttons, for precision and for
  /// people who can't pinch).
  void _adjust(String id, {double scaleBy = 1, double rotateBy = 0}) {
    for (final s in _stickers) {
      if (s.id == id) {
        final next = s.copyWith(
          scale: (s.scale * scaleBy).clamp(0.35, 3.0),
          rotation: _normalizeDegrees(s.rotation + rotateBy),
        );
        _optimistic[id] = next;
        widget.onStickerChanged?.call(next);
      }
    }
    for (final t in _tapes) {
      if (t.id == id) {
        final next = t.copyWith(
          width: (t.width * scaleBy).clamp(36.0, 420.0),
          rotation: _normalizeDegrees(t.rotation + rotateBy),
        );
        _optimistic[id] = next;
        widget.onTapeChanged?.call(next);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        final w = _size.width;
        final h = _size.height;
        final children = <Widget>[];
        _Placed? selected;

        Widget place(_Placed p, Size size, Widget art, {required String semantic}) {
          final live = (_live != null && _target == p.id) ? _live : null;
          final center = live?.center ?? p.center;
          final rotation = live?.rotationDeg ?? p.rotationDeg;
          final isSelected = widget.editable && widget.selectedId == p.id;
          if (isSelected) selected = _Placed(p.id, p.isTape, center, size, rotation);
          return Positioned(
            left: center.dx - size.width / 2,
            top: center.dy - size.height / 2,
            width: size.width,
            height: size.height,
            child: Semantics(
              label: semantic,
              selected: isSelected,
              child: Transform.rotate(
                angle: degToRad(rotation),
                child: DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: isSelected
                      ? BoxDecoration(
                          border: Border.all(color: context.chefColors.focusRing, width: 2),
                          borderRadius: BorderRadius.circular(6),
                        )
                      : const BoxDecoration(),
                  child: art,
                ),
              ),
            ),
          );
        }

        final placements = {for (final p in _placements()) p.id: p};
        for (final t in _tapes) {
          final p = placements[t.id]!;
          final live = (_live != null && _target == t.id) ? _live : null;
          final size = live == null ? p.size : tapeBoxSize(t.copyWith(width: live.scale), w);
          children.add(
            place(
              p,
              size,
              TapeArt(tape: t, size: size),
              semantic: 'Washi tape',
            ),
          );
        }
        for (final s in _stickers) {
          final p = placements[s.id]!;
          final live = (_live != null && _target == s.id) ? _live : null;
          final size = live == null ? p.size : stickerBoxSize(s.copyWith(scale: live.scale), w);
          children.add(
            place(
              p,
              size,
              StickerArt(sticker: s, size: size),
              semantic: s.label ?? 'Sticker',
            ),
          );
        }

        final layer = Stack(
          key: _layerKey,
          clipBehavior: Clip.none,
          children: [
            // Decorations never block taps on the page in reading mode.
            IgnorePointer(
              child: SizedBox(
                width: w,
                height: h,
                child: Stack(clipBehavior: Clip.none, children: children),
              ),
            ),
            if (widget.editable)
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerUp: (e) {
                    // A tap on empty paper clears the selection (raw pointer
                    // events, so page buttons underneath keep working).
                    if (_target == null && widget.selectedId != null && _hit(e.position) == null) {
                      widget.onSelect?.call(null);
                    }
                  },
                  child: RawGestureDetector(
                    behavior: HitTestBehavior.translucent,
                    gestures: {
                      _ItemScaleRecognizer: GestureRecognizerFactoryWithHandlers<_ItemScaleRecognizer>(
                        () => _ItemScaleRecognizer(allow: _allowPointer),
                        (r) => r
                          ..onStart = _onStart
                          ..onUpdate = _onUpdate
                          ..onEnd = _onEnd,
                      ),
                    },
                  ),
                ),
              ),
            if (selected != null && _live == null)
              _SelectionPill(
                anchor: selected!,
                layerSize: _size,
                isTape: selected!.isTape,
                onShrink: () => _adjust(selected!.id, scaleBy: 1 / 1.15),
                onGrow: () => _adjust(selected!.id, scaleBy: 1.15),
                onRotateLeft: () => _adjust(selected!.id, rotateBy: -15),
                onRotateRight: () => _adjust(selected!.id, rotateBy: 15),
                onFront: selected!.isTape ? null : () => widget.onBringToFront?.call(selected!.id),
                onRemove: () => widget.onRemove?.call(selected!.id),
              ),
          ],
        );
        return layer;
      },
    );
  }
}

/// Scale recognizer that only takes pointers [allow]s, and claims them
/// immediately so a vertical page scroll can't steal a sticker drag.
class _ItemScaleRecognizer extends ScaleGestureRecognizer {
  _ItemScaleRecognizer({required this.allow});
  final bool Function(PointerDownEvent) allow;

  @override
  bool isPointerAllowed(PointerDownEvent event) => super.isPointerAllowed(event) && allow(event);

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolvePointer(event.pointer, GestureDisposition.accepted);
  }
}

class _SelectionPill extends StatelessWidget {
  final _Placed anchor;
  final Size layerSize;
  final bool isTape;
  final VoidCallback onShrink;
  final VoidCallback onGrow;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback? onFront;
  final VoidCallback onRemove;

  const _SelectionPill({
    required this.anchor,
    required this.layerSize,
    required this.isTape,
    required this.onShrink,
    required this.onGrow,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onFront,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    const pillHeight = 44.0;
    final pillWidth = onFront == null ? 5 * 40.0 + 12 : 6 * 40.0 + 12;
    final radius = math.max(anchor.size.width, anchor.size.height) / 2;
    var top = anchor.center.dy - radius - pillHeight - 6;
    if (top < 0) top = anchor.center.dy + radius + 6; // no room above: show below
    final left = (anchor.center.dx - pillWidth / 2).clamp(0.0, math.max(0.0, layerSize.width - pillWidth)).toDouble();

    Widget button(IconData icon, String tip, VoidCallback? onTap, {Color? color}) => SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        tooltip: tip,
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: color),
      ),
    );

    return Positioned(
      left: left,
      top: top,
      child: Material(
        elevation: 4,
        color: c.surfacePaper,
        shape: StadiumBorder(side: BorderSide(color: c.outlineSubtle)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              button(LucideIcons.minus, isTape ? 'Shorter' : 'Smaller', onShrink),
              button(LucideIcons.plus, isTape ? 'Longer' : 'Bigger', onGrow),
              button(LucideIcons.rotateCcw, 'Rotate left', onRotateLeft),
              button(LucideIcons.rotateCw, 'Rotate right', onRotateRight),
              if (onFront != null) button(LucideIcons.bringToFront, 'Bring to front', onFront),
              button(LucideIcons.trash2, 'Remove', onRemove, color: c.stateDanger),
            ],
          ),
        ),
      ),
    );
  }
}
