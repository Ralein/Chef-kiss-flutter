import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:chefs_kiss/app/providers.dart';
import 'package:chefs_kiss/app/router.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/data/repositories/drift_recipe_repository.dart';

void main() {
  testWidgets('Chef App smoke test - renders library and interacts with recipes', (tester) async {
    final db = AppDatabase.inMemory();
    final recipeRepo = DriftRecipeRepository(db);

    // Seed test recipe
    final testRecipe = Recipe(
      id: 'smoke_recipe_1',
      profileId: 'default',
      title: 'Heirloom Tomato Salad',
      summary: 'Fresh basil and ripe tomatoes with olive oil.',
      status: RecipeStatus.ready,
      baseServings: Rational(2),
      difficulty: RecipeDifficulty.easy,
      totalMinutes: 5,
      createdAt: 1000,
      updatedAt: 1000,
      isCurated: true,
      ingredients: [
        RecipeIngredient(
          id: 'ing_1',
          recipeId: 'smoke_recipe_1',
          displayName: 'Heirloom Tomatoes',
          quantity: Rational(2),
          unitCode: 'each',
          position: 1,
        ),
      ],
      steps: const [
        RecipeStep(
          id: 'step_1',
          recipeId: 'smoke_recipe_1',
          position: 1,
          instructionShort: 'Slice tomatoes and season with flaky salt.',
        ),
      ],
    );
    await recipeRepo.saveRecipe(testRecipe);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          recipeRepositoryProvider.overrideWithValue(recipeRepo),
        ],
        child: MaterialApp.router(
          theme: ChefTheme.light(),
          routerConfig: appRouter,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Library header and recipe card render
    expect(find.text("Chef's Kiss"), findsOneWidget);
    expect(find.text('Heirloom Tomato Salad'), findsOneWidget);
    expect(find.text('2 serv'), findsOneWidget);

    // 2. Tap on recipe to open detail page
    await tester.tap(find.text('Heirloom Tomato Salad'));
    await tester.pumpAndSettle();

    // 3. Verify Recipe Detail elements
    expect(find.text('Start Cooking'), findsOneWidget);
    expect(find.text('Heirloom Tomatoes'), findsOneWidget);

    // 4. Tap "Start Cooking" to enter immersive Cook Mode
    await tester.tap(find.text('Start Cooking'));
    await tester.pumpAndSettle();

    // 5. Verify Cook Mode active step and Next/Finish button
    expect(find.text('Step 1 of 1 • Serves 2'), findsOneWidget);
    expect(find.text('Slice tomatoes and season with flaky salt.'), findsOneWidget);
    expect(find.text('Finish Cooking'), findsOneWidget);

    // 6. Finish cooking
    await tester.tap(find.text('Finish Cooking'));
    await tester.pumpAndSettle();

    expect(find.text('Chef’s Kiss!'), findsOneWidget);

    await db.close();
  });
}
