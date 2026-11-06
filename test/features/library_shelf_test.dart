import 'package:app_contracts/app_contracts.dart';
import 'package:chefs_kiss/app/bootstrap.dart';
import 'package:chefs_kiss/app/providers.dart';
import 'package:chefs_kiss/core/ai/ai_connection.dart';
import 'package:chefs_kiss/core/media/image_store.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/data/repositories/drift_recipe_repository.dart';
import 'package:chefs_kiss/features/library/domain/shelf_style.dart';
import 'package:chefs_kiss/features/library/presentation/book_editor_screen.dart';
import 'package:chefs_kiss/features/journal/presentation/widgets/journal_pages.dart' show captionAddsToTitle;
import 'package:chefs_kiss/features/library/presentation/widgets/kitchen_art.dart';
import 'package:chefs_kiss/features/library/presentation/widgets/library_bookcase.dart';
import 'package:chefs_kiss/features/library/presentation/widgets/library_books.dart';
import 'package:chefs_kiss/features/library/presentation/widgets/shelf_art.dart';
import 'package:chefs_kiss/features/library/presentation/widgets/shelf_style_editor.dart';
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
}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final db = AppDatabase(NativeDatabase.memory());
  for (final r in recipes) {
    await DriftRecipeRepository(db).saveRecipe(r);
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

void main() {
  group('ShelfStyle', () {
    test('round-trips through JSON and tolerates junk', () {
      const style = ShelfStyle(
        wall: WallStyle.panels,
        tint: 3,
        wood: ShelfWood.oak,
        glow: ShelfGlow.cool,
        candles: CandleAmount.many,
        greenery: Greenery.ivy,
        flowers: FlowerKind.sunflowers,
        kitchen: Kitchenware.pantry,
      );
      expect(ShelfStyle.fromJson(style.toJson()), style);
      expect(ShelfStyle.fromJson(null), const ShelfStyle());
      expect(ShelfStyle.fromJson({'wall': 'castle', 'tint': 99, 'wood': 7}), const ShelfStyle());
    });

    test('a kitchen by default; styles saved before kitchenware get it too', () {
      expect(const ShelfStyle().wall, WallStyle.subway);
      expect(const ShelfStyle().kitchen, Kitchenware.everything);
      final older = ShelfStyle.fromJson({'wall': 'brick', 'tint': 2, 'greenery': 'ivy'});
      expect(older.wall, WallStyle.brick, reason: 'a chosen wall is kept');
      expect(older.kitchen, Kitchenware.everything);
    });

    test('light walls switch the scene to dark ink', () {
      expect(const ShelfStyle().isDark, isTrue);
      final light = wallTints.indexed.firstWhere((e) => e.$2.color.computeLuminance() > 0.4).$1;
      expect(ShelfStyle(tint: light).isDark, isFalse);
    });
  });

  testWidgets('style editor previews live, saves, and ✕ discards', (tester) async {
    final (db, container) = await _pumpApp(tester, recipes: [_recipe('a', 'Apple pie')]);
    expect(find.byType(ShelfBook), findsOneWidget);

    await tester.tap(find.byTooltip('Style shelves'));
    await tester.pumpAndSettle();
    expect(find.byType(ShelfStyleEditor), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing, reason: 'nothing competes with the editor');

    await _pick(tester, _option('Wood panels'));
    expect(_sceneWall(), WallStyle.panels, reason: 'the scene previews the choice live');
    await _pick(tester, find.byTooltip('Flowers'));
    await _pick(tester, _option('Sunflowers'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(ShelfStyleEditor), findsNothing);
    var stored = await _storedShelf(tester, container);
    expect(stored.wall, WallStyle.panels);
    expect(stored.flowers, FlowerKind.sunflowers);

    // A change that is discarded never reaches preferences.
    await tester.tap(find.byTooltip('Style shelves'));
    await tester.pumpAndSettle();
    await _pick(tester, _option('Linen'));
    expect(_sceneWall(), WallStyle.linen);
    await tester.tap(find.byTooltip('Discard changes'));
    await tester.pumpAndSettle();
    expect(_sceneWall(), WallStyle.panels, reason: 'discarding restores the saved look');
    stored = await _storedShelf(tester, container);
    expect(stored.wall, WallStyle.panels);

    // Back closes the editor before it leaves the library.
    await tester.tap(find.byTooltip('Style shelves'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ShelfStyleEditor), findsNothing);
    expect(find.byType(ShelfBook), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _teardown(tester, db);
  });

  testWidgets('edit book: spine and title changes are saved to the recipe', (tester) async {
    final (db, _) = await _pumpApp(tester, recipes: [_recipe('a', 'Apple pie')]);
    await tester.longPress(_book('Apple pie'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit book'));
    await tester.pumpAndSettle();
    expect(find.byType(BookEditorScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Grandma’s apple pie');
    await _pick(tester, find.widgetWithText(ChoiceChip, 'Cover'));
    await _pick(tester, find.text('Spine').first);
    await _pick(tester, find.text('Italic serif'));
    await _pick(tester, find.bySemanticsLabel('Forest'));
    await _pick(tester, find.text('Raised ribs'));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.byType(BookEditorScreen), findsNothing);

    final saved = (await tester.runAsync(() => DriftRecipeRepository(db).getRecipeById('a')))!.orNull!;
    expect(saved.title, 'Grandma’s apple pie');
    expect(saved.bookStyle.display, BookDisplay.cover);
    expect(saved.bookStyle.font, SpineFont.serifItalic);
    expect(saved.bookStyle.spineColor, '#2F4A3A');
    expect(saved.bookStyle.pattern, SpinePattern.ribs);
    await _teardown(tester, db);
  });

  testWidgets('edit book: leaving with unsaved changes asks first', (tester) async {
    final (db, _) = await _pumpApp(tester, recipes: [_recipe('a', 'Apple pie')]);
    await tester.longPress(_book('Apple pie'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit book'));
    await tester.pumpAndSettle();
    await _pick(tester, find.text('Spine').first);
    await _pick(tester, find.text('Modern sans'));

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.byType(BookEditorScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.byType(BookEditorScreen), findsNothing);
    final saved = (await tester.runAsync(() => DriftRecipeRepository(db).getRecipeById('a')))!.orNull!;
    expect(saved.bookStyle.isDefault, isTrue);
    await _teardown(tester, db);
  });

  testWidgets('the library has no duplicate create actions', (tester) async {
    // Empty library: the empty state is the only call to action.
    final (db, _) = await _pumpApp(tester);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('AI recipe'), findsNothing, reason: 'quick actions moved off the home page');

    // Empty collections: one button, no FAB.
    await tester.tap(find.text('Collections').last);
    await tester.pumpAndSettle();
    expect(find.text('Create a collection'), findsOneWidget);
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
    );
    final books = find.byType(ShelfBook);
    expect(books, findsNWidgets(5));
    final shelves = {for (final e in books.evaluate()) tester.getRect(find.byWidget(e.widget)).bottom.round()};
    expect(shelves, hasLength(3), reason: '2 + 2 + 1, not one crowded plank');

    Finder inScene(Type type) => find.descendant(of: find.byType(LibraryBookcase), matching: find.byType(type));
    expect(inScene(UtensilCrock), findsWidgets);
    expect(inScene(PantryJars), findsWidgets);

    // What hangs from a shelf never covers a book.
    final hanging = [...inScene(TrailingIvy).evaluate(), ...inScene(HangingUtensils).evaluate()];
    expect(hanging, isNotEmpty);
    for (final h in hanging) {
      final rect = tester.getRect(find.byWidget(h.widget));
      for (final b in books.evaluate()) {
        final book = tester.getRect(find.byWidget(b.widget));
        expect(
          rect.intersect(book).isEmpty || rect.intersect(book).width <= 0.5,
          isTrue,
          reason: 'hangs clear of books',
        );
      }
    }
    expect(tester.takeException(), isNull);
    await _teardown(tester, db);
  });

  testWidgets('one recipe still gets a bookcase: the other shelves hold kitchen things', (tester) async {
    final (db, _) = await _pumpApp(tester, size: const Size(430, 1500), recipes: [_recipe('a', 'Apple pie')]);
    // The top edge plus three shelves.
    expect(find.descendant(of: find.byType(LibraryBookcase), matching: find.byType(ShelfPlank)), findsNWidgets(4));
    expect(find.byType(ShelfBook), findsOneWidget);
    await _teardown(tester, db);
  });

  testWidgets('kitchenware can be turned off and on in the style editor', (tester) async {
    final (db, container) = await _pumpApp(tester, recipes: [_recipe('a', 'Apple pie')]);
    Finder inScene(Type type) => find.descendant(of: find.byType(LibraryBookcase), matching: find.byType(type));
    expect(inScene(UtensilCrock), findsWidgets);

    await tester.tap(find.byTooltip('Style shelves'));
    await tester.pumpAndSettle();
    await _pick(tester, find.byTooltip('Kitchen'));
    await _pick(tester, _option('None'));
    expect(inScene(UtensilCrock), findsNothing);
    expect(inScene(HangingUtensils), findsNothing);
    await _pick(tester, _option('Pantry jars'));
    expect(inScene(PantryJars), findsWidgets);
    expect(inScene(UtensilCrock), findsNothing);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((await _storedShelf(tester, container)).kitchen, Kitchenware.pantry);
    await _teardown(tester, db);
  });
}
