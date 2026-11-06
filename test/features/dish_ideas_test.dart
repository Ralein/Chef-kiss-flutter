import 'package:app_contracts/app_contracts.dart';
import 'package:chefs_kiss/app/providers.dart';
import 'package:chefs_kiss/core/ai/ai_client.dart';
import 'package:chefs_kiss/core/ai/ai_connection.dart';
import 'package:chefs_kiss/core/ai/claude_client.dart';
import 'package:chefs_kiss/features/imports/presentation/dish_ideas_screen.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_domain/recipe_domain.dart';

/// Answers every request with one dish idea, and remembers what was asked.
/// (The gateway's own HTTP handling is tested in gateway_client_test.dart.)
class _IdeasAi implements AiClient {
  final asked = <String>[];

  @override
  Future<Result<void, AppFailure>> checkAccess() async => const Result.ok(null);

  @override
  void close() {}

  @override
  Future<Result<ClaudeJsonResponse, AppFailure>> createStructured({
    required String system,
    required List<ClaudeContent> content,
    required Map<String, dynamic> schema,
    String effort = 'medium',
    int maxTokens = 16000,
    String feature = 'ai',
  }) async {
    asked.add(content.whereType<ClaudeText>().map((t) => t.text).join());
    return const Result.ok(
      ClaudeJsonResponse(
        json: {
          'ideas': [
            {
              'title': 'Spinach frittata',
              'summary': 'Eggs and greens set in one pan.',
              'minutes': 25,
              'uses': ['Eggs', 'Spinach'],
              'missing': ['Feta'],
            },
          ],
        },
        model: 'kimi-k3-free',
        requestId: null,
        usage: ClaudeUsage(1, 1),
      ),
    );
  }
}

void main() {
  testWidgets('what you have becomes dish ideas, each with what it uses and needs', (tester) async {
    final ai = _IdeasAi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiClientProvider.overrideWithValue(ai),
          collectionsStreamProvider.overrideWith((ref) => Stream.value(const <RecipeCollection>[])),
        ],
        child: MaterialApp(theme: ChefTheme.light(), home: const DishIdeasScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'spinach, eggs');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(InputChip, 'spinach'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'eggs'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Eggs'), findsNothing, reason: 'quick picks hide what is already there');

    await tester.tap(find.text('Suggest dishes'));
    await tester.pumpAndSettle();
    expect(find.text('Spinach frittata'), findsOneWidget);
    expect(find.text('Also needs Feta'), findsOneWidget);
    expect(find.text('Make this recipe'), findsOneWidget);
    expect(ai.asked.single, allOf(contains('- spinach'), contains('- eggs')));
  });

  testWidgets('without AI set up, the screen says how to turn it on', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secretStoreProvider.overrideWithValue(InMemorySecretStore()),
          collectionsStreamProvider.overrideWith((ref) => Stream.value(const <RecipeCollection>[])),
        ],
        child: MaterialApp(theme: ChefTheme.light(), home: const DishIdeasScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Suggest dishes'), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });
}
