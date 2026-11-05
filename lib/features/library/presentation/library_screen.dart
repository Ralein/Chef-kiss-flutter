import 'dart:async';

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/audio_chime_service.dart';
import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../imports/presentation/import_flows.dart';
import '../../nutrition/presentation/recipe_insights.dart';
import '../../../app/widgets/kitchen_format.dart';
import '../../journal/presentation/journal_view.dart';
import 'widgets/bookshelf.dart';
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

/// How the Recipes tab shows your recipes. The last choice is remembered.
enum LibraryView {
  cards('Cards', 'Recipe cards'),
  shelf('Shelf', 'Bookshelf'),
  journal('Journal', 'Recipe journal');

  final String label;
  final String tooltip;
  const LibraryView(this.label, this.tooltip);

  IconData get icon => switch (this) {
        LibraryView.cards => LucideIcons.layoutGrid,
        LibraryView.shelf => LucideIcons.libraryBig,
        LibraryView.journal => LucideIcons.bookOpen,
      };

  static LibraryView? fromName(String? name) => LibraryView.values.where((v) => v.name == name).firstOrNull;
}

/// The Recipes tab: photo cards, a bookshelf of recipe books, or the recipe
/// journal opened to one of them.
class LibraryScreen extends ConsumerStatefulWidget {
  /// Forces a view (deep links); otherwise the remembered one is used.
  final LibraryView? initialView;
  final String? initialRecipeId;
  final bool startDecorating;

