import 'package:app_contracts/app_contracts.dart';
import 'package:chefs_kiss/app/bootstrap.dart';
import 'package:chefs_kiss/app/providers.dart';
import 'package:chefs_kiss/app/router.dart';
import 'package:chefs_kiss/app/widgets/food_art.dart';
import 'package:chefs_kiss/core/ai/ai_connection.dart';
import 'package:chefs_kiss/core/media/image_store.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/data/repositories/drift_recipe_repository.dart';
import 'package:chefs_kiss/features/journal/application/recipe_edits.dart';
import 'package:chefs_kiss/features/journal/presentation/widgets/page_flip_book.dart';
import 'package:chefs_kiss/features/journal/presentation/widgets/sticker_art.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_domain/recipe_domain.dart';

Recipe _recipe(String id, String title, {int steps = 2, List<ScrapbookSticker> stickers = const []}) => Recipe(
      id: id,
      profileId: 'default',
      title: title,
      summary: 'A test recipe.',
      baseServings: Rational(2),
      totalMinutes: 20,
      createdAt: 1,
      updatedAt: 1,
      status: RecipeStatus.ready,
      stickers: stickers,
      ingredients: [
        RecipeIngredient(id: '$id-i1', recipeId: id, displayName: 'Olive oil', quantity: Rational(2), unitCode: 'tbsp', position: 1),
      ],
      steps: [
        for (var i = 1; i <= steps; i++)
          RecipeStep(id: '$id-s$i', recipeId: id, position: i, instructionShort: 'Do step $i of $title.'),
      ],
    );

Future<(AppDatabase, ProviderContainer)> _pumpApp(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  List<Recipe> recipes = const [],
  List<Override> extra = const [],
}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final db = AppDatabase(NativeDatabase.memory());
  for (final r in recipes) {
    await DriftRecipeRepository(db).saveRecipe(r);
  }
  await tester.pumpWidget(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      secretStoreProvider.overrideWithValue(InMemorySecretStore()),
      screenAwakeServiceProvider.overrideWithValue(FakeScreenAwakeService()),
      imageStoreProvider.overrideWithValue(const NoopImageStore()),
      ...extra,
    ],
    child: const ChefApp(),
  ));
  await tester.pumpAndSettle();
  return (db, ProviderScope.containerOf(tester.element(find.byType(ChefApp))));
}

Future<void> _teardown(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 100));
  await tester.runAsync(db.close);
}

Future<Recipe> _load(WidgetTester tester, AppDatabase db, String id) async =>
    (await tester.runAsync(() => DriftRecipeRepository(db).getRecipeById(id)))!.orNull!;

