import 'package:app_contracts/app_contracts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/providers.dart';
import '../../../data/seed/starter_recipes.dart';
import '../../library/domain/book_covers.dart';
import '../../library/domain/shelf_style.dart';

/// The welcome tour finished on this device: the tour's version once it's
/// done. Until then the app opens on the tour.
const onboardingDoneKey = 'onboarding.done';

/// Bump when the tour changes enough to show it again; it then opens once
/// more, starting from what the cook already set.
const tourVersion = 3;

/// Whether the stored [value] means the current tour has been finished.
bool isTourDone(Object? value) => value is int && value >= tourVersion;

/// How many new recipes the cook wants to try this year.
const cookingGoalKey = 'profile.cooking_goal';

/// The home screen's welcome card, once closed or followed.
const welcomeCardDismissedKey = 'home.welcome_dismissed';

/// What a profile is called until the cook gives a name.
const defaultCookName = 'Local Cook';

/// Whether the welcome tour has been finished on this device.
final onboardingDoneProvider = StreamProvider<bool>((ref) {
  return ref.watch(preferencesRepositoryProvider).watchJson(onboardingDoneKey).map(isTourDone);
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
  /// A ready-made look for the shelves, or null to keep them as they are.
  ShelfLook? look = shelfLooks.first;

  /// The shelves as the cook already dressed them, when that's none of the
  /// ready-made looks.
  ShelfStyle? ownShelves;
  final Set<String> starterIds = {};

  /// Starts from the shelves already set, for a cook seeing a new tour.
  void prefill({ShelfStyle? shelves}) {
    if (shelves != null) {
      look = shelfLooks.where((l) => shelves.looksLike(l.style)).firstOrNull;
      // Shelves dressed by hand stay as they are unless a look is picked.
      if (look == null) ownShelves = shelves;
    }
  }

  /// The shelves as they'll look once the tour is saved.
  ShelfStyle get shelves => look?.style ?? ownShelves ?? const ShelfStyle();
}

/// Saves the cook's answers: the shelves' look and the starter recipes they
/// picked. The tour is marked done separately, when the cook opens their
/// kitchen.
Future<void> saveOnboarding(
  OnboardingAnswers answers, {
  required List<Recipe> starters,
  required PreferencesRepository prefs,
  required RecipeRepository recipes,
  required CollectionRepository books,
}) async {
  // A fresh look for the shelves; books already arranged stay where they are.
  if (answers.look case final look?) {
    final current = ShelfStyle.fromJson(await prefs.readJson(shelfStyleKey));
    if (!current.looksLike(look.style)) await prefs.writeJson(shelfStyleKey, current.withLook(look.style).toJson());
  }

  final picked = [
    for (final r in starters)
      if (answers.starterIds.contains(r.id)) r,
  ];
  if (picked.isEmpty) return;
  await recipes.seedStarterRecipes(picked);
  // Each classic stands on the shelf as its own book, dressed as it was
  // shown in the tour.
  for (final r in picked) {
    final book = (await books.createCollection(profileId: 'default', name: r.title, colorToken: 'accent.herb')).orNull;
    if (book == null) continue;
    await books.addRecipeToCollection(book.id, r.id);
    await saveBookCover(prefs, book.id, BookCover(style: r.bookStyle));
  }
}

Future<void> saveCookName(SettingsRepository settings, String name) async {
  final profile = (await settings.getProfile()).orNull;
  if (profile != null) await settings.updateProfile(profile.copyWith(displayName: name.trim()));
}

Future<void> markTourDone(PreferencesRepository prefs) => prefs.writeJson(onboardingDoneKey, tourVersion);
