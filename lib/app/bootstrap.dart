import 'dart:async';
import 'dart:ui';

import 'package:app_contracts/app_contracts.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../data/seed/starter_recipes.dart';
import '../features/onboarding/application/onboarding.dart';
import '../features/voice/read_aloud_controller.dart';
import '../features/voice/spoken_text.dart';
import 'audio_chime_service.dart';
import 'chef_toast_service.dart';
import 'providers.dart';
import 'router.dart';
import 'widgets/splash_view.dart';

/// Bump when the bundled sample content changes. v1–v3 added sample recipes
/// on first launch; v4 offers real starter recipes in the welcome tour
/// instead and retires those samples.
const _starterSeedVersion = 4;
const _starterSeedKey = 'seed.starter_version';

Future<void> bootstrapAndRun() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // The system launch screen stays up until the splash's medallion is ready
  // to draw, so the two meet without a blink.
  binding.deferFirstFrame();
  unawaited(precacheSplashArt().whenComplete(binding.allowFirstFrame));
  final container = ProviderContainer();
  final logger = container.read(appLoggerProvider);
  _installErrorHandlers(logger);

  // Keep voice preferences loaded so a finishing timer can check them
  // synchronously.
  container.listen(voiceSettingsProvider, (_, __) {});

  // Timer alarms surface from anywhere in the app, not just the recipe page.
  container.read(kitchenTimersProvider).onFinished = (timer) {
    audioChime.playTimerComplete();
    ChefToastService.show(
      title: '${timer.label} is done',
      description: timer.recipeTitle,
      type: ChefToastType.alarm,
      duration: const Duration(seconds: 8),
    );
    final voice = container.read(voiceSettingsProvider).valueOrNull ?? const VoiceSettings();
    if (voice.announceTimers) {
      unawaited(container
          .read(readAloudProvider)
          .say('timer:${timer.id}', SpokenRecipe.timerDone(timer.label, recipeTitle: timer.recipeTitle)));
    }
  };

  runApp(UncontrolledProviderScope(container: container, child: const ChefApp()));

  // Tidy up after the first frame: opening the database (a web worker on the
  // web, disk I/O on low-end phones) must never delay startup.
  unawaited(_retireSamplesOnce(container, logger));
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

Future<void> _retireSamplesOnce(ProviderContainer container, AppLogger logger) async {
  try {
    final prefs = container.read(preferencesRepositoryProvider);
    final seeded = await prefs.readJson(_starterSeedKey);
    final previous = seeded is int ? seeded : 0;
    if (previous >= _starterSeedVersion) return;
    final retired = await retireSampleRecipes(container.read(recipeRepositoryProvider));
    await prefs.writeJson(_starterSeedKey, _starterSeedVersion);
    logger.info('Sample recipes retired', feature: 'bootstrap', metadata: {'count': retired});
  } catch (e, st) {
    // Never block launch on tidying up sample content.
    logger.error('Retiring sample recipes failed', feature: 'bootstrap', error: e, stackTrace: st);
  }
}

/// Moves the placeholder recipes earlier versions added to Recently deleted
/// (restorable from Settings), and clears any cover still showing the stock
/// sketchbook art those versions bundled. Returns how many were retired.
@visibleForTesting
Future<int> retireSampleRecipes(RecipeRepository repo) async {
  var retired = 0;
  for (final id in retiredStarterIds) {
    final recipe = (await repo.getRecipeById(id)).orNull;
    if (recipe == null || recipe.isDeleted) continue;
    if ((await repo.deleteRecipe(id)).isSuccess) retired++;
  }
  final live = (await repo.getRecipes()).orNull ?? const <Recipe>[];
  for (final recipe in live) {
    if (recipe.coverImage?.startsWith(_retiredArt) ?? false) {
      await repo.saveRecipe(recipe.copyWith(clearCoverImage: true));
    }
  }
  return retired;
}

/// Where the retired sample artwork lived.
const _retiredArt = 'assets/illustrations/sketchbook_';

class ChefApp extends ConsumerWidget {
  const ChefApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Until it's known whether the welcome tour is done: the splash, rather
    // than a glimpse of the wrong screen.
    final onboarded = ref.watch(onboardingDoneProvider);
    // A returning cook's shelf opens filled, not on a loading spinner.
    final deciding = !ref.watch(splashShownProvider) ||
        onboarded.isLoading ||
        (onboarded.valueOrNull == true && ref.watch(allRecipesProvider).isLoading);
    return MaterialApp.router(
      title: 'Chef’s Kiss',
      debugShowCheckedModeBanner: false,
      theme: ChefTheme.light(),
      darkTheme: ChefTheme.dark(),
      themeMode: ref.watch(appearanceProvider).valueOrNull ?? ThemeMode.system,
      scaffoldMessengerKey: ChefToastService.messengerKey,
      routerConfig: ref.watch(routerProvider),
      // The launch screen carries on until the app knows whether to open the
      // welcome tour or the kitchen, then gives way to it.
      builder: (context, child) => AnimatedSwitcher(
        duration: ChefMotion.emphasis,
        switchInCurve: ChefMotion.easeExit,
        child: deciding ? const SplashView(key: ValueKey('splash')) : KeyedSubtree(key: const ValueKey('app'), child: child!),
      ),
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
