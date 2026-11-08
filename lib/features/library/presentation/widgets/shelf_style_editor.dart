import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../domain/shelf_style.dart';
import 'decor_art.dart';
import 'shelf_art.dart';
import 'shelf_edit_controller.dart';
import 'shelf_layout.dart';
import 'shelf_scene.dart' show ShelfMiniRoom;

enum _Category {
  looks('Looks', LucideIcons.swatchBook),
  wall('Wall', LucideIcons.image),
  shelf('Shelf', LucideIcons.rows3),
  kitchen('Kitchen', LucideIcons.cookingPot),
  plants('Plants', LucideIcons.sprout),
  lights('Lights', LucideIcons.lamp);

  final String label;
  final IconData icon;
  const _Category(this.label, this.icon);

  /// The palette of decorations a category offers, if any.
  DecorGroup? get group => switch (this) {
    _Category.kitchen => DecorGroup.kitchen,
    _Category.plants => DecorGroup.plants,
    _Category.lights => DecorGroup.lights,
    _ => null,
  };
}

const _cream = Color(0xFFFBF6EC);

/// Dress the bookcase: start from a ready-made look, pick the wall and the
/// shelves, then drag kitchen things, plants and candles onto the shelves —
/// or tap them to add — and move, flip, resize or remove what's there. The
/// shelves behind preview everything live; ✕ reverts.
class ShelfStyleEditor extends StatefulWidget {
  final ShelfEditController controller;
  final ValueChanged<ShelfStyle> onSave;
  final VoidCallback onCancel;

  /// Opens with the panel tucked away, leaving the shelves in view.
  final bool startCollapsed;

  const ShelfStyleEditor({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
    this.startCollapsed = false,
  });

  @override
  State<ShelfStyleEditor> createState() => _ShelfStyleEditorState();
}

class _ShelfStyleEditorState extends State<ShelfStyleEditor> {
  _Category _category = _Category.looks;
  late bool _panelOpen = !widget.startCollapsed;
  final _bottom = GlobalKey();

  ShelfEditController get _c => widget.controller;

  void _choose(_Category c) {
    _c.select(null);
    setState(() {
      if (_category == c) {
        _panelOpen = !_panelOpen;
      } else {
        _category = c;
        _panelOpen = true;
      }
    });
  }

