import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../domain/shelf_style.dart';
import 'library_books.dart';
import 'shelf_art.dart';

enum _Category {
  wall('Wall', LucideIcons.image),
  shelf('Shelf', LucideIcons.rows3),
  lights('Lights', LucideIcons.lamp),
  plants('Plants', LucideIcons.sprout),
  flowers('Flowers', LucideIcons.flower2);

  final String label;
  final IconData icon;
  const _Category(this.label, this.icon);
}

/// Dress the bookcase: wall texture and colour, shelf wood and LED strip,
/// candles, greenery and flowers. Changes preview live; ✕ reverts.
class ShelfStyleEditor extends StatefulWidget {
  final ShelfStyle initial;
  final ValueChanged<ShelfStyle> onPreview;
  final ValueChanged<ShelfStyle> onSave;
  final VoidCallback onCancel;

  const ShelfStyleEditor({
    super.key,
    required this.initial,
    required this.onPreview,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<ShelfStyleEditor> createState() => _ShelfStyleEditorState();
}

class _ShelfStyleEditorState extends State<ShelfStyleEditor> {
  late ShelfStyle _style = widget.initial;
  _Category _category = _Category.wall;
  bool _panelOpen = true;

  void _set(ShelfStyle s) {
    setState(() => _style = s);
    widget.onPreview(s);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Theme(
      data: ChefTheme.dark(),
      child: Builder(
        builder: (context) => SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
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
                      onPressed: () => widget.onSave(_style),
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
              ),
              const Spacer(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSize(
                          duration: ChefMotion.standard,
                          curve: ChefMotion.easeStandard,
                          child: _panelOpen ? _panel(context) : const SizedBox(width: double.infinity),
                        ),
                        const SizedBox(height: 10),
                        _toolbar(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: _glass(radius: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final c in _Category.values)
            Tooltip(
              message: c.label,
              child: Semantics(
                button: true,
                selected: c == _category,
                label: c.label,
                excludeSemantics: true,
                child: InkResponse(
                  radius: 30,
                  onTap: () => setState(() {
                    if (_category == c) {
                      _panelOpen = !_panelOpen;
                    } else {
                      _category = c;
                      _panelOpen = true;
                    }
                  }),
                  child: AnimatedContainer(
                    duration: ChefMotion.quick,
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c == _category ? const Color(0xFFFBF6EC) : Colors.transparent,
                    ),
                    child: Icon(c.icon, color: c == _category ? const Color(0xFF1C1A18) : Colors.white70),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _panel(BuildContext context) {
    final t = context.chefText;
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
                child: Text(
                  _category.label,
                  style: const TextStyle(
                    fontFamily: kSerifFamily,
                    fontStyle: FontStyle.italic,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Hide',
                onPressed: () => setState(() => _panelOpen = false),
                icon: const Icon(LucideIcons.chevronDown, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._options(context),
          const SizedBox(height: 2),
          Text(_hint, style: t.bodySmall?.copyWith(color: Colors.white54)),
        ],
      ),
    );
  }

  String get _hint => switch (_category) {
    _Category.wall => 'The wall behind your shelves.',
    _Category.shelf => 'Shelf wood and the light strip underneath.',
    _Category.lights => 'Candles flicker softly between your books.',
    _Category.plants => 'Potted plants and ivy trailing over the shelves.',
    _Category.flowers => 'A vase on alternate shelves.',
  };

  List<Widget> _options(BuildContext context) {
    switch (_category) {
      case _Category.wall:
        return [
          _tiles([
            for (final w in WallStyle.values)
              _Tile(
                label: w.label,
                selected: _style.wall == w,
                onTap: () => _set(_style.copyWith(wall: w)),
                child: CustomPaint(
                  painter: WallPainter(style: w, tint: _style.wallColor),
                ),
              ),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Tint', style: TextStyle(color: Colors.white70)),
              for (final (i, tint) in wallTints.indexed)
                _Swatch(
                  color: tint.color,
                  label: tint.name,
                  selected: _style.tint == i,
                  onTap: () => _set(_style.copyWith(tint: i)),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ];
      case _Category.shelf:
        return [
          _tiles([
            for (final w in ShelfWood.values)
              _Tile(
                label: w.label,
                selected: _style.wood == w,
                onTap: () => _set(_style.copyWith(wood: w)),
                child: ColoredBox(
                  color: _style.wallColor,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ShelfPlank(wood: w, glow: _style.glow, height: 12),
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
              const Text('Light strip', style: TextStyle(color: Colors.white70)),
              for (final g in ShelfGlow.values)
                ChoiceChip(
                  label: Text(g.label),
                  selected: _style.glow == g,
                  onSelected: (_) => _set(_style.copyWith(glow: g)),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ];
      case _Category.lights:
        return [
          _tiles([
            for (final a in CandleAmount.values)
              _Tile(
                label: a.label,
                selected: _style.candles == a,
                onTap: () => _set(_style.copyWith(candles: a)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: switch (a) {
                      CandleAmount.none => [const Icon(LucideIcons.ban, color: Colors.white38)],
                      CandleAmount.few => [
                        SizedBox.fromSize(
                          size: Candle.sizeOf(CandleKind.pillar, 0.8),
                          child: const Candle(kind: CandleKind.pillar),
                        ),
                      ],
                      CandleAmount.many => [
                        SizedBox.fromSize(
                          size: Candle.sizeOf(CandleKind.taper, 0.7),
                          child: const Candle(kind: CandleKind.taper, seed: 1),
                        ),
                        const SizedBox(width: 6),
                        SizedBox.fromSize(
                          size: Candle.sizeOf(CandleKind.pillar, 0.8),
                          child: const Candle(kind: CandleKind.pillar, seed: 2),
                        ),
                      ],
                    },
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 10),
        ];
      case _Category.plants:
        return [
          _tiles([
            for (final g in Greenery.values)
              _Tile(
                label: g.label,
                selected: _style.greenery == g,
                onTap: () => _set(_style.copyWith(greenery: g)),
                child: switch (g) {
                  Greenery.none => const Center(child: Icon(LucideIcons.ban, color: Colors.white38)),
                  Greenery.potted => const Padding(padding: EdgeInsets.all(8), child: PottedPlant(seed: 1)),
                  Greenery.lush => const Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(padding: EdgeInsets.fromLTRB(22, 14, 6, 6), child: PottedPlant(seed: 2)),
                      Positioned(left: 4, top: 0, width: 40, height: 56, child: TrailingIvy(seed: 3)),
                    ],
                  ),
                  Greenery.ivy => const Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 6),
                    child: TrailingIvy(seed: 4),
                  ),
                },
              ),
          ]),
          const SizedBox(height: 10),
        ];
      case _Category.flowers:
        return [
          _tiles([
            for (final f in FlowerKind.values)
              _Tile(
                label: f.label,
                selected: _style.flowers == f,
                onTap: () => _set(_style.copyWith(flowers: f)),
                child: f == FlowerKind.none
                    ? const Center(child: Icon(LucideIcons.ban, color: Colors.white38))
                    : Padding(
                        padding: const EdgeInsets.all(8),
                        child: FlowerVase(kind: f, seed: f.index),
                      ),
              ),
          ]),
          const SizedBox(height: 10),
        ];
    }
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

  BoxDecoration _glass({required double radius}) => BoxDecoration(
    color: const Color(0xF0151414),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
  );
}

class _Tile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  const _Tile({required this.label, required this.selected, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
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
                    color: selected ? const Color(0xFFFBF6EC) : Colors.white.withValues(alpha: 0.08),
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
                style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.white54),
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
          child: AnimatedContainer(
            duration: ChefMotion.quick,
            width: 34,
            height: 34,
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
    );
  }
}
