import 'dart:io';

import 'package:app_contracts/app_contracts.dart';
import 'package:chefs_kiss/app/bootstrap.dart';
import 'package:chefs_kiss/app/providers.dart';
import 'package:chefs_kiss/core/ai/ai_connection.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/data/repositories/drift_food_log_repository.dart' show DriftPreferencesRepository;
import 'package:chefs_kiss/data/repositories/drift_recipe_repository.dart';
import 'package:chefs_kiss/data/repositories/drift_settings_repository.dart';
import 'package:chefs_kiss/data/seed/starter_recipes.dart';
import 'package:chefs_kiss/features/library/domain/shelf_style.dart';
import 'package:chefs_kiss/features/library/presentation/library_screen.dart';
import 'package:chefs_kiss/features/library/presentation/widgets/library_books.dart';
import 'package:chefs_kiss/features/onboarding/application/onboarding.dart';
import 'package:chefs_kiss/features/onboarding/presentation/onboarding_screen.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_domain/recipe_domain.dart';

List<Recipe> _starters() => parseStarterRecipes(File(starterRecipesAsset).readAsStringSync());

Recipe _recipe(String id, String title, {String? cover}) => Recipe(
  id: id,
  profileId: 'default',
  title: title,
  status: RecipeStatus.ready,
  baseServings: Rational(2),
  coverImage: cover,
  createdAt: 1000,
  updatedAt: 1000,
);