  /// Tells the controller which band of screen shows the shelves, so a drag
  /// near either edge of it scrolls them.
  void _reportScene(double top) {
    if (!mounted) return;
    _c.sceneTop = top;
    final box = _bottom.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) _c.sceneBottom = box.localToGlobal(Offset.zero).dy;
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportScene(padding.top + 76));
    return Theme(
      data: ChefTheme.dark(),
      child: ListenableBuilder(
        listenable: _c,
        builder: (context, _) {
          final selected = _c.selected;
          return SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    _topBar(),
                    const Spacer(),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Padding(
                          key: _bottom,
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + padding.bottom),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSize(
                                duration: ChefMotion.standard,
                                curve: ChefMotion.easeStandard,
                                child: selected != null
                                    ? _piecePanel(context, selected)
                                    : _panelOpen
                                    ? _panel(context)
                                    : const SizedBox(width: double.infinity),
                              ),
                              const SizedBox(height: 10),
                              _toolbar(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (selected != null && !_c.dragging) _actionsFor(context, selected),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _topBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Row(
      children: [
        IconButton.outlined(
          tooltip: 'Discard changes',
          onPressed: widget.onCancel,
          icon: const Icon(LucideIcons.x),
          style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: 0.35)),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () => widget.onSave(_c.style),
          icon: const Icon(LucideIcons.check, size: 18),
          label: const Text('Save'),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.35),
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
          ),
        ),
      ],
    ),
  );

  /// Flip, duplicate and delete, floating above the selected piece — kept on
  /// screen when the piece stands at either end of a shelf.
  Widget _actionsFor(BuildContext context, PlacedDecor piece) {
    final m = _c.metrics;
    final left = ShelfMetrics.inset + m.leftOf(piece);
    final center = left + m.sizeOf(piece).width / 2;
    final width = MediaQuery.sizeOf(context).width;
    const half = _PieceActions.width / 2;
    final (target, follower, nudge) = center - half < 8
        ? (Alignment.topLeft, Alignment.bottomLeft, -6.0)
        : center + half > width - 8
        ? (Alignment.topRight, Alignment.bottomRight, 6.0)
        : (Alignment.topCenter, Alignment.bottomCenter, 0.0);
    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: _c.selectionLink,
        showWhenUnlinked: false,
        targetAnchor: target,
        followerAnchor: follower,
        offset: Offset(nudge, -14),
        child: _PieceActions(
          onFlip: () => _c.flip(piece.id),
          onDuplicate: () => _c.duplicate(piece.id),
          onDelete: () => _c.remove(piece.id),
        ),
      ),
    );
  }

  Widget _toolbar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: _glass(radius: 40),
      child: Row(
        children: [
          for (final c in _Category.values) ...[
            // Room first, then the things to put in it.
            if (c == _Category.kitchen)
              Container(
                width: 1,
                height: 28,
                color: context.chefColors.outlineSubtle,
                margin: const EdgeInsets.symmetric(horizontal: 2),
              ),
            Expanded(child: _tab(c)),
          ],
        ],
      ),
    );
  }

  Widget _tab(_Category c) {
    final active = c == _category && _c.selected == null && _panelOpen;
    return Tooltip(
      message: c.label,
      child: Semantics(
        button: true,
        selected: c == _category,
        label: c.label,
        excludeSemantics: true,
        child: InkResponse(
          radius: 28,
          onTap: () => _choose(c),
          child: LayoutBuilder(
            builder: (context, box) {
              final d = box.maxWidth.clamp(40.0, 52.0);
              return SizedBox(
                height: 52,
                child: Center(
                  child: AnimatedContainer(
                    duration: ChefMotion.quick,
                    width: d,
                    height: d,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: active ? _cream : Colors.transparent),
                    child: Icon(c.icon, color: active ? const Color(0xFF1C1A18) : context.chefColors.contentSecondary),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _panel(BuildContext context) {
    final t = context.chefText;
    final c = context.chefColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 18),
      decoration: _glass(radius: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(header: true, child: Text(_category.label, style: t.titleLarge)),
              ),
              IconButton(
                tooltip: 'Hide',
                onPressed: () => setState(() => _panelOpen = false),
                icon: Icon(LucideIcons.chevronDown, color: c.contentSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._options(),
          const SizedBox(height: 2),
          Text(_hint, style: t.bodySmall),
        ],
      ),
    );
  }

  String get _hint => switch (_category) {
    _Category.looks => 'Start from a ready-made kitchen. Hold any book or decoration to move it.',
    _Category.wall => 'The wall behind your shelves.',
    _Category.shelf => 'Shelf wood and the light strip underneath.',
    _ => 'Drag onto a shelf, or tap to add. Hold anything on the shelves, books too, to move it.',
  };

  List<Widget> _options() {
    final style = _c.style;
    final label = context.chefText.labelLarge?.copyWith(color: context.chefColors.contentSecondary);
    if (_category.group case final group?) {
      return [
        _tiles([
          for (final piece in DecorPiece.values)
            if (piece.group == group) _PaletteTile(piece: piece, controller: _c),
        ]),
        const SizedBox(height: 10),
      ];
    }
    switch (_category) {
      case _Category.looks:
        final bare = style.copyWith(decor: const []);
        return [
          _tiles([
            for (final look in shelfLooks)
              _Tile(
                label: look.name,
                selected: style.looksLike(look.style),
                onTap: () => _c.applyLook(look),
                child: ShelfMiniRoom(look.style),
              ),
            _Tile(label: 'Bare shelves', selected: _c.pieces.isEmpty, onTap: _c.clearDecor, child: ShelfMiniRoom(bare)),
          ]),
          const SizedBox(height: 10),
        ];
      case _Category.wall:
        return [
          _tiles([
            for (final w in WallStyle.values)
              _Tile(
                label: w.label,
                selected: style.wall == w,
                onTap: () => _c.style = style.copyWith(wall: w),
                // A patch of wall shrunk to fit, so tiles and magnets show at
                // something like their size on the shelves.
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: 210,
                    height: 200,
                    child: CustomPaint(
                      painter: WallPainter(style: w, tint: style.wallColor),
                    ),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 12),
          Text('Tint', style: label),
          // One row of equal cells: every swatch gets a full-size tap target.
          Row(
            children: [
              for (final (i, tint) in wallTints.indexed)
                Expanded(
                  child: _Swatch(
                    color: tint.color,
                    label: tint.name,
                    selected: style.tint == i,
                    onTap: () => _c.style = style.copyWith(tint: i),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ];
      case _Category.shelf:
        return [
          _tiles([
            for (final w in ShelfWood.values)
              _Tile(
                label: w.label,
                selected: style.wood == w,
                onTap: () => _c.style = style.copyWith(wood: w),
                child: ColoredBox(
                  color: style.wallColor,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ShelfPlank(wood: w, glow: style.glow, height: 12),
                    ),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Light strip', style: label),
              for (final g in ShelfGlow.values)
                ChoiceChip(
                  label: Text(g.label),
                  selected: style.glow == g,
                  onSelected: (_) => _c.style = style.copyWith(glow: g),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('Shelves', style: label),
              const Spacer(),
              IconButton(
                tooltip: 'Remove a shelf',
                onPressed: _c.shelfCount > 1 ? _c.removeShelf : null,
                icon: const Icon(LucideIcons.minus, size: 20),
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '${_c.shelfCount}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(tooltip: 'Add a shelf', onPressed: _c.addShelf, icon: const Icon(LucideIcons.plus, size: 20)),
            ],
          ),
          const SizedBox(height: 6),
        ];
      case _Category.kitchen || _Category.plants || _Category.lights:
        return const [];
    }
  }

  /// The selected piece: its name, its size, and how to move it.
  Widget _piecePanel(BuildContext context, PlacedDecor piece) {
    final t = context.chefText;
    final label = t.labelLarge?.copyWith(color: context.chefColors.contentSecondary);
    final percent = (piece.size * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 10, 14),
      decoration: _glass(radius: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(header: true, child: Text(piece.piece.label, style: t.titleLarge)),
              ),
              TextButton(onPressed: () => _c.select(null), child: const Text('Done')),
            ],
          ),
          Row(
            children: [
              Text('Size', style: label),
              Expanded(
                child: Semantics(
                  label: 'Size',
                  child: Slider(
                    value: piece.size,
                    min: PlacedDecor.minSize,
                    max: PlacedDecor.maxSize,
                    divisions: 18,
                    semanticFormatterCallback: (v) => '${(v * 100).round()} percent',
                    onChanged: (v) => _c.resize(piece.id, v),
                  ),
                ),
              ),
              SizedBox(
                width: 46,
                child: Text(
                  '$percent%',
                  textAlign: TextAlign.end,
                  style: label?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                ),
              ),
            ],
          ),
          Text('Drag it along the shelf or onto another one.', style: t.bodySmall),
        ],
      ),
    );
  }

  Widget _tiles(List<Widget> tiles) => SizedBox(
    height: 112,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: tiles.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, i) => tiles[i],
    ),
  );
}

BoxDecoration _glass({required double radius}) => BoxDecoration(
  color: const Color(0xF0151414),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
);

/// A decoration in the palette: tap to add it to a shelf, or drag it up
/// onto the one you want.
class _PaletteTile extends StatelessWidget {
  final DecorPiece piece;
  final ShelfEditController controller;

  const _PaletteTile({required this.piece, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = piece.size * controller.metrics.scale;
    final seed = controller.pieces.where((p) => p.piece == piece).length;
    return Draggable<DecorDrag>(
      data: DecorDrag.add(piece, size),
      // Sideways swipes scroll the palette; upward drags pick the piece up.
      affinity: Axis.vertical,
      // Held by its base (or by its hook, if it hangs), above the finger.
      dragAnchorStrategy: (_, _, _) => Offset(size.width / 2, piece.hangs ? size.height * 0.1 : size.height * 0.92),
      feedback: SizedBox.fromSize(
        size: size,
        child: Opacity(opacity: 0.92, child: DecorArt(piece, seed: seed)),
      ),
      onDragStarted: controller.dragStarted,
      onDragUpdate: (u) => controller.dragMoved(u.globalPosition),
      onDragEnd: (_) => controller.dragEnded(),
      child: _Tile(
        label: piece.label,
        hint: 'Adds it to a shelf',
        selected: false,
        onTap: () => controller.add(piece),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Align(
            alignment: piece.hangs ? Alignment.topCenter : Alignment.bottomCenter,
            child: FittedBox(
              child: SizedBox.fromSize(
                size: piece.size,
                child: DecorArt(piece, seed: seed),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Flip, duplicate and delete for the selected piece.
class _PieceActions extends StatelessWidget {
  final VoidCallback onFlip;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _PieceActions({required this.onFlip, required this.onDuplicate, required this.onDelete});

  /// Three 66-wide buttons, the padding and the border.
  static const width = 3 * 66.0 + 10;

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(4),
        decoration: _glass(radius: 18),
        child: Row(
          children: [
            // This package's flipVertical2 is the left-right mirror glyph.
            _action(context, LucideIcons.flipVertical2, 'Flip', onFlip, c.contentPrimary),
            _action(context, LucideIcons.copy, 'Duplicate', onDuplicate, c.contentPrimary),
            _action(context, LucideIcons.trash2, 'Delete', onDelete, c.stateDanger),
          ],
        ),
      ),
    );
  }

  Widget _action(BuildContext context, IconData icon, String label, VoidCallback onTap, Color color) => Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, maxLines: 1, style: context.chefText.labelSmall?.copyWith(color: color)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Tile extends StatelessWidget {
  final String label;
  final String? hint;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  const _Tile({required this.label, this.hint, required this.selected, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      hint: hint,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 84,
          child: Column(
            children: [
              AnimatedContainer(
                duration: ChefMotion.quick,
                width: 84,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF1F1E1D),
                  border: Border.all(
                    color: selected ? _cream : Colors.white.withValues(alpha: 0.08),
                    width: selected ? 2 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.chefText.labelMedium?.copyWith(
                  color: selected ? context.chefColors.contentPrimary : context.chefColors.contentSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Swatch({required this.color, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: '$label wall',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 48,
            child: Center(
              child: AnimatedContainer(
                duration: ChefMotion.quick,
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: selected ? const Color(0xFFE3C77F) : Colors.white.withValues(alpha: 0.18),
                    width: selected ? 2.5 : 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
