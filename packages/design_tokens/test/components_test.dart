import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_domain/recipe_domain.dart';

void main() {
  group('Design Tokens Components', () {
    testWidgets('IngredientTile renders name and formatted fraction', (tester) async {
      final ing = RecipeIngredient(
        id: 'i_1',
        recipeId: 'r_1',
        displayName: 'Tomatoes',
        quantity: Rational(3, 2),
        unitCode: 'cups',
        prepText: 'diced',
        position: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ChefTheme.light(),
          home: Scaffold(
            body: IngredientTile(
              ingredient: ing,
            ),
          ),
        ),
      );

      expect(find.text('Tomatoes'), findsOneWidget);
      expect(find.text('1 ½'), findsOneWidget);
      expect(find.text('cups'), findsOneWidget);
      expect(find.text('diced'), findsOneWidget);
    });

    testWidgets('QuantityStepper increments and decrements correctly', (tester) async {
      Rational currentServings = Rational(2);

      await tester.pumpWidget(
        MaterialApp(
          theme: ChefTheme.light(),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: QuantityStepper(
                  value: currentServings,
                  onChanged: (newVal) {
                    setState(() {
                      currentServings = newVal;
                    });
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
      expect(find.text('Servings'), findsOneWidget);

      // Tap + button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('3'), findsOneWidget);

      // Tap - button
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('TimerChip formats remaining seconds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ChefTheme.light(),
          home: const Scaffold(
            body: TimerChip(
              label: 'Bake',
              remainingSeconds: 185,
              totalSeconds: 185,
              status: SessionTimerStatus.running,
            ),
          ),
        ),
      );

      expect(find.text('Bake'), findsOneWidget);
      expect(find.text('03:05'), findsOneWidget);
    });
  });
}