void main() {
  group('starter recipes', () {
    test('are real, complete recipes with no stock artwork', () {
      final recipes = _starters();
      expect(recipes, hasLength(8));
      expect({for (final r in recipes) r.id}, hasLength(8), reason: 'unique ids');
      final analyzer = RecipeNutritionAnalyzer();
      for (final r in recipes) {
        expect(r.coverImage, isNull, reason: r.title);
        expect(r.ingredients.length, greaterThanOrEqualTo(6), reason: r.title);
        expect(r.steps.length, greaterThanOrEqualTo(4), reason: r.title);
        expect(r.totalMinutes, greaterThan(0), reason: r.title);
        expect(r.summary, isNotEmpty, reason: r.title);
        expect(r.labels.where((l) => l.kind == 'cuisine'), hasLength(1), reason: r.title);
        for (final step in r.steps) {
          expect(step.timers.every((t) => t.durationSeconds > 0), isTrue, reason: step.instructionShort);
          expect(step.temperatureC == null, step.temperatureF == null, reason: 'both scales: ${step.instructionShort}');
        }
        // Every amount reads in a kitchen unit, and most lines count toward nutrition.
        final report = analyzer.analyze(r);
        expect(report.coverage, greaterThanOrEqualTo(0.85), reason: '${r.title}: ${report.unresolved.map((l) => l.ingredient.displayName)}');
      }
    });
  });

  group('retiring the old samples', () {
    test('moves the placeholder recipes to Recently deleted and clears stock covers', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = DriftRecipeRepository(db);
      await repo.saveRecipe(_recipe('pasta-pomodoro', 'Artisanal Ribbon Fettuccine', cover: 'assets/illustrations/sketchbook_pasta.jpg'));
      await repo.saveRecipe(_recipe('mine', 'My salad', cover: 'assets/illustrations/sketchbook_salad.jpg'));
      await repo.saveRecipe(_recipe('photo', 'My soup', cover: 'https://example.com/soup.jpg'));

      expect(await retireSampleRecipes(repo), 1);

      expect((await repo.getRecipeById('pasta-pomodoro')).orNull!.isDeleted, isTrue, reason: 'restorable, not purged');
      final mine = (await repo.getRecipeById('mine')).orNull!;
      expect(mine.isDeleted, isFalse);
      expect(mine.coverImage, isNull);
      expect((await repo.getRecipeById('photo')).orNull!.coverImage, 'https://example.com/soup.jpg');
      // Running again changes nothing.
      expect(await retireSampleRecipes(repo), 0);
    });
  });

  group('the welcome tour', () {
    test('a finished tour counts only for its own version', () {
      expect(isTourDone(null), isFalse);
      expect(isTourDone(true), isFalse, reason: 'the first tour stored true; the redesign shows once more');
      expect(isTourDone(tourVersion), isTrue);
      expect(isTourDone(tourVersion + 1), isTrue);
    });

    test('saving keeps the name, the look, the picked recipes and the goal', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final prefs = DriftPreferencesRepository(db);
      final settings = DriftSettingsRepository(db);
      final recipes = DriftRecipeRepository(db);

      final answers = OnboardingAnswers()
        ..name = '  Ana '
        ..frequency = '3-4'
        ..keeps = 'memory'
        ..look = shelfLooks[2]
        ..goal = 30;
      answers.wants.add('ideas');
      answers.starterIds.addAll(['starter-dal-tadka', 'starter-guacamole']);

      await saveOnboarding(answers, starters: _starters(), prefs: prefs, settings: settings, recipes: recipes);

      expect((await settings.getProfile()).orNull!.displayName, 'Ana');
      expect(ShelfStyle.fromJson(await prefs.readJson(shelfStyleKey)).looksLike(shelfLooks[2].style), isTrue);
      final saved = (await recipes.getRecipes()).orNull!;
      expect(saved.map((r) => r.id).toSet(), {'starter-dal-tadka', 'starter-guacamole'});
      expect(await prefs.readJson(cookingGoalKey), 30);
      expect(await prefs.readJson(cookingHabitsKey), {'frequency': '3-4', 'wants': ['ideas'], 'keeps': 'memory'});
      expect(await prefs.readJson(onboardingDoneKey), isNull, reason: 'opening the kitchen marks it done');
    });

    test('shelves dressed by hand stay as they are unless a look is picked', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final prefs = DriftPreferencesRepository(db);
      const mine = ShelfStyle(wall: WallStyle.brick, tint: 5, decor: [PlacedDecor(id: 'p', piece: DecorPiece.pot, shelf: 0, x: 0.5)]);
      await prefs.writeJson(shelfStyleKey, mine.toJson());

      final answers = OnboardingAnswers()..prefill(name: defaultCookName, shelves: mine);
      expect(answers.look, isNull);
      expect(answers.ownShelves, mine);
      expect(answers.name, isEmpty, reason: 'the default profile name is no name');

      await saveOnboarding(
        answers,
        starters: const [],
        prefs: prefs,
        settings: DriftSettingsRepository(db),
        recipes: DriftRecipeRepository(db),
      );
      expect(ShelfStyle.fromJson(await prefs.readJson(shelfStyleKey)), mine);
    });
  });

  testWidgets('a new cook is welcomed, set up and brought into their kitchen', (tester) async {
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
      ],
      child: const ChefApp(),
    ));
    await tester.pumpAndSettle();

    // Settles quickly or fails, naming the step that didn't.
    Future<void> settle() => tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 30),
    );

    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder);
      await settle();
      await tester.tap(finder);
      await settle();
      expect(tester.takeException(), isNull);
    }

    Future<void> next() => tap(find.widgetWithText(FilledButton, 'Continue'));

    // Welcome: the policies are a tap away.
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Welcome to Chef’s Kiss'), findsOneWidget);
    expect(find.textContaining('Privacy Policy', findRichText: true), findsOneWidget);
    await tap(find.text('Get started'));

    // Back returns to the previous screen.
    expect(find.text('What should we call you?'), findsOneWidget);
    await tap(find.byType(BackButton));
    expect(find.text('Welcome to Chef’s Kiss'), findsOneWidget);
    await tap(find.text('Get started'));

    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.pumpAndSettle();
    await next();

    // About their cooking: every question is optional.
    expect(find.text('About your cooking'), findsOneWidget);
    await tap(find.text('3–4 days a week'));
    await tap(find.text('Ideas for what to cook'));
    await tap(find.text('Screenshots and bookmarks'));
    await next();

    // A look for the shelves.
    expect(find.text('Pick a look for your shelves'), findsOneWidget);
    await tap(find.text('Herb garden'));
    await next();

    // Starter recipes: nothing is added unless picked.
    expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);
    await tap(find.widgetWithText(CheckboxListTile, 'Dal Tadka').first);
    await tap(find.widgetWithText(CheckboxListTile, 'Shakshuka').first);
    expect(find.widgetWithText(FilledButton, 'Add 2 recipes'), findsOneWidget);
    await tap(find.widgetWithText(FilledButton, 'Add 2 recipes'));

    // The goal starts from how often they cook.
    expect(find.text('52'), findsOneWidget);
    await tap(find.text('Two a week'));
    expect(find.text('104'), findsOneWidget);
    await tap(find.byTooltip('More'));
    expect(find.text('105'), findsOneWidget);
    await next();

    // Ready: their kitchen and where to begin, from what they said.
    expect(find.text('Your kitchen is ready, Ana'), findsOneWidget);
    expect(find.text('Shakshuka and 1 more are waiting in My Recipes.'), findsOneWidget);
    expect(find.text('Scan the recipes you have'), findsOneWidget);
    expect(find.text('Find something to cook'), findsOneWidget);
    await tap(find.text('Open my kitchen'));

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(LibraryScreen), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is ShelfBook && w.recipe.title == 'My Recipes'), findsOneWidget);
    expect(find.text('Welcome to Chef’s Kiss, Ana!'), findsOneWidget);

    final container = ProviderScope.containerOf(tester.element(find.byType(LibraryScreen)));
    final stored = await tester.runAsync(() async {
      final prefs = container.read(preferencesRepositoryProvider);
      return (
        done: await prefs.readJson(onboardingDoneKey),
        goal: await prefs.readJson(cookingGoalKey),
        style: ShelfStyle.fromJson(await prefs.readJson(shelfStyleKey)),
        recipes: (await container.read(recipeRepositoryProvider).getRecipes()).orNull!,
      );
    });
    expect(stored!.done, tourVersion);
    expect(stored.goal, 105);
    expect(stored.style.looksLike(shelfLooks[1].style), isTrue);
    expect(stored.recipes.map((r) => r.title).toSet(), {'Dal Tadka', 'Shakshuka'});

    // The welcome card leads to the developer's note and then steps aside.
    await tap(find.text('Welcome to Chef’s Kiss, Ana!'));
    expect(find.text('A note from the developer'), findsOneWidget);
    await tap(find.byTooltip('Back'));
    expect(find.text('Welcome to Chef’s Kiss, Ana!'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(db.close);
  });
}
