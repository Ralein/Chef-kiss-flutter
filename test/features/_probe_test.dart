import 'package:chefs_kiss/app/providers.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/features/imports/presentation/dish_ideas_screen.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('probe', (tester) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(theme: ChefTheme.light(), home: const DishIdeasScreen()),
      ),
    );
    debugPrint('P1');
    await tester.pump(const Duration(milliseconds: 100));
    debugPrint('P2');
    await tester.pumpWidget(const SizedBox());
    debugPrint('P3');
    await tester.pump(const Duration(milliseconds: 100));
    debugPrint('P4');
    await tester.runAsync(db.close);
    debugPrint('P5');
  });
}
