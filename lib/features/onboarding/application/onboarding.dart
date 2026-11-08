import 'package:app_contracts/app_contracts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/providers.dart';
import '../../../data/seed/starter_recipes.dart';
import '../../library/domain/shelf_style.dart';

/// Set once the welcome tour is finished; until then the app opens on it.
const onboardingDoneKey = 'onboarding.done';

/// How many new recipes the cook wants to try this year.
const cookingGoalKey = 'profile.cooking_goal';

/// What the cook told the welcome tour about their kitchen.
const cookingHabitsKey = 'profile.habits';

/// The home screen's welcome card, once closed or followed.
const welcomeCardDismissedKey = 'home.welcome_dismissed';

/// What a profile is called until the cook gives a name.
const defaultCookName = 'Local Cook';

/// Whether the welcome tour has been finished on this device.
final onboardingDoneProvider = StreamProvider<bool>((ref) {
  return ref.watch(preferencesRepositoryProvider).watchJson(onboardingDoneKey).map((v) => v == true);
});

final cookingGoalProvider = StreamProvider<int?>((ref) {
  return ref.watch(preferencesRepositoryProvider).watchJson(cookingGoalKey).map((v) => v is int && v > 0 ? v : null);
});

final welcomeCardDismissedProvider = StreamProvider<bool>((ref) {
  return ref.watch(preferencesRepositoryProvider).watchJson(welcomeCardDismissedKey).map((v) => v == true);
});

/// The name the cook gave, or null while it's still the default.
final cookNameProvider = Provider<String?>((ref) {
  final name = ref.watch(userProfileProvider).valueOrNull?.displayName.trim();
  return name == null || name.isEmpty || name == defaultCookName ? null : name;
});

final starterRecipesProvider = FutureProvider<List<Recipe>>((ref) => loadStarterRecipes());

/// Everything the welcome tour asks.
class OnboardingAnswers {
  String name = '';
  String? frequency;
  final Set<String> wants = {};
  String? keeps;
  ShelfLook look = shelfLooks.first;
  final Set<String> starterIds = {};
  int goal = 52;

  Map<String, Object?> habitsJson() => {
    if (frequency != null) 'frequency': frequency,
    if (wants.isNotEmpty) 'wants': wants.toList(),
    if (keeps != null) 'keeps': keeps,
  };
}

/// Saves the cook's answers: their name, the shelves' look, the starter
/// recipes they picked and their goal. The tour is marked done separately,
/// once its last screen has played.
Future<void> saveOnboarding(
  OnboardingAnswers answers, {
  required List<Recipe> starters,
  required PreferencesRepository prefs,
  required SettingsRepository settings,
  required RecipeRepository recipes,
}) async {
  final name = answers.name.trim();
  if (name.isNotEmpty) await saveCookName(settings, name);

  // A fresh look for the shelves; books already arranged stay where they are.
  final current = ShelfStyle.fromJson(await prefs.readJson(shelfStyleKey));
  await prefs.writeJson(shelfStyleKey, current.withLook(answers.look.style).toJson());

  final picked = [
    for (final r in starters)
      if (answers.starterIds.contains(r.id)) r,
  ];
  if (picked.isNotEmpty) await recipes.seedStarterRecipes(picked);

  await prefs.writeJson(cookingGoalKey, answers.goal);
  await prefs.writeJson(cookingHabitsKey, answers.habitsJson());
}

Future<void> saveCookName(SettingsRepository settings, String name) async {
  final profile = (await settings.getProfile()).orNull;
  if (profile != null) await settings.updateProfile(profile.copyWith(displayName: name.trim()));
}
