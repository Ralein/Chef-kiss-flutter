import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../domain/shelf_style.dart';
import 'decor_art.dart';
import 'library_books.dart';
import 'shelf_art.dart';
import 'shelf_edit_controller.dart';
import 'shelf_layout.dart';

/// The library as floating kitchen shelves on a wall: books spine-out (and a
/// few face-out) around the decorations placed on them — crocks of
/// utensils, pantry jars, pots, candles, plants and flowers — with LED strips
/// glowing under each shelf and ivy or a utensil rail hanging below.
///
/// With [edit], the bookcase is being dressed: books step back, and every
/// decoration can be selected, dragged to another spot or shelf, or dropped
/// in from the editor's palette.
///
/// The wall itself is painted by the screen behind the scroll view.
class LibraryBookcase extends StatelessWidget {
  final List<Recipe> recipes;
  final ShelfStyle style;
  final ValueChanged<Recipe> onOpen;
  final ValueChanged<Recipe>? onLongPress;
  final ShelfEditController? edit;

  const LibraryBookcase({
    super.key,
    required this.recipes,
    required this.style,
    required this.onOpen,
    this.onLongPress,
    this.edit,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final metrics = ShelfMetrics.forWidth(constraints.crossAxisExtent);
        final rows = layoutShelves(recipes, style.pieces, metrics);
        if (edit case final edit?) {
          edit.metrics = metrics;
          edit.shelfCount = rows.length;
        }
        return SliverList.builder(
          itemCount: rows.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              // The top shelf edge: lights the first row and holds what hangs into it.
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ShelfPlank(wood: style.wood, glow: style.glow, height: 10 * metrics.scale),
              );
            }
            return _ShelfRow(
              row: rows[i - 1],
              style: style,
              metrics: metrics,
              onOpen: onOpen,
              onLongPress: onLongPress,
              edit: edit,
            );
          },
        );
      },
    );
  }
}

class _ShelfRow extends StatefulWidget {
  final ShelfRowPlan row;
  final ShelfStyle style;
  final ShelfMetrics metrics;
  final ValueChanged<Recipe> onOpen;
  final ValueChanged<Recipe>? onLongPress;
  final ShelfEditController? edit;

  const _ShelfRow({
    required this.row,
    required this.style,
    required this.metrics,
    required this.onOpen,
    required this.onLongPress,
    required this.edit,
  });

  @override
  State<_ShelfRow> createState() => _ShelfRowState();
}

class _ShelfRowState extends State<_ShelfRow> {
  /// Where a piece being dragged over this shelf would land.
  Rect? _landing;

  ShelfMetrics get _m => widget.metrics;
  static const _inset = ShelfMetrics.inset;

  @override
  Widget build(BuildContext context) {
    final edit = widget.edit;
    final row = widget.row;
    final scene = SizedBox(
      height: _m.rowHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 8,
            right: 8,
            child: LightWash(glow: widget.style.glow, height: 110 * _m.scale),
          ),
          if (edit != null)
            // Tapping the wall puts down whatever is selected.
            Positioned.fill(
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => edit.select(null)),
            ),
          for (final b in row.books) _book(b),
          // Standing pieces, then what hangs in front of them; each in the
          // order placed, so the last moved is on top.
          for (final d in row.decor)
            if (!d.hangs) _piece(d),
          for (final d in row.decor)
            if (d.hangs) _piece(d),
          if (_landing case final landing?) Positioned.fromRect(rect: landing, child: const _LandingMarker()),
          Positioned(
            left: 4,
            right: 4,
            bottom: 0,
            child: ShelfPlank(wood: widget.style.wood, glow: widget.style.glow, height: _m.plank),
          ),
        ],
      ),
    );
    if (edit == null) return scene;
    return DragTarget<DecorDrag>(
      onMove: (details) {
        final landing = _landingFor(details);
        if (landing != _landing) setState(() => _landing = landing);
      },
      onLeave: (_) => setState(() => _landing = null),
      onAcceptWithDetails: (details) {
        setState(() => _landing = null);
        final x = _xFor(details);
        if (details.data.placed case final placed?) {
          edit.move(placed.id, shelf: row.index, x: x);
        } else {
          edit.add(details.data.piece, shelf: row.index, x: x);
        }
      },
      builder: (context, _, _) => scene,
    );
  }

  /// The dragged art's left edge, as an x position on this shelf.
  double _xFor(DragTargetDetails<DecorDrag> details) {
    final box = context.findRenderObject()! as RenderBox;
    final topLeft = box.globalToLocal(details.offset);
    return _m.xFor(topLeft.dx - _inset, details.data.size.width);
  }

  Rect _landingFor(DragTargetDetails<DecorDrag> details) {
    final size = details.data.size;
    final left = _inset + _xFor(details) * (_m.inner - size.width).clamp(0.0, double.infinity);
    final top = details.data.piece.hangs ? 0.0 : _m.room - size.height;
    return Rect.fromLTWH(left, top, size.width, size.height);
  }

  Widget _book(BookSpot b) {
    final edit = widget.edit;
    final book = ShelfBook(
      recipe: b.recipe,
      faceOut: b.faceOut,
      width: b.width,
      height: b.height,
      scale: _m.scale,
      onTap: () => widget.onOpen(b.recipe),
      onLongPress: widget.onLongPress == null ? null : () => widget.onLongPress!(b.recipe),
    );
    if (edit == null) {
      return Positioned(
        key: ValueKey('book ${b.recipe.id}'),
        left: _inset + b.left,
        bottom: _m.plank + 3,
        width: b.width,
        height: b.height,
        child: book,
      );
    }
    // While dressing the shelves, books step back and slide aside for decor.
    return AnimatedPositioned(
      key: ValueKey('book ${b.recipe.id}'),
      duration: ChefMotion.standard,
      curve: ChefMotion.easeStandard,
      left: _inset + b.left,
      bottom: _m.plank + 3,
      width: b.width,
      height: b.height,
      child: IgnorePointer(child: Opacity(opacity: 0.32, child: book)),
    );
  }

  Widget _piece(DecorSpot d) {
    final art = DecorArt(d.decor.piece, seed: d.decor.seed, flipped: d.decor.flipped);
    final edit = widget.edit;
    return Positioned(
      key: ValueKey('decor ${d.decor.id}'),
      left: _inset + d.left,
      top: d.hangs ? 0 : null,
      bottom: d.hangs ? null : _m.plank + 3,
      width: d.size.width,
      height: d.size.height,
      child: edit == null ? art : _EditablePiece(spot: d, edit: edit, child: art),
    );
  }
}

