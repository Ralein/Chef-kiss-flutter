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

  group('saving the welcome tour', () {
    test('keeps the name, the look, the picked recipes and the goal', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final prefs = DriftPreferencesRepository(db);
      final settings = DriftSettingsRepository(db);
      final recipes = DriftRecipeRepository(db);
      final starters = _starters();

      final answers = OnboardingAnswers()
        ..name = '  Ana '
        ..frequency = '3-4'
        ..keeps = 'memory'
        ..look = shelfLooks[2]
        ..goal = 30;
      answers.wants.add('ideas');
      answers.starterIds.addAll(['starter-dal-tadka', 'starter-guacamole']);

      await saveOnboarding(answers, starters: starters, prefs: prefs, settings: settings, recipes: recipes);

      expect((await settings.getProfile()).orNull!.displayName, 'Ana');
      expect(ShelfStyle.fromJson(await prefs.readJson(shelfStyleKey)).looksLike(shelfLooks[2].style), isTrue);
      final saved = (await recipes.getRecipes()).orNull!;
      expect(saved.map((r) => r.id).toSet(), {'starter-dal-tadka', 'starter-guacamole'});
      expect(await prefs.readJson(cookingGoalKey), 30);
      expect(await prefs.readJson(cookingHabitsKey), {'frequency': '3-4', 'wants': ['ideas'], 'keeps': 'memory'});
      expect(await prefs.readJson(onboardingDoneKey), isNull, reason: 'the last screen marks it done');
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

    // The logo, then the welcome.
    expect(find.byType(OnboardingScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    Finder words(String text) => find.textContaining(text, findRichText: true);
    expect(words('Welcome, chef'), findsOneWidget);

    Future<void> tap(Finder finder) async {
      await tester.tap(finder);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    Future<void> next() => tap(find.text('Continue'));

    await tap(find.text('Start your journey'));
    expect(words('stayed with you'), findsOneWidget);
    // Back returns to the previous screen.
    await tap(find.byTooltip('Back'));
    expect(words('Welcome, chef'), findsOneWidget);
    await tap(find.text('Start your journey'));
    await next();
    expect(words('the home your recipes'), findsOneWidget);
    await next();

    // A name is needed to go on; the policies are a tap away.
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue')).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.pumpAndSettle();
    await next();
    expect(words('Nice to meet you, Ana!'), findsOneWidget);
    await next();

    await tap(find.text('3–4 days a week'));
    await next();
    await tap(find.text('One place for all my recipes'));
    await tap(find.text('Ideas for what to cook tonight'));
    await next();
    await tap(find.text('In my head'));
    await next();
    expect(words('someone’s memory'), findsOneWidget);
    await next();
    expect(words('It doesn’t have to be this way, Ana'), findsOneWidget);
    await next();

    // A full shelf of the starter recipes, then a look for the cook's own.
    expect(find.byType(ShelfBook), findsWidgets);
    await tap(find.text('Let’s begin'));
    expect(find.text('Cozy kitchen'), findsOneWidget);
    await tap(find.byTooltip('Next look'));
    expect(find.text('Herb garden'), findsOneWidget);
    // "Great taste" moves on by itself.
    await tester.tap(find.text('I like it!'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(words('great taste'), findsOneWidget);
    await tester.pumpAndSettle();

    // Starter recipes: nothing is added unless picked.
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Add to my cookbook')).onPressed, isNull);
    await tap(find.text('Dal Tadka'));
    await tap(find.text('Shakshuka'));
    await tap(find.text('Add 2 recipes'));
    expect(words('Your kitchen is alive, Ana!'), findsOneWidget);
    await tap(find.text('I’m so happy!'));

    await tap(find.byTooltip('More'));
    await tap(find.byTooltip('More'));
    expect(find.text('54'), findsOneWidget);
    expect(find.text('About one new dish a week'), findsOneWidget);
    await next();
    expect(words('~1.08 m tall'), findsOneWidget);

    // Building the kitchen, then the library with the picked recipes.
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(words('Building your'), findsOneWidget);
    expect(find.text('Adding Shakshuka'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
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
    expect(stored!.done, isTrue);
    expect(stored.goal, 54);
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
