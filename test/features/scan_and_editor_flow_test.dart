import 'dart:convert';

import 'package:app_contracts/app_contracts.dart';
import 'package:chefs_kiss/app/bootstrap.dart';
import 'package:chefs_kiss/app/providers.dart';
import 'package:chefs_kiss/app/router.dart';
import 'package:chefs_kiss/core/ai/ai_connection.dart';
import 'package:chefs_kiss/core/ai/claude_client.dart';
import 'package:chefs_kiss/core/media/image_store.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/data/repositories/drift_recipe_repository.dart';
import 'package:chefs_kiss/features/scan/presentation/scan_screen.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipe_domain/recipe_domain.dart';

final _tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC',
);

ClaudeClient _fakeVisionClient() => ClaudeClient(
      ClaudeConfig(baseUri: ClaudeConfig.anthropicApi, apiKey: 'test'),
      sleep: (_) async {},
      httpClient: MockClient((_) async => http.Response(
            jsonEncode({
              'stop_reason': 'end_turn',
              'content': [
                {
                  'type': 'text',
                  'text': jsonEncode({
                    'is_food': true,
                    'title': 'Avocado toast',
                    'description': 'Sourdough with smashed avocado and a fried egg.',
                    'cuisine': 'Brunch',
                    'confidence': 0.82,
                    'items': [
                      {'name': 'Sourdough toast', 'portion': '2 slices', 'grams': 100, 'calories': 270, 'protein_g': 11, 'carbs_g': 52, 'fat_g': 2, 'fiber_g': 2, 'sugar_g': 2, 'sodium_mg': 600, 'confidence': 0.9},
                      {'name': 'Avocado', 'portion': '1/2 fruit', 'grams': 75, 'calories': 120, 'protein_g': 1.5, 'carbs_g': 6, 'fat_g': 11, 'fiber_g': 5, 'sugar_g': 0.5, 'sodium_mg': 5, 'confidence': 0.85},
                      {'name': 'Fried egg', 'portion': '1 large', 'grams': 46, 'calories': 90, 'protein_g': 6, 'carbs_g': 0.4, 'fat_g': 7, 'fiber_g': 0, 'sugar_g': 0.2, 'sodium_mg': 95, 'confidence': 0.8},
                    ],
                    'allergens': ['gluten', 'egg'],
                    'dietary_tags': ['vegetarian'],
                    'health_notes': ['Good source of fiber.'],
                    'detected_ingredients': ['bread', 'avocado', 'egg'],
                    'recipe_ideas': ['Avocado egg toast'],
                  }),
                },
              ],
              'usage': {'input_tokens': 1, 'output_tokens': 1},
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          )),
    );

Future<(AppDatabase, ProviderContainer)> _pump(WidgetTester tester, {List<Override> extra = const []}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final db = AppDatabase(NativeDatabase.memory());
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
  final container = ProviderScope.containerOf(tester.element(find.byType(ChefApp)));
  return (db, container);
}

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 50 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _teardown(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 100));
  await tester.runAsync(db.close);
}

void main() {
  testWidgets('scan a meal → review items → log it → see it in the food log', (tester) async {
    final (db, container) = await _pump(tester, extra: [aiClientProvider.overrideWithValue(_fakeVisionClient())]);

    container.read(routerProvider).push('/analyze', extra: ScanRequest(mode: ScanMode.meal, bytes: _tinyPng));
    await _pumpUntil(tester, find.text('Avocado toast'));
    await tester.pumpAndSettle();

    final results = find.byType(Scrollable).first;

    expect(find.text('Avocado toast'), findsOneWidget);
    expect(find.textContaining('480', findRichText: true), findsWidgets, reason: 'total = 270 + 120 + 90');

    // Halve the portion, then remove the egg: (270 + 120) / 2 = 195 kcal.
    await tester.scrollUntilVisible(find.text('½'), 150, scrollable: results);
    await tester.tap(find.text('½'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byTooltip('Remove Fried egg'), 150, scrollable: results);
    await tester.tap(find.byTooltip('Remove Fried egg'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Egg'), 150, scrollable: results);
    expect(find.text('Egg'), findsOneWidget, reason: 'allergen chip');

    await tester.drag(results, const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(find.textContaining('195', findRichText: true), findsWidgets);

    await tester.tap(find.text('Log meal'));
    await _pumpUntil(tester, find.text('Logged · view food log'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logged · view food log'));
    await tester.pumpAndSettle();

    // Today's total on the summary card, then the entry under its meal.
    expect(find.textContaining('195', findRichText: true), findsWidgets);
    await tester.scrollUntilVisible(find.text('Avocado toast'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Avocado toast'), findsOneWidget);
    await _teardown(tester, db);
  });

  testWidgets('editor creates a recipe, and editing keeps cover, stickers and favorite', (tester) async {
    final (db, container) = await _pump(tester);
    final repo = DriftRecipeRepository(db);
    await repo.saveRecipe(Recipe(
      id: 'keepsake',
      profileId: 'default',
      title: 'Grandma pie',
      baseServings: Rational(6),
      createdAt: 42,
      updatedAt: 42,
      coverImage: 'assets/illustrations/sketchbook_crepes.jpg',
      isFavorite: true,
      stickers: const [ScrapbookSticker(id: 'st', content: 'food-donut', x: 30, y: 40)],
      ingredients: [RecipeIngredient(id: 'i', recipeId: 'keepsake', displayName: 'Flour', quantity: Rational(2), unitCode: 'cup', position: 1)],
      steps: const [RecipeStep(id: 's', recipeId: 'keepsake', position: 1, instructionShort: 'Bake.')],
    ));

    // Edit the existing recipe's title only.
    container.read(routerProvider).push('/editor/keepsake');
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Grandma’s apple pie');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final edited = (await repo.getRecipeById('keepsake')).orNull!;
    expect(edited.title, 'Grandma’s apple pie');
    expect(edited.coverImage, 'assets/illustrations/sketchbook_crepes.jpg');
    expect(edited.stickers.single.id, 'st');
    expect(edited.isFavorite, isTrue);
    expect(edited.createdAt, 42);
    expect(edited.ingredients.single.quantity, Rational(2));

    // Create a new recipe from scratch with a unicode fraction.
    container.read(routerProvider).push('/editor');
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Quick lemonade');
    await tester.enterText(find.widgetWithText(TextField, 'Qty').first, '1½');
    await tester.enterText(find.widgetWithText(TextField, 'Unit').first, 'cup');
    await tester.enterText(find.widgetWithText(TextField, 'Ingredient').first, 'lemon juice');
    await tester.enterText(find.widgetWithText(TextField, 'Instruction').first, 'Stir with cold water and sugar.');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Quick lemonade'), findsWidgets, reason: 'opens the new recipe');
    final created = (await repo.getRecipes()).orNull!.firstWhere((r) => r.title == 'Quick lemonade');
    expect(created.ingredients.single.quantity, Rational(3, 2));
    expect(created.status, RecipeStatus.ready);
    await _teardown(tester, db);
  });
}
