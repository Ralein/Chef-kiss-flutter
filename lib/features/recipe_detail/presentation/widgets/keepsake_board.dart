import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../../app/chef_toast_service.dart';
import '../../../../app/providers.dart';
import '../../../../app/widgets/common_widgets.dart';
import '../../../recipe_editor/presentation/sticker_tray_modal.dart';

/// Scrapbook area where stickers and washi tape are placed freely.
///
/// Positions are stored as percentages (0–100) of the free space on the
/// board, so a layout survives different screen sizes.
class KeepsakeBoard extends ConsumerStatefulWidget {
  final Recipe recipe;
  final bool editing;
  final VoidCallback onDone;

  const KeepsakeBoard({super.key, required this.recipe, required this.editing, required this.onDone});

  @override
  ConsumerState<KeepsakeBoard> createState() => _KeepsakeBoardState();
}

class _KeepsakeBoardState extends ConsumerState<KeepsakeBoard> {
  static const double _boardHeight = 230;
  static const double _tapeHeight = 18;
  final Map<String, Offset> _live = {};

  double _stickerSize(ScrapbookSticker s) => (64 * s.scale).clamp(32, 120).toDouble();

  Future<void> _save(Recipe updated, {String? toast}) async {
    final repo = ref.read(recipeRepositoryProvider);
    final res = await repo.saveRecipe(updated);
    if (!mounted) return;
    if (res.isFailure) {
      ChefToastService.show(context: context, title: 'Could not save the page', type: ChefToastType.error);
    } else if (toast != null) {
      final previous = widget.recipe;
      ChefToastService.show(
        context: context,
        title: toast,
        type: ChefToastType.info,
        actionLabel: 'Undo',
        onAction: () => repo.saveRecipe(
              (res.orNull ?? updated).copyWith(stickers: previous.stickers, washiTapes: previous.washiTapes),
            ),
      );
    }
  }