  const LibraryScreen({
    super.key,
    this.initialView,
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
  LibraryView? _view;

  /// Where Back returns to after opening a book in the journal.
  LibraryView _browseView = LibraryView.shelf;
  late String? _journalRecipeId = widget.initialRecipeId;
  final _journalKey = GlobalKey<JournalViewState>();

  void _openInJournal(Recipe recipe) {
    audioChime.playPageFlip();
    setState(() {
      _journalRecipeId = recipe.id;
      if (_view != LibraryView.journal) _browseView = _view ?? LibraryView.shelf;
      _view = LibraryView.journal;
    });
  }

  /// A choice made with the view switch: remembered for next time.
  void _chooseView(LibraryView view) {
    if (view == _view) return;
    setState(() {
      if (view != LibraryView.journal) _browseView = view;
      _view = view;
    });
    unawaited(ref.read(preferencesRepositoryProvider).writeJson(libraryViewKey, view.name));
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
              leading: const Icon(LucideIcons.bookOpen),
              title: const Text('Open in journal'),
              onTap: () => Navigator.pop(ctx, 'journal'),
            ),
            ListTile(
              leading: const Icon(LucideIcons.notebookText),
              title: const Text('Details & nutrition'),
              onTap: () => Navigator.pop(ctx, 'details'),
            ),
            if (recipe.steps.isNotEmpty)
              ListTile(
                leading: const Icon(LucideIcons.chefHat),
                title: const Text('Start cooking'),
                onTap: () => Navigator.pop(ctx, 'cook'),
              ),
            ListTile(
              leading: Icon(recipe.isFavorite ? LucideIcons.heartOff : LucideIcons.heart),
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
      _Filter('fav', 'Favorites', (r) => r.isFavorite, icon: LucideIcons.heart),
      _Filter('quick', 'Under 30 min', (r) => r.totalMinutes > 0 && r.totalMinutes <= 30, icon: LucideIcons.zap),
      _Filter('easy', 'Easy', (r) => r.difficulty == RecipeDifficulty.easy, icon: LucideIcons.smile),
      _Filter('veg', 'Vegetarian', (r) {
        final diet = RecipeInsights.of(r).diet;
        return diet.isComplete && diet.isVegetarian;
      }, icon: LucideIcons.leaf),
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

  /// Back inside the journal: leave decorate mode, then return to the view
  /// the journal was opened from. Ignored when another tab or a full-screen
  /// page is showing, so Back works normally there.
  Future<bool> _handleBack() async {
    if (!mounted || _view != LibraryView.journal) return false;
    if (!TickerMode.valuesOf(context).enabled || !(ModalRoute.of(context)?.isCurrent ?? false)) return false;
    final journal = _journalKey.currentState;
    if (journal != null && journal.isDecorating) {
      journal.stopDecorating();
      return true;
    }
    // Leaving the journal with Back also makes the previous view the one to
    // reopen next time.
    _chooseView(_browseView);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(allRecipesProvider);
    final remembered = ref.watch(libraryViewPrefProvider);
    if (_view == null && !remembered.isLoading) {
      _view = widget.initialView ?? LibraryView.fromName(remembered.valueOrNull) ?? LibraryView.shelf;
      if (_view != LibraryView.journal) _browseView = _view!;
    }
    final view = _view;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): _searchFocus.requestFocus,
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): _searchFocus.requestFocus,
      },
      // go_router only consults PopScope when a navigator has more than one
      // page, so the tab's root screen listens for Back directly.
      child: BackButtonListener(
        onBackButtonPressed: _handleBack,
        child: Scaffold(
          floatingActionButton: view == LibraryView.journal || view == null
              ? null
              : FloatingActionButton.extended(
                  heroTag: 'library-fab',
                  onPressed: () => showAddRecipeSheet(context, ref),
                  icon: const Icon(LucideIcons.plus),
                  label: const Text('New recipe'),
                ),
          body: SafeArea(
            bottom: false,
            child: view == null
                ? const LoadingView()
                : recipesAsync.when(
                    loading: () => const LoadingView(),
                    error: (e, _) => ErrorView(
                      message: 'Your recipes could not be loaded.',
                      onRetry: () => ref.invalidate(allRecipesProvider),
                    ),
                    data: (all) =>
                        view == LibraryView.journal ? _buildJournal(context, all) : _buildContent(context, all, view),
                  ),
          ),
        ),
      ),
    );
  }

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
              _ViewToggle(view: LibraryView.journal, onChanged: _chooseView),
            ],
          ),
        ),
        Expanded(
          child: recipes.isEmpty
              ? EmptyStateScene(
                  icon: LucideIcons.bookOpen,
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

  Widget _buildContent(BuildContext context, List<Recipe> all, LibraryView view) {
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
                    if (all.isNotEmpty) _ViewToggle(view: view, onChanged: _chooseView),
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
                            prefixIcon: const Icon(LucideIcons.search, size: 20),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    icon: const Icon(LucideIcons.x, size: 20),
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
                        icon: const Icon(LucideIcons.arrowUpDown, size: 20),
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
                    avatar: f.icon == null ? null : Icon(f.icon, size: 16),
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
              icon: LucideIcons.bookHeart,
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
              icon: LucideIcons.searchX,
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
          if (view == LibraryView.cards)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: RecipeGrid(
                recipes: visible,
                onOpen: (r) => context.push('/recipe/${r.id}'),
                onToggleFavorite: _toggleFavorite,
                onLongPress: _showBookActions,
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
          action(LucideIcons.sparkles, 'AI recipe', 'Describe any dish', c.accentTomato, onCreate),
          const SizedBox(width: 10),
          action(LucideIcons.scanLine, 'Scan food', 'Calories & macros', c.accentHerb, onScan),
          const SizedBox(width: 10),
          action(LucideIcons.download, 'Import', 'Link, text or photo', c.macroCarbs, onImport),
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
    final roomy = MediaQuery.sizeOf(context).width >= 600;
    return SegmentedButton<LibraryView>(
      showSelectedIcon: false,
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
      segments: [
        for (final v in LibraryView.values)
          ButtonSegment(
            value: v,
            icon: Icon(v.icon, size: 18),
            label: roomy ? Text(v.label) : null,
            tooltip: v.tooltip,
          ),
      ],
      selected: {view},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
