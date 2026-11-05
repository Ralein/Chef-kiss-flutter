import 'dart:async';

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../imports/presentation/import_flows.dart';
import '../../nutrition/presentation/recipe_insights.dart';
import 'widgets/recipe_card.dart';

enum _Sort { recent, alphabetical, quickest, fewestIngredients }

extension on _Sort {
  String get label => switch (this) {
        _Sort.recent => 'Recently updated',
        _Sort.alphabetical => 'A–Z',
        _Sort.quickest => 'Quickest',
        _Sort.fewestIngredients => 'Fewest ingredients',
      };
}

/// A library filter: built-ins (favorites, quick, easy, vegetarian) plus the
/// cuisine/tag labels that actually occur in the user's recipes.
class _Filter {
  final String id;
  final String label;
  final IconData? icon;
  final bool Function(Recipe) test;
  const _Filter(this.id, this.label, this.test, {this.icon});
}

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;
  String _query = '';
  String _filterId = 'all';
  _Sort _sort = _Sort.recent;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _query = value.trim().toLowerCase());
    });
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    final res = await ref.read(recipeRepositoryProvider).toggleFavorite(recipe.id);
    if (!mounted) return;
    res.when(
      ok: (isFav) => ChefToastService.show(
        context: context,
        title: isFav ? 'Added to favorites' : 'Removed from favorites',
        description: recipe.title,
        type: ChefToastType.success,
        duration: const Duration(seconds: 2),
      ),
      err: (f) => ChefToastService.show(context: context, title: f.message, type: ChefToastType.error),
    );
  }

  List<_Filter> _filtersFor(List<Recipe> recipes) {
    final filters = <_Filter>[
      _Filter('all', 'All', (_) => true),
      _Filter('fav', 'Favorites', (r) => r.isFavorite, icon: Icons.favorite_rounded),
      _Filter('quick', 'Under 30 min', (r) => r.totalMinutes > 0 && r.totalMinutes <= 30, icon: Icons.bolt_rounded),
      _Filter('easy', 'Easy', (r) => r.difficulty == RecipeDifficulty.easy),
      _Filter('veg', 'Vegetarian', (r) {
        final diet = RecipeInsights.of(r).diet;
        return diet.isComplete && diet.isVegetarian;
      }, icon: Icons.eco_outlined),
    ];

    final counts = <String, ({String name, int count})>{};
    for (final r in recipes) {
      for (final l in r.labels.where((l) => l.kind == 'cuisine' || l.kind == 'tag' || l.kind == 'dietary')) {
        final key = l.canonicalKey.toLowerCase();
        counts[key] = (name: l.displayName, count: (counts[key]?.count ?? 0) + 1);
      }
    }
    final top = counts.entries.toList()..sort((a, b) => b.value.count.compareTo(a.value.count));
    for (final e in top.take(6)) {
      filters.add(_Filter('label:${e.key}', e.value.name,
          (r) => r.labels.any((l) => l.canonicalKey.toLowerCase() == e.key)));
    }
    return filters;
  }

  List<Recipe> _apply(List<Recipe> recipes, List<_Filter> filters) {
    final filter = filters.firstWhere((f) => f.id == _filterId, orElse: () => filters.first);
    final out = recipes.where((r) {
      if (!filter.test(r)) return false;
      if (_query.isEmpty) return true;
      return r.title.toLowerCase().contains(_query) ||
          (r.summary?.toLowerCase().contains(_query) ?? false) ||
          r.ingredients.any((i) => i.displayName.toLowerCase().contains(_query)) ||
          r.labels.any((l) => l.displayName.toLowerCase().contains(_query));
    }).toList();

    switch (_sort) {
      case _Sort.recent:
        out.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case _Sort.alphabetical:
        out.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case _Sort.quickest:
        int minutes(Recipe r) => r.totalMinutes <= 0 ? 1 << 20 : r.totalMinutes;
        out.sort((a, b) => minutes(a).compareTo(minutes(b)));
      case _Sort.fewestIngredients:
        out.sort((a, b) => a.ingredients.length.compareTo(b.ingredients.length));
    }
    return out;
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 5) return 'Late-night cooking?';
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(allRecipesProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): _searchFocus.requestFocus,
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): _searchFocus.requestFocus,
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'library-fab',
          onPressed: () => showAddRecipeSheet(context, ref),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New recipe'),
        ),
        body: SafeArea(
          bottom: false,
          child: recipesAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(
              message: 'Your recipes could not be loaded.',
              onRetry: () => ref.invalidate(allRecipesProvider),
            ),
            data: (all) => _buildContent(context, all),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Recipe> all) {
    final c = context.chefColors;
    final t = context.chefText;
    final filters = _filtersFor(all);
    final visible = _apply(all, filters);
    final favorites = all.where((r) => r.isFavorite).length;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const ChefBrandBadge(size: 36, showTitle: false),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_greeting, style: t.bodyMedium?.copyWith(color: c.contentSecondary)),
                          Semantics(header: true, child: Text('Your recipes', style: t.headlineMedium)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _QuickActions(
                  onCreate: () => showAiStudioSheet(context, ref),
                  onScan: () => context.go('/scan'),
                  onImport: () => showAddRecipeSheet(context, ref),
                ),
                if (all.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          onChanged: _onSearchChanged,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search recipes, ingredients, tags',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<_Sort>(
                        tooltip: 'Sort recipes',
                        initialValue: _sort,
                        onSelected: (s) => setState(() => _sort = s),
                        itemBuilder: (_) => [
                          for (final s in _Sort.values)
                            CheckedPopupMenuItem(value: s, checked: s == _sort, child: Text(s.label)),
                        ],
                        icon: const Icon(Icons.sort_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        if (all.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final f = filters[i];
                  return FilterChip(
                    selected: _filterId == f.id,
                    showCheckmark: false,
                    avatar: f.icon == null ? null : Icon(f.icon, size: 18),
                    label: Text(f.label),
                    onSelected: (_) => setState(() => _filterId = f.id),
                  );
                },
              ),
            ),
          ),
        if (all.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Text(
                '${visible.length} of ${all.length} recipes · $favorites favorite${favorites == 1 ? '' : 's'}',
                style: t.bodySmall,
              ),
            ),
          ),
        if (all.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateScene(
              icon: Icons.menu_book_rounded,
              title: 'Your cookbook is empty',
              message: 'Create a recipe with AI, scan a cookbook page, import from a website, or write your own.',
              actionLabel: 'Add your first recipe',
              onAction: () => showAddRecipeSheet(context, ref),
            ),
          )
        else if (visible.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateScene(
              icon: Icons.search_off_rounded,
              title: 'No matching recipes',
              message: 'Try a different search or filter.',
              actionLabel: 'Clear filters',
              onAction: () {
                _searchController.clear();
                setState(() {
                  _query = '';
                  _filterId = 'all';
                });
              },
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: RecipeGrid(
              recipes: visible,
              onOpen: (r) => context.push('/recipe/${r.id}'),
              onToggleFavorite: _toggleFavorite,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 104)),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onScan;
  final VoidCallback onImport;
  const _QuickActions({required this.onCreate, required this.onScan, required this.onImport});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;

    Widget action(IconData icon, String title, String subtitle, Color tint, VoidCallback onTap) {
      return Expanded(
        child: ChefCard(
          onTap: onTap,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: c.meterTrack(tint), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: tint, size: 22),
              ),
              const SizedBox(height: 10),
              Text(title, style: t.titleSmall, maxLines: 2),
              const SizedBox(height: 2),
              Text(subtitle, style: t.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        action(Icons.auto_awesome_rounded, 'AI recipe', 'Describe any dish', c.accentTomato, onCreate),
        const SizedBox(width: 10),
        action(Icons.photo_camera_outlined, 'Scan food', 'Calories & macros', c.accentHerb, onScan),
        const SizedBox(width: 10),
        action(Icons.download_rounded, 'Import', 'Link, text or photo', c.macroCarbs, onImport),
      ],
    ),
    );
  }
}
