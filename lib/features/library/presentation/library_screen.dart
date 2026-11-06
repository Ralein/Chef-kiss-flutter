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
import '../domain/shelf_style.dart';
import 'widgets/library_bookcase.dart';
import 'widgets/shelf_art.dart';
import 'widgets/shelf_edit_controller.dart';
import 'widgets/shelf_style_editor.dart';
import 'widgets/recipe_card.dart';

enum _Sort { shelf, recent, alphabetical, quickest, fewestIngredients }

extension on _Sort {
  String get label => switch (this) {
    _Sort.shelf => 'As on the shelves',
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

  const LibraryScreen({super.key, this.initialView, this.initialRecipeId, this.startDecorating = false});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;
  String _query = '';
  String _filterId = 'all';

  /// The sort picked from the menu; until then, the shelves' own order once
  /// books have been arranged there, else most recent first.
  _Sort? _sortChoice;
  LibraryView? _view;

  /// Where Back returns to after opening a book in the journal.
  LibraryView _browseView = LibraryView.shelf;

  /// Set while the bookcase is being dressed; it holds the unsaved style.
  ShelfEditController? _edit;

  /// A style just saved, shown until preferences report it back.
  ShelfStyle? _savedStyle;
  final _shelfScroll = ScrollController();

  /// Stands in for [_edit] when nothing is being dressed.
  final _noEdits = ChangeNotifier();

  /// Open the editor with its panel tucked away, to move books.
  bool _editorCollapsed = false;

  /// The bookcase's style: unsaved while dressing it, else as saved.
  ShelfStyle get _shelfStyle =>
      _edit?.style ?? _savedStyle ?? ref.watch(shelfStyleProvider).valueOrNull ?? const ShelfStyle();

  _Sort _sortFor(ShelfStyle style) => _sortChoice ?? (style.books != null ? _Sort.shelf : _Sort.recent);
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
      // As tall as its actions need; scrolls only on a very short screen.
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
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
                leading: const Icon(LucideIcons.paintbrush),
                title: const Text('Edit book'),
                subtitle: const Text('Spine colour, lettering, cover or spine'),
                onTap: () => Navigator.pop(ctx, 'book'),
              ),
              if (_view == LibraryView.shelf)
                ListTile(
                  leading: const Icon(LucideIcons.move),
                  title: const Text('Move on the shelves'),
                  subtitle: const Text('Hold a book, then drag it to a new spot'),
                  onTap: () => Navigator.pop(ctx, 'move'),
                ),
              ListTile(
                leading: Icon(recipe.isFavorite ? LucideIcons.heartOff : LucideIcons.heart),
                title: Text(recipe.isFavorite ? 'Remove from favorites' : 'Add to favorites'),
                onTap: () => Navigator.pop(ctx, 'favorite'),
              ),
            ],
          ),
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
      case 'book':
        context.push('/book/${recipe.id}');
      case 'move':
        _startStyling(_shelfStyle, collapsed: true);
      case 'favorite':
        _toggleFavorite(recipe);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _shelfScroll.dispose();
    _noEdits.dispose();
    if (_edit != null) {
      _edit!.dispose();
      // Leaving mid-edit: give the navigation bar back once this frame is done.
      final immersive = ref.read(immersiveModeProvider.notifier);
      Future.microtask(() => immersive.state = false);
    }
    super.dispose();
  }

  /// Dressing the bookcase takes the whole screen, navigation bar included.
  void _startStyling(ShelfStyle style, {bool collapsed = false}) {
    setState(() {
      _edit = ShelfEditController(style, scroll: _shelfScroll);
      _editorCollapsed = collapsed;
    });
    ref.read(immersiveModeProvider.notifier).state = true;
  }

  void _stopStyling() {
    final edit = _edit;
    setState(() => _edit = null);
    ref.read(immersiveModeProvider.notifier).state = false;
    // The editor still listens until this frame unmounts it.
    WidgetsBinding.instance.addPostFrameCallback((_) => edit?.dispose());
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

  List<Recipe> _apply(List<Recipe> recipes, List<_Filter> filters, ShelfStyle style, {bool unfiltered = false}) {
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

    switch (_sortFor(style)) {
      case _Sort.shelf:
        // Shelf by shelf, left to right; books never arranged after them.
        final place = {for (final (i, id) in (style.books ?? const <List<String>>[]).expand((s) => s).indexed) id: i};
        out.sort((a, b) {
          final byShelf = (place[a.id] ?? 1 << 30).compareTo(place[b.id] ?? 1 << 30);
          return byShelf != 0 ? byShelf : b.updatedAt.compareTo(a.updatedAt);
        });
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
    if (mounted && _edit != null) {
      // Put down the selected piece first, then leave without saving.
      if (_edit!.selected != null) {
        _edit!.select(null);
      } else {
        _stopStyling();
      }
      return true;
    }
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
          // One "add" per screen: an empty library uses its own call to action.
          floatingActionButton:
              view == LibraryView.journal ||
                  view == null ||
                  _edit != null ||
                  !(recipesAsync.valueOrNull?.isNotEmpty ?? false)
              ? null
              : FloatingActionButton.extended(
                  heroTag: 'library-fab',
                  onPressed: () => showAddRecipeSheet(context, ref),
                  icon: const Icon(LucideIcons.plus),
                  label: const Text('New recipe'),
                ),
          body: view == null
              ? const SafeArea(child: LoadingView())
              : recipesAsync.when(
                  loading: () => const SafeArea(child: LoadingView()),
                  error: (e, _) => SafeArea(
                    child: ErrorView(
                      message: 'Your recipes could not be loaded.',
                      onRetry: () => ref.invalidate(allRecipesProvider),
                    ),
                  ),
                  data: (all) => switch (view) {
                    LibraryView.journal => SafeArea(bottom: false, child: _buildJournal(context, all)),
                    LibraryView.shelf when all.isNotEmpty => _buildShelf(context, all),
                    _ => SafeArea(bottom: false, child: _buildCards(context, all)),
                  },
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

  /// Title, view switch, search, sort and filters — shared by cards and shelf.
  List<Widget> _header(BuildContext context, List<Recipe> all, LibraryView view, List<_Filter> filters, int visible) {
    final c = context.chefColors;
    final t = context.chefText;
    final favorites = all.where((r) => r.isFavorite).length;
    return [
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
              if (all.isNotEmpty) ...[
                const SizedBox(height: 18),
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
                    const SizedBox(width: 4),
                    PopupMenuButton<_Sort>(
                      tooltip: 'Sort recipes',
                      initialValue: _sortFor(_shelfStyle),
                      onSelected: (s) => setState(() => _sortChoice = s),
                      itemBuilder: (_) => [
                        for (final s in _Sort.values)
                          if (s != _Sort.shelf || _shelfStyle.books != null)
                            CheckedPopupMenuItem(value: s, checked: s == _sortFor(_shelfStyle), child: Text(s.label)),
                      ],
                      icon: const Icon(LucideIcons.arrowUpDown, size: 20),
                    ),
                    if (view == LibraryView.shelf)
                      IconButton(
                        tooltip: 'Style shelves',
                        onPressed: () => _startStyling(_shelfStyle),
                        icon: const Icon(LucideIcons.paintbrush, size: 20),
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
              separatorBuilder: (_, _) => const SizedBox(width: 8),
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
              '$visible of ${all.length} recipes · $favorites favorite${favorites == 1 ? '' : 's'}',
              style: t.bodySmall?.copyWith(color: c.contentSecondary),
            ),
          ),
        ),
    ];
  }

  Widget _emptyLibrary(BuildContext context) => EmptyStateScene(
    icon: LucideIcons.bookHeart,
    title: 'Your cookbook is empty',
    message: 'Create a recipe with AI, scan a cookbook page, import from a website, or write your own.',
    actionLabel: 'Add your first recipe',
    onAction: () => showAddRecipeSheet(context, ref),
  );

  Widget _noMatches() => EmptyStateScene(
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
  );

  Widget _buildCards(BuildContext context, List<Recipe> all) {
    final filters = _filtersFor(all);
    final visible = _apply(all, filters, _shelfStyle);
    return CustomScrollView(
      slivers: [
        ..._header(context, all, LibraryView.cards, filters, visible.length),
        if (all.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _emptyLibrary(context))
        else if (visible.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _noMatches())
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: RecipeGrid(
              recipes: visible,
              onOpen: (r) => context.push('/recipe/${r.id}'),
              onToggleFavorite: _toggleFavorite,
              onLongPress: _showBookActions,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 104)),
      ],
    );
  }

  /// The library room: the wall fills the screen (under the status bar too),
  /// shelves scroll over it, and the controls take the wall's light or dark.
  Widget _buildShelf(BuildContext context, List<Recipe> all) {
    final saved = ref.watch(shelfStyleProvider).valueOrNull ?? const ShelfStyle();
    // One shape whether or not the shelves are being dressed, so opening the
    // editor keeps every book (and its loaded cover) in place.
    return ListenableBuilder(
      listenable: _edit ?? _noEdits,
      builder: (context, _) => _shelfRoom(context, all, _edit?.style ?? _savedStyle ?? saved, _edit),
    );
  }

  Widget _shelfRoom(BuildContext context, List<Recipe> all, ShelfStyle style, ShelfEditController? edit) {
    final filters = _filtersFor(all);
    final visible = _apply(all, filters, style);
    final theme = style.isDark ? ChefTheme.dark() : ChefTheme.light();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Theme(
        data: theme,
        child: Builder(
          builder: (context) => Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: WallPainter(style: style.wall, tint: style.wallColor),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: CustomScrollView(
                  controller: _shelfScroll,
                  slivers: [
                    if (edit != null)
                      const SliverToBoxAdapter(child: SizedBox(height: 76))
                    else
                      ..._header(context, all, LibraryView.shelf, filters, visible.length),
                    if (visible.isEmpty && edit == null)
                      SliverFillRemaining(hasScrollBody: false, child: _noMatches())
                    else
                      // Dressing the shelves shows every book, whatever the
                      // filter, in the order the shelves keep them.
                      LibraryBookcase(
                        key: const ValueKey('bookcase'),
                        recipes: edit != null ? _apply(all, filters, style, unfiltered: true) : visible,
                        style: style,
                        // Books as arranged, unless sorted some other way (a
                        // book moved just now always shows where it was put).
                        arranged: (edit?.booksMoved ?? false) || _sortFor(style) == _Sort.shelf ? style.books : null,
                        onOpen: edit != null ? (_) {} : _openInJournal,
                        onLongPress: edit != null ? null : _showBookActions,
                        edit: edit,
                      ),
                    SliverToBoxAdapter(child: SizedBox(height: edit != null ? 340 : 120)),
                  ],
                ),
              ),
              if (edit != null)
                Positioned.fill(
                  child: ShelfStyleEditor(
                    controller: edit,
                    startCollapsed: _editorCollapsed,
                    onCancel: _stopStyling,
                    onSave: (s) async {
                      setState(() {
                        _savedStyle = s;
                        // Moved books show where they were put.
                        if (edit.booksMoved) _sortChoice = null;
                      });
                      _stopStyling();
                      await saveShelfStyle(ref, s);
                      if (mounted) setState(() => _savedStyle = null);
                    },
                  ),
                ),
            ],
          ),
        ),
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
