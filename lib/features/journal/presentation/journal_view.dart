import 'dart:math' as math;

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
import '../../../app/widgets/recipe_image.dart';
import '../../recipe_detail/presentation/widgets/recipe_sheets.dart';
import '../../voice/listen_button.dart';
import '../application/recipe_edits.dart';
import '../../library/presentation/widgets/library_books.dart' show kSerifFamily;
import 'widgets/journal_pages.dart';
import 'widgets/page_flip_book.dart';
import 'widgets/sticker_art.dart';
import 'widgets/sticker_tray.dart';

/// The recipe journal: an "ex libris" bookplate and a table of contents,
/// then every recipe as a two-page keepsake spread (story & ingredients on
/// the left, method on the right) in a book whose pages turn.
///
/// Phones show one page at a time; wide screens show
/// facing pages with index tabs down the side. "Decorate" turns the visible
/// pages into a scrapbook: stickers, washi tape, icons and themes.
class JournalView extends ConsumerStatefulWidget {
  final List<Recipe> recipes;
  final String? initialRecipeId;

  /// Reports the recipe on screen, so the library can come back to it.
  final ValueChanged<String>? onRecipeShown;

  /// Reports decorate mode, so the parent can hide its own chrome.
  final ValueChanged<bool>? onDecoratingChanged;

  /// Open straight into decorate mode (from "Decorate page" elsewhere).
  final bool startDecorating;

  const JournalView({
    super.key,
    required this.recipes,
    this.initialRecipeId,
    this.onRecipeShown,
    this.onDecoratingChanged,
    this.startDecorating = false,
  });

  static const spreadBreakpoint = 860.0;

  @override
  ConsumerState<JournalView> createState() => JournalViewState();
}

class JournalViewState extends ConsumerState<JournalView> {
  /// The bookplate and the contents page come before the recipes.
  static const _frontPages = 2;

  PageFlipController? _controller;
  bool? _spread;
  bool _decorating = false;
  String? _selectedId;
  late String? _currentId = widget.initialRecipeId;

  /// True while the book is silently re-aligned after the recipe list changed.
  bool _resyncing = false;

  bool get isDecorating => _decorating;

  @override
  void initState() {
    super.initState();
    if (widget.startDecorating) {
      _decorating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onDecoratingChanged?.call(true);
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // --- Pages and positions --------------------------------------------------------
  //
  // Page indexes: 0 bookplate, 1 contents, then recipe i on pages 2+2i (story)
  // and 3+2i (method). A position is a page in single-page mode and a spread
  // (pages 2p, 2p+1) in spread mode, so recipe i is spread i+1.

  int get _pageCount => _frontPages + widget.recipes.length * 2;

  int get _positionCount => _spread == true ? _pageCount ~/ 2 : _pageCount;

  int get _firstVisiblePage {
    final c = _controller;
    if (c == null) return 0;
    return _spread == true ? c.position * 2 : c.position;
  }

  /// The recipe on screen, or null on the bookplate/contents.
  int? get _recipeIndex {
    if (widget.recipes.isEmpty) return null;
    final page = _firstVisiblePage;
    if (page < _frontPages) return null;
    return ((page - _frontPages) ~/ 2).clamp(0, widget.recipes.length - 1);
  }

  /// 0 = story page, 1 = method page (single-page mode).
  int get _side => _spread == true ? 0 : (_firstVisiblePage - _frontPages) % 2;

  Recipe? get _current {
    final i = _recipeIndex;
    return i == null ? null : widget.recipes[i];
  }

  int _positionForRecipe(int index, {int side = 0, bool? spread}) =>
      (spread ?? _spread == true) ? index + 1 : _frontPages + index * 2 + side;

  int get _contentsPosition => _spread == true ? 0 : 1;

  void _ensureController(bool spread) {
    if (_spread == spread && _controller != null) return;
    final int position;
    if (_controller == null) {
      final i = widget.recipes.indexWhere((r) => r.id == _currentId);
      position = i < 0 ? 0 : _positionForRecipe(i, spread: spread);
    } else {
      final i = _recipeIndex;
      position = i == null ? 0 : _positionForRecipe(i, side: spread ? 0 : _side, spread: spread);
    }
    final old = _controller;
    _controller = PageFlipController(initialPosition: position);
    _spread = spread;
    if (old != null) WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  @override
  void didUpdateWidget(JournalView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the same recipe open when recipes are added or removed.
    final c = _controller;
    if (c == null || _currentId == null || widget.recipes.isEmpty || _firstVisiblePage < _frontPages) return;
    final index = widget.recipes.indexWhere((r) => r.id == _currentId);
    if (index < 0) return;
    final target = _positionForRecipe(index, side: _side);
    if (target != c.position) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _resyncing = true;
        c.jumpTo(target);
        _resyncing = false;
      });
    }
  }

