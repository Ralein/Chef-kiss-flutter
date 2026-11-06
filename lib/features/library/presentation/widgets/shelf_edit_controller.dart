import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../domain/shelf_style.dart';
import 'shelf_layout.dart';

/// What is being dragged onto a shelf: a new piece from the editor's
/// palette, or one already standing somewhere.
@immutable
class DecorDrag {
  final DecorPiece piece;
  final PlacedDecor? placed;

  /// The dragged art's size on screen.
  final Size size;

  const DecorDrag.add(this.piece, this.size) : placed = null;
  DecorDrag.move(PlacedDecor this.placed, this.size) : piece = placed.piece;
}

/// A book being carried to another spot on the shelves.
@immutable
class BookDrag {
  final String recipeId;

  /// The book's size on screen.
  final Size size;

  const BookDrag(this.recipeId, this.size);
}

/// The bookcase being dressed: a working copy of its style, the selected
/// decoration, and any drag in progress. Shared by the style editor's panels
/// and the bookcase previewing them.
class ShelfEditController extends ChangeNotifier {
  ShelfEditController(ShelfStyle initial, {this.scroll}) : _style = initial;

  /// The shelves' scroll view, scrolled while a piece is dragged to an edge.
  final ScrollController? scroll;

  /// Ties the selected piece's toolbar to the piece.
  final selectionLink = LayerLink();

  /// Reported by the bookcase as it lays out.
  ShelfMetrics metrics = ShelfMetrics.forWidth(390);
  int shelfCount = ShelfMetrics.minShelves;

  /// The band of screen where shelves can be seen, between the editor's top
  /// bar and its panel.
  double sceneTop = 0;
  double sceneBottom = double.infinity;

  ShelfStyle _style;
  String? _selectedId;
  String? _reveal;
  bool _dragging = false;
  bool _booksMoved = false;
  int _ids = 0;

  ShelfStyle get style => _style;
  List<PlacedDecor> get pieces => _style.pieces;
  bool get dragging => _dragging;

  /// Whether a book was moved since the editor opened: the shelves then show
  /// the books as arranged, whatever order the library is sorted in.
  bool get booksMoved => _booksMoved;
  PlacedDecor? get selected => _selectedId == null ? null : pieces.where((p) => p.id == _selectedId).firstOrNull;

  set style(ShelfStyle style) {
    if (style == _style) return;
    _style = style;
    notifyListeners();
  }

  void select(String? id) {
    if (id == _selectedId) return;
    _selectedId = id;
    notifyListeners();
  }

  /// True once for a piece that was just added, so it can scroll into view.
  bool takeReveal(String id) {
    if (_reveal != id) return false;
    _reveal = null;
    return true;
  }

  void _setPieces(List<PlacedDecor> pieces, {String? select, bool reveal = false}) {
    _style = _style.copyWith(decor: pieces);
    if (select != null) _selectedId = select;
    if (reveal) _reveal = select;
    if (_selectedId != null && !pieces.any((p) => p.id == _selectedId)) _selectedId = null;
    notifyListeners();
  }

  void _change(String id, PlacedDecor Function(PlacedDecor) change, {bool toFront = false, bool select = false}) {
    final list = [...pieces];
    final i = list.indexWhere((p) => p.id == id);
    if (i < 0) return;
    final changed = change(list.removeAt(i));
    // Drawn in list order: something just moved goes on top.
    list.insert(toFront ? list.length : i, changed);
    _setPieces(list, select: select ? id : null);
  }

  /// Moves a piece (and selects it), on top of anything it now overlaps.
  void move(String id, {required int shelf, required double x}) =>
      _change(id, (p) => p.copyWith(shelf: shelf, x: x), toFront: true, select: true);

  /// Moves a piece a step sideways or a shelf up or down: the keyboard and
  /// screen-reader way to move it.
  void nudge(String id, {int dx = 0, int shelves = 0}) => _change(
    id,
    (p) => p.copyWith(x: p.x + dx * 0.1, shelf: (p.shelf + shelves).clamp(0, math.max(0, shelfCount - 1))),
  );

