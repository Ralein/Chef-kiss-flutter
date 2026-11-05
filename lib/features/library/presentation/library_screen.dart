import 'dart:async';

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/audio_chime_service.dart';
import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../imports/presentation/import_flows.dart';
import '../../nutrition/presentation/recipe_insights.dart';
import '../../../app/widgets/food_art.dart';
import '../../../app/widgets/kitchen_format.dart';
import '../../journal/presentation/journal_view.dart';
import 'widgets/bookshelf.dart';

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

enum LibraryView { shelf, journal }

/// The Recipes tab: a bookshelf of recipe books, or the recipe journal
/// opened to one of them.
class LibraryScreen extends ConsumerStatefulWidget {
  final LibraryView initialView;
  final String? initialRecipeId;
  final bool startDecorating;

  const LibraryScreen({
    super.key,
    this.initialView = LibraryView.shelf,
    this.initialRecipeId,
    this.startDecorating = false,
  });

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
  late LibraryView _view = widget.initialView;
  late String? _journalRecipeId = widget.initialRecipeId;
  final _journalKey = GlobalKey<JournalViewState>();

  void _openInJournal(Recipe recipe) {
    audioChime.playPageFlip();
    setState(() {
      _journalRecipeId = recipe.id;
      _view = LibraryView.journal;
    });
  }

  void _setView(LibraryView view) {
    if (view == _view) return;
    setState(() => _view = view);
  }

  Future<void> _showBookActions(Recipe recipe) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Text(recipe.title, style: ctx.chefText.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                '${KitchenFormat.minutes(recipe.totalMinutes)} · serves ${recipe.baseServings.toDisplayString()} · '
                '${recipe.ingredients.length} ingredients',
                style: ctx.chefText.bodySmall,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.auto_stories_outlined),
              title: const Text('Open in journal'),
              onTap: () => Navigator.pop(ctx, 'journal'),
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new_rounded),
              title: const Text('Details & nutrition'),
              onTap: () => Navigator.pop(ctx, 'details'),
            ),
            if (recipe.steps.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.play_arrow_rounded),
                title: const Text('Start cooking'),
                onTap: () => Navigator.pop(ctx, 'cook'),
              ),
            ListTile(
              leading: Icon(recipe.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
              title: Text(recipe.isFavorite ? 'Remove from favorites' : 'Add to favorites'),
              onTap: () => Navigator.pop(ctx, 'favorite'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'journal':
        _openInJournal(recipe);
      case 'details':
        context.push('/recipe/${recipe.id}');
      case 'cook':
        context.push('/cook/${recipe.id}');
      case 'favorite':
        _toggleFavorite(recipe);
    }
  }

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
      filters.add(
        _Filter('label:${e.key}', e.value.name, (r) => r.labels.any((l) => l.canonicalKey.toLowerCase() == e.key)),
      );
    }
    return filters;
  }

  List<Recipe> _apply(List<Recipe> recipes, List<_Filter> filters, {bool unfiltered = false}) {
    final filterId = unfiltered ? 'all' : _filterId;
    final query = unfiltered ? '' : _query;
    final filter = filters.firstWhere((f) => f.id == filterId, orElse: () => filters.first);
    final out = recipes.where((r) {
      if (!filter.test(r)) return false;
      if (query.isEmpty) return true;
      return r.title.toLowerCase().contains(query) ||
          (r.summary?.toLowerCase().contains(query) ?? false) ||
          r.ingredients.any((i) => i.displayName.toLowerCase().contains(query)) ||
          r.labels.any((l) => l.displayName.toLowerCase().contains(query));
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
      child: PopScope(
        canPop: _view == LibraryView.shelf,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          final journal = _journalKey.currentState;
          if (journal != null && journal.isDecorating) return;
          _setView(LibraryView.shelf);
        },
        child: Scaffold(
          floatingActionButton: _view == LibraryView.journal
              ? null
              : FloatingActionButton.extended(
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
              data: (all) => _view == LibraryView.journal ? _buildJournal(context, all) : _buildContent(context, all),
            ),
          ),
        ),
      ),
    );
  }

  /// All recipes in the shelf's sort order — the journal is the whole book,
  /// whatever the shelf is filtered to.
  /// The journal is a book: recipes stay in the order they were added, so
  /// editing or decorating one never shuffles the pages.
  List<Recipe> _bookOrder(List<Recipe> all) => [...all]
    ..sort((a, b) {
      final byAdded = a.createdAt.compareTo(b.createdAt);
      return byAdded != 0 ? byAdded : a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

  Widget _buildJournal(BuildContext context, List<Recipe> all) {
    final t = context.chefText;
    final recipes = _bookOrder(all);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 16, 2),
          child: Row(
            children: [
              Expanded(
                child: Semantics(header: true, child: Text('Recipe journal', style: t.titleLarge)),
              ),
              _ViewToggle(view: _view, onChanged: _setView),
            ],
          ),
        ),
        Expanded(
          child: recipes.isEmpty
              ? EmptyStateScene(
                  icon: Icons.auto_stories_outlined,
                  illustration: const DoodleCluster(ids: ['food-sourdough', 'food-whisk', 'food-basil']),
                  title: 'Your journal is empty',
                  message: 'Every recipe you add gets its own keepsake spread here.',
                  actionLabel: 'Add a recipe',
                  onAction: () => showAddRecipeSheet(context, ref),
                )
              : JournalView(
                  key: _journalKey,
                  recipes: recipes,
                  initialRecipeId: _journalRecipeId,
                  startDecorating: widget.startDecorating && _journalRecipeId == widget.initialRecipeId,
                  onRecipeShown: (id) => _journalRecipeId = id,
                ),
        ),
      ],
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
                    if (all.isNotEmpty) _ViewToggle(view: _view, onChanged: _setView),
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
              illustration: const DoodleCluster(ids: ['food-bread-loaf', 'food-tomato', 'food-whisk']),
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
              illustration: const DoodleCluster(ids: ['food-mushroom', 'food-garlic', 'food-chili']),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: BookshelfSliver(recipes: visible, onOpen: _openInJournal, onLongPress: _showBookActions),
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

class _ViewToggle extends StatelessWidget {
  final LibraryView view;
  final ValueChanged<LibraryView> onChanged;
  const _ViewToggle({required this.view, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 400;
    return SegmentedButton<LibraryView>(
      showSelectedIcon: false,
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
      segments: [
        ButtonSegment(
          value: LibraryView.shelf,
          icon: const Icon(Icons.shelves, size: 18),
          label: narrow ? null : const Text('Shelf'),
          tooltip: 'Bookshelf',
        ),
        ButtonSegment(
          value: LibraryView.journal,
          icon: const Icon(Icons.auto_stories_outlined, size: 18),
          label: narrow ? null : const Text('Journal'),
          tooltip: 'Recipe journal',
        ),
      ],
      selected: {view},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