  void _openTray() {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      builder: (_) => StickerTrayModal(
        targetPageSide: 'left',
        onTargetPageSideChanged: (_) {},
        onAddSticker: (sticker) => _save(widget.recipe.copyWith(
          stickers: [...widget.recipe.stickers, sticker.copyWith(pageSide: 'left', x: 50, y: 50)],
        )),
        onAddWashiTape: (tape) => _save(widget.recipe.copyWith(
          washiTapes: [...widget.recipe.washiTapes, tape.copyWith(pageSide: 'left', x: 50, y: 10)],
        )),
      ),
    );
  }

  Offset _pixelPos(double xPct, double yPct, double freeW, double freeH) =>
      Offset(freeW * (xPct.clamp(0, 100) / 100), freeH * (yPct.clamp(0, 100) / 100));

  void _commitSticker(ScrapbookSticker s, double freeW, double freeH) {
    final delta = _live.remove(s.id) ?? Offset.zero;
    final start = _pixelPos(s.x, s.y, freeW, freeH);
    final end = start + delta;
    final x = freeW <= 0 ? 50.0 : (end.dx / freeW * 100).clamp(0.0, 100.0);
    final y = freeH <= 0 ? 50.0 : (end.dy / freeH * 100).clamp(0.0, 100.0);
    _save(widget.recipe.copyWith(
      stickers: [for (final it in widget.recipe.stickers) it.id == s.id ? it.copyWith(x: x, y: y) : it],
    ));
  }

  void _commitTape(WashiTapeDecoration w, double freeW, double freeH) {
    final delta = _live.remove(w.id) ?? Offset.zero;
    final end = _pixelPos(w.x, w.y, freeW, freeH) + delta;
    final x = freeW <= 0 ? 50.0 : (end.dx / freeW * 100).clamp(0.0, 100.0);
    final y = freeH <= 0 ? 10.0 : (end.dy / freeH * 100).clamp(0.0, 100.0);
    _save(widget.recipe.copyWith(
      washiTapes: [for (final it in widget.recipe.washiTapes) it.id == w.id ? it.copyWith(x: x, y: y) : it],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final recipe = widget.recipe;
    final editing = widget.editing;
    if (!editing && recipe.stickers.isEmpty && recipe.washiTapes.isEmpty) return const SizedBox.shrink();

    return ChefCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            'Keepsake page',
            subtitle: editing ? 'Drag to place · tap × to remove' : null,
            trailing: editing
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: _openTray,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add'),
                      ),
                      const SizedBox(width: 4),
                      TextButton(onPressed: widget.onDone, child: const Text('Done')),
                    ],
                  )
                : null,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: _boardHeight,
              color: c.surfaceRaised,
              child: LayoutBuilder(builder: (context, box) {
                final children = <Widget>[];

                for (final w in recipe.washiTapes) {
                  final width = w.width.clamp(40, box.maxWidth).toDouble();
                  final freeW = (box.maxWidth - width).clamp(0, double.infinity).toDouble();
                  final freeH = (box.maxHeight - _tapeHeight).clamp(0, double.infinity).toDouble();
                  final pos = _pixelPos(w.x, w.y, freeW, freeH) + (_live[w.id] ?? Offset.zero);
                  final pattern = WashiTapePattern.values.firstWhere(
                    (p) => p.name == w.pattern,
                    orElse: () => WashiTapePattern.terracotta,
                  );
                  children.add(Positioned(
                    left: pos.dx.clamp(0, freeW),
                    top: pos.dy.clamp(0, freeH),
                    child: _Draggable(
                      editing: editing,
                      label: 'Washi tape',
                      onDrag: (d) => setState(() => _live[w.id] = (_live[w.id] ?? Offset.zero) + d),
                      onEnd: () => _commitTape(w, freeW, freeH),
                      onRemove: () => _save(
                        recipe.copyWith(washiTapes: recipe.washiTapes.where((it) => it.id != w.id).toList()),
                        toast: 'Washi tape removed',
                      ),
                      child: WashiTape(width: width, height: _tapeHeight, rotation: w.rotation, pattern: pattern),
                    ),
                  ));
                }

                for (final s in recipe.stickers) {
                  final size = _stickerSize(s);
                  final freeW = (box.maxWidth - size).clamp(0, double.infinity).toDouble();
                  final freeH = (box.maxHeight - size).clamp(0, double.infinity).toDouble();
                  final pos = _pixelPos(s.x, s.y, freeW, freeH) + (_live[s.id] ?? Offset.zero);
                  final stamp = renderCulinaryStampById(
                        s.content.isNotEmpty ? s.content : (s.iconId ?? 'food-donut'),
                        size: size,
                        rotation: s.rotation,
                      ) ??
                      Icon(Icons.star_rounded, size: size * 0.6, color: c.accentYolk);
                  children.add(Positioned(
                    left: pos.dx.clamp(0, freeW),
                    top: pos.dy.clamp(0, freeH),
                    child: _Draggable(
                      editing: editing,
                      label: s.label ?? 'Sticker',
                      onDrag: (d) => setState(() => _live[s.id] = (_live[s.id] ?? Offset.zero) + d),
                      onEnd: () => _commitSticker(s, freeW, freeH),
                      onRemove: () => _save(
                        recipe.copyWith(stickers: recipe.stickers.where((it) => it.id != s.id).toList()),
                        toast: 'Sticker removed',
                      ),
                      child: SizedBox(width: size, height: size, child: Center(child: stamp)),
                    ),
                  ));
                }

                if (children.isEmpty) {
                  children.add(Center(
                    child: Text(
                      'Add stickers and washi tape to make this page yours.',
                      style: context.chefText.bodyMedium?.copyWith(color: c.contentSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ));
                }
                return Stack(clipBehavior: Clip.hardEdge, children: children);
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _Draggable extends StatelessWidget {
  final bool editing;
  final String label;
  final ValueChanged<Offset> onDrag;
  final VoidCallback onEnd;
  final VoidCallback onRemove;
  final Widget child;

  const _Draggable({
    required this.editing,
    required this.label,
    required this.onDrag,
    required this.onEnd,
    required this.onRemove,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!editing) return Semantics(label: label, child: child);
    final c = context.chefColors;
    return Semantics(
      label: '$label, draggable',
      child: GestureDetector(
        onPanUpdate: (d) => onDrag(d.delta),
        onPanEnd: (_) => onEnd(),
        onPanCancel: onEnd,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              right: -10,
              top: -10,
              child: Material(
                color: c.stateDanger,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onRemove,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded, size: 14, color: c.onAccent, semanticLabel: 'Remove $label'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