  void resize(String id, double size) => _change(id, (p) => p.copyWith(size: size));
  void flip(String id) => _change(id, (p) => p.copyWith(flipped: !p.flipped));
  void remove(String id) => _setPieces([
    for (final p in pieces)
      if (p.id != id) p,
  ]);

  String _newId() => 'p${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}${_ids++}';

  /// Adds [piece] at a spot, or else in the first free space from the top
  /// shelf down, and selects it.
  void add(DecorPiece piece, {int? shelf, double? x}) {
    var spot = (shelf: shelf ?? 0, x: x ?? 0.5);
    if (shelf == null || x == null) spot = _freeSpot(piece.size.width * metrics.scale, from: 0);
    final placed = PlacedDecor(
      id: _newId(),
      piece: piece,
      shelf: spot.shelf,
      x: spot.x,
      // Another of the same piece gets another glaze or bloom.
      seed: pieces.where((p) => p.piece == piece).length,
    );
    _setPieces([...pieces, placed], select: placed.id, reveal: shelf == null);
  }

  /// A copy beside the original, or on the next shelf with room.
  void duplicate(String id) {
    final original = pieces.where((p) => p.id == id).firstOrNull;
    if (original == null) return;
    final spot = _freeSpot(metrics.sizeOf(original).width, from: original.shelf, near: original.x);
    final copy = PlacedDecor(
      id: _newId(),
      piece: original.piece,
      shelf: spot.shelf,
      x: spot.x,
      size: original.size,
      flipped: original.flipped,
      seed: original.seed + 1,
    );
    _setPieces([...pieces, copy], select: copy.id, reveal: true);
  }

  ({int shelf, double x}) _freeSpot(double width, {required int from, double? near}) {
    for (var shelf = from; shelf <= math.max(from, shelfCount); shelf++) {
      final x = freeSpotOn(shelf, width, pieces, metrics, near: shelf == from ? near : null);
      if (x != null) return (shelf: shelf, x: x);
    }
    return (shelf: from, x: near ?? 0.5);
  }

  /// Puts the books on the shelves as [shelves] lists them (recipe ids).
  void arrangeBooks(List<List<String>> shelves) {
    _style = _style.copyWith(books: shelves);
    _booksMoved = true;
    _selectedId = null;
    notifyListeners();
  }

  /// A ready-made room; the books stay where they were put.
  void applyLook(ShelfLook look) {
    _style = _style.withLook(look.style);
    _selectedId = null;
    notifyListeners();
  }

  void clearDecor() => _setPieces(const []);

  // --- Dragging ---------------------------------------------------------------------------

  Timer? _autoScroll;
  double _scrollSpeed = 0;

  void dragStarted() {
    _dragging = true;
    notifyListeners();
  }

  /// Scrolls the shelves while a drag lingers near the top or bottom of
  /// the visible scene, faster the closer it gets.
  void dragMoved(Offset global) {
    const zone = 72.0, fastest = 14.0;
    final y = global.dy;
    // Over the editor's panel doesn't count: a piece dragged in from the
    // palette starts there.
    final push = y < sceneTop + zone
        ? -(sceneTop + zone - y) / zone
        : (y > sceneBottom - zone && y <= sceneBottom ? (y - sceneBottom + zone) / zone : 0.0);
    _scrollSpeed = push.clamp(-1.0, 1.0) * fastest;
    final scroll = this.scroll;
    if (_scrollSpeed == 0 || scroll == null || !scroll.hasClients) {
      _stopAutoScroll();
      return;
    }
    _autoScroll ??= Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!scroll.hasClients) return;
      final p = scroll.position;
      final to = (p.pixels + _scrollSpeed).clamp(p.minScrollExtent, p.maxScrollExtent);
      if (to != p.pixels) p.jumpTo(to);
    });
  }

  void dragEnded() {
    _stopAutoScroll();
    _dragging = false;
    notifyListeners();
  }

  void _stopAutoScroll() {
    _autoScroll?.cancel();
    _autoScroll = null;
  }

  @override
  void dispose() {
    _stopAutoScroll();
    super.dispose();
  }
}