/// A decoration while the shelves are being dressed: tap to select, drag a
/// selected piece (or hold any piece) to move it.
class _EditablePiece extends StatelessWidget {
  final DecorSpot spot;
  final ShelfEditController edit;
  final Widget child;

  const _EditablePiece({required this.spot, required this.edit, required this.child});

  @override
  Widget build(BuildContext context) {
    final d = spot.decor;
    final selected = edit.selected?.id == d.id;
    if (selected && edit.takeReveal(d.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Scrollable.ensureVisible(context, alignment: 0.4, duration: ChefMotion.standard);
        }
      });
    }

    final shown = selected
        ? CompositedTransformTarget(
            link: edit.selectionLink,
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                child,
                const Positioned(left: -6, top: -6, right: -6, bottom: -6, child: _SelectionOutline()),
              ],
            ),
          )
        : child;
    final feedback = _DragFeedback(size: spot.size, child: child);
    final ghost = Opacity(opacity: 0.25, child: child);
    final data = DecorDrag.move(d, spot.size);
    // A selected piece moves with a plain drag; any other needs a hold, so
    // swiping across the shelves still scrolls them.
    final draggable = selected
        ? Draggable<DecorDrag>(
            data: data,
            feedback: feedback,
            childWhenDragging: ghost,
            onDragStarted: edit.dragStarted,
            onDragUpdate: (u) => edit.dragMoved(u.globalPosition),
            onDragEnd: (_) => edit.dragEnded(),
            child: shown,
          )
        : LongPressDraggable<DecorDrag>(
            data: data,
            delay: const Duration(milliseconds: 300),
            feedback: feedback,
            childWhenDragging: ghost,
            onDragStarted: () {
              HapticFeedback.selectionClick();
              edit.dragStarted();
            },
            onDragUpdate: (u) => edit.dragMoved(u.globalPosition),
            onDragEnd: (_) => edit.dragEnded(),
            child: shown,
          );

    return Semantics(
      button: true,
      selected: selected,
      label: '${d.piece.label}, shelf ${d.shelf + 1}',
      hint: selected ? null : 'Double tap to select it',
      onTap: () => edit.select(d.id),
      customSemanticsActions: selected
          ? {
              const CustomSemanticsAction(label: 'Move left'): () => edit.nudge(d.id, dx: -1),
              const CustomSemanticsAction(label: 'Move right'): () => edit.nudge(d.id, dx: 1),
              if (d.shelf > 0)
                const CustomSemanticsAction(label: 'Move up a shelf'): () => edit.nudge(d.id, shelves: -1),
              if (d.shelf < edit.shelfCount - 1)
                const CustomSemanticsAction(label: 'Move down a shelf'): () => edit.nudge(d.id, shelves: 1),
            }
          : null,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: selected ? SystemMouseCursors.grab : SystemMouseCursors.click,
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => edit.select(d.id), child: draggable),
      ),
    );
  }
}

class _DragFeedback extends StatelessWidget {
  final Size size;
  final Widget child;
  const _DragFeedback({required this.size, required this.child});

  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
    size: size,
    child: Opacity(opacity: 0.92, child: child),
  );
}

class _SelectionOutline extends StatelessWidget {
  const _SelectionOutline();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 1.5),
      ),
    ),
  );
}

/// Where a dragged piece will land.
class _LandingMarker extends StatelessWidget {
  const _LandingMarker();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
    ),
  );
}
