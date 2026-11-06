import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:app_contracts/app_contracts.dart';
import 'package:chefs_kiss/app/bootstrap.dart';
import 'package:chefs_kiss/app/providers.dart';
import 'package:chefs_kiss/core/ai/ai_connection.dart';
import 'package:chefs_kiss/core/media/image_store.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/data/repositories/drift_collection_repository.dart';
import 'package:chefs_kiss/data/repositories/drift_recipe_repository.dart';
import 'package:chefs_kiss/features/library/domain/book_covers.dart';
import 'package:chefs_kiss/features/library/domain/cookbook.dart';
import 'package:chefs_kiss/features/library/domain/shelf_style.dart';
import 'package:chefs_kiss/features/library/presentation/book_editor_screen.dart';
import 'package:chefs_kiss/features/journal/presentation/widgets/journal_pages.dart' show captionAddsToTitle;
import 'package:chefs_kiss/features/library/presentation/widgets/kitchen_art.dart';
import 'package:chefs_kiss/features/library/presentation/widgets/library_bookcase.dart';
import 'package:chefs_kiss/features/library/presentation/widgets/library_books.dart';
import 'package:chefs_kiss/features/library/presentation/widgets/shelf_art.dart';
import 'package:chefs_kiss/features/library/presentation/widgets/shelf_edit_controller.dart';
import 'package:chefs_kiss/features/library/presentation/widgets/shelf_layout.dart';
import 'package:chefs_kiss/features/library/presentation/widgets/shelf_style_editor.dart';
import 'package:chefs_kiss/features/library/presentation/widgets/spine_from_photo.dart';
import 'package:chefs_kiss/features/journal/presentation/journal_view.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_domain/recipe_domain.dart';

Recipe _recipe(String id, String title, {bool favorite = false, String? caption}) => Recipe(
  id: id,
  profileId: 'default',
  title: title,
  summary: 'A test recipe.',
  baseServings: Rational(2),
  totalMinutes: 20,
  createdAt: 1,
  updatedAt: 1,
  status: RecipeStatus.ready,
  isFavorite: favorite,
  polaroidCaption: caption,
  ingredients: [
    RecipeIngredient(
      id: '$id-i1',
      recipeId: id,
      displayName: 'Olive oil',
      quantity: Rational(2),
      unitCode: 'tbsp',
      position: 1,
    ),
  ],
  steps: [RecipeStep(id: '$id-s1', recipeId: id, position: 1, instructionShort: 'Stir.')],
);

Future<(AppDatabase, ProviderContainer)> _pumpApp(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  List<Recipe> recipes = const [],
  Map<String, List<String>> cookbooks = const {},
}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final db = AppDatabase(NativeDatabase.memory());
  for (final r in recipes) {
    await DriftRecipeRepository(db).saveRecipe(r);
  }
  // Made before the app runs: once it watches the database, writes from a
  // test must go through the app.
  for (final MapEntry(key: name, value: ids) in cookbooks.entries) {
    final books = DriftCollectionRepository(db);
    final book = (await books.createCollection(profileId: 'default', name: name, colorToken: 'accent.herb')).orNull!;
    for (final id in ids) {
      await books.addRecipeToCollection(book.id, id);
    }
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        secretStoreProvider.overrideWithValue(InMemorySecretStore()),
        screenAwakeServiceProvider.overrideWithValue(FakeScreenAwakeService()),
        imageStoreProvider.overrideWithValue(const NoopImageStore()),
      ],
      child: const ChefApp(),
    ),
  );
  await tester.pumpAndSettle();
  return (db, ProviderScope.containerOf(tester.element(find.byType(ChefApp))));
}

Future<void> _teardown(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 100));
  await tester.runAsync(db.close);
}

/// Every book's saved look, by book id.
Future<Map<String, BookCover>> _storedCovers(WidgetTester tester, ProviderContainer container) async {
  final Object? json = await tester.runAsync<Object?>(
    () => container.read(preferencesRepositoryProvider).readJson(bookCoversKey),
  );
  return {
    if (json is Map)
      for (final e in json.entries) e.key as String: BookCover.fromJson(e.value),
  };
}

/// Five books: My Recipes holding the first recipe, and a cookbook for each
/// of the others.
const _fiveBooks = {
  'Baking': ['r1'],
  'Cakes': ['r2'],
  'Desserts': ['r3'],
  'Eggs': ['r4'],
};

Future<ShelfStyle> _storedShelf(WidgetTester tester, ProviderContainer container) async {
  final Object? json = await tester.runAsync<Object?>(
    () => container.read(preferencesRepositoryProvider).readJson(shelfStyleKey),
  );
  return ShelfStyle.fromJson(json);
}

