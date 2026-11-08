import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/about/presentation/developer_screen.dart';
import '../features/about/presentation/legal_screen.dart';
import '../features/collections/presentation/collection_detail_screen.dart';
import '../features/collections/presentation/collections_screen.dart';
import '../features/cook_mode/presentation/cook_mode_screen.dart';
import '../features/food_log/presentation/food_log_screen.dart';
import '../features/imports/presentation/dish_ideas_screen.dart';
import '../features/imports/presentation/import_review_screen.dart';
import '../features/library/presentation/book_editor_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/onboarding/application/onboarding.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/recipe_detail/presentation/recipe_detail_screen.dart';
import '../features/recipe_editor/presentation/recipe_editor_screen.dart';
import '../features/scan/presentation/scan_analysis_screen.dart';
import '../features/scan/presentation/scan_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'app_shell.dart';

/// Root navigator key — full-screen flows (recipe, cook mode, editor) are
/// pushed here, above the tab shell.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// One router per app instance (tests get a fresh one per ProviderScope).
/// Until the welcome tour is finished, every page leads to it.
final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ValueNotifier<bool?>(null);
  ref.listen(onboardingDoneProvider, (_, next) => onboarded.value = next.valueOrNull, fireImmediately: true);
  final router = createRouter(onboarded: onboarded);
  ref.onDispose(() {
    router.dispose();
    onboarded.dispose();
  });
  return router;
});

/// Pages a cook can open before finishing the welcome tour.
const _openBeforeWelcome = {'/welcome', '/privacy', '/terms'};

/// [onboarded] is whether the welcome tour is done; null while unknown.
GoRouter createRouter({String initialLocation = '/', ValueListenable<bool?>? onboarded}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: onboarded,
    redirect: (context, state) {
      final done = onboarded?.value;
      final at = state.matchedLocation;
      if (done == false && !_openBeforeWelcome.contains(at)) return '/welcome';
      if (done == true && at == '/welcome') return '/';
      return null;
    },
    routes: [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/welcome',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/about',
        builder: (context, state) => const DeveloperScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/privacy',
        builder: (context, state) => const LegalScreen(document: LegalDocument.privacy),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/terms',
        builder: (context, state) => const LegalScreen(document: LegalDocument.terms),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/',
              // `/?view=journal&recipe=<id>[&decorate=1]` opens the cookbook at a recipe;
              // `&book=<id>` opens one book.
              builder: (context, state) {
                final q = state.uri.queryParameters;
                return LibraryScreen(
                  key: ValueKey('library:${state.uri.query}'),
                  initialView: LibraryView.fromName(q['view']),
                  initialRecipeId: q['recipe'],
                  initialBook: q['book'],
                  startDecorating: q['decorate'] == '1',
                );
              },
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/scan', builder: (context, state) => const ScanScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/log',
              builder: (context, state) => FoodLogScreen(
                key: ValueKey('log:${state.uri.queryParameters['day']}'),
                initialDayKey: state.uri.queryParameters['day'],
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/collections',
              builder: (context, state) => const CollectionsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => CollectionDetailScreen(collectionId: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => SettingsScreen(
                key: ValueKey('settings:${state.uri.query}'),
                initialSection: state.uri.queryParameters['section'],
              ),
            ),
          ]),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/recipe/:id',
        builder: (context, state) => RecipeDetailScreen(recipeId: state.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/book/:id',
        builder: (context, state) => BookEditorScreen(bookId: state.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/cook/:id',
        builder: (context, state) => CookModeScreen(
          recipeId: state.pathParameters['id']!,
          servings: double.tryParse(state.uri.queryParameters['servings'] ?? ''),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/editor',
        builder: (context, state) => const RecipeEditorScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/editor/:id',
        builder: (context, state) => RecipeEditorScreen(recipeId: state.pathParameters['id']),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/import/review/:id',
        builder: (context, state) => ImportReviewScreen(
          jobId: state.pathParameters['id']!,
          cookbookId: state.uri.queryParameters['cookbook'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/ideas',
        builder: (context, state) => const DishIdeasScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/analyze',
        builder: (context, state) => ScanAnalysisScreen(request: state.extra is ScanRequest ? state.extra as ScanRequest : null),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundScreen(),
  );
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_outlined, size: 48),
            const SizedBox(height: 12),
            Text('This page doesn’t exist', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => context.go('/'), child: const Text('Back to recipes')),
          ],
        ),
      ),
    );
  }
}
