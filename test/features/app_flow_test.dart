import 'package:app_contracts/app_contracts.dart';
import 'package:chefs_kiss/app/bootstrap.dart';
import 'package:chefs_kiss/app/providers.dart';
import 'package:chefs_kiss/core/ai/ai_connection.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/data/repositories/drift_recipe_repository.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_domain/recipe_domain.dart';

Recipe _salad() => Recipe(
      id: 'salad',
      profileId: 'default',
      title: 'Heirloom Tomato Salad',
      summary: 'Ripe tomatoes, basil and good olive oil.',
      status: RecipeStatus.ready,
      baseServings: Rational(2),
      difficulty: RecipeDifficulty.easy,
      totalMinutes: 10,
      createdAt: 1000,
      updatedAt: 1000,
      ingredients: [
        RecipeIngredient(id: 'i1', recipeId: 'salad', displayName: 'Heirloom tomatoes', quantity: Rational(2), position: 1),
        RecipeIngredient(id: 'i2', recipeId: 'salad', displayName: 'Olive oil', quantity: Rational(2), unitCode: 'tbsp', position: 2),
      ],
      steps: const [
        RecipeStep(id: 's1', recipeId: 'salad', position: 1, instructionShort: 'Slice the tomatoes and season with flaky salt.'),
      ],
    );

Future<AppDatabase> _pumpApp(WidgetTester tester, Size size) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final db = AppDatabase(NativeDatabase.memory());
  await DriftRecipeRepository(db).saveRecipe(_salad());

  await tester.pumpWidget(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      secretStoreProvider.overrideWithValue(InMemorySecretStore()),
      screenAwakeServiceProvider.overrideWithValue(FakeScreenAwakeService()),
    ],
    child: const ChefApp(),
  ));
  await tester.pumpAndSettle();
  return db;
}

Future<void> _teardown(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 100));
  await tester.runAsync(db.close);
}

void main() {
  testWidgets('phone: browse, scale, cook to completion, and visit every tab', (tester) async {
    final db = await _pumpApp(tester, const Size(390, 844));

    // Library with bottom navigation (no duplicate headers).
    expect(find.text('Your recipes'), findsOneWidget);
    expect(find.text('Heirloom Tomato Salad'), findsOneWidget);
    for (final tab in ['Recipes', 'Scan', 'Food log', 'Collections', 'Settings']) {
      expect(find.text(tab), findsWidgets, reason: '$tab tab');
    }

    // Opening a book shows its journal spread; ingredients scale with servings.
    await tester.tap(find.text('Heirloom Tomato Salad'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'layout after step 1');
    expect(find.text('Start cooking'), findsOneWidget);
    expect(find.textContaining('Heirloom tomatoes', findRichText: true), findsWidgets);
    expect(find.text('2 serv.'), findsOneWidget);
    await tester.tap(find.byTooltip('More servings'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'layout after step 2');
    expect(find.text('3 serv.'), findsOneWidget);
    expect(find.textContaining('3 tbsp', findRichText: true), findsOneWidget, reason: '2 tbsp × 1.5');

    // Cook mode → finish.
    await tester.tap(find.text('Start cooking'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'layout after step 3');
    expect(find.text('Step 1 of 1'), findsOneWidget);
    expect(find.text('Slice the tomatoes and season with flaky salt.'), findsOneWidget);
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'layout after step 4');
    expect(find.text('Chef’s kiss!'), findsOneWidget);
    await tester.tap(find.text('Back to recipe'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'layout after step 5');
    // Back in the journal; return to the bookshelf.
    expect(find.text('Mise en place'), findsOneWidget);
    await tester.tap(find.byTooltip('Bookshelf'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'layout after step 6');
    expect(find.text('Your recipes'), findsOneWidget);

    // Scan without AI configured explains how to enable it.
    await tester.tap(find.text('Scan').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'layout after step 7');
    expect(find.text('Set up AI to use food scanning'), findsOneWidget);

    // Food log starts empty.
    await tester.tap(find.text('Food log').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'layout after step 8');
    expect(find.text('Nothing logged yet today'), findsOneWidget);

    // Settings shows AI status honestly.
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'layout after step 9');
    expect(find.text('Not set up'), findsOneWidget);

    await _teardown(tester, db);
  });

  testWidgets('desktop: navigation rail, journal spread and two-column recipe layout render without overflow', (tester) async {
    final db = await _pumpApp(tester, const Size(1366, 900));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    // The journal opens as a two-page spread with index tabs.
    await tester.tap(find.text('Heirloom Tomato Salad'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'journal spread');
    expect(find.text('Mise en place'), findsOneWidget);
    expect(find.text('METHOD & TIMERS'), findsOneWidget);
    expect(find.text('Recipe 1 of 1'), findsOneWidget);

    // Details: two-column recipe page with nutrition.
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(find.text('Method'), findsOneWidget);
    expect(find.text('Nutrition'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _teardown(tester, db);
  });
}
