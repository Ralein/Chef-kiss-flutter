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
/// Books stand in [recipes] order, or as [arranged] by hand. With [edit],
/// the bookcase is being dressed: books and decorations can be picked up and
/// moved, and decorations dropped in from the editor's palette.
///
/// The wall itself is painted by the screen behind the scroll view.
class LibraryBookcase extends StatelessWidget {
  final List<Recipe> recipes;
  final ShelfStyle style;
  final List<List<String>>? arranged;
  final ValueChanged<Recipe> onOpen;
  final ValueChanged<Recipe>? onLongPress;
  final ShelfEditController? edit;

  /// While searching or filtering: how many matching recipes each book holds,
  /// by book id. Books with none fade; the others show their count.
  final Map<String, int>? matches;

  const LibraryBookcase({
    super.key,
    required this.recipes,
    required this.style,
    this.arranged,
    required this.onOpen,
    this.onLongPress,
    this.edit,
    this.matches,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final metrics = ShelfMetrics.forWidth(constraints.crossAxisExtent);
        final rows = layoutShelves(
          recipes,
          style.pieces,
          metrics,
          arranged: arranged,
          minShelves: style.shelves ?? ShelfMetrics.minShelves,
        );
        // The books as they stand now: where a moved book is taken from.
        final shelves = [
          for (final r in rows) [for (final b in r.books) b.recipe.id],
        ];
        if (edit case final edit?) {
          edit.metrics = metrics;
          edit.reportShelves(rows.length);
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
              shelves: shelves,
              style: style,
              metrics: metrics,
              onOpen: onOpen,
              onLongPress: onLongPress,
              edit: edit,
              matches: matches,
            );
          },
        );
      },
    );
  }
}

class _ShelfRow extends StatefulWidget {
  final ShelfRowPlan row;
  final List<List<String>> shelves;
  final ShelfStyle style;
  final ShelfMetrics metrics;
  final ValueChanged<Recipe> onOpen;
  final ValueChanged<Recipe>? onLongPress;
  final ShelfEditController? edit;
  final Map<String, int>? matches;

  const _ShelfRow({
    required this.row,
    required this.shelves,
    required this.style,
    required this.metrics,
    required this.onOpen,
    required this.onLongPress,
    required this.edit,
    required this.matches,
  });

  @override
  State<_ShelfRow> createState() => _ShelfRowState();
}

class _ShelfRowState extends State<_ShelfRow> {
  /// Where something dragged over this shelf would land: a box for a
  /// decoration, a bar between books for a book.
  ({Rect rect, bool between})? _landing;

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
              key: const ValueKey('wall'),
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => edit.select(null)),
            ),
          for (final b in row.books) _book(b),
          // Standing pieces, then what hangs in front of them; each in the
          // order placed, so the last moved is on top.
          for (final d in row.decor)
            if (!d.hangs) _piece(d),
          for (final d in row.decor)
            if (d.hangs) _piece(d),
          if (_landing case final landing?)
            Positioned.fromRect(
              rect: landing.rect,
              child: _LandingMarker(between: landing.between),
            ),
          Positioned(
            left: 4,
            right: 4,
            bottom: 0,
            child: ShelfPlank(wood: widget.style.wood, glow: widget.style.glow, height: _m.plank),
          ),
        ],
      ),
    );
    // The same widgets whether or not the shelves are being dressed, so
    // switching keeps every book (and its loaded cover) as it is.
    return DragTarget<Object>(
      onWillAcceptWithDetails: (d) => widget.edit != null && (d.data is DecorDrag || d.data is BookDrag),
      onMove: (details) {
        final landing = _landingFor(details);
        if (landing != _landing) setState(() => _landing = landing);
      },
      onLeave: (_) => setState(() => _landing = null),
      onAcceptWithDetails: (details) {
        setState(() => _landing = null);
        switch (details.data) {
          case final DecorDrag drag:
            final x = _m.xFor(_left(details.offset), drag.size.width);
            if (drag.placed case final placed?) {
              edit?.move(placed.id, shelf: row.index, x: x);
            } else {
              edit?.add(drag.piece, shelf: row.index, x: x);
            }
          case final BookDrag drag:
            final index = _bookIndex(drag, _left(details.offset) + drag.size.width / 2);
            edit?.arrangeBooks(moveBook(widget.shelves, drag.recipeId, row.index, index));
        }
      },
      builder: (context, _, _) => scene,
    );
  }

  /// Where the dragged thing's left edge is, from the left end of this shelf.
  double _left(Offset globalTopLeft) {
    final box = context.findRenderObject()! as RenderBox;
    return box.globalToLocal(globalTopLeft).dx - _inset;
  }

  /// Where on this shelf a book dropped with its middle at [center] goes:
  /// before the first book whose middle is further right.
  int _bookIndex(BookDrag drag, double center) =>
      widget.row.books.where((b) => b.recipe.id != drag.recipeId && b.left + b.width / 2 < center).length;

  ({Rect rect, bool between})? _landingFor(DragTargetDetails<Object> details) {
    switch (details.data) {
      case final DecorDrag drag:
        final size = drag.size;
        final x = _m.xFor(_left(details.offset), size.width);
        final left = _inset + x * (_m.inner - size.width).clamp(0.0, double.infinity);
        final top = drag.piece.hangs ? 0.0 : _m.room - size.height;
        return (rect: Rect.fromLTWH(left, top, size.width, size.height), between: false);
      case final BookDrag drag:
        final center = _left(details.offset) + drag.size.width / 2;
        final others = [
          for (final b in widget.row.books)
            if (b.recipe.id != drag.recipeId) b,
        ];
        final index = _bookIndex(drag, center);
        final x = others.isEmpty
            ? center
            : index < others.length
            ? others[index].left - 2
            : others.last.left + others.last.width + 2;
        final height = drag.size.height;
        return (rect: Rect.fromLTWH(_inset + x - 1.5, _m.room - height, 3, height), between: true);
    }
    return null;
  }

  /// While filtering, a book without matches fades; one with them shows how many.
  Widget _withMatches(String id, Widget book) {
    final matches = widget.matches;
    if (matches == null) return book;
    final count = matches[id] ?? 0;
    if (count == 0) return Opacity(opacity: 0.3, child: book);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: book),
        Positioned(
          top: -8,
          right: -8,
          child: Semantics(label: '$count matching', child: _MatchBadge(count)),
        ),
      ],
    );
  }

  Widget _book(BookSpot b) {
    final edit = widget.edit;
    final Widget book = _withMatches(
      b.recipe.id,
      ShelfBook(
        recipe: b.recipe,
        faceOut: b.faceOut,
        width: b.width,
        height: b.height,
        scale: _m.scale,
        // While dressing the shelves a tap only puts down a selected piece.
        onTap: edit == null ? () => widget.onOpen(b.recipe) : () => edit.select(null),
        onLongPress: edit == null && widget.onLongPress != null ? () => widget.onLongPress!(b.recipe) : null,
      ),
    );
    // Books slide aside as others (or decorations) move in. Each keeps the
    // same widgets in and out of the editor, so none reloads its cover.
    return AnimatedPositioned(
      key: ValueKey('book ${b.recipe.id}'),
      duration: edit == null ? Duration.zero : ChefMotion.standard,
      curve: ChefMotion.easeStandard,
      left: _inset + b.left,
      bottom: _m.plank + 3,
      width: b.width,
      height: b.height,
      child: _MovableBook(
        spot: b,
        shelf: widget.row.index,
        shelves: widget.shelves,
        edit: edit,
        scale: _m.scale,
        child: book,
      ),
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

/// A book that, while the shelves are being dressed ([edit] set), can be
/// held and carried along the shelf or onto another one.
/// A count of matching recipes, pinned to a book's top corner.
class _MatchBadge extends StatelessWidget {
  final int count;
  const _MatchBadge(this.count);

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.accentTomato,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 3)],
      ),
      child: Text(
        '$count',
        style: TextStyle(color: c.contentInverse, fontSize: 12, fontWeight: FontWeight.w700, height: 1),
      ),
    );
  }
}