/// Options sit in a scrolling list above a pinned Save button: bring each
/// into view first so the tap lands on it rather than on the button.
Future<void> _pick(WidgetTester tester, Finder option) async {
  await tester.ensureVisible(option);
  await tester.pumpAndSettle();
  await tester.tap(option);
  await tester.pumpAndSettle();
}

/// Scrolls the book editor down to [option], then taps it.
Future<void> _pickInEditor(WidgetTester tester, Finder option) async {
  await tester.scrollUntilVisible(
    option,
    160,
    scrollable: find.descendant(of: find.byType(BookEditorScreen), matching: find.byType(Scrollable)).first,
  );
  await _pick(tester, option);
}

/// The wall the library scene paints behind the shelves (the first one in the
/// tree; the editor's preview tiles come after it).
WallStyle _sceneWall() => find
    .byWidgetPredicate((w) => w is CustomPaint && w.painter is WallPainter)
    .evaluate()
    .map((e) => ((e.widget as CustomPaint).painter! as WallPainter).style)
    .first;

/// An option tile in the style editor; it may start scrolled out of view.
Finder _option(String label) => find.text(label, skipOffstage: false);

Finder _book(String title) => find.byWidgetPredicate((w) => w is ShelfBook && w.recipe.title == title);

/// Something on the shelves themselves (not in the editor's palette).
Finder _inScene(Type type) => find.descendant(of: find.byType(LibraryBookcase), matching: find.byType(type));

Future<void> _openEditor(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Style shelves'));
  await tester.pumpAndSettle();
}

/// One shelf down, on a phone: the space above a plank, the plank, its shadow.
const _shelf = 190.0 + 14 + 3;

/// Italic text inside [scope].
Finder _italic(Finder scope) =>
    find.descendant(of: scope, matching: find.byWidgetPredicate((w) => w is RichText && _anyItalic(w.text)));

bool _anyItalic(InlineSpan span) {
  if (span.style?.fontStyle == FontStyle.italic) return true;
  return span is TextSpan && (span.children ?? const []).any(_anyItalic);
}

/// Which shelf a book stands on: books stand on top of their shelf's plank.
int _shelfOf(WidgetTester tester, Finder book) {
  final planks = find.descendant(of: find.byType(LibraryBookcase), matching: find.byType(ShelfPlank));
  final tops = [for (final e in planks.evaluate()) tester.getRect(find.byWidget(e.widget)).top]..sort();
  final bottom = tester.getRect(book).bottom;
  // The first plank is the top edge, above every shelf.
  return tops.skip(1).toList().indexWhere((t) => (t - bottom).abs() < 1.5);
}