void main() {
  group('FoodArt', () {
    test('matches whole words, most specific first', () {
      expect(FoodArt.doodleFor(['Steamed broccoli']), 'food-broccoli');
      expect(FoodArt.doodleFor(['Margherita pizza']), 'food-pizza-slice');
      expect(FoodArt.doodleFor(['Eggplant parmesan']), 'food-eggplant');
      expect(FoodArt.doodleFor(['Fish tacos']), 'food-taco');
      expect(FoodArt.doodleFor(['Graham crackers']), isNull);
      expect(FoodArt.stampFor(['Spicy tuna sushi']), 'postage-sushi');
      expect(FoodArt.stampFor(['Mystery stew']), 'postage-skillet');
    });
  });

  group('RecipeEditQueue', () {
    test('back-to-back edits build on each other instead of overwriting', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = DriftRecipeRepository(db);
      final original = (await repo.saveRecipe(_recipe('r', 'Soup'))).orNull!;
      final queue = RecipeEditQueue(repo);

      const a = ScrapbookSticker(id: 'a', content: 'food-tomato', type: 'doodle', pageSide: 'left', x: 10, y: 10, rotation: 0, scale: 1);
      const b = ScrapbookSticker(id: 'b', content: 'food-basil', type: 'doodle', pageSide: 'right', x: 20, y: 20, rotation: 0, scale: 1);
      // Both edits start from the same stale copy, as two quick drags would.
      final first = queue.apply(original, (r) => r.copyWith(stickers: [...r.stickers, a]));
      final second = queue.apply(original, (r) => r.copyWith(stickers: [...r.stickers, b]));
      await Future.wait([first, second]);

      final saved = (await repo.getRecipeById('r')).orNull!;
      expect(saved.stickers.map((s) => s.id), ['a', 'b']);
    });
  });

  group('starter decorations', () {
    test('only undecorated, undeleted starters get the bundled stickers', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = DriftRecipeRepository(db);
      const userSticker = ScrapbookSticker(id: 'mine', content: 'food-donut', type: 'doodle', pageSide: 'left', x: 5, y: 5, rotation: 0, scale: 1);
      await repo.saveRecipe(_recipe('plain', 'Plain'));
      await repo.saveRecipe(_recipe('decorated', 'Decorated', stickers: const [userSticker]));
      await repo.saveRecipe(_recipe('gone', 'Gone'));
      await repo.deleteRecipe('gone');

      const bundled = ScrapbookSticker(id: 'b', content: 'postage-tomato', type: 'stamp', pageSide: 'left', x: 80, y: 7, rotation: 8, scale: 0.9);
      final starters = [
        for (final id in ['plain', 'decorated', 'gone', 'missing']) _recipe(id, id, stickers: const [bundled]),
      ];
      expect(await decorateStarterRecipes(repo, starters), 1);
      expect((await repo.getRecipeById('plain')).orNull!.stickers.single.id, 'b');
      expect((await repo.getRecipeById('decorated')).orNull!.stickers.single.id, 'mine');
    });
  });

  group('PageFlipBook', () {
    Widget book(PageFlipController controller, {bool spread = false}) => MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: spread ? 900 : 360,
              height: 600,
              child: PageFlipBook(
                controller: controller,
                spread: spread,
                pageCount: 6,
                pageBuilder: (context, i) => ColoredBox(color: Colors.white, child: Center(child: Text('Page $i'))),
              ),
            ),
          ),
        );

    testWidgets('single page: controller and drags turn pages', (tester) async {
      final controller = PageFlipController();
      await tester.pumpWidget(book(controller));
      expect(find.text('Page 0'), findsOneWidget);

      // Page turns animate on frames, so pump rather than awaiting the turn.
      controller.next();
      await tester.pumpAndSettle();
      expect(controller.position, 1);
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Page 0'), findsNothing);

      await tester.drag(find.text('Page 1'), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(controller.position, 2);

      // A short drag springs back.
      await tester.drag(find.text('Page 2'), const Offset(40, 0));
      await tester.pumpAndSettle();
      expect(controller.position, 2);

      await tester.drag(find.text('Page 2'), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(controller.position, 1);

      // Can't turn past the first page.
      controller.jumpTo(0);
      await tester.pumpAndSettle();
      await tester.drag(find.text('Page 0'), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(controller.position, 0);
    });

    testWidgets('spread: facing pages turn together', (tester) async {
      final controller = PageFlipController();
      await tester.pumpWidget(book(controller, spread: true));
      expect(find.text('Page 0'), findsOneWidget);
      expect(find.text('Page 1'), findsOneWidget);

      controller.animateTo(2);
      await tester.pumpAndSettle();
      expect(find.text('Page 4'), findsOneWidget);
      expect(find.text('Page 5'), findsOneWidget);
      expect(find.text('Page 0'), findsNothing);
    });
  });

  testWidgets('journal: decorate a page — add, remove and undo a sticker', (tester) async {
    final (db, _) = await _pumpApp(tester, recipes: [_recipe('soup', 'Tomato soup')]);

    await tester.tap(find.text('Tomato soup'));
    await tester.pumpAndSettle();
    expect(find.text('Mise en place'), findsOneWidget);

    await tester.tap(find.byTooltip('Decorate page'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add a sticker'));
    await tester.pumpAndSettle();
    expect(find.text('Add to your page'), findsOneWidget);

    await tester.tap(find.text('San Marzano Tomato'));
    await tester.pumpAndSettle();
    var saved = await _load(tester, db, 'soup');
    expect(saved.stickers, hasLength(1));
    expect(saved.stickers.single.pageSide, 'left');
    expect(saved.stickers.single.content, 'postage-tomato');

    // Drag it with a finger: the page doesn't scroll, the sticker moves.
    final before = saved.stickers.single;
    await tester.dragFrom(tester.getCenter(find.byType(StickerArt)), const Offset(60, 120));
    await tester.pumpAndSettle();
    saved = await _load(tester, db, 'soup');
    expect(saved.stickers.single.x, greaterThan(before.x));
    expect(saved.stickers.single.y, greaterThan(before.y));

    // The new sticker is selected: its toolbar can resize and remove it.
    await tester.tap(find.byTooltip('Bigger'));
    await tester.pumpAndSettle();
    saved = await _load(tester, db, 'soup');
    expect(saved.stickers.single.scale, greaterThan(1));

    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();
    expect((await _load(tester, db, 'soup')).stickers, isEmpty);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await _load(tester, db, 'soup')).stickers, hasLength(1));

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await _teardown(tester, db);
  });

  testWidgets('journal: Story/Method toggle and page buttons turn pages', (tester) async {
    final (db, _) = await _pumpApp(tester, recipes: [_recipe('a', 'Apple pie'), _recipe('b', 'Banana bread')]);
    // The journal keeps the order recipes were added (ties: A–Z), so editing
    // never reshuffles it: Apple pie is page 1, Banana bread follows.
    await tester.tap(find.text('Apple pie'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Method'));
    await tester.pumpAndSettle();
    expect(find.text('METHOD & TIMERS'), findsOneWidget);
    expect(find.textContaining('Do step 1 of'), findsOneWidget);

    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    // Next recipe's story page.
    expect(find.text('Mise en place'), findsOneWidget);
    expect(find.textContaining(' of 2 · Story'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _teardown(tester, db);
  });

  testWidgets('cook mode reads steps aloud once enabled, and remembers it', (tester) async {
    final tts = FakeSpeechOutputService();
    final (db, container) = await _pumpApp(
      tester,
      recipes: [_recipe('soup', 'Tomato soup')],
      extra: [speechOutputServiceProvider.overrideWithValue(tts)],
    );
    container.read(routerProvider).push('/cook/soup');
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Read steps aloud'));
    await tester.pumpAndSettle();
    expect(tts.lastSpokenText, 'Step 1 of 2. Do step 1 of Tomato soup.');

    await tester.tap(find.text('Next step'));
    await tester.pumpAndSettle();
    expect(tts.lastSpokenText, 'Step 2 of 2. Do step 2 of Tomato soup.');

    final stored = await tester.runAsync(() => container.read(preferencesRepositoryProvider).readJson(voiceSettingsKey));
    expect((stored as Map)['readStepsInCookMode'], isTrue);

    // "Read step" works on demand too.
    await tester.tap(find.text('Read step'));
    await tester.pump();
    expect(tts.lastSpokenText, startsWith('Step 2 of 2'));
    await tester.pumpAndSettle();
    await _teardown(tester, db);
  });
}