  void _onPositionChanged(int _) {
    if (_resyncing) return;
    audioChime.playPageFlip();
    final recipe = _current;
    if (recipe != null && recipe.id != _currentId) {
      _currentId = recipe.id;
      widget.onRecipeShown?.call(recipe.id);
    }
    setState(() => _selectedId = null);
  }

  /// Opens [recipeId]'s story page with a page turn.
  Future<void> openRecipe(String recipeId) async {
    final index = widget.recipes.indexWhere((r) => r.id == recipeId);
    final c = _controller;
    if (index < 0 || c == null) return;
    await c.animateTo(_positionForRecipe(index));
  }

  Future<void> _openContents() async => _controller?.animateTo(_contentsPosition);

  Future<void> _go(int delta) async {
    final c = _controller;
    if (c == null) return;
    if (delta > 0) {
      await c.next();
    } else {
      await c.previous();
    }
  }

  /// Leaves decorate mode (Back button while decorating).
  void stopDecorating() => _setDecorating(false);

  void _setDecorating(bool value) {
    setState(() {
      _decorating = value;
      _selectedId = null;
    });
    widget.onDecoratingChanged?.call(value);
  }

  // --- Editing -------------------------------------------------------------------

  Future<void> _edit(Recipe recipe, Recipe Function(Recipe) change) async {
    final res = await ref.read(recipeEditQueueProvider).apply(recipe, change);
    if (res.isFailure && mounted) {
      ChefToastService.show(context: context, title: 'Could not save the page', type: ChefToastType.error);
    }
  }

  void _removeItem(Recipe recipe, String id) {
    final latest = ref.read(recipeEditQueueProvider).latest(recipe);
    final sticker = latest.stickers.where((s) => s.id == id).firstOrNull;
    final tape = latest.washiTapes.where((t) => t.id == id).firstOrNull;
    _edit(
      recipe,
      (r) => r.copyWith(
        stickers: r.stickers.where((s) => s.id != id).toList(),
        washiTapes: r.washiTapes.where((t) => t.id != id).toList(),
      ),
    );
    setState(() => _selectedId = null);
    ChefToastService.show(
      context: context,
      title: tape != null ? 'Washi tape removed' : 'Sticker removed',
      actionLabel: 'Undo',
      onAction: () => _edit(
        recipe,
        (r) => r.copyWith(
          stickers: [...r.stickers.where((s) => s.id != id), if (sticker != null) sticker],
          washiTapes: [...r.washiTapes.where((t) => t.id != id), if (tape != null) tape],
        ),
      ),
    );
  }

