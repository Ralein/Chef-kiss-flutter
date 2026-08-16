import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_shell.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/recipe_detail/presentation/recipe_detail_screen.dart';
import '../features/recipe_editor/presentation/recipe_editor_screen.dart';
import '../features/cook_mode/presentation/cook_mode_screen.dart';
import '../features/collections/presentation/collections_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/imports/presentation/import_review_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Shell routes with persistent adaptive navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LibraryScreen(),
        ),
        GoRoute(
          path: '/recipe/:id',
          builder: (context, state) {
            final recipeId = state.pathParameters['id']!;
            return RecipeDetailScreen(recipeId: recipeId);
          },
        ),
        GoRoute(
          path: '/collections',
          builder: (context, state) => const CollectionsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),

    // Immersive Cook Mode (dedicated route without shell)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/cook/:id',
      builder: (context, state) {
        final recipeId = state.pathParameters['id']!;
        return CookModeScreen(recipeId: recipeId);
      },
    ),

    // Guided Recipe Editor (new or edit existing)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/editor',
      builder: (context, state) => const RecipeEditorScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/editor/:id',
      builder: (context, state) {
        final recipeId = state.pathParameters['id'];
        return RecipeEditorScreen(recipeId: recipeId);
      },
    ),

    // Smart Import Review Screen
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/import/review/:id',
      builder: (context, state) {
        final jobId = state.pathParameters['id']!;
        return ImportReviewScreen(jobId: jobId);
      },
    ),
  ],
);
