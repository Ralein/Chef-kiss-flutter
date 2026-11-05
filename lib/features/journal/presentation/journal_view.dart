import 'dart:async';
import 'dart:math' as math;

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/audio_chime_service.dart';
import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/kitchen_format.dart';
import '../../../app/widgets/recipe_image.dart';
import '../../recipe_detail/presentation/widgets/recipe_sheets.dart';
import '../../voice/listen_button.dart';
import '../application/recipe_edits.dart';
import 'widgets/journal_pages.dart';
import 'widgets/page_flip_book.dart';
import 'widgets/sticker_art.dart';
import 'widgets/sticker_tray.dart';

/// The recipe journal: every recipe as a two-page keepsake spread (story &
/// ingredients on the left, method on the right) in a book whose pages turn.
///
/// Phones show one page at a time with a spiral binding; wide screens show
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
  PageFlipController? _controller;
  bool? _spread;
  bool _decorating = false;
  String? _selectedId;
  late String? _currentId = widget.initialRecipeId;

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

  int _indexOf(String? id) {
    final i = widget.recipes.indexWhere((r) => r.id == id);
    return i < 0 ? 0 : i;
  }

  int get _recipeIndex {
    final c = _controller;
    if (c == null || widget.recipes.isEmpty) return 0;
    final i = _spread == true ? c.position : c.position ~/ 2;
    return i.clamp(0, widget.recipes.length - 1);
  }

  /// 0 = story page, 1 = method page (single-page mode only).
  int get _side => (_spread == true || _controller == null) ? 0 : _controller!.position % 2;

  Recipe? get _current => widget.recipes.isEmpty ? null : widget.recipes[_recipeIndex];

  void _ensureController(bool spread) {
    if (_spread == spread && _controller != null) return;
    final index = _controller == null ? _indexOf(_currentId) : _recipeIndex;
    final side = _side;
    final old = _controller;
    _controller = PageFlipController(initialPosition: spread ? index : index * 2 + side);
    _spread = spread;
    if (old != null) WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  @override
  void didUpdateWidget(JournalView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the same recipe open when the list changes (edits re-sort it).
    final c = _controller;
    if (c == null || _currentId == null || widget.recipes.isEmpty) return;
    final index = widget.recipes.indexWhere((r) => r.id == _currentId);
    if (index < 0) return;
    final target = _spread == true ? index : index * 2 + _side;
    if (target != c.position) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) c.jumpTo(target);
      });
    }
  }

  void _onPositionChanged(int _) {
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
    await c.animateTo(_spread == true ? index : index * 2);
  }

  Future<void> _go(int delta) async {
    final c = _controller;
    if (c == null) return;
    if (delta > 0) {
      await c.next();
    } else {
      await c.previous();
    }
  }

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

  Future<void> _addDecoration({String? side}) async {
    final recipe = _current;
    if (recipe == null) return;
    var pageSide = side;
    if (pageSide == null) {
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
                  leading: const Icon(Icons.auto_stories_outlined),
                  title: const Text('Story page (left)'),
                  onTap: () => Navigator.pop(ctx, 'left'),
                ),
                ListTile(
                  leading: const Icon(Icons.format_list_numbered_rounded),
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
                trailing: option == recipe.theme ? const Icon(Icons.check_rounded) : null,
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
              leading: const Icon(Icons.image_outlined),
              title: const Text('Change photo'),
              onTap: () => Navigator.pop(ctx, 'photo'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_note_rounded),
              title: const Text('Edit caption'),
              onTap: () => Navigator.pop(ctx, 'caption'),
            ),
            ListTile(
              leading: const Icon(Icons.rotate_left_rounded),
              title: const Text('Tilt left'),
              onTap: () => Navigator.pop(ctx, 'left'),
            ),
            ListTile(
              leading: const Icon(Icons.rotate_right_rounded),
              title: const Text('Tilt right'),
              onTap: () => Navigator.pop(ctx, 'right'),
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
      case 'left' || 'right':
        final delta = choice == 'left' ? -3.0 : 3.0;
        await _edit(
          recipe,
          (r) => r.copyWith(polaroidRotation: ((r.polaroidRotation ?? -2) + delta).clamp(-12.0, 12.0)),
        );
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

  Widget _buildPage(BuildContext context, int pageIndex) {
    final recipe = widget.recipes[pageIndex ~/ 2];
    final actions = _actions;
    return pageIndex.isEven
        ? StoryPage(recipe: recipe, pageNumber: pageIndex + 1, recipeNumber: pageIndex ~/ 2 + 1, actions: actions)
        : MethodPage(recipe: recipe, pageNumber: pageIndex + 1, actions: actions);
  }

  Future<void> _showContents() async {
    final c = context.chefColors;
    final picked = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (ctx, scroll) => ListView.builder(
          controller: scroll,
          itemCount: widget.recipes.length + 1,
          itemBuilder: (ctx, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text('Contents', style: ctx.chefText.titleLarge),
              );
            }
            final r = widget.recipes[i - 1];
            final current = r.id == _current?.id;
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox.square(
                  dimension: 48,
                  child: RecipeImage(source: r.coverImage, theme: r.theme),
                ),
              ),
              title: Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text('Pages ${2 * i - 1}–${2 * i} · ${KitchenFormat.minutes(r.totalMinutes)}'),
              trailing: current ? Icon(Icons.bookmark_rounded, color: c.accentTomato) : null,
              selected: current,
              onTap: () => Navigator.pop(ctx, r.id),
            );
          },
        ),
      ),
    );
    if (picked != null && mounted) await openRecipe(picked);
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
            final recipe = _current!;
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
                    _decorating ? _decorateBar(spread) : _toolbar(recipe, spread),
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
                                    onOpen: (id) => openRecipe(id),
                                  ),
                                ],
                              )
                            : _binder(recipe, controller, spread),
                      ),
                    ),
                    if (!_decorating) _bottomBar(recipe, controller, spread),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _binder(Recipe recipe, PageFlipController controller, bool spread) {
    final palette = JournalPalette.of(context, recipe.theme);
    final positions = spread ? widget.recipes.length : widget.recipes.length * 2;
    final progress = positions <= 1 ? 0.0 : controller.position / (positions - 1);
    Widget corner(double turns) => IgnorePointer(
      child: Transform.rotate(angle: turns * math.pi / 2, child: const _BrassCorner()),
    );
    return Semantics(
      label: spread
          ? 'Recipe journal, pages ${controller.position * 2 + 1} and ${controller.position * 2 + 2} of ${positions * 2}'
          : 'Recipe journal, page ${controller.position + 1} of $positions',
      container: true,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: ChefMotion.emphasis,
              decoration: BoxDecoration(
                color: palette.binding,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 18, offset: const Offset(0, 8)),
                ],
              ),
              padding: spread ? const EdgeInsets.all(12) : const EdgeInsets.fromLTRB(18, 8, 8, 8),
              child: Stack(
                children: [
                  if (spread)
                    Positioned.fill(
                      child: _PageEdges(progress: progress, color: palette.paper),
                    ),
                  Positioned.fill(
                    left: spread ? 6 : 0,
                    right: spread ? 6 : 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(spread ? 6 : 10),
                      child: PageFlipBook(
                        controller: controller,
                        spread: spread,
                        pageCount: widget.recipes.length * 2,
                        pageIdentity: (i) => '${widget.recipes[i ~/ 2].id}:${i % 2}',
                        pageBuilder: _buildPage,
                        interactive: !_decorating,
                        onPositionChanged: _onPositionChanged,
                        onEdgeReached: () => HapticFeedback.selectionClick(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!spread) const Positioned(left: 2, top: 6, bottom: 6, child: _SpiralBinding()),
          if (spread) Positioned(left: 0, top: 0, child: corner(0)),
          Positioned(right: 0, top: 0, child: corner(1)),
          Positioned(right: 0, bottom: 0, child: corner(2)),
          if (spread) Positioned(left: 0, bottom: 0, child: corner(3)),
        ],
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
    final t = context.chefText;
    final listen = ListenButton(
      sessionId: 'recipe:${recipe.id}',
      compact: !spread,
      tonal: true,
      script: () => recipeScript(recipe, servings: servings.toDouble()),
    );
    if (!spread) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
        child: Row(
          children: [
            // Shrinks rather than overflowing with large text.
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SegmentedButton<int>(
                    showSelectedIcon: false,
                    style: const ButtonStyle(visualDensity: VisualDensity.compact),
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Story'), icon: Icon(Icons.auto_stories_outlined, size: 18)),
                      ButtonSegment(
                        value: 1,
                        label: Text('Method'),
                        icon: Icon(Icons.format_list_numbered_rounded, size: 18),
                      ),
                    ],
                    selected: {_side},
                    onSelectionChanged: (s) => _controller?.animateTo(_recipeIndex * 2 + s.first),
                  ),
                ),
              ),
            ),
            listen,
            IconButton(
              tooltip: 'Decorate page',
              onPressed: () => _setDecorating(true),
              icon: const Icon(Icons.auto_fix_high_outlined),
            ),
            _moreMenu(recipe),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(
        children: [
          Flexible(
            child: Text(
              'Recipe ${_recipeIndex + 1} of ${widget.recipes.length}',
              style: t.labelLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(onPressed: _showContents, icon: const Icon(Icons.toc_rounded), label: const Text('Contents')),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    listen,
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _setDecorating(true),
                      icon: const Icon(Icons.auto_fix_high_outlined),
                      label: const Text('Decorate'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/recipe/${recipe.id}'),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Details'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: recipe.steps.isEmpty ? null : () => context.push('/cook/${recipe.id}?servings=$servings'),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Cook'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moreMenu(Recipe recipe) {
    return PopupMenuButton<String>(
      tooltip: 'More',
      onSelected: (v) {
        switch (v) {
          case 'contents':
            _showContents();
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
          child: ListTile(leading: Icon(Icons.toc_rounded), title: Text('Contents')),
        ),
        PopupMenuItem(
          value: 'details',
          child: ListTile(leading: Icon(Icons.open_in_new_rounded), title: Text('Details & nutrition')),
        ),
        PopupMenuItem(
          value: 'collection',
          child: ListTile(leading: Icon(Icons.collections_bookmark_outlined), title: Text('Save to collection')),
        ),
        PopupMenuItem(
          value: 'edit',
          child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit recipe')),
        ),
      ],
    );
  }

  Widget _decorateBar(bool spread) {
    final t = context.chefText;
    return LayoutBuilder(builder: (context, box) {
      final roomy = box.maxWidth >= 440;
      return Padding(
        padding: EdgeInsets.fromLTRB(spread ? 20 : 12, 4, spread ? 20 : 12, 4),
        child: Row(
          children: [
            if (roomy) ...[
              FilledButton.tonalIcon(
                onPressed: _addDecoration,
                icon: const Icon(Icons.add_reaction_outlined),
                label: const Text('Add'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _pickTheme,
                icon: const Icon(Icons.palette_outlined),
                label: const Text('Theme'),
              ),
            ] else ...[
              IconButton.filledTonal(
                tooltip: 'Add a sticker',
                onPressed: _addDecoration,
                icon: const Icon(Icons.add_reaction_outlined),
              ),
              IconButton.outlined(
                tooltip: 'Page theme',
                onPressed: _pickTheme,
                icon: const Icon(Icons.palette_outlined),
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
              icon: const Icon(Icons.check_rounded),
              label: const Text('Done'),
            ),
          ],
        ),
      );
    });
  }

  Widget _bottomBar(Recipe recipe, PageFlipController controller, bool spread) => Consumer(
    builder: (context, ref, _) {
      final servings =
          ref.watch(journalServingsProvider(recipe.id)) ?? math.max(1, recipe.baseServings.toDouble().round());
      return _bottomBarFor(recipe, controller, spread, servings);
    },
  );

  Widget _bottomBarFor(Recipe recipe, PageFlipController controller, bool spread, int servings) {
    final t = context.chefText;
    final c = context.chefColors;
    final positions = spread ? widget.recipes.length : widget.recipes.length * 2;
    final atStart = controller.position <= 0;
    final atEnd = controller.position >= positions - 1;
    final caption = spread
        ? 'Pages ${controller.position * 2 + 1}–${controller.position * 2 + 2} of ${positions * 2}'
        : '${_recipeIndex + 1} of ${widget.recipes.length} · ${_side == 0 ? 'Story' : 'Method'}';

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(spread ? 20 : 8, 2, spread ? 20 : 8, 6),
        child: Row(
          children: [
            IconButton.outlined(
              tooltip: 'Previous page',
              onPressed: atStart ? null : () => _go(-1),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: spread
                  ? Center(
                      child: Text(caption, style: t.labelLarge?.copyWith(color: c.contentSecondary)),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(caption, style: t.labelSmall?.copyWith(color: c.contentSecondary)),
                        const SizedBox(height: 2),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: recipe.steps.isEmpty
                                ? null
                                : () => context.push('/cook/${recipe.id}?servings=$servings'),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Start cooking'),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              tooltip: 'Next page',
              onPressed: atEnd ? null : () => _go(1),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

/// Coloured bookmark tabs down the side of the open book.
class _IndexTabs extends StatelessWidget {
  final List<Recipe> recipes;
  final int currentIndex;
  final ValueChanged<String> onOpen;
  const _IndexTabs({required this.recipes, required this.currentIndex, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    return SizedBox(
      width: 112,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 24),
        itemCount: recipes.length,
        itemBuilder: (context, i) {
          final r = recipes[i];
          final active = i == currentIndex;
          final color = Color.lerp(r.theme.accent(c), Colors.black, c.isDark ? 0.35 : 0.18)!;
          final word = r.title.split(RegExp(r'\s+')).firstWhere((w) => w.length > 2, orElse: () => r.title);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Tooltip(
                message: r.title,
                child: Semantics(
                  button: true,
                  selected: active,
                  label: 'Open ${r.title}',
                  excludeSemantics: true,
                  child: AnimatedContainer(
                    duration: ChefMotion.standard,
                    width: active ? 108 : 96,
                    child: Material(
                      color: color,
                      elevation: active ? 4 : 1,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
                      ),
                      child: InkWell(
                        onTap: () => onOpen(r.id),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                          child: Text(
                            word,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.chefText.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Paper block thickness on either side of an open book.
class _PageEdges extends StatelessWidget {
  final double progress;
  final Color color;
  const _PageEdges({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) => IgnorePointer(child: CustomPaint(painter: _PageEdgesPainter(progress, color)));
}

class _PageEdgesPainter extends CustomPainter {
  final double progress;
  final Color color;
  _PageEdgesPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final line = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 0.8;
    final left = (2 + 6 * progress).round();
    final right = (2 + 6 * (1 - progress)).round();
    for (var i = 0; i < left; i++) {
      final x = 6.0 - i * 1.0;
      canvas.drawRect(Rect.fromLTRB(x - 1, 2, x, size.height - 2), paint);
      canvas.drawLine(Offset(x - 1, 2), Offset(x - 1, size.height - 2), line);
    }
    for (var i = 0; i < right; i++) {
      final x = size.width - 6.0 + i * 1.0;
      canvas.drawRect(Rect.fromLTRB(x, 2, x + 1, size.height - 2), paint);
      canvas.drawLine(Offset(x + 1, 2), Offset(x + 1, size.height - 2), line);
    }
  }

  @override
  bool shouldRepaint(_PageEdgesPainter old) => old.progress != progress || old.color != color;
}

/// Metal rings down the left edge of the single-page book.
class _SpiralBinding extends StatelessWidget {
  const _SpiralBinding();

  @override
  Widget build(BuildContext context) => const IgnorePointer(
    child: SizedBox(width: 26, child: CustomPaint(painter: _SpiralPainter())),
  );
}

class _SpiralPainter extends CustomPainter {
  const _SpiralPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..shader = const LinearGradient(
        colors: [Color(0xFF8D8D8D), Color(0xFFE6E6E6), Color(0xFF7A7A7A)],
      ).createShader(Offset.zero & size);
    final hole = Paint()..color = Colors.black.withValues(alpha: 0.35);
    for (var y = 22.0; y < size.height - 10; y += 28) {
      canvas.drawCircle(Offset(size.width - 6, y), 3.2, hole);
      canvas.drawArc(
        Rect.fromCenter(center: Offset(size.width / 2, y), width: size.width - 4, height: 12),
        math.pi * 0.95,
        math.pi * 1.1,
        false,
        ring,
      );
    }
  }

  @override
  bool shouldRepaint(_SpiralPainter old) => false;
}

class _BrassCorner extends StatelessWidget {
  const _BrassCorner();

  @override
  Widget build(BuildContext context) =>
      const SizedBox.square(dimension: 26, child: CustomPaint(painter: _BrassPainter()));
}

class _BrassPainter extends CustomPainter {
  const _BrassPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9C98A), Color(0xFFB98B3E), Color(0xFF8A6427)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.28), 2, Paint()..color = const Color(0xFF6E4E1C));
  }

  @override
  bool shouldRepaint(_BrassPainter old) => false;
}
