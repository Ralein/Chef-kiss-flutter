import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:design_tokens/design_tokens.dart';
import 'providers.dart';
import 'router.dart';

Future<void> bootstrapAndRun() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create default database container
  final container = ProviderContainer();

  try {
    // Load starter recipes from seed asset
    final jsonStr = await rootBundle.loadString('assets/seed/starter_recipes.json');
    final dynamic parsed = jsonDecode(jsonStr);
    if (parsed is List) {
      final starterRecipes = parsed.map((item) => _parseStarterRecipe(item as Map<String, dynamic>)).toList();
      final repo = container.read(recipeRepositoryProvider);
      await repo.seedStarterRecipes(starterRecipes);
    }
  } catch (e) {
    debugPrint('Seed loading skipped or failed: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ChefApp(),
    ),
  );
}

class ChefApp extends ConsumerWidget {
  const ChefApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: "Chef's Kiss",
      debugShowCheckedModeBanner: false,
      theme: ChefTheme.light(),
      darkTheme: ChefTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}

Recipe _parseStarterRecipe(Map<String, dynamic> json) {
  final ingredients = (json['ingredients'] as List<dynamic>?)?.map((i) {
        return RecipeIngredient(
          id: i['id'] as String,
          recipeId: json['id'] as String,
          displayName: i['displayName'] as String,
          quantity: i['quantityNum'] != null
              ? Rational(i['quantityNum'] as int, i['quantityDen'] as int? ?? 1)
              : null,
          unitCode: i['unitCode'] as String?,
          authoredQuantity: i['authoredQuantity'] as String?,
          scalingPolicy: ScalingPolicy.fromString(i['scalingPolicy'] as String?),
          prepText: i['prepText'] as String?,
          position: i['position'] as int? ?? 1,
          icon: i['icon'] as String?,
          iconColor: i['iconColor'] as String?,
          x: (i['x'] as num?)?.toDouble(),
          y: (i['y'] as num?)?.toDouble(),
        );
      }).toList() ??
      [];

  final steps = (json['steps'] as List<dynamic>?)?.map((s) {
        final timers = (s['timers'] as List<dynamic>?)?.map((t) {
              return StepTimer(
                id: t['id'] as String,
                recipeStepId: s['id'] as String,
                label: t['label'] as String,
                durationSeconds: t['durationSeconds'] as int,
                position: t['position'] as int? ?? 1,
              );
            }).toList() ??
            [];

        return RecipeStep(
          id: s['id'] as String,
          recipeId: json['id'] as String,
          position: s['position'] as int? ?? 1,
          instructionShort: s['instructionShort'] as String,
          instructionDetail: s['instructionDetail'] as String?,
          actionKey: s['actionKey'] as String?,
          iconKey: s['iconKey'] as String?,
          iconColor: s['iconColor'] as String?,
          cookwareKey: s['cookwareKey'] as String?,
          durationSeconds: s['durationSeconds'] as int?,
          temperatureC: s['temperatureC'] as int?,
          temperatureF: s['temperatureF'] as int?,
          x: (s['x'] as num?)?.toDouble(),
          y: (s['y'] as num?)?.toDouble(),
          timers: timers,
        );
      }).toList() ??
      [];

  final tools = (json['tools'] as List<dynamic>?)?.map((t) {
        return RecipeTool(
          id: t['id'] as String,
          recipeId: json['id'] as String,
          displayName: t['displayName'] as String,
          quantity: t['quantity'] as int? ?? 1,
          position: t['position'] as int? ?? 1,
        );
      }).toList() ??
      [];

  final labels = (json['labels'] as List<dynamic>?)?.map((l) {
        return RecipeLabel(
          id: l['id'] as String,
          recipeId: json['id'] as String,
          labelId: l['labelId'] as String,
          kind: l['kind'] as String,
          canonicalKey: l['canonicalKey'] as String,
          displayName: l['displayName'] as String,
        );
      }).toList() ??
      [];

  final stickers = (json['stickers'] as List<dynamic>?)
          ?.map((e) => ScrapbookSticker.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [];
  final washiTapes = (json['washiTapes'] as List<dynamic>?)
          ?.map((e) => WashiTapeDecoration.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [];
  final moodStamps = (json['moodStamps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

  final now = DateTime.now().toUtc().millisecondsSinceEpoch;

  return Recipe(
    id: json['id'] as String,
    profileId: json['profileId'] as String? ?? 'system',
    title: json['title'] as String,
    slug: json['slug'] as String?,
    summary: json['summary'] as String?,
    status: RecipeStatus.fromString(json['status'] as String?),
    baseServings: Rational(
      json['baseServingsNum'] as int? ?? 2,
      json['baseServingsDen'] as int? ?? 1,
    ),
    difficulty: RecipeDifficulty.fromString(json['difficulty'] as String?),
    totalMinutes: json['totalMinutes'] as int? ?? 0,
    visualTemplate: json['visualTemplate'] as String?,
    visualStyleVersion: json['visualStyleVersion'] as String? ?? 'v1',
    isCurated: json['isCurated'] as bool? ?? false,
    origin: Origin.fromString(json['origin'] as String?),
    isFavorite: json['isFavorite'] as bool? ?? false,
    coverImage: json['coverImage'] as String?,
    polaroidCaption: json['polaroidCaption'] as String?,
    polaroidRotation: (json['polaroidRotation'] as num?)?.toDouble(),
    polaroidX: (json['polaroidX'] as num?)?.toDouble(),
    polaroidY: (json['polaroidY'] as num?)?.toDouble(),
    chefTip: json['chefTip'] as String?,
    chefTipIcon: json['chefTipIcon'] as String?,
    chefTipIconColor: json['chefTipIconColor'] as String?,
    theme: ScrapbookTheme.fromKey(json['theme'] as String?),
    moodStamps: moodStamps,
    stickers: stickers,
    washiTapes: washiTapes,
    createdAt: now,
    updatedAt: now,
    ingredients: ingredients,
    steps: steps,
    tools: tools,
    labels: labels,
  );
}
