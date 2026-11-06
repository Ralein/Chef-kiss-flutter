import 'dart:math' as math;

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../../app/widgets/kitchen_format.dart';
import '../../../app/widgets/recipe_image.dart';
import 'widgets/recipe_sections.dart';
import 'widgets/recipe_sheets.dart';
import '../../voice/listen_button.dart';

enum _MenuAction { collection, journal, decorate, cover, tip, copy, delete }

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  int? _servings;
  final Set<String> _checked = {};

  int _servingsFor(Recipe r) => _servings ?? math.max(1, r.baseServings.toDouble().round());

  Future<void> _save(Recipe updated, String message) async {
    final res = await ref.read(recipeRepositoryProvider).saveRecipe(updated);
    if (!mounted) return;
    ChefToastService.show(
      context: context,
      title: res.isSuccess ? message : 'Could not save changes',
      description: res.isSuccess ? null : res.error?.message,
      type: res.isSuccess ? ChefToastType.success : ChefToastType.error,
    );
  }

  Future<void> _toggleFavorite(Recipe r) async {
    await ref.read(recipeRepositoryProvider).toggleFavorite(r.id);
  }

  Future<void> _onMenu(_MenuAction action, Recipe recipe) async {
    switch (action) {
      case _MenuAction.collection:
        await showMoveToBookSheet(context, recipe);
      case _MenuAction.journal:
        context.go('/?view=journal&recipe=${recipe.id}');
      case _MenuAction.decorate:
        context.go('/?view=journal&recipe=${recipe.id}&decorate=1');
      case _MenuAction.cover:
        final choice = await showCoverPhotoSheet(context, theme: recipe.theme);
        if (choice == null || !mounted) return;
        await _save(
          choice.source == null ? recipe.copyWith(clearCoverImage: true) : recipe.copyWith(coverImage: choice.source),
          'Cover updated',
        );
      case _MenuAction.tip:
        final tip = await showTextPromptDialog(
          context,
          title: 'Chef’s tip',
          initial: recipe.chefTip,
          hint: 'A secret, a substitution, or a lesson learned',
          maxLines: 4,
        );
        if (tip != null && mounted) await _save(recipe.copyWith(chefTip: tip.trim()), 'Tip saved');
      case _MenuAction.copy:
        await Clipboard.setData(ClipboardData(text: _asPlainText(recipe)));
        if (mounted) {
          ChefToastService.show(context: context, title: 'Recipe copied to clipboard', type: ChefToastType.success);
        }
      case _MenuAction.delete:
        await _confirmDelete(recipe);
    }
  }

  Future<void> _confirmDelete(Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete recipe?'),
        content: Text('“${recipe.title}” will move to Recently deleted in Settings, where you can restore it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: context.chefColors.stateDanger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final repo = ref.read(recipeRepositoryProvider);
    final res = await repo.deleteRecipe(recipe.id);
    if (!mounted) return;
    if (res.isFailure) {
      ChefToastService.show(context: context, title: 'Could not delete recipe', type: ChefToastType.error);
      return;
    }
    context.go('/');
    ChefToastService.show(
      title: 'Recipe deleted',
      description: recipe.title,
      actionLabel: 'Undo',
      onAction: () => repo.restoreRecipe(recipe.id),
    );
  }

  String _asPlainText(Recipe r) {
    final b = StringBuffer()..writeln(r.title);
    if (r.summary != null && r.summary!.isNotEmpty) b.writeln(r.summary);
    b
      ..writeln()
      ..writeln('Serves ${r.baseServings.toDisplayString()} · ${KitchenFormat.minutes(r.totalMinutes)}')
      ..writeln()
      ..writeln('Ingredients');
    for (final i in r.ingredients) {
      b.writeln('• ${i.formatDisplay()}');
    }
    b
      ..writeln()
      ..writeln('Method');
    for (var s = 0; s < r.steps.length; s++) {
      b.writeln('${s + 1}. ${r.steps[s].instructionShort}');
      if (r.steps[s].instructionDetail?.isNotEmpty ?? false) b.writeln('   ${r.steps[s].instructionDetail}');
    }
    if (r.chefTip != null && r.chefTip!.isNotEmpty) {
      b
        ..writeln()
        ..writeln('Tip: ${r.chefTip}');
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(singleRecipeProvider(widget.recipeId));
    return async.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          message: 'This recipe could not be loaded.',
          onRetry: () => ref.invalidate(singleRecipeProvider(widget.recipeId)),
        ),
      ),
      data: (recipe) {
        if (recipe == null || recipe.isDeleted) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyStateScene(
              icon: Icons.menu_book_outlined,
              title: 'Recipe not found',
              message: 'It may have been deleted.',
              actionLabel: 'Back to recipes',
              onAction: () => context.go('/'),
            ),
          );
        }
        return _buildRecipe(context, recipe);
      },
    );
  }

  Widget _buildRecipe(BuildContext context, Recipe recipe) {
    final c = context.chefColors;
    final report = ref.watch(recipeNutritionProvider(recipe.id)) ?? RecipeNutritionAnalyzer().analyze(recipe);
    final servings = _servingsFor(recipe);

    final ingredients = IngredientsSection(
      recipe: recipe,
      servings: servings,
      onServingsChanged: (v) => setState(() => _servings = v),
      checked: _checked,
      onToggle: (id) => setState(() => _checked.contains(id) ? _checked.remove(id) : _checked.add(id)),
      onClearChecks: () => setState(_checked.clear),
    );
    final overview = _Overview(recipe: recipe, servings: servings, onEditTip: () => _onMenu(_MenuAction.tip, recipe));
    final nutrition = NutritionSection(recipe: recipe, report: report);
    final method = MethodSection(recipe: recipe);
    final notes = recipe.notes.isEmpty ? null : _NotesCard(notes: recipe.notes);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;
          const gap = SizedBox(height: 16);
          final body = wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: Column(children: [overview, gap, nutrition, gap, ingredients])),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          method,
                          if (notes != null) ...[gap, notes],
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    overview,
                    gap,
                    ingredients,
                    gap,
                    method,
                    gap,
                    nutrition,
                    if (notes != null) ...[gap, notes],
                  ],
                );

          return CustomScrollView(
            slivers: [
              _HeroAppBar(
                recipe: recipe,
                expandedHeight: wide ? 360 : 280,
                onFavorite: () => _toggleFavorite(recipe),
                onEdit: () => context.push('/editor/${recipe.id}'),
                onMenu: (a) => _onMenu(a, recipe),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), child: body),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _CookBar(
        enabled: recipe.steps.isNotEmpty,
        onCook: () => context.push('/cook/${recipe.id}?servings=$servings'),
        background: c.surfacePaper,
      ),
    );
  }
}

