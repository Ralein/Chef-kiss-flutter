import 'dart:math' as math;

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../../app/providers.dart';
import '../../../../app/widgets/kitchen_format.dart';
import '../../../../app/widgets/recipe_image.dart';
import '../../../../app/widgets/step_timer_button.dart';
import '../../../../core/media/recipe_art.dart';
import '../../../recipe_detail/presentation/widgets/recipe_sections.dart';
import '../../../voice/spoken_text.dart';
import '../../application/recipe_edits.dart';
import 'scrapbook_layer.dart';
import 'sticker_art.dart';

/// Paper, ink and binding colours for a recipe's theme in light or dark mode.
class JournalPalette {
  final Color paper;
  final Color line;
  final Color margin;
  final Color accent;
  final Color binding;
  final Color polaroid;
  final Color polaroidInk;
  final Color note;
  final Color noteInk;

  const JournalPalette({
    required this.paper,
    required this.line,
    required this.margin,
    required this.accent,
    required this.binding,
    required this.polaroid,
    required this.polaroidInk,
    required this.note,
    required this.noteInk,
  });

  factory JournalPalette.of(BuildContext context, ScrapbookTheme theme) {
    final c = context.chefColors;
    final accent = theme.accent(c);
    if (c.isDark) {
      return JournalPalette(
        paper: const Color(0xFF26221E),
        line: const Color(0xFF3B352F),
        margin: c.accentTomato.withValues(alpha: 0.4),
        accent: accent,
        binding: Color.lerp(accent, Colors.black, 0.55)!,
        polaroid: const Color(0xFFEDE7DF),
        polaroidInk: const Color(0xFF2C2623),
        note: const Color(0xFF4A3F22),
        noteInk: const Color(0xFFF5EBD0),
      );
    }
    return JournalPalette(
      paper: const Color(0xFFFDFAF4),
      line: const Color(0xFFE8DECE),
      margin: c.accentTomato.withValues(alpha: 0.35),
      accent: accent,
      binding: Color.lerp(accent, Colors.black, 0.28)!,
      polaroid: Colors.white,
      polaroidInk: const Color(0xFF2C2623),
      note: const Color(0xFFFFF1BF),
      noteInk: const Color(0xFF4A3B12),
    );
  }

  /// Ink colours were chosen for light paper; lift them on dark paper.
  Color ink(BuildContext context, Color color) =>
      context.chefColors.isDark ? Color.lerp(color, Colors.white, 0.4)! : color;
}

/// Everything a page can ask the journal to do. Pages stay dumb: the journal
/// owns saving, selection and dialogs.
class JournalPageActions {
  final bool decorating;
  final String? selectedId;
  final ValueChanged<String?> onSelect;
  final void Function(Recipe, ScrapbookSticker) onStickerChanged;
  final void Function(Recipe, WashiTapeDecoration) onTapeChanged;
  final void Function(Recipe, String id) onRemoveItem;
  final void Function(Recipe, String id) onBringToFront;
  final void Function(Recipe, RecipeIngredient) onPickIngredientIcon;
  final void Function(Recipe, RecipeStep) onPickStepIcon;
  final void Function(Recipe) onEditTip;
  final void Function(Recipe) onEditPolaroid;
  final void Function(Recipe) onToggleFavorite;

  const JournalPageActions({
    required this.decorating,
    required this.selectedId,
    required this.onSelect,
    required this.onStickerChanged,
    required this.onTapeChanged,
    required this.onRemoveItem,
    required this.onBringToFront,
    required this.onPickIngredientIcon,
    required this.onPickStepIcon,
    required this.onEditTip,
    required this.onEditPolaroid,
    required this.onToggleFavorite,
  });
}

/// A sheet of journal paper: background ruling, scrolling content, and the
/// scrapbook layer for this side's stickers and tape.
class JournalPageFrame extends StatelessWidget {
  final Recipe recipe;
  final String side;
  final JournalPageActions actions;
  final bool ruled;
  final double marginX;
  final EdgeInsets padding;
  final Widget child;

  const JournalPageFrame({
    super.key,
    required this.recipe,
    required this.side,
    required this.actions,
    required this.child,
    this.ruled = false,
    this.marginX = 0,
    this.padding = const EdgeInsets.fromLTRB(22, 22, 22, 28),
  });