class _MovableBook extends StatelessWidget {
  final BookSpot spot;
  final int shelf;
  final List<List<String>> shelves;
  final ShelfEditController? edit;
  final double scale;
  final Widget child;

  const _MovableBook({
    required this.spot,
    required this.shelf,
    required this.shelves,
    required this.edit,
    required this.scale,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final edit = this.edit;
    final id = spot.recipe.id;
    final onShelf = shelves[shelf];
    final i = onShelf.indexOf(id);
    void moveTo(int toShelf, int index) => edit?.arrangeBooks(moveBook(shelves, id, toShelf, index));
    final size = Size(spot.width, spot.height);
    final face = spot.faceOut ? BookCoverFace(recipe: spot.recipe) : BookSpine(recipe: spot.recipe, scale: scale);
    return Semantics(
      // In the editor a book is something to move rather than to open.
      excludeSemantics: edit != null,
      button: edit != null ? true : null,
      label: edit == null ? null : '${spot.recipe.title}, shelf ${shelf + 1}',
      hint: edit == null ? null : 'Hold to move it',
      customSemanticsActions: edit == null
          ? null
          : {
              if (i > 0 || shelf > 0)
                const CustomSemanticsAction(label: 'Move left'): () =>
                    i > 0 ? moveTo(shelf, i - 1) : moveTo(shelf - 1, shelves[shelf - 1].length),
              const CustomSemanticsAction(label: 'Move right'): () =>
                  i < onShelf.length - 1 ? moveTo(shelf, i + 1) : moveTo(shelf + 1, 0),
              if (shelf > 0) const CustomSemanticsAction(label: 'Move up a shelf'): () => moveTo(shelf - 1, i),
              const CustomSemanticsAction(label: 'Move down a shelf'): () => moveTo(shelf + 1, i),
            },
      child: LongPressDraggable<Object>(
        data: BookDrag(id, size),
        // Only while dressing the shelves.
        maxSimultaneousDrags: edit == null ? 0 : null,
        delay: const Duration(milliseconds: 300),
        feedback: SizedBox.fromSize(
          size: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 14, offset: const Offset(3, 8)),
              ],
            ),
            child: face,
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.25, child: child),
        onDragStarted: () {
          HapticFeedback.selectionClick();
          edit?.dragStarted();
        },
        onDragUpdate: (u) => edit?.dragMoved(u.globalPosition),
        onDragEnd: (_) => edit?.dragEnded(),
        child: child,
      ),
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
    // The whole box takes the touch, even for art that ignores touches
    // itself, like the hanging rail and trailing ivy.
    final target = ColoredBox(color: const Color(0x00000000), child: shown);
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
            child: target,
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
            child: target,
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

/// Where a dragged decoration will land, or the gap a book will go into.
class _LandingMarker extends StatelessWidget {
  final bool between;
  const _LandingMarker({required this.between});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: DecoratedBox(
      decoration: between
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.white.withValues(alpha: 0.85),
              boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.4), blurRadius: 8)],
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withValues(alpha: 0.10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
            ),
    ),
  );
}
