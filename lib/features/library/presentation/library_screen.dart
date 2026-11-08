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
import '../../onboarding/application/onboarding.dart';
import '../../recipe_detail/presentation/widgets/recipe_sheets.dart'
    show createBook, showMoveToBookSheet, showTextPromptDialog;
import '../domain/book_covers.dart';
import '../domain/cookbook.dart';
import '../domain/shelf_style.dart';
import 'widgets/library_bookcase.dart';
import 'widgets/shelf_art.dart';
import 'widgets/shelf_edit_controller.dart';
import 'widgets/shelf_style_editor.dart';
import 'widgets/recipe_card.dart';

enum _Sort { shelf, recent, alphabetical, quickest, fewestIngredients }

extension on _Sort {
  String get label => switch (this) {
    _Sort.shelf => 'Shelf order',
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
  journal('Cookbook', 'Cookbook');

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

  /// Opens this book (a cookbook's id or My Recipes) in the Cookbook view.
  final String? initialBook;

  const LibraryScreen({
    super.key,
    this.initialView,
    this.initialRecipeId,
    this.startDecorating = false,
    this.initialBook,
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
  GlobalKey<JournalViewState> _journalKey = GlobalKey<JournalViewState>();

  /// The book being read in the journal — a cookbook's id or [myRecipesId];
  /// null for the whole journal.
  late String? _journalBook = widget.initialBook;

  /// While searching, the search field takes the title's place.
  bool _searching = false;

  /// The recipe each book was last open at: a book reopens there.
  final _bookmarks = <String, String>{};

  /// A recipe opens in its book, at its page.
  void _openInJournal(Recipe recipe) => _openJournal(
    recipeId: recipe.id,
    book: bookOf(ref.read(collectionsStreamProvider).valueOrNull ?? const [], recipe.id),
  );

  /// A book opens as a journal of its own recipes, at its bookplate or
  /// where it was left.
  void _openCookbook(String bookId) => _openJournal(book: bookId, recipeId: _bookmarks[bookId]);

  /// While searching or filtering, a book opens to just its matches.
  void _openFromShelf(Recipe item) {
    if (!Cookbook.isCookbook(item)) return _openInJournal(item);
    final bookId = Cookbook.collectionIdOf(item);
    _narrowed ? _openJournal(book: bookId, matchesOnly: true) : _openCookbook(bookId);
  }

  /// The open book shows only the recipes matching the search and filter.
  bool _journalMatchesOnly = false;

  void _openJournal({String? recipeId, String? book, bool matchesOnly = false}) {
    audioChime.playPageFlip();
    setState(() {
      if (matchesOnly != _journalMatchesOnly) _journalKey = GlobalKey<JournalViewState>();
      _journalMatchesOnly = matchesOnly;
      // Another book is another journal.
      if (book != _journalBook) _journalKey = GlobalKey<JournalViewState>();
      _journalBook = book;
      _journalRecipeId = recipeId;
      if (_view != LibraryView.journal) _browseView = _view ?? LibraryView.shelf;
      _view = LibraryView.journal;
    });
  }

  void _startSearch() {
    setState(() => _searching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
  }

  void _closeSearch() {
    _debounce?.cancel();
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() {
      _query = '';
      _searching = false;
    });
  }

  /// A choice made with the view switch: remembered for next time.
  void _chooseView(LibraryView view) {
    if (view == _view) return;
    setState(() {
      if (view != LibraryView.journal) _browseView = view;
      if (_journalBook != null) {
        // Next time the journal opens whole, not at this cookbook.
        _journalBook = null;
        _journalKey = GlobalKey<JournalViewState>();
      }
      _view = view;
    });
    unawaited(ref.read(preferencesRepositoryProvider).writeJson(libraryViewKey, view.name));
  }

  Future<void> _showBookActions(Recipe recipe) async {
    final books = ref.read(collectionsStreamProvider).valueOrNull ?? const <RecipeCollection>[];
    final inBook = bookName(bookOf(books, recipe.id), books, ref.read(bookCoversProvider).valueOrNull ?? const {});
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
                title: const Text('Open in the cookbook'),
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
                leading: const Icon(LucideIcons.folderInput),
                title: const Text('Move to a book'),
                subtitle: Text('In $inBook'),
                onTap: () => Navigator.pop(ctx, 'cookbook'),
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
      case 'cookbook':
        await showMoveToBookSheet(context, recipe);
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
      _Filter('quick', 'Under 30 min', (r) => r.totalMinutes > 0 && r.totalMinutes <= 30, icon: LucideIcons.timer),
      _Filter('easy', 'Easy', (r) => r.difficulty == RecipeDifficulty.easy, icon: LucideIcons.signalLow),
      _Filter('veg', 'Vegetarian', (r) {
        final diet = RecipeInsights.of(r).diet;
        return diet.isComplete && diet.isVegetarian;
      }, icon: LucideIcons.carrot),
    ];

    final counts = <String, ({String name, String kind, int count})>{};
    for (final r in recipes) {
      for (final l in r.labels.where((l) => l.kind == 'cuisine' || l.kind == 'tag' || l.kind == 'dietary')) {
        final key = l.canonicalKey.toLowerCase();
        counts[key] = (name: l.displayName, kind: l.kind, count: (counts[key]?.count ?? 0) + 1);
      }
    }
    final top = counts.entries.toList()..sort((a, b) => b.value.count.compareTo(a.value.count));
    for (final e in top.take(6)) {
      filters.add(
        _Filter(
          'label:${e.key}',
          e.value.name,
          (r) => r.labels.any((l) => l.canonicalKey.toLowerCase() == e.key),
          // Cuisines are places; diets and other tags are tags.
          icon: e.value.kind == 'cuisine' ? LucideIcons.globe : LucideIcons.tag,
        ),
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
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): _startSearch,
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): _startSearch,
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
    final books = ref.watch(collectionsStreamProvider).valueOrNull ?? const <RecipeCollection>[];
    final covers = ref.watch(bookCoversProvider).valueOrNull ?? const <String, BookCover>{};
    final bookId = _journalBook;
    final book = books.where((b) => b.id == bookId).firstOrNull;
    final isMine = bookId == myRecipesId;
    final byId = {for (final r in all) r.id: r};
    // A book keeps the journal's order: as the recipes were added.
    final recipes = _bookOrder(
      isMine
          ? unfiledRecipes(all, books)
          : book != null
          ? [for (final id in book.recipeIds) ?byId[id]]
          : all,
    );
    if (_journalMatchesOnly && _narrowed) {
      final matching = {for (final r in _apply(all, _filtersFor(all), _shelfStyle)) r.id};
      recipes.retainWhere((r) => matching.contains(r.id));
    }
    final volume = isMine
        ? Cookbook.myRecipes(recipes: recipes.length, cover: covers[myRecipesId])
        : book != null
        ? Cookbook.volume(book, recipes: recipes.length, cover: covers[book.id])
        : null;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 16, 2),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(volume?.title ?? 'Cookbook', style: t.titleLarge, overflow: TextOverflow.ellipsis),
                ),
              ),
              if (volume != null)
                IconButton(
                  tooltip: 'Book options',
                  onPressed: () => _showVolumeActions(Cookbook.collectionIdOf(volume), volume),
                  icon: const Icon(LucideIcons.ellipsis, size: 20),
                ),
              _ViewToggle(view: LibraryView.journal, onChanged: _chooseView),
            ],
          ),
        ),
        Expanded(
          child: recipes.isEmpty && book != null
              ? EmptyStateScene(
                  icon: LucideIcons.bookOpen,
                  title: '${book.name} is empty',
                  message: 'Add recipes to this book and they fill its pages.',
                  actionLabel: 'Add recipes',
                  onAction: () => _pickRecipesFor(book, all),
                )
              : recipes.isEmpty && volume != null
              ? EmptyStateScene(
                  icon: LucideIcons.bookHeart,
                  title: '${volume.title} is empty',
                  message: 'New recipes start here, until you move them to a book of their own.',
                  actionLabel: 'Add a recipe',
                  onAction: () => showAddRecipeSheet(context, ref),
                )
              : recipes.isEmpty
              ? EmptyStateScene(
                  icon: LucideIcons.bookOpen,
                  title: 'Your cookbook is empty',
                  message: 'Every recipe you add gets its own keepsake spread here.',
                  actionLabel: 'Add a recipe',
                  onAction: () => showAddRecipeSheet(context, ref),
                )
              : JournalView(
                  key: _journalKey,
                  recipes: recipes,
                  title: volume?.title,
                  initialRecipeId: _journalRecipeId,
                  startDecorating: widget.startDecorating && _journalRecipeId == widget.initialRecipeId,
                  onRecipeShown: (id) {
                    _journalRecipeId = id;
                    if (bookId != null) _bookmarks[bookId] = id;
                  },
                ),
        ),
      ],
    );
  }

  bool get _narrowed => _filterId != 'all' || _query.isNotEmpty;

  /// Title, search and view switch, then sort and filters — shared by the
  /// cards and the shelf.
  List<Widget> _header(BuildContext context, List<Recipe> all, LibraryView view, List<_Filter> filters, int visible) {
    final t = context.chefText;
    final sort = _sortFor(_shelfStyle);
    // Chips before the filters: New book on the shelf, then the sort.
    final lead = view == LibraryView.shelf ? 2 : 1;
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
        sliver: SliverToBoxAdapter(
          child: SizedBox(
            height: 52,
            child: _searching || _query.isNotEmpty
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          onChanged: _onSearchChanged,
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            hintText: 'Search recipes, ingredients, tags',
                            prefixIcon: Icon(LucideIcons.search, size: 20),
                            isDense: true,
                          ),
                        ),
                      ),
                      TextButton(onPressed: _closeSearch, child: const Text('Cancel')),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Semantics(header: true, child: Text('Recipes', style: t.headlineMedium)),
                      ),
                      if (all.isNotEmpty) ...[
                        IconButton(
                          tooltip: 'Search',
                          onPressed: _startSearch,
                          icon: const Icon(LucideIcons.search, size: 20),
                        ),
                        if (view == LibraryView.shelf)
                          IconButton(
                            tooltip: 'Style shelves',
                            onPressed: () => _startStyling(_shelfStyle),
                            icon: const Icon(LucideIcons.paintbrush, size: 20),
                          ),
                        const SizedBox(width: 4),
                        _ViewToggle(view: view, onChanged: _chooseView),
                      ],
                    ],
                  ),
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
              itemCount: filters.length + lead,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                if (view == LibraryView.shelf && i == 0) {
                  return ActionChip(
                    avatar: const Icon(LucideIcons.bookPlus, size: 16),
                    label: const Text('New book'),
                    onPressed: _newBook,
                  );
                }
                i -= lead - 1;
                if (i == 0) {
                  return PopupMenuButton<_Sort>(
                    tooltip: 'Sort recipes',
                    initialValue: sort,
                    onSelected: (s) => setState(() => _sortChoice = s),
                    itemBuilder: (_) => [
                      for (final s in _Sort.values)
                        if (s != _Sort.shelf || _shelfStyle.books != null)
                          CheckedPopupMenuItem(value: s, checked: s == sort, child: Text(s.label)),
                    ],
                    child: IgnorePointer(
                      child: ActionChip(
                        avatar: const Icon(LucideIcons.arrowUpDown, size: 16),
                        label: Text(sort.label),
                        onPressed: () {},
                      ),
                    ),
                  );
                }
                final f = filters[i - 1];
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
      if (all.isNotEmpty && _narrowed)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          sliver: SliverToBoxAdapter(child: Text('$visible of ${all.length} recipes', style: t.bodySmall)),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 12)),
      if (!_narrowed && !(ref.watch(welcomeCardDismissedProvider).valueOrNull ?? true))
        const SliverToBoxAdapter(child: _WelcomeCard()),
    ];
  }

  /// How many of [matching] each book holds, by its id on the shelf.
  Map<String, int> _matchesByBook(List<Recipe> matching, List<RecipeCollection> books) {
    final counts = <String, int>{};
    for (final r in matching) {
      final id = Cookbook.volumeId(bookOf(books, r.id));
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }

  /// What stands on the shelf: My Recipes, holding every recipe in no
  /// cookbook, then each cookbook — searching and filtering included, which
  /// light up the books holding matches.
  List<Recipe> _shelfItems(
    List<Recipe> all,
    List<RecipeCollection> books,
    Map<String, BookCover> covers,
    ShelfStyle style,
  ) {
    final ids = {for (final r in all) r.id};
    final loose = unfiledRecipes(all, books).length;
    final volumes = [
      for (final b in books) Cookbook.volume(b, recipes: b.recipeIds.where(ids.contains).length, cover: covers[b.id]),
    ];
    if (_sortFor(style) == _Sort.alphabetical) {
      volumes.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else {
      volumes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return [
      // Once every recipe is in a book of its own, My Recipes steps aside.
      if (loose > 0 || books.isEmpty) Cookbook.myRecipes(recipes: loose, cover: covers[myRecipesId]),
      ...volumes,
    ];
  }

  void _showShelfActions(Recipe item) {
    if (Cookbook.isCookbook(item)) {
      _showVolumeActions(Cookbook.collectionIdOf(item), item);
    } else {
      _showBookActions(item);
    }
  }

  /// Makes a book, then fills it.
  Future<void> _newBook() async {
    final book = await createBook(context, ref);
    if (book == null || !mounted) return;
    await _pickRecipesFor(book, ref.read(allRecipesProvider).valueOrNull ?? const []);
  }

  /// A book's menu: open it, dress it, turn it, fill it, name it, move it.
  Future<void> _showVolumeActions(String bookId, Recipe volume) async {
    final books = ref.read(collectionsStreamProvider).valueOrNull ?? const <RecipeCollection>[];
    final book = books.where((b) => b.id == bookId).firstOrNull;
    final isMine = bookId == myRecipesId;
    if (!isMine && book == null) return;
    final covers = ref.read(bookCoversProvider).valueOrNull ?? const <String, BookCover>{};
    final cover = covers[bookId] ?? const BookCover();
    final action = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: Text(volume.title, style: ctx.chefText.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(volume.summary ?? '', style: ctx.chefText.bodySmall),
              ),
              if (_view != LibraryView.journal)
                ListTile(
                  leading: const Icon(LucideIcons.bookOpen),
                  title: const Text('Open'),
                  onTap: () => Navigator.pop(ctx, 'open'),
                ),
              ListTile(
                leading: const Icon(LucideIcons.paintbrush),
                title: const Text('Edit book'),
                subtitle: const Text('Cover photo, spine pattern, lettering'),
                onTap: () => Navigator.pop(ctx, 'edit'),
              ),
              ListTile(
                leading: Icon(cover.facesOut ? LucideIcons.bookCopy : LucideIcons.bookImage),
                title: Text(cover.facesOut ? 'Show the spine' : 'Show the cover'),
                subtitle: Text(cover.facesOut ? 'Stand it spine-out' : 'Stand it face-out on the shelf'),
                onTap: () => Navigator.pop(ctx, 'face'),
              ),
              if (!isMine)
                ListTile(
                  leading: const Icon(LucideIcons.listPlus),
                  title: const Text('Add or remove recipes'),
                  onTap: () => Navigator.pop(ctx, 'recipes'),
                ),
              ListTile(
                leading: const Icon(LucideIcons.pencil),
                title: const Text('Rename'),
                onTap: () => Navigator.pop(ctx, 'rename'),
              ),
              if (_view == LibraryView.shelf)
                ListTile(
                  leading: const Icon(LucideIcons.move),
                  title: const Text('Move on the shelves'),
                  subtitle: const Text('Hold a book, then drag it to a new spot'),
                  onTap: () => Navigator.pop(ctx, 'move'),
                ),
              if (!isMine)
                ListTile(
                  leading: const Icon(LucideIcons.trash2),
                  title: const Text('Delete book'),
                  subtitle: Text('Its recipes go back to ${bookName(myRecipesId, books, covers)}'),
                  onTap: () => Navigator.pop(ctx, 'delete'),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || action == null) return;
    final repo = ref.read(collectionRepositoryProvider);
    final prefs = ref.read(preferencesRepositoryProvider);
    switch (action) {
      case 'open':
        _openCookbook(bookId);
      case 'edit':
        await context.push('/book/$bookId');
      case 'face':
        final display = cover.facesOut ? BookDisplay.spine : BookDisplay.cover;
        await saveBookCover(prefs, bookId, cover.copyWith(style: cover.style.copyWith(display: display)));
      case 'recipes':
        await _pickRecipesFor(book!, ref.read(allRecipesProvider).valueOrNull ?? const []);
      case 'rename':
        final name = (await showTextPromptDialog(context, title: 'Rename book', initial: volume.title))?.trim();
        if (name == null || name.isEmpty) return;
        if (isMine) {
          final title = name == 'My Recipes' ? null : name;
          await saveBookCover(
            prefs,
            bookId,
            BookCover(title: title, photo: cover.photo, style: cover.style, palette: cover.palette),
          );
        } else {
          await repo.updateCollection(book!.copyWith(name: name, updatedAt: DateTime.now().millisecondsSinceEpoch));
        }
      case 'move':
        _startStyling(_shelfStyle, collapsed: true);
      case 'delete':
        final home = bookName(myRecipesId, books, covers);
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete book?'),
            content: Text('“${book!.name}” comes off the shelf. Its recipes go back to $home.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
            ],
          ),
        );
        if (ok != true) return;
        await repo.deleteCollection(book!.id);
        await forgetBookCover(prefs, book.id);
        // Reading it? Back to the shelf.
        if (mounted && _journalBook == book.id) _chooseView(_browseView);
    }
  }

  /// Ticks recipes into [book], or back out to My Recipes. A recipe is in
  /// one book at a time, so ticking one moves it here.
  Future<void> _pickRecipesFor(RecipeCollection book, List<Recipe> all) {
    final recipes = [...all]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (ctx, scroll) => Consumer(
          builder: (ctx, ref, _) {
            final repo = ref.read(collectionRepositoryProvider);
            final books = ref.watch(collectionsStreamProvider).valueOrNull ?? const <RecipeCollection>[];
            final covers = ref.watch(bookCoversProvider).valueOrNull ?? const <String, BookCover>{};
            final current = books.where((b) => b.id == book.id).firstOrNull ?? book;
            final inBook = current.recipeIds.toSet();
            return ListView(
              controller: scroll,
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
                  child: Text('Recipes in ${current.name}', style: ctx.chefText.titleLarge),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    'A recipe is in one book at a time: ticking one moves it here.',
                    style: ctx.chefText.bodySmall,
                  ),
                ),
                for (final r in recipes)
                  CheckboxListTile(
                    value: inBook.contains(r.id),
                    title: Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      inBook.contains(r.id)
                          ? KitchenFormat.minutes(r.totalMinutes)
                          : 'In ${bookName(bookOf(books, r.id), books, covers)}',
                    ),
                    onChanged: (on) => moveRecipeToBook(repo, books, r.id, on == true ? book.id : myRecipesId),
                  ),
              ],
            );
          },
        ),
      ),
    );
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
    final books = ref.watch(collectionsStreamProvider).valueOrNull ?? const <RecipeCollection>[];
    final covers = ref.watch(bookCoversProvider).valueOrNull ?? const <String, BookCover>{};
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
                        recipes: _shelfItems(all, books, covers, style),
                        matches: edit == null && _narrowed ? _matchesByBook(visible, books) : null,
                        style: style,
                        // Books as arranged, unless sorted some other way (a
                        // book moved just now always shows where it was put).
                        arranged: (edit?.booksMoved ?? false) || _sortFor(style) == _Sort.shelf ? style.books : null,
                        onOpen: edit != null ? (_) {} : _openFromShelf,
                        onLongPress: edit != null ? null : _showShelfActions,
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

/// New in the kitchen: a card to meet the developer, until it's closed or
/// followed.
class _WelcomeCard extends ConsumerWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.chefColors;
    final t = context.chefText;
    final name = ref.watch(cookNameProvider);
    void dismiss() => ref.read(preferencesRepositoryProvider).writeJson(welcomeCardDismissedKey, true);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Material(
        color: c.surfacePaper.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ChefRadius.tile),
          side: BorderSide(color: c.outlineSubtle),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            dismiss();
            context.push('/about');
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: c.tomatoSoft,
                  child: Icon(LucideIcons.heartHandshake, size: 20, color: c.accentTomato),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name == null ? 'Welcome to Chef’s Kiss!' : 'Welcome to Chef’s Kiss, $name!',
                        style: t.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text('Meet the developer and share your ideas', style: t.bodySmall),
                    ],
                  ),
                ),
                IconButton(tooltip: 'Close', onPressed: dismiss, icon: const Icon(LucideIcons.x, size: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