  @override
  Widget build(BuildContext context) {
    final palette = JournalPalette.of(context, recipe.theme);
    final stickers = recipe.stickers.where((s) => (s.pageSide == 'right') == (side == 'right')).toList();
    final tapes = recipe.washiTapes.where((t) => (t.pageSide == 'right') == (side == 'right')).toList();
    return ColoredBox(
      color: palette.paper,
      child: LayoutBuilder(
        builder: (context, viewport) {
          return SingleChildScrollView(
            primary: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewport.maxHeight),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PaperPainter(
                        ruled: ruled,
                        line: palette.line,
                        margin: palette.margin,
                        marginX: marginX,
                      ),
                    ),
                  ),
                  Padding(padding: padding, child: child),
                  Positioned.fill(
                    child: ScrapbookLayer(
                      stickers: stickers,
                      tapes: tapes,
                      editable: actions.decorating,
                      selectedId: actions.selectedId,
                      onSelect: actions.onSelect,
                      onStickerChanged: (s) => actions.onStickerChanged(recipe, s),
                      onTapeChanged: (t) => actions.onTapeChanged(recipe, t),
                      onRemove: (id) => actions.onRemoveItem(recipe, id),
                      onBringToFront: (id) => actions.onBringToFront(recipe, id),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PaperPainter extends CustomPainter {
  final bool ruled;
  final Color line;
  final Color margin;
  final double marginX;
  _PaperPainter({required this.ruled, required this.line, required this.margin, required this.marginX});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = line;
    if (ruled) {
      paint.strokeWidth = 1;
      for (var y = 64.0; y < size.height; y += 30) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
      if (marginX > 0) {
        canvas.drawLine(
          Offset(marginX, 0),
          Offset(marginX, size.height),
          Paint()
            ..color = margin
            ..strokeWidth = 1.4,
        );
      }
    } else {
      for (var y = 14.0; y < size.height; y += 22) {
        for (var x = 14.0; x < size.width; x += 22) {
          canvas.drawCircle(Offset(x, y), 1.1, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PaperPainter old) =>
      old.ruled != ruled || old.line != line || old.margin != margin || old.marginX != marginX;
}

// --- Story page (left) -------------------------------------------------------------

class StoryPage extends ConsumerStatefulWidget {
  final Recipe recipe;
  final int pageNumber;
  final int recipeNumber;
  final JournalPageActions actions;

  const StoryPage({
    super.key,
    required this.recipe,
    required this.pageNumber,
    required this.recipeNumber,
    required this.actions,
  });

  @override
  ConsumerState<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends ConsumerState<StoryPage> {
  final Set<String> _checked = {};

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final actions = widget.actions;
    final c = context.chefColors;
    final t = context.chefText;
    final palette = JournalPalette.of(context, recipe.theme);
    final base = math.max(1, recipe.baseServings.toDouble().round());
    final servings = ref.watch(journalServingsProvider(recipe.id)) ?? base;
    final readingIngredients = ref.watch(
      readAloudProvider.select(
        (v) => v.sessionId == 'recipe:${recipe.id}' && v.segmentId == SpokenRecipe.ingredientsId,
      ),
    );

    final rows = <Widget>[];
    String? lastGroup;
    for (final ing in recipe.ingredients) {
      final group = ing.groupKey?.trim();
      if (group != null && group.isNotEmpty && group != lastGroup) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Text(
              group.toUpperCase(),
              style: t.labelSmall?.copyWith(letterSpacing: 1.2, color: c.contentSecondary),
            ),
          ),
        );
        lastGroup = group;
      }
      final scaled = scaleFor(recipe, ing, servings.toDouble());
      rows.add(
        _IngredientLine(
          ingredient: ing,
          amount: ingredientAmount(scaled),
          checked: _checked.contains(ing.id),
          decorating: actions.decorating,
          palette: palette,
          onToggle: () => setState(() => _checked.contains(ing.id) ? _checked.remove(ing.id) : _checked.add(ing.id)),
          onPickIcon: () => actions.onPickIngredientIcon(recipe, ing),
        ),
      );
    }

    return JournalPageFrame(
      recipe: recipe,
      side: 'left',
      actions: actions,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(
            label: 'No. ${widget.recipeNumber.toString().padLeft(2, '0')} · Keepsake',
            color: palette.ink(context, palette.accent),
            trailing: IconButton(
              tooltip: recipe.isFavorite ? 'Remove from favorites' : 'Add to favorites',
              onPressed: () => actions.onToggleFavorite(recipe),
              icon: Icon(
                recipe.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: recipe.isFavorite ? c.accentTomato : c.contentSecondary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: _Polaroid(
              recipe: recipe,
              palette: palette,
              decorating: actions.decorating,
              onEdit: () => actions.onEditPolaroid(recipe),
            ),
          ),
          const SizedBox(height: 22),
          Semantics(header: true, child: Text(recipe.title, style: t.headlineMedium?.copyWith(height: 1.2))),
          if (recipe.summary != null && recipe.summary!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '“${recipe.summary!.trim()}”',
              style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: c.contentSecondary),
            ),
          ],
          if (recipe.moodStamps.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 8,
              children: [
                for (final (i, stamp) in recipe.moodStamps.take(4).indexed)
                  DoodleStamp(
                    label: stamp,
                    icon: getCulinaryIconData(stamp),
                    color: palette.ink(context, palette.accent),
                    rotation: (i.isEven ? -1 : 1) * 0.03,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          _MetaRow(recipe: recipe),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: ChefMotion.standard,
                  style: (t.titleLarge ?? const TextStyle()).copyWith(
                    color: readingIngredients ? palette.ink(context, palette.accent) : c.contentPrimary,
                  ),
                  child: const Text('Mise en place'),
                ),
              ),
              ServingsStepper(
                value: servings,
                onChanged: (v) => ref.read(journalServingsProvider(recipe.id).notifier).state = v,
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No ingredients yet — add them in the editor.', style: t.bodyMedium),
            )
          else
            ...rows,
          const SizedBox(height: 28),
          _Folio(number: widget.pageNumber, caption: 'Story & prep'),
        ],
      ),
    );
  }
}

class _Polaroid extends StatelessWidget {
  final Recipe recipe;
  final JournalPalette palette;
  final bool decorating;
  final VoidCallback onEdit;
  const _Polaroid({required this.recipe, required this.palette, required this.decorating, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final caption = (recipe.polaroidCaption?.trim().isNotEmpty ?? false)
        ? recipe.polaroidCaption!.trim()
        : recipe.title;
    final tape = switch (recipe.theme) {
      ScrapbookTheme.terracottaClassic => WashiTapePattern.terracotta,
      ScrapbookTheme.matchaSage => WashiTapePattern.sage,
      ScrapbookTheme.artisanKraft => WashiTapePattern.kraft,
      ScrapbookTheme.nordicSlate => WashiTapePattern.dots,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth * 0.84, 340.0);
        return Transform.rotate(
          angle: degToRad(recipe.polaroidRotation ?? -2),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: width,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                decoration: BoxDecoration(
                  color: palette.polaroid,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ClipRect(
                        child: RecipeImage(
                          source: recipe.coverImage,
                          theme: recipe.theme,
                          semanticLabel: 'Photo of ${recipe.title}',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: palette.polaroidInk,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -9,
                left: width / 2 - 45,
                child: WashiTape(width: 90, height: 18, rotation: 0.05, pattern: tape),
              ),
              if (decorating)
                Positioned(
                  right: -8,
                  top: -8,
                  child: IconButton.filledTonal(
                    tooltip: 'Change photo or caption',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded, size: 18),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _IngredientLine extends StatelessWidget {
  final RecipeIngredient ingredient;
  final String amount;
  final bool checked;
  final bool decorating;
  final JournalPalette palette;
  final VoidCallback onToggle;
  final VoidCallback onPickIcon;

  const _IngredientLine({
    required this.ingredient,
    required this.amount,
    required this.checked,
    required this.decorating,
    required this.palette,
    required this.onToggle,
    required this.onPickIcon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final ink = palette.ink(context, parseHexColor(ingredient.iconColor) ?? palette.accent);
    final iconKey = ingredient.icon ?? RecipeArt.iconKeyFor(ingredient.displayName);
    final strike = checked ? TextDecoration.lineThrough : null;
    final bubble = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ink.withValues(alpha: 0.14),
        border: decorating ? Border.all(color: ink, width: 1.5) : null,
      ),
      child: Icon(getCulinaryIconData(iconKey), size: 17, color: ink),
    );

    return Semantics(
      checked: decorating ? null : checked,
      label:
          '${amount.isEmpty ? '' : '$amount '}${ingredient.displayName}'
          '${ingredient.prepText?.isNotEmpty ?? false ? ', ${ingredient.prepText}' : ''}',
      excludeSemantics: !decorating,
      child: InkWell(
        onTap: decorating ? null : onToggle,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              decorating
                  ? IconButton(
                      tooltip: 'Change icon for ${ingredient.displayName}',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                      onPressed: onPickIcon,
                      icon: bubble,
                    )
                  : Padding(padding: const EdgeInsets.all(4), child: bubble),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: ingredient.displayName,
                          style: t.bodyLarge?.copyWith(
                            decoration: strike,
                            color: checked ? c.contentSecondary : c.contentPrimary,
                          ),
                        ),
                        if (ingredient.prepText?.isNotEmpty ?? false)
                          TextSpan(
                            text: ', ${ingredient.prepText}',
                            style: t.bodyMedium?.copyWith(color: c.contentSecondary, decoration: strike),
                          ),
                        if (ingredient.isOptional)
                          TextSpan(
                            text: ' (optional)',
                            style: t.bodySmall?.copyWith(color: c.contentSecondary),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (amount.isNotEmpty) ...[
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: Text(
                    amount,
                    style: t.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      decoration: strike,
                      color: checked ? c.contentSecondary : c.contentPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final Recipe recipe;
  const _MetaRow({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    Widget item(IconData icon, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: c.contentSecondary),
        const SizedBox(width: 4),
        Text(text, style: t.labelMedium?.copyWith(color: c.contentSecondary)),
      ],
    );
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        item(Icons.schedule_rounded, KitchenFormat.minutes(recipe.totalMinutes)),
        item(Icons.people_outline_rounded, 'Serves ${recipe.baseServings.toDisplayString()}'),
        item(Icons.signal_cellular_alt_rounded, switch (recipe.difficulty) {
          RecipeDifficulty.easy => 'Easy',
          RecipeDifficulty.medium => 'Medium',
          RecipeDifficulty.hard => 'Challenging',
        }),
        item(Icons.format_list_bulleted_rounded, '${recipe.ingredients.length} ingredients'),
      ],
    );
  }
}

// --- Method page (right) --------------------------------------------------------------

class MethodPage extends ConsumerWidget {
  final Recipe recipe;
  final int pageNumber;
  final JournalPageActions actions;

  const MethodPage({super.key, required this.recipe, required this.pageNumber, required this.actions});

  static const _marginX = 52.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.chefText;
    final c = context.chefColors;
    final palette = JournalPalette.of(context, recipe.theme);
    final reading = ref.watch(
      readAloudProvider.select((v) => v.sessionId == 'recipe:${recipe.id}' ? v.segmentId : null),
    );
    final hasTip = recipe.chefTip?.trim().isNotEmpty ?? false;

    return JournalPageFrame(
      recipe: recipe,
      side: 'right',
      actions: actions,
      ruled: true,
      marginX: _marginX,
      padding: const EdgeInsets.fromLTRB(12, 22, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: _marginX - 4),
            child: _PageHeader(label: 'Method & timers', color: palette.ink(context, palette.accent)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: _marginX - 4, top: 4),
            child: Text(
              recipe.steps.isEmpty
                  ? 'No steps yet'
                  : '${recipe.steps.length} step${recipe.steps.length == 1 ? '' : 's'} · ${KitchenFormat.minutes(recipe.totalMinutes)}',
              style: t.bodySmall,
            ),
          ),
          const SizedBox(height: 14),
          if (recipe.steps.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: _marginX - 4),
              child: Text('Add the method in the editor to cook it step by step.', style: t.bodyMedium),
            ),
          for (var i = 0; i < recipe.steps.length; i++)
            _StepEntry(
              recipe: recipe,
              step: recipe.steps[i],
              number: i + 1,
              palette: palette,
              highlighted: reading == SpokenRecipe.stepId(recipe.steps[i]),
              decorating: actions.decorating,
              onPickIcon: () => actions.onPickStepIcon(recipe, recipe.steps[i]),
            ),
          if (hasTip || actions.decorating) ...[
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.only(left: _marginX - 4),
              child: _TipNote(
                recipe: recipe,
                palette: palette,
                highlighted: reading == 'tip',
                onTap: actions.decorating ? () => actions.onEditTip(recipe) : null,
              ),
            ),
          ],
          const SizedBox(height: 28),
          _Folio(number: pageNumber, caption: 'Method & timers'),
          SizedBox(height: c.isDark ? 0 : 0),
        ],
      ),
    );
  }
}

class _StepEntry extends StatelessWidget {
  final Recipe recipe;
  final RecipeStep step;
  final int number;
  final JournalPalette palette;
  final bool highlighted;
  final bool decorating;
  final VoidCallback onPickIcon;

  const _StepEntry({
    required this.recipe,
    required this.step,
    required this.number,
    required this.palette,
    required this.highlighted,
    required this.decorating,
    required this.onPickIcon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final ink = palette.ink(context, parseHexColor(step.iconColor) ?? palette.accent);
    final action = step.actionKey?.trim();
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ink.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ChefRadius.pill),
        border: decorating ? Border.all(color: ink, width: 1.2) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getCulinaryIconData(step.iconKey ?? action), size: 14, color: ink),
          if (action != null && action.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              action.toUpperCase(),
              style: t.labelSmall?.copyWith(color: ink, letterSpacing: 0.8, fontWeight: FontWeight.w800),
            ),
          ],
          if (decorating) ...[const SizedBox(width: 4), Icon(Icons.edit_rounded, size: 12, color: ink)],
        ],
      ),
    );

    return AnimatedContainer(
      duration: ChefMotion.standard,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
      decoration: BoxDecoration(
        color: highlighted ? c.yolkSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MethodPage._marginX - 8,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: palette.accent, shape: BoxShape.circle),
                child: Text(
                  '$number',
                  style: t.labelLarge?.copyWith(color: c.onAccent, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (decorating)
                  InkWell(
                    onTap: onPickIcon,
                    borderRadius: BorderRadius.circular(ChefRadius.pill),
                    child: Semantics(button: true, label: 'Change icon for step $number', child: chip),
                  )
                else if ((action?.isNotEmpty ?? false) || step.iconKey != null)
                  chip,
                const SizedBox(height: 6),
                Text(step.instructionShort, style: t.titleMedium?.copyWith(height: 1.35)),
                if (step.instructionDetail?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(step.instructionDetail!, style: t.bodyMedium?.copyWith(color: c.contentSecondary, height: 1.45)),
                ],
                if (step.timers.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final timer in step.timers)
                        StepTimerButton(timer: timer, recipeId: recipe.id, recipeTitle: recipe.title),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipNote extends StatelessWidget {
  final Recipe recipe;
  final JournalPalette palette;
  final bool highlighted;
  final VoidCallback? onTap;
  const _TipNote({required this.recipe, required this.palette, required this.highlighted, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final tip = recipe.chefTip?.trim() ?? '';
    final icon = getCulinaryIconData(recipe.chefTipIcon ?? 'lightbulb');
    final note = Transform.rotate(
      angle: degToRad(-1.2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: ChefMotion.standard,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            decoration: BoxDecoration(
              color: palette.note,
              borderRadius: BorderRadius.circular(4),
              border: highlighted ? Border.all(color: palette.accent, width: 2) : null,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 8, offset: const Offset(2, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: palette.noteInk),
                    const SizedBox(width: 6),
                    Text(
                      'Chef’s tip',
                      style: t.labelLarge?.copyWith(color: palette.noteInk, fontWeight: FontWeight.w800),
                    ),
                    if (onTap != null) ...[const Spacer(), Icon(Icons.edit_rounded, size: 16, color: palette.noteInk)],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tip.isEmpty ? 'Tap to add a secret, a swap, or a lesson learned.' : tip,
                  style: t.bodyMedium?.copyWith(color: palette.noteInk, fontStyle: FontStyle.italic, height: 1.45),
                ),
              ],
            ),
          ),
          const Positioned(
            top: -8,
            left: 18,
            child: WashiTape(width: 64, height: 16, rotation: -0.12, pattern: WashiTapePattern.dots),
          ),
        ],
      ),
    );
    if (onTap == null) return note;
    return Semantics(
      button: true,
      label: 'Edit chef’s tip',
      child: GestureDetector(onTap: onTap, child: note),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String label;
  final Color color;
  final Widget? trailing;
  const _PageHeader({required this.label, required this.color, this.trailing});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.chefText.labelMedium?.copyWith(
                color: color,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _Folio extends StatelessWidget {
  final int number;
  final String caption;
  const _Folio({required this.number, required this.caption});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    return ExcludeSemantics(
      child: Column(
        children: [
          Text('— $number —', style: t.labelMedium?.copyWith(color: c.contentSecondary)),
          const SizedBox(height: 2),
          Text(
            'Chef’s Kiss · $caption'.toUpperCase(),
            style: t.labelSmall?.copyWith(color: c.contentSecondary, letterSpacing: 1.4),
          ),
        ],
      ),
    );
  }
}