void main() {
  group('ShelfStyle', () {
    test('round-trips through JSON and tolerates junk', () {
      const style = ShelfStyle(
        wall: WallStyle.steel,
        tint: 3,
        wood: ShelfWood.oak,
        glow: ShelfGlow.cool,
        decor: [
          PlacedDecor(id: 'a', piece: DecorPiece.kettle, shelf: 2, x: 0.4, size: 1.2, flipped: true, seed: 3),
          PlacedDecor(id: 'b', piece: DecorPiece.ivy, shelf: 0, x: 1),
        ],
        books: [
          ['r2', 'r1'],
          [],
          ['r3'],
        ],
      );
      expect(ShelfStyle.fromJson(jsonDecode(jsonEncode(style.toJson()))), style);
      expect(ShelfStyle.fromJson(null), const ShelfStyle());
      expect(ShelfStyle.fromJson({'wall': 'castle', 'tint': 99, 'wood': 7}), const ShelfStyle());
      // Pieces this version doesn't have (the old cutting board) and broken
      // entries are dropped; out-of-range values are brought back in.
      final read = ShelfStyle.fromJson({
        'decor': [
          {'id': 'x', 'piece': 'board', 'shelf': 0, 'x': 0.5},
          {'id': 'y', 'piece': 'crock', 'shelf': 1, 'x': 7, 'size': 9},
          'junk',
        ],
      });
      expect(read.decor, [
        const PlacedDecor(id: 'y', piece: DecorPiece.crock, shelf: 1, x: 1, size: PlacedDecor.maxSize),
      ]);
    });

    test('a kitchen by default; styles saved before decorations could move get one too', () {
      expect(const ShelfStyle().wall, WallStyle.subway);
      expect(const ShelfStyle().pieces, cozyKitchenDecor);
      expect(cozyKitchenDecor.map((d) => d.piece), containsAll([DecorPiece.crock, DecorPiece.rail, DecorPiece.kettle]));
      final older = ShelfStyle.fromJson({'wall': 'brick', 'tint': 2, 'greenery': 'ivy', 'kitchen': 'pantry'});
      expect(older.wall, WallStyle.brick, reason: 'a chosen wall is kept');
      expect(older.pieces, cozyKitchenDecor);
    });

    test('light walls switch the scene to dark ink', () {
      expect(const ShelfStyle().isDark, isTrue);
      final light = wallTints.indexed.firstWhere((e) => e.$2.color.computeLuminance() > 0.4).$1;
      expect(ShelfStyle(tint: light).isDark, isFalse);
    });
  });

  group('shelf layout', () {
    final phone = ShelfMetrics.forWidth(390);
    List<Recipe> library(int n) => [for (var i = 0; i < n; i++) _recipe('r$i', 'Recipe $i')];

    test('books flow around decorations: each book once, in order, never under one', () {
      final recipes = library(40);
      final rows = layoutShelves(recipes, cozyKitchenDecor, phone);
      expect(
        [
          for (final r in rows)
            for (final b in r.books) b.recipe.id,
        ],
        [for (final r in recipes) r.id],
      );
      for (final row in rows) {
        for (final (i, b) in row.books.indexed) {
          expect(b.left, greaterThanOrEqualTo(0));
          expect(b.left + b.width, lessThanOrEqualTo(phone.inner));
          if (i > 0) expect(b.left, greaterThanOrEqualTo(row.books[i - 1].left + row.books[i - 1].width));
          for (final d in row.decor) {
            final overlap = math.min(b.left + b.width, d.right) - math.max(b.left, d.left);
            expect(
              overlap,
              lessThanOrEqualTo(0),
              reason: '${b.recipe.title} stands clear of the ${d.decor.piece.label}',
            );
          }
        }
      }
    });

    test('a small library spreads over three shelves', () {
      expect([for (final r in layoutShelves(library(5), const [], phone)) r.books.length], [2, 2, 1]);
    });

    test('there is a shelf for every decoration', () {
      const kettle = PlacedDecor(id: 'a', piece: DecorPiece.kettle, shelf: 5, x: 0.5);
      final rows = layoutShelves(library(1), const [kettle], phone);
      expect(rows, hasLength(6));
      expect(rows.last.decor.single.decor, kettle);
    });

    List<List<String>> shelvesOf(List<ShelfRowPlan> rows) => [
      for (final r in rows) [for (final b in r.books) b.recipe.id],
    ];

    test('arranged books keep their shelves; books never arranged follow the last one', () {
      final rows = layoutShelves(
        library(6),
        const [],
        phone,
        arranged: [
          ['r3'],
          [],
          ['r0', 'r1', 'gone'],
        ],
      );
      expect(shelvesOf(rows), [
        ['r3'],
        [],
        ['r0', 'r1', 'r2', 'r4', 'r5'],
      ]);
    });

    test('books that no longer fit move on to the start of the next shelf', () {
      final recipes = library(16);
      final rows = layoutShelves(
        recipes,
        const [],
        phone,
        arranged: [
          [for (final r in recipes.take(15)) r.id],
          ['r15'],
        ],
      );
      final first = rows[0].books.length;
      expect(first, lessThan(15));
      expect(shelvesOf(rows)[1], [for (final r in recipes.skip(first)) r.id]);
    });

    test('moving a book takes it off its shelf and puts it where it was dropped', () {
      expect(
        moveBook(
          [
            ['a', 'b'],
            ['c'],
          ],
          'a',
          1,
          1,
        ),
        [
          ['b'],
          ['c', 'a'],
        ],
      );
      expect(
        moveBook(
          [
            ['a', 'b'],
          ],
          'b',
          0,
          0,
        ),
        [
          ['b', 'a'],
        ],
      );
      expect(
        moveBook(
          [
            ['a'],
          ],
          'a',
          2,
          0,
        ),
        [
          [],
          [],
          ['a'],
        ],
      );
    });
  });

  test('the edit controller adds, duplicates, flips, resizes, moves and removes pieces', () {
    final edit = ShelfEditController(const ShelfStyle(decor: []));
    addTearDown(edit.dispose);
    edit.add(DecorPiece.kettle);
    final kettle = edit.selected!;
    expect(kettle.piece, DecorPiece.kettle, reason: 'what is added is selected');

    edit.duplicate(kettle.id);
    final copy = edit.selected!;
    expect(edit.pieces, hasLength(2));
    expect(copy.id, isNot(kettle.id));
    final m = edit.metrics;
    final apart = (m.leftOf(copy) - m.leftOf(kettle)).abs();
    expect(apart, greaterThanOrEqualTo(m.sizeOf(kettle).width), reason: 'the copy stands beside the original');

    edit.flip(copy.id);
    edit.resize(copy.id, 9);
    expect(edit.selected!.flipped, isTrue);
    expect(edit.selected!.size, PlacedDecor.maxSize);

    edit.move(kettle.id, shelf: 2, x: 1);
    expect(edit.pieces.last.id, kettle.id, reason: 'what moved last is drawn on top');
    expect(edit.selected!.id, kettle.id);
    expect((edit.selected!.shelf, edit.selected!.x), (2, 1.0));

    edit.remove(kettle.id);
    expect(edit.pieces.map((p) => p.id), [copy.id]);
    expect(edit.selected, isNull);

    edit.applyLook(shelfLooks[2]);
    expect(edit.style, shelfLooks[2].style);
    edit.clearDecor();
    expect(edit.pieces, isEmpty);

    // Books stay where they were put, whatever the look.
    edit.arrangeBooks([
      ['x'],
    ]);
    edit.applyLook(shelfLooks[1]);
    expect(edit.style.books, [
      ['x'],
    ]);
    expect(edit.style.wall, shelfLooks[1].style.wall);
  });

  testWidgets('style editor: looks, walls and decorations preview live; Save keeps them, ✕ discards', (tester) async {
    final (db, container) = await _pumpApp(tester, recipes: [_recipe('a', 'Apple pie')]);
    expect(find.byType(ShelfBook), findsOneWidget);
    final book = tester.state(find.byType(ShelfBook));

    await _openEditor(tester);
    expect(find.byType(ShelfStyleEditor), findsOneWidget);
    expect(tester.state(find.byType(ShelfBook)), same(book), reason: 'books stay put, covers and all');
    expect(find.byType(FloatingActionButton), findsNothing, reason: 'nothing competes with the editor');
    expect(find.byType(NavigationBar), findsNothing, reason: 'it takes the whole screen');
    expect(_italic(find.byType(ShelfStyleEditor)), findsNothing, reason: 'the app\'s own type, no italics');

    await _pick(tester, _option('Bistro'));
    expect(_sceneWall(), WallStyle.steel, reason: 'a look sets the wall');
    expect(_inScene(OilBottles), findsOneWidget, reason: 'and the decorations');
    await _pick(tester, find.byTooltip('Wall'));
    await _pick(tester, _option('Retro fridge'));
    expect(_sceneWall(), WallStyle.fridge);
    await _pick(tester, find.byTooltip('Plants'));
    await _pick(tester, _option('Sunflowers'));
    expect(_inScene(FlowerVase), findsOneWidget, reason: 'a tap puts it on a shelf');
    expect(find.text('Size'), findsOneWidget, reason: 'and selects it');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(ShelfStyleEditor), findsNothing);
    var stored = await _storedShelf(tester, container);
    expect(stored.wall, WallStyle.fridge);
    expect(stored.wood, ShelfWood.ebony);
    expect(stored.pieces.map((d) => d.piece), containsAll([DecorPiece.sunflowers, DecorPiece.bottles]));

    // A change that is discarded never reaches preferences.
    await _openEditor(tester);
    await _pick(tester, _option('Bare shelves'));
    expect(_inScene(OilBottles), findsNothing);
    await tester.tap(find.byTooltip('Discard changes'));
    await tester.pumpAndSettle();
    expect(_inScene(OilBottles), findsOneWidget, reason: 'discarding restores the saved shelves');
    stored = await _storedShelf(tester, container);
    expect(stored.pieces, isNotEmpty);
    expect(tester.takeException(), isNull);
    await _teardown(tester, db);
  });

  testWidgets('decorations move by dragging; the toolbar flips, duplicates and deletes', (tester) async {
    final (db, container) = await _pumpApp(tester, recipes: [_recipe('a', 'Apple pie')]);
    await _openEditor(tester);
    // Tuck the panel away to see more of the shelves.
    await tester.tap(find.byTooltip('Hide'));
    await tester.pumpAndSettle();

    // Any piece can be held and dragged: the jars go up a shelf.
    final jars = _inScene(PantryJars);
    final hold = await tester.startGesture(tester.getCenter(jars));
    await tester.pump(const Duration(milliseconds: 500));
    await hold.moveBy(const Offset(75, -_shelf / 2));
    await tester.pump();
    await hold.moveBy(const Offset(75, -_shelf / 2));
    await tester.pump();
    await hold.up();
    await tester.pumpAndSettle();

    // A selected piece moves with a plain drag: the crock goes down a shelf.
    final crock = _inScene(UtensilCrock);
    await tester.tap(crock);
    await tester.pumpAndSettle();
    expect(find.text('Utensil crock'), findsOneWidget, reason: 'its panel shows once selected');
    await tester.drag(crock, const Offset(160, _shelf));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Flip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplicate'));
    await tester.pumpAndSettle();
    expect(_inScene(UtensilCrock), findsNWidgets(2));
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(_inScene(UtensilCrock), findsOneWidget, reason: 'the copy was selected, and deleted');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final stored = (await _storedShelf(tester, container)).pieces;
    final savedCrock = stored.singleWhere((d) => d.piece == DecorPiece.crock);
    expect(savedCrock.shelf, 1);
    expect(savedCrock.x, greaterThan(0.3));
    expect(savedCrock.flipped, isTrue);
    final savedJars = stored.singleWhere((d) => d.piece == DecorPiece.jars);
    expect(savedJars.shelf, 0);
    expect(savedJars.x, greaterThan(0.3));
    expect(tester.takeException(), isNull);
    await _teardown(tester, db);
  });

  testWidgets('books can be held and moved to another shelf, and stay there', (tester) async {
    final titles = ['Apple pie', 'Banana bread', 'Carrot cake', 'Date squares', 'Eggplant parmesan'];
    final (db, container) = await _pumpApp(
      tester,
      size: const Size(390, 1100),
      recipes: [for (final (i, t) in titles.indexed) _recipe('r$i', t)],
      cookbooks: _fiveBooks,
    );
    // From the book's own menu: the editor opens with its panel tucked away.
    await tester.longPress(_book('My Recipes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move on the shelves'));
    await tester.pumpAndSettle();
    expect(find.byType(ShelfStyleEditor), findsOneWidget);
    expect(find.text('Looks'), findsNothing, reason: 'the shelves stay in view');

    final from = _shelfOf(tester, _book('My Recipes'));
    final to = from == 0 ? 1 : from - 1;
    final hold = await tester.startGesture(tester.getRect(_book('My Recipes')).center);
    await tester.pump(const Duration(milliseconds: 500));
    for (var i = 0; i < 2; i++) {
      await hold.moveBy(Offset(0, (to - from) * _shelf / 2));
      await tester.pump();
    }
    await hold.up();
    await tester.pumpAndSettle();
    expect(_shelfOf(tester, _book('My Recipes')), to, reason: 'it lands on the shelf it was dropped on');
    expect(find.byType(ShelfBook), findsNWidgets(5));

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final stored = await _storedShelf(tester, container);
    expect(stored.books![to], contains(Cookbook.volumeId(myRecipesId)));
    expect(_shelfOf(tester, _book('My Recipes')), to, reason: 'the library shows it where it was put');
    expect(tester.takeException(), isNull);
    await _teardown(tester, db);
  });

  testWidgets('shelves can be added and removed in the editor; what stood on a removed one moves up', (tester) async {
    final (db, container) = await _pumpApp(tester, size: const Size(390, 1100), recipes: [_recipe('a', 'Apple pie')]);
    Finder planks() => find.descendant(of: find.byType(LibraryBookcase), matching: find.byType(ShelfPlank));
    expect(planks(), findsNWidgets(4), reason: 'the top edge plus three shelves');
    await _openEditor(tester);
    await _pick(tester, find.byTooltip('Shelf'));
    await _pick(tester, find.byTooltip('Add a shelf'));
    expect(planks(), findsNWidgets(5));
    await _pick(tester, find.byTooltip('Remove a shelf'));
    await _pick(tester, find.byTooltip('Remove a shelf'));
    expect(planks(), findsNWidgets(3));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final stored = await _storedShelf(tester, container);
    expect(stored.shelves, 2);
    expect(stored.pieces.every((d) => d.shelf <= 1), isTrue, reason: 'the third shelf\'s things moved up');
    expect(tester.takeException(), isNull);
    await _teardown(tester, db);
  });

  testWidgets('the hanging utensil rail moves like everything else', (tester) async {
    final (db, container) = await _pumpApp(tester, recipes: [_recipe('a', 'Apple pie')]);
    await _openEditor(tester);
    await tester.tap(find.byTooltip('Hide'));
    await tester.pumpAndSettle();

    final rail = _inScene(HangingUtensils);
    final hold = await tester.startGesture(tester.getCenter(rail));
    await tester.pump(const Duration(milliseconds: 500));
    for (var i = 0; i < 2; i++) {
      await hold.moveBy(const Offset(-60, -_shelf / 2));
      await tester.pump();
    }
    await hold.up();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final saved = (await _storedShelf(tester, container)).pieces.singleWhere((d) => d.piece == DecorPiece.rail);
    expect(saved.shelf, 0, reason: 'up one shelf from where it hung');
    expect(saved.x, lessThan(1));
    expect(tester.takeException(), isNull);
    await _teardown(tester, db);
  });

  testWidgets('pieces drag in from the palette; Back puts the selection down, then closes', (tester) async {
    final (db, _) = await _pumpApp(tester, recipes: [_recipe('a', 'Apple pie')]);
    await _openEditor(tester);
    await _pick(tester, find.byTooltip('Kitchen'));
    expect(_inScene(Kettle), findsOneWidget);
    final tile = _option('Kettle');
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.drag(tile, const Offset(0, -340));
    await tester.pumpAndSettle();
    expect(_inScene(Kettle), findsNWidgets(2));
    expect(find.text('Flip'), findsOneWidget, reason: 'the new kettle is selected');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Flip'), findsNothing);
    expect(find.byType(ShelfStyleEditor), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ShelfStyleEditor), findsNothing);
    expect(find.byType(ShelfBook), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget, reason: 'navigation comes back');
    expect(tester.takeException(), isNull);
    await _teardown(tester, db);
  });

  testWidgets('edit book: its name, spine, lettering and cover-out are saved to the book', (tester) async {
    final (db, container) = await _pumpApp(tester, recipes: [_recipe('a', 'Apple pie')]);
    expect(_book('My Recipes'), findsOneWidget, reason: 'every recipe starts in My Recipes');
    await tester.longPress(_book('My Recipes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit book'));
    await tester.pumpAndSettle();
    expect(find.byType(BookEditorScreen), findsOneWidget);
    expect(_italic(find.byType(BookEditorScreen)), findsNothing, reason: "the app's own type, no italics");

    await tester.enterText(find.byType(TextField), 'Family favourites');
    await _pickInEditor(tester, find.bySemanticsLabel('Leaves'));
    await _pickInEditor(tester, find.bySemanticsLabel('Forest'));
    await _pickInEditor(tester, find.text('Cover out'));
    await _pickInEditor(tester, find.text('Sans'));
    expect(tester.takeException(), isNull);
    // One screen, the app's own pattern: a title bar with Save.
    expect(find.widgetWithText(AppBar, 'Edit book'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(BookEditorScreen), findsNothing);
    final saved = (await _storedCovers(tester, container))[myRecipesId]!;
    expect(saved.title, 'Family favourites');
    expect(saved.style.pattern, SpinePattern.leaves);
    expect(saved.style.spineColor, '#2F4A3A');
    expect(saved.style.display, BookDisplay.cover);
    expect(saved.style.font, SpineFont.sans);
    // On the shelf: renamed, and standing face-out.
    expect(_book('Family favourites'), findsOneWidget);
    expect(find.descendant(of: find.byType(LibraryBookcase), matching: find.byType(BookCoverFace)), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _teardown(tester, db);
  });

  testWidgets('edit book: leaving with unsaved changes asks first', (tester) async {
    final (db, container) = await _pumpApp(tester, recipes: [_recipe('a', 'Apple pie')]);
    await tester.longPress(_book('My Recipes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit book'));
    await tester.pumpAndSettle();
    await _pickInEditor(tester, find.text('Sans'));

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.byType(BookEditorScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.byType(BookEditorScreen), findsNothing);
    expect(await _storedCovers(tester, container), isEmpty);
    await _teardown(tester, db);
  });

  testWidgets('a book turns cover-out and back from its menu', (tester) async {
    final (db, container) = await _pumpApp(tester, recipes: [_recipe('a', 'Apple pie')]);
    Finder covers() => find.descendant(of: find.byType(LibraryBookcase), matching: find.byType(BookCoverFace));
    expect(covers(), findsNothing, reason: 'books stand spine-out');

    await tester.longPress(_book('My Recipes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show the cover'));
    await tester.pumpAndSettle();
    expect(covers(), findsOneWidget);
    expect((await _storedCovers(tester, container))[myRecipesId]!.style.display, BookDisplay.cover);

    await tester.longPress(_book('My Recipes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show the spine'));
    await tester.pumpAndSettle();
    expect(covers(), findsNothing);
    expect(tester.takeException(), isNull);
    await _teardown(tester, db);
  });

  testWidgets('a new book takes recipes from My Recipes; a recipe is in one book at a time', (tester) async {
    final (db, _) = await _pumpApp(
      tester,
      size: const Size(390, 1100),
      recipes: [_recipe('a', 'Apple pie'), _recipe('b', 'Banana bread')],
    );
    await tester.tap(find.text('New book'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Baking');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    // Its recipe list opens: ticking one moves it in.
    expect(find.text('Recipes in Baking'), findsOneWidget);
    expect(find.text('In My Recipes'), findsNWidgets(2));
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Banana bread'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(195, 40));
    await tester.pumpAndSettle();
    expect(_book('Baking'), findsOneWidget);
    expect(_book('My Recipes'), findsOneWidget, reason: 'Apple pie is still in it');

    // From a recipe's own menu it moves to another book.
    await tester.tap(find.byTooltip('Recipe cards'));
    await tester.pumpAndSettle();
    await tester.longPress(find.text('Apple pie'));
    await tester.pumpAndSettle();
    expect(find.text('In My Recipes'), findsOneWidget);
    await tester.tap(find.text('Move to a book'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Baking'));
    await tester.pumpAndSettle();
    final books = (await tester.runAsync(() => DriftCollectionRepository(db).getCollections()))!.orNull!;
    expect(books.single.recipeIds, unorderedEquals(['a', 'b']));

    await tester.tap(find.byTooltip('Bookshelf'));
    await tester.pumpAndSettle();
    expect(_book('Baking'), findsOneWidget);
    expect(_book('My Recipes'), findsNothing, reason: 'with every recipe in a book of its own, it steps aside');
    expect(tester.takeException(), isNull);
    await _teardown(tester, db);
  });

  testWidgets('the library has no duplicate create actions', (tester) async {
    // Empty library: the empty state is the only call to action.
    final (db, _) = await _pumpApp(tester);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('AI recipe'), findsNothing, reason: 'quick actions moved off the home page');

    // Empty collections: one button, no FAB.
    await tester.tap(find.text('Cookbooks').last);
    await tester.pumpAndSettle();
    expect(find.text('Create a cookbook'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    await _teardown(tester, db);
  });

  group('spine titles', () {
    const style = TextStyle(fontSize: 12.5, letterSpacing: 1.1, height: 1);

    test('a short title keeps its size on one line', () {
      final f = SpineTitle.fit('PIE', style, TextScaler.noScaling, length: 100, thickness: 27);
      expect(f.lines, ['PIE']);
      expect(f.size, 12.5);
    });

    test('a long title breaks into two balanced lines on a thick enough spine', () {
      final f = SpineTitle.fit('TOKYO SHOYU CRAFT RAMEN', style, TextScaler.noScaling, length: 100, thickness: 27);
      expect(f.lines, ['TOKYO SHOYU', 'CRAFT RAMEN']);
      expect(f.size, greaterThanOrEqualTo(7.75));
    });

    test('a thin spine keeps one line at a readable size', () {
      final f = SpineTitle.fit('TOKYO SHOYU CRAFT RAMEN', style, TextScaler.noScaling, length: 100, thickness: 14);
      expect(f.lines, hasLength(1));
      expect(f.size, greaterThanOrEqualTo(7.75));
    });
  });

  test('a photo caption that only repeats the title adds nothing', () {
    Recipe titled(String title, String? caption) => _recipe('x', title, caption: caption);
    expect(captionAddsToTitle(titled('Tokyo Shoyu Craft Ramen with Ajitsuke Egg', 'Tokyo Shoyu Ramen')), isFalse);
    expect(captionAddsToTitle(titled('French Crêpes Suzette with Sweet Berries', 'French crêpes suzette')), isFalse);
    expect(captionAddsToTitle(titled('Rustic Country Sourdough Boule', 'Artisan Sourdough Boule')), isTrue);
    expect(captionAddsToTitle(titled('Apple pie', null)), isFalse);
  });

  testWidgets('a small library spreads over three shelves, with kitchen things between', (tester) async {
    final titles = ['Apple pie', 'Banana bread', 'Carrot cake', 'Date squares', 'Eggplant parmesan'];
    final (db, _) = await _pumpApp(
      tester,
      size: const Size(430, 1500),
      recipes: [for (final (i, t) in titles.indexed) _recipe('r$i', t)],
      cookbooks: _fiveBooks,
    );
    final books = find.byType(ShelfBook);
    expect(books, findsNWidgets(5));
    final shelves = {for (final e in books.evaluate()) tester.getRect(find.byWidget(e.widget)).bottom.round()};
    expect(shelves, hasLength(3), reason: '2 + 2 + 1, not one crowded plank');

    expect(_inScene(UtensilCrock), findsWidgets);
    expect(_inScene(PantryJars), findsWidgets);

    // Nothing stands in front of a book or hangs over one.
    final decor = [
      for (final type in [UtensilCrock, PantryJars, DutchOven, Kettle, HerbPot, TrailingIvy, HangingUtensils])
        ..._inScene(type).evaluate(),
    ];
    expect(decor, isNotEmpty);
    for (final d in decor) {
      final rect = tester.getRect(find.byWidget(d.widget));
      for (final b in books.evaluate()) {
        final book = tester.getRect(find.byWidget(b.widget));
        expect(
          rect.intersect(book).width <= 0.5 || rect.intersect(book).height <= 0.5,
          isTrue,
          reason: 'clear of books',
        );
      }
    }
    expect(tester.takeException(), isNull);
    await _teardown(tester, db);
  });

  testWidgets('every recipe is in a book: a cookbook, or My Recipes; each opens to its own', (tester) async {
    final (db, _) = await _pumpApp(
      tester,
      recipes: [_recipe('a', 'Boeuf bourguignon'), _recipe('b', 'Crème brûlée'), _recipe('c', 'Apple pie')],
      cookbooks: {
        'French': ['a', 'b'],
      },
    );
    expect(_book('French'), findsOneWidget, reason: 'the cookbook stands as one book');
    expect(_book('My Recipes'), findsOneWidget, reason: 'recipes in no cookbook are in My Recipes');
    expect(find.byType(ShelfBook), findsNWidgets(2), reason: 'only books stand on the shelf');

    await tester.tap(_book('French'));
    await tester.pumpAndSettle();
    var journal = tester.widget<JournalView>(find.byType(JournalView));
    expect(journal.recipes.map((r) => r.title), ['Boeuf bourguignon', 'Crème brûlée']);
    expect(journal.title, 'French', reason: 'its bookplate carries its name');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(_book('My Recipes'));
    await tester.pumpAndSettle();
    journal = tester.widget<JournalView>(find.byType(JournalView));
    expect(journal.recipes.map((r) => r.title), ['Apple pie']);

    // Back on the shelf, a search lights up the books holding matches.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'brûlée');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(_book('Crème brûlée'), findsNothing, reason: 'recipes stay inside their books');
    expect(_book('French'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(LibraryBookcase), matching: find.text('1')),
      findsOneWidget,
      reason: 'French holds one match',
    );
    final faded = find.ancestor(of: _book('My Recipes'), matching: find.byType(Opacity));
    expect(tester.widget<Opacity>(faded.first).opacity, lessThan(0.5), reason: 'My Recipes has none');

    // Opened now, the book shows just its matches.
    await tester.tap(_book('French'));
    await tester.pumpAndSettle();
    journal = tester.widget<JournalView>(find.byType(JournalView));
    expect(journal.recipes.map((r) => r.title), ['Crème brûlée']);
    expect(tester.takeException(), isNull);
    await _teardown(tester, db);
  });

  test('a photo gives a book its colours: a deep cloth, a light print, and Shuffle steps through patterns', () {
    // Tomato-red pixels, basil-green ones and a white one.
    final rgba = Uint8List.fromList([
      210, 60, 40, 255, 205, 55, 35, 255, 215, 65, 45, 255, //
      60, 140, 60, 255, 70, 150, 65, 255, //
      255, 255, 255, 255,
    ]);
    final palette = paletteFromPixels(rgba).map(HSLColor.fromColor).toList();
    expect(palette, hasLength(3));
    expect(palette[0].hue, lessThan(25), reason: 'the main colour, red, binds the book');
    expect(palette[0].lightness, inInclusiveRange(0.19, 0.36), reason: 'deep enough for gilt lettering');
    expect(palette[1].hue, inInclusiveRange(90, 150), reason: 'the green prints the pattern');
    expect(palette[1].lightness, greaterThan(0.6));
    expect(paletteFromPixels(Uint8List(0)), isEmpty);

    final hex = paletteHex(paletteFromPixels(rgba));
    final first = spineFromPalette(BookCover.defaultStyle, hex);
    final next = spineFromPalette(BookCover.defaultStyle, hex, turn: 1);
    expect(first.spineColor, hex[0]);
    expect(first.accentColor, hex[1]);
    expect(SpinePattern.printed, contains(first.pattern));
    expect(next.pattern, isNot(first.pattern), reason: 'Shuffle tries another pattern');
    expect(next.spineColor, hex[0], reason: 'in the same colours');
  });

  testWidgets('one recipe still gets a bookcase: the other shelves hold kitchen things', (tester) async {
    final (db, _) = await _pumpApp(tester, size: const Size(430, 1500), recipes: [_recipe('a', 'Apple pie')]);
    // The top edge plus three shelves.
    expect(find.descendant(of: find.byType(LibraryBookcase), matching: find.byType(ShelfPlank)), findsNWidgets(4));
    expect(find.byType(ShelfBook), findsOneWidget);
    await _teardown(tester, db);
  });
}
