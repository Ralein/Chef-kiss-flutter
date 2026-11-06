import 'dart:convert';

import 'package:chefs_kiss/app/providers.dart';
import 'package:chefs_kiss/core/ai/ai_connection.dart';
import 'package:chefs_kiss/core/ai/gateway_client.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/features/imports/presentation/dish_ideas_screen.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('what you have becomes dish ideas, each with what it uses and needs', (tester) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(NativeDatabase.memory());
    final asked = <String>[];
    final gateway = GatewayClient(
      GatewayConfig(baseUri: Uri.parse('http://127.0.0.1:18899'), model: 'kimi-k3-free'),
      sleep: (_) async {},
      httpClient: MockClient((r) async {
        asked.add(r.body);
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'finish_reason': 'stop',
                'message': {
                  'content': jsonEncode({
                    'ideas': [
                      {
                        'title': 'Spinach frittata',
                        'summary': 'Eggs and greens set in one pan.',
                        'minutes': 25,
                        'uses': ['Eggs', 'Spinach'],
                        'missing': ['Feta'],
                      },
                    ],
                  }),
                },
              },
            ],
          }),
          200,
        );
      }),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db), aiClientProvider.overrideWithValue(gateway)],
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
    expect(asked.single, contains('- spinach'));

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  });
}