class _HeroAppBar extends StatelessWidget {
  final Recipe recipe;
  final double expandedHeight;
  final VoidCallback onFavorite;
  final VoidCallback onEdit;
  final ValueChanged<_MenuAction> onMenu;

  const _HeroAppBar({
    required this.recipe,
    required this.expandedHeight,
    required this.onFavorite,
    required this.onEdit,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    Widget circle(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(color: c.surfacePaper.withValues(alpha: 0.9), shape: const CircleBorder(), child: child),
    );

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: expandedHeight,
      backgroundColor: c.surfaceCanvas,
      automaticallyImplyLeading: false,
      leading: circle(BackButton(onPressed: () => context.canPop() ? context.pop() : context.go('/'))),
      title: _CollapsedTitle(title: recipe.title),
      actions: [
        circle(
          IconButton(
            tooltip: recipe.isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: onFavorite,
            icon: Icon(
              recipe.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: recipe.isFavorite ? c.accentTomato : c.contentPrimary,
            ),
          ),
        ),
        circle(
          IconButton(
            tooltip: 'Open in journal',
            onPressed: () => onMenu(_MenuAction.journal),
            icon: const Icon(Icons.auto_stories_outlined),
          ),
        ),
        circle(IconButton(tooltip: 'Edit recipe', onPressed: onEdit, icon: const Icon(Icons.edit_outlined))),
        circle(
          PopupMenuButton<_MenuAction>(
            tooltip: 'More options',
            onSelected: onMenu,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _MenuAction.collection,
                child: ListTile(leading: Icon(LucideIcons.folderInput), title: Text('Move to a book')),
              ),
              PopupMenuItem(
                value: _MenuAction.cover,
                child: ListTile(leading: Icon(Icons.image_outlined), title: Text('Change cover photo')),
              ),
              PopupMenuItem(
                value: _MenuAction.tip,
                child: ListTile(leading: Icon(Icons.lightbulb_outline_rounded), title: Text('Edit chef’s tip')),
              ),
              PopupMenuItem(
                value: _MenuAction.decorate,
                child: ListTile(leading: Icon(Icons.auto_fix_high_outlined), title: Text('Decorate in journal')),
              ),
              PopupMenuItem(
                value: _MenuAction.copy,
                child: ListTile(leading: Icon(Icons.copy_rounded), title: Text('Copy as text')),
              ),
              PopupMenuItem(
                value: _MenuAction.delete,
                child: ListTile(leading: Icon(Icons.delete_outline_rounded), title: Text('Delete')),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: RecipeImage(
          source: recipe.coverImage,
          theme: recipe.theme,
          semanticLabel: 'Photo of ${recipe.title}',
        ),
      ),
    );
  }
}

/// Shows the recipe title in the toolbar only once the hero has collapsed.
class _CollapsedTitle extends StatelessWidget {
  final String title;
  const _CollapsedTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final collapsed = settings == null || settings.currentExtent <= settings.minExtent + 12;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: collapsed ? 1 : 0,
      child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

class _Overview extends StatelessWidget {
  final Recipe recipe;
  final int servings;
  final VoidCallback onEditTip;
  const _Overview({required this.recipe, required this.servings, required this.onEditTip});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final cuisines = recipe.labels.where((l) => l.kind == 'cuisine').map((l) => l.displayName);
    final accent = recipe.theme.accent(c);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: Text(recipe.title, style: t.headlineMedium)),
        if (recipe.summary != null && recipe.summary!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(recipe.summary!, style: t.bodyLarge?.copyWith(color: c.contentSecondary)),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaChip(icon: Icons.schedule_rounded, label: KitchenFormat.minutes(recipe.totalMinutes)),
            _MetaChip(icon: Icons.people_outline_rounded, label: 'Serves ${recipe.baseServings.toDisplayString()}'),
            _MetaChip(icon: Icons.signal_cellular_alt_rounded, label: _difficulty(recipe.difficulty)),
            for (final cuisine in cuisines) _MetaChip(icon: Icons.public_rounded, label: cuisine),
            if (recipe.origin == Origin.aiProposed) _MetaChip(icon: Icons.auto_awesome_rounded, label: 'AI-assisted'),
            if (recipe.status == RecipeStatus.draft) const _MetaChip(icon: Icons.edit_note_rounded, label: 'Draft'),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: ListenButton(
            sessionId: 'recipe:${recipe.id}',
            label: 'Read recipe aloud',
            tonal: true,
            script: () => recipeScript(recipe, servings: servings.toDouble()),
          ),
        ),
        if (recipe.moodStamps.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final stamp in recipe.moodStamps)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ChefRadius.pill),
                    border: Border.all(color: accent.withValues(alpha: 0.6)),
                  ),
                  child: Text(stamp, style: t.labelMedium),
                ),
            ],
          ),
        ],
        if (recipe.chefTip?.trim().isNotEmpty ?? false) ...[
          const SizedBox(height: 16),
          ChefCard(
            color: c.yolkSoft,
            onTap: onEditTip,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: c.contentPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chef’s tip', style: t.labelLarge),
                      const SizedBox(height: 2),
                      Text(
                        recipe.chefTip?.trim().isNotEmpty ?? false ? recipe.chefTip! : 'Tap to add a tip',
                        style: t.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static String _difficulty(RecipeDifficulty d) => switch (d) {
    RecipeDifficulty.easy => 'Easy',
    RecipeDifficulty.medium => 'Medium',
    RecipeDifficulty.hard => 'Challenging',
  };
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: c.surfaceRaised, borderRadius: BorderRadius.circular(ChefRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: c.contentSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label, style: context.chefText.labelMedium, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final List<RecipeNote> notes;
  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return ChefCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('Notes'),
          const SizedBox(height: 8),
          for (final n in notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: SelectableText(n.body, style: context.chefText.bodyMedium),
            ),
        ],
      ),
    );
  }
}

class _CookBar extends StatelessWidget {
  final bool enabled;
  final VoidCallback onCook;
  final Color background;
  const _CookBar({required this.enabled, required this.onCook, required this.background});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    return Material(
      color: background,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.outlineSubtle)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          // heightFactor: 1 — as a bottomNavigationBar this gets loose
          // full-screen constraints; a plain Center would take them all.
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: enabled ? onCook : null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(enabled ? 'Start cooking' : 'Add steps to start cooking'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
