import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:app_contracts/app_contracts.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../core/media/recipe_art.dart';
import 'audio_chime_service.dart';
import 'chef_toast_service.dart';
import 'providers.dart';
import 'router.dart';

/// Bump when the bundled starter recipes change, to offer new ones once.
const _starterSeedVersion = 1;
const _starterSeedKey = 'seed.starter_version';

Future<void> bootstrapAndRun() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  final logger = container.read(appLoggerProvider);
  _installErrorHandlers(logger);

  // Timer alarms surface from anywhere in the app, not just the recipe page.
  container.read(kitchenTimersProvider).onFinished = (timer) {
    audioChime.playTimerComplete();
    ChefToastService.show(
      title: '${timer.label} is done',
      description: timer.recipeTitle,
      type: ChefToastType.alarm,
      duration: const Duration(seconds: 8),
    );
  };

  runApp(UncontrolledProviderScope(container: container, child: const ChefApp()));

  // Seed after the first frame: opening the database (a web worker on the
  // web, disk I/O on low-end phones) must never delay startup. The library
  // updates reactively when the starter recipes land.
  unawaited(_seedStarterRecipesOnce(container, logger));
}

void _installErrorHandlers(AppLogger logger) {
  FlutterError.onError = (details) {
    logger.error(
      'Flutter framework error',
      feature: 'app',
      error: details.exception,
      stackTrace: details.stack,
      metadata: {'library': details.library},
    );
    if (kDebugMode) FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('Uncaught async error', feature: 'app', error: error, stackTrace: stack);
    return true;
  };
  if (kReleaseMode) {
    // A calm card instead of a grey box if a single widget fails to build.
    ErrorWidget.builder = (details) => const _BuildErrorCard();
  }
}

Future<void> _seedStarterRecipesOnce(ProviderContainer container, AppLogger logger) async {
  try {
    final prefs = container.read(preferencesRepositoryProvider);
    final seeded = await prefs.readJson(_starterSeedKey);
    if (seeded is int && seeded >= _starterSeedVersion) return;

    final raw = await rootBundle.loadString('assets/seed/starter_recipes.json');
    final parsed = jsonDecode(raw);
    if (parsed is! List) return;
    final recipes = parsed.whereType<Map<String, dynamic>>().map(parseStarterRecipe).toList();
    final res = await container.read(recipeRepositoryProvider).seedStarterRecipes(recipes);
    if (res.isSuccess) await prefs.writeJson(_starterSeedKey, _starterSeedVersion);
    logger.info('Starter recipes seeded', feature: 'bootstrap', metadata: {'count': res.orNull});
  } catch (e, st) {
    // Never block launch on optional sample content.
    logger.error('Starter seeding failed', feature: 'bootstrap', error: e, stackTrace: st);
  }
}

class ChefApp extends ConsumerWidget {
  const ChefApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Chef’s Kiss',
      debugShowCheckedModeBanner: false,
      theme: ChefTheme.light(),
      darkTheme: ChefTheme.dark(),
      themeMode: ThemeMode.system,
      scaffoldMessengerKey: ChefToastService.messengerKey,
      routerConfig: ref.watch(routerProvider),
    );
  }
}

class _BuildErrorCard extends StatelessWidget {
  const _BuildErrorCard();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Something on this screen couldn’t be displayed.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF6B625B)),
        ),
      ),
    );
  }
}

/// Builds a [Recipe] from the bundled starter JSON format.
Recipe parseStarterRecipe(Map<String, dynamic> json) {
  final recipeId = json['id'] as String;

  final ingredients = (json['ingredients'] as List<dynamic>? ?? const []).map((i) {
    return RecipeIngredient(
      id: i['id'] as String,
      recipeId: recipeId,
      displayName: i['displayName'] as String,
      quantity: i['quantityNum'] != null ? Rational(i['quantityNum'] as int, i['quantityDen'] as int? ?? 1) : null,
      unitCode: i['unitCode'] as String?,
      authoredQuantity: i['authoredQuantity'] as String?,
      scalingPolicy: ScalingPolicy.fromString(i['scalingPolicy'] as String?),
      prepText: i['prepText'] as String?,
      position: i['position'] as int? ?? 1,
      icon: i['icon'] as String? ?? RecipeArt.iconKeyFor(i['displayName'] as String),
      iconColor: i['iconColor'] as String?,
      x: (i['x'] as num?)?.toDouble(),
      y: (i['y'] as num?)?.toDouble(),
    );
  }).toList();

  final steps = (json['steps'] as List<dynamic>? ?? const []).map((s) {
    final timers = (s['timers'] as List<dynamic>? ?? const []).map((t) {
      return StepTimer(
        id: t['id'] as String,
        recipeStepId: s['id'] as String,
        label: t['label'] as String,
        durationSeconds: t['durationSeconds'] as int,
        position: t['position'] as int? ?? 1,
      );
    }).toList();
    return RecipeStep(
      id: s['id'] as String,
      recipeId: recipeId,
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
  }).toList();

  final tools = (json['tools'] as List<dynamic>? ?? const []).map((t) {
    return RecipeTool(
      id: t['id'] as String,
      recipeId: recipeId,
      displayName: t['displayName'] as String,
      quantity: t['quantity'] as int? ?? 1,
      position: t['position'] as int? ?? 1,
    );
  }).toList();

  final labels = (json['labels'] as List<dynamic>? ?? const []).map((l) {
    return RecipeLabel(
      id: l['id'] as String,
      recipeId: recipeId,
      labelId: l['labelId'] as String,
      kind: l['kind'] as String,
      canonicalKey: l['canonicalKey'] as String,
      displayName: l['displayName'] as String,
    );
  }).toList();

  final now = DateTime.now().toUtc().millisecondsSinceEpoch;
  return Recipe(
    id: recipeId,
    profileId: json['profileId'] as String? ?? 'default',
    title: json['title'] as String,
    slug: json['slug'] as String?,
    summary: json['summary'] as String?,
    status: RecipeStatus.fromString(json['status'] as String?),
    baseServings: Rational(json['baseServingsNum'] as int? ?? 2, json['baseServingsDen'] as int? ?? 1),
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
    moodStamps: (json['moodStamps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    stickers: (json['stickers'] as List<dynamic>?)
            ?.map((e) => ScrapbookSticker.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    washiTapes: (json['washiTapes'] as List<dynamic>?)
            ?.map((e) => WashiTapeDecoration.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    createdAt: now,
    updatedAt: now,
    ingredients: ingredients,
    steps: steps,
    tools: tools,
    labels: labels,
  );
}