  Future<void> _addDecoration() async {
    final recipe = _current;
    if (recipe == null) return;
    String? pageSide;
    if (_spread == true) {
      pageSide = await showModalBottomSheet<String>(
        context: context,
        useRootNavigator: true,
        showDragHandle: true,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.bookOpenText),
                title: const Text('Story page (left)'),
                onTap: () => Navigator.pop(ctx, 'left'),
              ),
              ListTile(
                leading: const Icon(LucideIcons.listOrdered),
                title: const Text('Method page (right)'),
                onTap: () => Navigator.pop(ctx, 'right'),
              ),
            ],
          ),
        ),
      );
      if (pageSide == null || !mounted) return;
    } else {
      pageSide = _side == 0 ? 'left' : 'right';
    }
    final addition = await showStickerTray(context, pageSide: pageSide);
    if (addition == null || !mounted) return;
    switch (addition) {
      case StickerAddition(:final sticker):
        await _edit(recipe, (r) => r.copyWith(stickers: [...r.stickers, sticker]));
        if (mounted) setState(() => _selectedId = sticker.id);
      case TapeAddition(:final tape):
        await _edit(recipe, (r) => r.copyWith(washiTapes: [...r.washiTapes, tape]));
        if (mounted) setState(() => _selectedId = tape.id);
    }
  }

  Future<void> _pickTheme() async {
    final recipe = _current;
    if (recipe == null) return;
    final c = context.chefColors;
    final theme = await showModalBottomSheet<ScrapbookTheme>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Page theme', style: ctx.chefText.titleLarge),
            ),
            for (final option in ScrapbookTheme.values)
              ListTile(
                leading: CircleAvatar(backgroundColor: option.accent(c), radius: 14),
                title: Text(option.label),
                trailing: option == recipe.theme ? const Icon(LucideIcons.check) : null,
                onTap: () => Navigator.pop(ctx, option),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (theme != null && mounted) await _edit(recipe, (r) => r.copyWith(theme: theme));
  }

  Future<void> _pickIngredientIcon(Recipe recipe, RecipeIngredient ing) async {
    final pick = await showCulinaryIconPicker(
      context,
      currentKey: ing.icon,
      currentInk: parseHexColor(ing.iconColor),
      title: 'Icon for ${ing.displayName}',
    );
    if (pick == null || !mounted) return;
    await _edit(
      recipe,
      (r) => r.copyWith(
        ingredients: [
          for (final i in r.ingredients)
            i.id == ing.id ? i.copyWith(icon: pick.key, iconColor: toHexColor(pick.ink)) : i,
        ],
      ),
    );
  }

  Future<void> _pickStepIcon(Recipe recipe, RecipeStep step) async {
    final pick = await showCulinaryIconPicker(
      context,
      currentKey: step.iconKey,
      currentInk: parseHexColor(step.iconColor),
      title: 'Icon for step ${recipe.steps.indexOf(step) + 1}',
    );
    if (pick == null || !mounted) return;
    await _edit(
      recipe,
      (r) => r.copyWith(
        steps: [
          for (final s in r.steps) s.id == step.id ? s.copyWith(iconKey: pick.key, iconColor: toHexColor(pick.ink)) : s,
        ],
      ),
    );
  }

  Future<void> _editTip(Recipe recipe) async {
    final tip = await showTextPromptDialog(
      context,
      title: 'Chef’s tip',
      initial: recipe.chefTip,
      hint: 'A secret, a substitution, or a lesson learned',
      maxLines: 4,
    );
    if (tip != null && mounted) await _edit(recipe, (r) => r.copyWith(chefTip: tip.trim()));
  }

  Future<void> _editPolaroid(Recipe recipe) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.imagePlus),
              title: const Text('Change photo'),
              onTap: () => Navigator.pop(ctx, 'photo'),
            ),
            ListTile(
              leading: const Icon(LucideIcons.penLine),
              title: const Text('Edit caption'),
              onTap: () => Navigator.pop(ctx, 'caption'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    switch (choice) {
      case 'photo':
        final cover = await showCoverPhotoSheet(context, theme: recipe.theme);
        if (cover == null || !mounted) return;
        await _edit(
          recipe,
          (r) => cover.source == null ? r.copyWith(clearCoverImage: true) : r.copyWith(coverImage: cover.source),
        );
      case 'caption':
        final caption = await showTextPromptDialog(
          context,
          title: 'Photo caption',
          initial: recipe.polaroidCaption ?? recipe.title,
        );
        if (caption != null && mounted) await _edit(recipe, (r) => r.copyWith(polaroidCaption: caption.trim()));
    }
  }

  JournalPageActions get _actions => JournalPageActions(
    decorating: _decorating,
    selectedId: _selectedId,
    onSelect: (id) => setState(() => _selectedId = id),
    onStickerChanged: (recipe, s) =>
        _edit(recipe, (r) => r.copyWith(stickers: [for (final it in r.stickers) it.id == s.id ? s : it])),
    onTapeChanged: (recipe, t) =>
        _edit(recipe, (r) => r.copyWith(washiTapes: [for (final it in r.washiTapes) it.id == t.id ? t : it])),
    onRemoveItem: _removeItem,
    onBringToFront: (recipe, id) => _edit(recipe, (r) {
      final top = r.stickers.fold<int>(0, (m, s) => math.max(m, s.zIndex)) + 1;
      return r.copyWith(stickers: [for (final s in r.stickers) s.id == id ? s.copyWith(zIndex: top) : s]);
    }),
    onPickIngredientIcon: _pickIngredientIcon,
    onPickStepIcon: _pickStepIcon,
    onEditTip: _editTip,
    onEditPolaroid: _editPolaroid,
    onToggleFavorite: (recipe) => ref.read(recipeRepositoryProvider).toggleFavorite(recipe.id),
  );

  Object _pageIdentity(int pageIndex) => pageIndex < _frontPages
      ? 'front:$pageIndex'
      : '${widget.recipes[(pageIndex - _frontPages) ~/ 2].id}:${pageIndex % 2}';

  Widget _buildPage(BuildContext context, int pageIndex) {
    final spread = _spread == true;
    // A folded corner on the outer edge turns the page: bottom-left on the
    // left page of a spread (back), bottom-right otherwise (forward).
    DogEar? ear;
    if (spread && pageIndex.isEven) {
      if (pageIndex > 0) ear = DogEar.previous(() => _go(-1));
    } else if (pageIndex < _pageCount - 1) {
      ear = DogEar.next(() => _go(1));
    }

    // The bottom bar already offers "Contents" on the bookplate.
    if (pageIndex == 0) return BookplatePage(recipes: widget.recipes, dogEar: ear);
    if (pageIndex == 1) return ContentsPage(recipes: widget.recipes, onOpen: openRecipe, dogEar: ear);

    final index = (pageIndex - _frontPages) ~/ 2;
    final recipe = widget.recipes[index];
    final actions = _actions;
    return pageIndex.isEven
        ? StoryPage(recipe: recipe, pageNumber: pageIndex + 1, recipeNumber: index + 1, actions: actions, dogEar: ear)
        : MethodPage(recipe: recipe, pageNumber: pageIndex + 1, actions: actions, dogEar: ear);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recipes.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final spread = constraints.maxWidth >= JournalView.spreadBreakpoint;
        _ensureController(spread);
        final controller = _controller!;
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final recipe = _current;
            final decorating = _decorating && recipe != null;
            return CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.arrowRight): () => _go(1),
                const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _go(-1),
                const SingleActivator(LogicalKeyboardKey.pageDown): () => _go(1),
                const SingleActivator(LogicalKeyboardKey.pageUp): () => _go(-1),
              },
              child: Focus(
                autofocus: true,
                child: Column(
                  children: [
                    if (decorating)
                      _decorateBar(spread)
                    else if (recipe == null)
                      _frontToolbar(spread)
                    else
                      _toolbar(recipe, spread),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(spread ? 20 : 12, 4, spread ? 8 : 12, 4),
                        child: spread
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: _binder(recipe, controller, spread)),
                                  _IndexTabs(
                                    recipes: widget.recipes,
                                    currentIndex: _recipeIndex,
                                    enabled: !decorating,
                                    onOpen: openRecipe,
                                    onContents: _openContents,
                                  ),
                                ],
                              )
                            : _binder(recipe, controller, spread),
                      ),
                    ),
                    if (!decorating) _bottomBar(recipe, controller, spread),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// The book: a clean page with a soft shadow and a hint of the pages
  /// stacked behind it.
  Widget _binder(Recipe? recipe, PageFlipController controller, bool spread) {
    final palette = JournalPalette.of(context, recipe?.theme ?? BookplatePage.theme);
    final first = _firstVisiblePage + 1;
    final radius = BorderRadius.circular(spread ? 10 : 16);
    return Semantics(
      label: spread
          ? 'Recipe journal, pages $first and ${first + 1} of $_pageCount'
          : 'Recipe journal, page $first of $_pageCount',
      container: true,
      child: Padding(
        padding: const EdgeInsets.only(right: 6, bottom: 6),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final depth in const [6.0, 3.0])
              Positioned.fill(
                left: depth,
                top: depth,
                right: -depth,
                bottom: -depth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color.lerp(palette.paper, Colors.black, depth / 120),
                    borderRadius: radius,
                    border: Border.all(color: palette.line.withValues(alpha: 0.6), width: 0.5),
                  ),
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 18, offset: const Offset(0, 8)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: PageFlipBook(
                    controller: controller,
                    spread: spread,
                    pageCount: _pageCount,
                    pageIdentity: _pageIdentity,
                    pageBuilder: _buildPage,
                    interactive: !_decorating,
                    backColor: palette.back,
                    onPositionChanged: _onPositionChanged,
                    onEdgeReached: () => HapticFeedback.selectionClick(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toolbar over the bookplate and contents.
  Widget _frontToolbar(bool spread) {
    final c = context.chefColors;
    final onContents = _firstVisiblePage == 1 || spread;
    return Padding(
      padding: EdgeInsets.fromLTRB(spread ? 20 : 18, 4, spread ? 20 : 8, 4),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Expanded(
              child: Text(
                spread ? 'Ex libris & contents' : (onContents ? 'Contents' : 'Ex libris'),
                style: TextStyle(fontFamily: kSerifFamily, fontSize: 20, color: c.contentPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // On phones the bottom bar already offers this.
            if (spread)
              TextButton.icon(
                onPressed: () => openRecipe(widget.recipes.first.id),
                icon: const Icon(LucideIcons.bookOpen, size: 18),
                label: const Text('First recipe'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _toolbar(Recipe recipe, bool spread) => Consumer(
    builder: (context, ref, _) {
      final servings =
          ref.watch(journalServingsProvider(recipe.id)) ?? math.max(1, recipe.baseServings.toDouble().round());
      return _toolbarFor(recipe, spread, servings);
    },
  );

  Widget _toolbarFor(Recipe recipe, bool spread, int servings) {
    final c = context.chefColors;
    final t = context.chefText;
    final index = _recipeIndex ?? 0;
    final listen = ListenButton(
      sessionId: 'recipe:${recipe.id}',
      compact: true,
      script: () => recipeScript(recipe, servings: servings.toDouble()),
    );
    final decorate = IconButton(
      tooltip: 'Decorate page',
      onPressed: () => _setDecorating(true),
      icon: const Icon(LucideIcons.wandSparkles),
    );
    if (!spread) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 4, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                recipe.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: kSerifFamily, fontSize: 20, color: c.contentPrimary),
              ),
            ),
            listen,
            decorate,
            _moreMenu(recipe),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(
        children: [
          Text(
            'Recipe ${index + 1} of ${widget.recipes.length}',
            style: t.labelLarge?.copyWith(color: c.contentSecondary),
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            onPressed: _openContents,
            icon: const Icon(LucideIcons.tableOfContents, size: 18),
            label: const Text('Contents'),
          ),
          const Spacer(),
          listen,
          decorate,
          TextButton.icon(
            onPressed: () => context.push('/recipe/${recipe.id}'),
            icon: const Icon(LucideIcons.notebookText, size: 18),
            label: const Text('Details'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: recipe.steps.isEmpty ? null : () => context.push('/cook/${recipe.id}?servings=$servings'),
            icon: const Icon(LucideIcons.chefHat, size: 18),
            label: const Text('Cook'),
          ),
        ],
      ),
    );
  }

  Widget _moreMenu(Recipe recipe) {
    return PopupMenuButton<String>(
      tooltip: 'More',
      icon: const Icon(LucideIcons.ellipsisVertical),
      onSelected: (v) {
        switch (v) {
          case 'contents':
            _openContents();
          case 'details':
            context.push('/recipe/${recipe.id}');
          case 'collection':
            showAddToCollectionSheet(context, recipe);
          case 'edit':
            context.push('/editor/${recipe.id}');
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'contents',
          child: ListTile(leading: Icon(LucideIcons.tableOfContents), title: Text('Contents')),
        ),
        PopupMenuItem(
          value: 'details',
          child: ListTile(leading: Icon(LucideIcons.notebookText), title: Text('Details & nutrition')),
        ),
        PopupMenuItem(
          value: 'collection',
          child: ListTile(leading: Icon(LucideIcons.folderHeart), title: Text('Save to collection')),
        ),
        PopupMenuItem(
          value: 'edit',
          child: ListTile(leading: Icon(LucideIcons.squarePen), title: Text('Edit recipe')),
        ),
      ],
    );
  }

  Widget _decorateBar(bool spread) {
    final t = context.chefText;
    return LayoutBuilder(
      builder: (context, box) {
        final roomy = box.maxWidth >= 440;
        return Padding(
          padding: EdgeInsets.fromLTRB(spread ? 20 : 12, 4, spread ? 20 : 12, 4),
          child: Row(
            children: [
              if (roomy) ...[
                FilledButton.tonalIcon(
                  onPressed: _addDecoration,
                  icon: const Icon(LucideIcons.sticker, size: 18),
                  label: const Text('Add'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _pickTheme,
                  icon: const Icon(LucideIcons.palette, size: 18),
                  label: const Text('Theme'),
                ),
              ] else ...[
                IconButton.filledTonal(
                  tooltip: 'Add a sticker',
                  onPressed: _addDecoration,
                  icon: const Icon(LucideIcons.sticker),
                ),
                IconButton.outlined(
                  tooltip: 'Page theme',
                  onPressed: _pickTheme,
                  icon: const Icon(LucideIcons.palette),
                ),
              ],
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  spread ? 'Drag to move · pinch or use the toolbar to resize and rotate' : 'Drag · pinch · tap icons',
                  style: t.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => _setDecorating(false),
                icon: const Icon(LucideIcons.check, size: 18),
                label: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomBar(Recipe? recipe, PageFlipController controller, bool spread) => Consumer(
    builder: (context, ref, _) {
      final servings = recipe == null
          ? 1
          : ref.watch(journalServingsProvider(recipe.id)) ?? math.max(1, recipe.baseServings.toDouble().round());
      return _bottomBarFor(recipe, controller, spread, servings);
    },
  );

  /// Previous · where you are (with a thin progress line) · next, and Cook.
  Widget _bottomBarFor(Recipe? recipe, PageFlipController controller, bool spread, int servings) {
    final t = context.chefText;
    final c = context.chefColors;
    final atStart = controller.position <= 0;
    final atEnd = controller.position >= _positionCount - 1;
    final index = _recipeIndex;
    final first = _firstVisiblePage + 1;
    final caption = spread
        ? 'Pages $first–${first + 1} of $_pageCount'
        : index == null
        ? (first == 1 ? 'Ex libris' : 'Contents')
        : '${_side == 0 ? 'Ingredients' : 'Method'}  ·  ${index + 1} of ${widget.recipes.length}';
    final progress = _positionCount <= 1 ? 1.0 : controller.position / (_positionCount - 1);

    final Widget? action = spread
        ? null
        : recipe == null
        ? FilledButton.tonalIcon(
            onPressed: first == 1 ? _openContents : () => openRecipe(widget.recipes.first.id),
            icon: Icon(first == 1 ? LucideIcons.tableOfContents : LucideIcons.bookOpen, size: 18),
            label: Text(first == 1 ? 'Contents' : 'Open'),
          )
        : FilledButton.icon(
            onPressed: recipe.steps.isEmpty ? null : () => context.push('/cook/${recipe.id}?servings=$servings'),
            icon: const Icon(LucideIcons.chefHat, size: 18),
            label: const Text('Cook'),
          );

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(spread ? 20 : 8, 2, spread ? 20 : 12, 8),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Previous page',
              onPressed: atStart ? null : () => _go(-1),
              icon: const Icon(LucideIcons.chevronLeft),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.labelMedium?.copyWith(color: c.contentSecondary),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: progress),
                      duration: ChefMotion.emphasis,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 3,
                        backgroundColor: c.outlineSubtle,
                        color: c.contentSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Next page',
              onPressed: atEnd ? null : () => _go(1),
              icon: const Icon(LucideIcons.chevronRight),
            ),
            if (action != null) ...[const SizedBox(width: 4), action],
          ],
        ),
      ),
    );
  }
}

/// Coloured bookmark tabs down the side of the open book: Contents first,
/// then one per recipe.
class _IndexTabs extends StatelessWidget {
  final List<Recipe> recipes;
  final int? currentIndex;
  final bool enabled;
  final ValueChanged<String> onOpen;
  final VoidCallback onContents;

  const _IndexTabs({
    required this.recipes,
    required this.currentIndex,
    required this.enabled,
    required this.onOpen,
    required this.onContents,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    Widget tab({
      required String label,
      required String tooltip,
      required Color color,
      required bool active,
      required VoidCallback onTap,
      IconData? icon,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Tooltip(
            message: tooltip,
            child: Semantics(
              button: true,
              selected: active,
              enabled: enabled,
              label: tooltip,
              excludeSemantics: true,
              child: AnimatedContainer(
                duration: ChefMotion.standard,
                width: active ? 108 : 96,
                child: Material(
                  color: enabled ? color : color.withValues(alpha: 0.5),
                  elevation: active ? 4 : 1,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
                  ),
                  child: InkWell(
                    onTap: enabled ? onTap : null,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                      child: Row(
                        children: [
                          if (icon != null) ...[Icon(icon, size: 14, color: Colors.white), const SizedBox(width: 6)],
                          Expanded(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.chefText.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 112,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 24),
        itemCount: recipes.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return tab(
              label: 'Contents',
              tooltip: 'Contents',
              icon: LucideIcons.tableOfContents,
              color: c.isDark ? const Color(0xFF4A4440) : const Color(0xFF3B3430),
              active: currentIndex == null,
              onTap: onContents,
            );
          }
          final r = recipes[i - 1];
          final word = r.title.split(RegExp(r'\s+')).firstWhere((w) => w.length > 2, orElse: () => r.title);
          return tab(
            label: word,
            tooltip: 'Open ${r.title}',
            color: Color.lerp(r.theme.accent(c), Colors.black, c.isDark ? 0.35 : 0.18)!,
            active: currentIndex == i - 1,
            onTap: () => onOpen(r.id),
          );
        },
      ),
    );
  }
}
