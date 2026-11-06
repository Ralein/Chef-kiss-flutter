import 'dart:math' as math;

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../../app/providers.dart';
import '../../../../app/widgets/kitchen_format.dart';
import '../../../../app/widgets/recipe_image.dart';
import '../../../../app/widgets/step_timer_button.dart';
import '../../../../core/media/recipe_art.dart';
import '../../../library/presentation/widgets/library_books.dart' show kSerifFamily;
import '../../../recipe_detail/presentation/widgets/recipe_sections.dart';
import '../../../voice/spoken_text.dart';
import '../../application/recipe_edits.dart';
import 'scrapbook_layer.dart';
import 'sticker_art.dart';

/// Paper and ink for a recipe's theme in light or dark mode. The journal is
/// deliberately quiet: warm paper, one accent colour, serif headings.
class JournalPalette {
  final Color paper;
  final Color line;
  final Color margin;
  final Color accent;
  final Color binding;
  final Color back;

  const JournalPalette({
    required this.paper,
    required this.line,
    required this.margin,
    required this.accent,
    required this.binding,
    required this.back,
  });

  factory JournalPalette.of(BuildContext context, ScrapbookTheme theme) {
    final c = context.chefColors;
    final accent = theme.accent(c);
    if (c.isDark) {
      return JournalPalette(
        paper: const Color(0xFF23201D),
        line: const Color(0xFF3A3530),
        margin: c.accentTomato.withValues(alpha: 0.4),
        accent: accent,
        binding: Color.lerp(accent, Colors.black, 0.6)!,
        back: const Color(0xFF2E2A26),
      );
    }
    return JournalPalette(
      paper: const Color(0xFFFCF9F4),
      line: const Color(0xFFE7DFD3),
      margin: c.accentTomato.withValues(alpha: 0.35),
      accent: accent,
      binding: Color.lerp(accent, Colors.black, 0.35)!,
      back: const Color(0xFFF0E9DE),
    );
  }

  /// Ink colours were chosen for light paper; lift them on dark paper.
  Color ink(BuildContext context, Color color) =>
      context.chefColors.isDark ? Color.lerp(color, Colors.white, 0.4)! : color;
}

/// Whether the photo caption says something the title doesn't. "Tokyo Shoyu
/// Ramen" under "Tokyo Shoyu Craft Ramen with Ajitsuke Egg" only repeats it,
/// so the page leaves it out (it still shows while decorating, to edit).
bool captionAddsToTitle(Recipe recipe) {
  final caption = recipe.polaroidCaption?.trim().toLowerCase() ?? '';
  if (caption.isEmpty) return false;
  final word = RegExp(r"[\p{L}\p{N}']+", unicode: true);
  final title = {for (final m in word.allMatches(recipe.title.toLowerCase())) m.group(0)};
  return word.allMatches(caption).any((m) => !title.contains(m.group(0)));
}

TextStyle _serif(double size, Color color, {bool italic = false, double height = 1.15}) => TextStyle(
  fontFamily: kSerifFamily,
  fontSize: size,
  color: color,
  height: height,
  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
);

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

/// A folded-down page corner that turns the page when tapped.
class DogEar {
  /// Bottom-left corner turning back (left pages of a spread); otherwise the
  /// bottom-right corner turning forward.
  final bool previous;
  final VoidCallback onTap;
  const DogEar.next(this.onTap) : previous = false;
  const DogEar.previous(this.onTap) : previous = true;
}

/// A sheet of journal paper: background ruling, scrolling content, an
/// optional overlay (the scrapbook layer) and an optional dog-ear corner.
class JournalPaper extends StatefulWidget {
  final ScrapbookTheme theme;
  final bool ruled;
  final double marginX;
  final EdgeInsets padding;
  final Widget child;
  final Widget? overlay;
  final DogEar? dogEar;

  /// Gives [child] at least the page's height (for layouts that centre or
  /// pin content to the bottom).
  final bool fillHeight;

  const JournalPaper({
    super.key,
    required this.theme,
    required this.child,
    this.ruled = false,
    this.marginX = 0,
    this.padding = const EdgeInsets.fromLTRB(22, 22, 22, 28),
    this.overlay,
    this.dogEar,
    this.fillHeight = false,
  });

  @override
  State<JournalPaper> createState() => _JournalPaperState();
}

class _JournalPaperState extends State<JournalPaper> {
  /// The folded corner appears once the page is read to the end (or fits on
  /// screen), so it never sits on top of a button mid-page.
  bool _atEnd = false;

  bool _onMetrics(ScrollMetrics m) {
    final atEnd = m.extentAfter < 12;
    if (atEnd != _atEnd) setState(() => _atEnd = atEnd);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final palette = JournalPalette.of(context, widget.theme);
    final ear = widget.dogEar;
    final padding = widget.padding;
    return ColoredBox(
      color: palette.paper,
      child: Stack(
        children: [
          Positioned.fill(
            child: NotificationListener<ScrollMetricsNotification>(
              onNotification: (n) => _onMetrics(n.metrics),
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) => _onMetrics(n.metrics),
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
                                  ruled: widget.ruled,
                                  line: palette.line,
                                  margin: palette.margin,
                                  marginX: widget.marginX,
                                ),
                              ),
                            ),
                            // Extra room at the bottom so the dog-ear never covers text.
                            Padding(
                              padding: ear == null ? padding : padding.copyWith(bottom: padding.bottom + 28),
                              child: widget.fillHeight
                                  ? ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: (viewport.maxHeight - padding.vertical - (ear == null ? 0 : 28))
                                            .clamp(0, double.infinity),
                                      ),
                                      child: widget.child,
                                    )
                                  : widget.child,
                            ),
                            if (widget.overlay != null) Positioned.fill(child: widget.overlay!),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (ear != null)
            Positioned(
              bottom: 0,
              left: ear.previous ? 0 : null,
              right: ear.previous ? null : 0,
              child: IgnorePointer(
                ignoring: !_atEnd,
                child: AnimatedOpacity(
                  opacity: _atEnd ? 1 : 0,
                  duration: ChefMotion.standard,
                  child: _DogEarButton(ear: ear, palette: palette),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A recipe page: [JournalPaper] plus the scrapbook layer for this side's
/// stickers and tape.
class JournalPageFrame extends StatelessWidget {
  final Recipe recipe;
  final String side;
  final JournalPageActions actions;
  final bool ruled;
  final double marginX;
  final EdgeInsets padding;
  final DogEar? dogEar;
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
    this.dogEar,
  });

  @override
  Widget build(BuildContext context) {
    final stickers = recipe.stickers.where((s) => (s.pageSide == 'right') == (side == 'right')).toList();
    final tapes = recipe.washiTapes.where((t) => (t.pageSide == 'right') == (side == 'right')).toList();
    return JournalPaper(
      theme: recipe.theme,
      ruled: ruled,
      marginX: marginX,
      padding: padding,
      dogEar: actions.decorating ? null : dogEar,
      overlay: ScrapbookLayer(
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
      child: child,
    );
  }
}

class _DogEarButton extends StatefulWidget {
  final DogEar ear;
  final JournalPalette palette;
  const _DogEarButton({required this.ear, required this.palette});

  @override
  State<_DogEarButton> createState() => _DogEarButtonState();
}

class _DogEarButtonState extends State<_DogEarButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final fold = _hover ? 38.0 : 26.0;
    return Semantics(
      button: true,
      label: widget.ear.previous ? 'Previous page' : 'Next page',
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.ear.onTap,
          child: SizedBox.square(
            dimension: 56,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: fold),
              duration: ChefMotion.standard,
              curve: ChefMotion.easeStandard,
              builder: (context, size, _) => CustomPaint(
                painter: _DogEarPainter(
                  fold: size,
                  previous: widget.ear.previous,
                  under: widget.palette.binding,
                  flap: Color.lerp(widget.palette.paper, widget.palette.line, 0.65)!,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The page corner folded over along its diagonal: the binding shows where
/// the corner was, and the flap (the back of the paper) lies on the page.
class _DogEarPainter extends CustomPainter {
  final double fold;
  final bool previous;
  final Color under;
  final Color flap;
  _DogEarPainter({required this.fold, required this.previous, required this.under, required this.flap});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, s = fold;
    // Coordinates for the bottom-right corner, mirrored for bottom-left.
    double x(double v) => previous ? w - v : v;
    final corner = Path()
      ..moveTo(x(w - s), h)
      ..lineTo(x(w), h - s)
      ..lineTo(x(w), h)
      ..close();
    final flapPath = Path()
      ..moveTo(x(w - s), h)
      ..lineTo(x(w), h - s)
      ..lineTo(x(w - s), h - s)
      ..close();
    canvas.drawPath(corner, Paint()..color = under);
    canvas.drawShadow(flapPath, Colors.black, 3, false);
    canvas.drawPath(
      flapPath,
      Paint()
        ..shader = LinearGradient(
          begin: previous ? Alignment.bottomLeft : Alignment.bottomRight,
          end: previous ? Alignment.topRight : Alignment.topLeft,
          colors: [flap, Color.lerp(flap, Colors.white, 0.35)!],
        ).createShader(Rect.fromLTWH(previous ? 0 : w - s, h - s, s, s)),
    );
  }

  @override
  bool shouldRepaint(_DogEarPainter old) =>
      old.fold != fold || old.previous != previous || old.under != under || old.flap != flap;
}

/// Plain paper: optional faint ruling (unused by the minimal pages).
class _PaperPainter extends CustomPainter {
  final bool ruled;
  final Color line;
  final Color margin;
  final double marginX;
  _PaperPainter({required this.ruled, required this.line, required this.margin, required this.marginX});

  @override
  void paint(Canvas canvas, Size size) {
    if (!ruled) return;
    final paint = Paint()
      ..color = line
      ..strokeWidth = 1;
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
  }

  @override
  bool shouldRepaint(_PaperPainter old) =>
      old.ruled != ruled || old.line != line || old.margin != margin || old.marginX != marginX;
}

/// A contents title followed by a dot leader that starts where the title's
/// last line ends, so every page number lines up on the right without
/// hiding the page's ruling.
class _LeaderTitle extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color dots;
  const _LeaderTitle({required this.text, required this.style, required this.dots});

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: direction,
          textScaler: scaler,
          maxLines: 2,
          ellipsis: '…',
        )..layout(maxWidth: box.maxWidth);
        return CustomPaint(size: Size(box.maxWidth, painter.height), painter: _LeaderTitlePainter(painter, dots));
      },
    );
  }
}

class _LeaderTitlePainter extends CustomPainter {
  final TextPainter text;
  final Color dots;
  _LeaderTitlePainter(this.text, this.dots);

  @override
  void paint(Canvas canvas, Size size) {
    text.paint(canvas, Offset.zero);
    final lines = text.computeLineMetrics();
    if (lines.isEmpty) return;
    final last = lines.last;
    final paint = Paint()..color = dots;
    final y = last.baseline;
    for (var x = last.left + last.width + 8; x < size.width - 2; x += 6) {
      canvas.drawCircle(Offset(x, y - 1), 1, paint);
    }
  }

  @override
  bool shouldRepaint(_LeaderTitlePainter old) => true;
}

/// A hairline between list rows.
class _Hairline extends StatelessWidget {
  final Color color;
  final double indent;
  const _Hairline({required this.color, this.indent = 0});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: indent),
    child: SizedBox(
      height: 1,
      width: double.infinity,
      child: ColoredBox(color: color),
    ),
  );
}

class _Folio extends StatelessWidget {
  final int number;
  const _Folio({required this.number});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Center(
      child: Text('$number', style: context.chefText.labelSmall?.copyWith(color: context.chefColors.contentSecondary)),
    ),
  );
}

// --- Story page (left) -------------------------------------------------------------

class StoryPage extends ConsumerStatefulWidget {
  final Recipe recipe;
  final int pageNumber;
  final int recipeNumber;
  final JournalPageActions actions;
  final DogEar? dogEar;

  const StoryPage({
    super.key,
    required this.recipe,
    required this.pageNumber,
    required this.recipeNumber,
    required this.actions,
    this.dogEar,
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
    final accent = palette.ink(context, palette.accent);
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
            padding: const EdgeInsets.only(top: 14, bottom: 4),
            child: Text(
              group.toUpperCase(),
              style: t.labelSmall?.copyWith(letterSpacing: 1.4, color: c.contentSecondary),
            ),
          ),
        );
        lastGroup = group;
      }
      if (rows.isNotEmpty && rows.last is _IngredientLine) rows.add(_Hairline(color: palette.line));
      rows.add(
        _IngredientLine(
          ingredient: ing,
          amount: ingredientAmount(scaleFor(recipe, ing, servings.toDouble())),
          checked: _checked.contains(ing.id),
          decorating: actions.decorating,
          palette: palette,
          onToggle: () => setState(() => _checked.contains(ing.id) ? _checked.remove(ing.id) : _checked.add(ing.id)),
          onPickIcon: () => actions.onPickIngredientIcon(recipe, ing),
        ),
      );
    }

    final difficulty = switch (recipe.difficulty) {
      RecipeDifficulty.easy => 'Easy',
      RecipeDifficulty.medium => 'Medium',
      RecipeDifficulty.hard => 'Challenging',
    };

    return JournalPageFrame(
      recipe: recipe,
      side: 'left',
      actions: actions,
      dogEar: widget.dogEar,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'No. ${widget.recipeNumber.toString().padLeft(2, '0')}',
                  style: t.labelMedium?.copyWith(color: c.contentSecondary, letterSpacing: 1.6),
                ),
              ),
              IconButton(
                tooltip: recipe.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                onPressed: () => actions.onToggleFavorite(recipe),
                icon: Icon(
                  recipe.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 20,
                  color: recipe.isFavorite ? c.accentTomato : c.contentSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _Photo(recipe: recipe, decorating: actions.decorating, onEdit: () => actions.onEditPolaroid(recipe)),
          if (actions.decorating ? (recipe.polaroidCaption?.trim().isNotEmpty ?? false) : captionAddsToTitle(recipe)) ...[
            const SizedBox(height: 8),
            Text(
              recipe.polaroidCaption!.trim(),
              textAlign: TextAlign.center,
              style: _serif(14, c.contentSecondary, italic: true),
            ),
          ],
          const SizedBox(height: 22),
          Semantics(header: true, child: Text(recipe.title, style: _serif(28, c.contentPrimary))),
          if (recipe.summary?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Text(recipe.summary!.trim(), style: t.bodyMedium?.copyWith(color: c.contentSecondary, height: 1.5)),
          ],
          if (recipe.moodStamps.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              recipe.moodStamps.take(4).join('  ·  ').toUpperCase(),
              style: t.labelSmall?.copyWith(color: accent, letterSpacing: 1.4, fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            [
              KitchenFormat.minutes(recipe.totalMinutes),
              'Serves ${recipe.baseServings.toDisplayString()}',
              difficulty,
            ].join('  ·  '),
            style: t.labelMedium?.copyWith(color: c.contentSecondary),
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: ChefMotion.standard,
                  style: _serif(21, readingIngredients ? accent : c.contentPrimary),
                  child: const Text('Ingredients'),
                ),
              ),
              ServingsStepper(
                value: servings,
                onChanged: (v) => ref.read(journalServingsProvider(recipe.id).notifier).state = v,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No ingredients yet — add them in the editor.', style: t.bodyMedium),
            )
          else
            ...rows,
          const SizedBox(height: 32),
          _Folio(number: widget.pageNumber),
        ],
      ),
    );
  }
}

/// The recipe photo: clean, rounded, softly lifted off the page.
class _Photo extends StatelessWidget {
  final Recipe recipe;
  final bool decorating;
  final VoidCallback onEdit;
  const _Photo({required this.recipe, required this.decorating, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 14, offset: const Offset(0, 6)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: RecipeImage(
                source: recipe.coverImage,
                theme: recipe.theme,
                semanticLabel: 'Photo of ${recipe.title}',
              ),
            ),
          ),
        ),
        if (decorating)
          Positioned(
            right: 8,
            top: 8,
            child: IconButton.filledTonal(
              tooltip: 'Change photo or caption',
              onPressed: onEdit,
              icon: const Icon(LucideIcons.pencil, size: 16),
            ),
          ),
      ],
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
    final textColor = checked ? c.contentSecondary : c.contentPrimary;
    final icon = Icon(getCulinaryIconData(iconKey), size: 16, color: ink.withValues(alpha: checked ? 0.4 : 0.9));

    return Semantics(
      checked: decorating ? null : checked,
      label:
          '${amount.isEmpty ? '' : '$amount '}${ingredient.displayName}'
          '${ingredient.prepText?.isNotEmpty ?? false ? ', ${ingredient.prepText}' : ''}',
      excludeSemantics: !decorating,
      child: InkWell(
        onTap: decorating ? null : onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: decorating
                    ? IconButton(
                        tooltip: 'Change icon for ${ingredient.displayName}',
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints.tightFor(width: 28, height: 24),
                        onPressed: onPickIcon,
                        icon: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: ink, width: 1.2),
                          ),
                          child: Padding(padding: const EdgeInsets.all(3), child: icon),
                        ),
                      )
                    : Padding(padding: const EdgeInsets.only(top: 2), child: icon),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: ingredient.displayName,
                        style: t.bodyLarge?.copyWith(decoration: strike, color: textColor),
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
              if (amount.isNotEmpty) ...[
                const SizedBox(width: 12),
                Text(
                  amount,
                  style: t.labelLarge?.copyWith(fontWeight: FontWeight.w700, decoration: strike, color: textColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// --- Method page (right) --------------------------------------------------------------

class MethodPage extends ConsumerWidget {
  final Recipe recipe;
  final int pageNumber;
  final JournalPageActions actions;
  final DogEar? dogEar;

  const MethodPage({super.key, required this.recipe, required this.pageNumber, required this.actions, this.dogEar});

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
      dogEar: dogEar,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text('Method', style: _serif(28, c.contentPrimary))),
          const SizedBox(height: 4),
          Text(
            recipe.steps.isEmpty
                ? recipe.title
                : '${recipe.title}  ·  ${recipe.steps.length} step${recipe.steps.length == 1 ? '' : 's'}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.bodySmall?.copyWith(color: c.contentSecondary),
          ),
          const SizedBox(height: 22),
          if (recipe.steps.isEmpty) Text('Add the method in the editor to cook it step by step.', style: t.bodyMedium),
          for (var i = 0; i < recipe.steps.length; i++) ...[
            if (i > 0) _Hairline(color: palette.line, indent: 40),
            _StepEntry(
              recipe: recipe,
              step: recipe.steps[i],
              number: i + 1,
              palette: palette,
              highlighted: reading == SpokenRecipe.stepId(recipe.steps[i]),
              decorating: actions.decorating,
              onPickIcon: () => actions.onPickStepIcon(recipe, recipe.steps[i]),
            ),
          ],
          if (hasTip || actions.decorating) ...[
            const SizedBox(height: 22),
            _TipNote(
              recipe: recipe,
              palette: palette,
              highlighted: reading == 'tip',
              onTap: actions.decorating ? () => actions.onEditTip(recipe) : null,
            ),
          ],
          const SizedBox(height: 32),
          _Folio(number: pageNumber),
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
    final accent = palette.ink(context, palette.accent);
    final ink = palette.ink(context, parseHexColor(step.iconColor) ?? palette.accent);
    final action = step.actionKey?.trim();
    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(getCulinaryIconData(step.iconKey ?? action), size: 13, color: ink),
        if (action != null && action.isNotEmpty) ...[
          const SizedBox(width: 5),
          Text(
            action.toUpperCase(),
            style: t.labelSmall?.copyWith(color: ink, letterSpacing: 1.2, fontWeight: FontWeight.w700),
          ),
        ],
        if (decorating) ...[const SizedBox(width: 5), Icon(LucideIcons.pencil, size: 11, color: ink)],
      ],
    );

    return AnimatedContainer(
      duration: ChefMotion.standard,
      padding: const EdgeInsets.fromLTRB(0, 14, 6, 14),
      decoration: BoxDecoration(
        color: highlighted ? c.yolkSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 40, child: Text(number.toString().padLeft(2, '0'), style: _serif(22, accent, height: 1.05))),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (decorating)
                  InkWell(
                    onTap: onPickIcon,
                    child: Semantics(button: true, label: 'Change icon for step $number', child: label),
                  )
                else if ((action?.isNotEmpty ?? false) || step.iconKey != null)
                  label,
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

/// The chef's tip as a quiet pull quote.
class _TipNote extends StatelessWidget {
  final Recipe recipe;
  final JournalPalette palette;
  final bool highlighted;
  final VoidCallback? onTap;
  const _TipNote({required this.recipe, required this.palette, required this.highlighted, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final accent = palette.ink(context, palette.accent);
    final tip = recipe.chefTip?.trim() ?? '';
    final note = AnimatedContainer(
      duration: ChefMotion.standard,
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
      decoration: BoxDecoration(
        color: highlighted ? c.yolkSoft : Colors.transparent,
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'CHEF’S TIP',
                  style: t.labelSmall?.copyWith(color: accent, letterSpacing: 1.4, fontWeight: FontWeight.w700),
                ),
              ),
              if (onTap != null) Icon(LucideIcons.pencil, size: 14, color: c.contentSecondary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            tip.isEmpty ? 'Tap to add a secret, a swap, or a lesson learned.' : tip,
            style: _serif(17, c.contentPrimary, italic: true, height: 1.4),
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

// --- Front matter ---------------------------------------------------------------------

/// The first page of the journal: an "ex libris" title page.
class BookplatePage extends StatelessWidget {
  final List<Recipe> recipes;
  final DogEar? dogEar;
  const BookplatePage({super.key, required this.recipes, this.dogEar});

  static const theme = ScrapbookTheme.terracottaClassic;

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final palette = JournalPalette.of(context, theme);
    final accent = palette.ink(context, palette.accent);
    final favorites = recipes.where((r) => r.isFavorite).length;
    final first = recipes.isEmpty ? null : recipes.map((r) => r.createdAt).reduce(math.min);
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', //
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final since = first == null || first <= 0
        ? null
        : () {
            final d = DateTime.fromMillisecondsSinceEpoch(first);
            return '${months[d.month - 1]} ${d.year}';
          }();

    return JournalPaper(
      theme: theme,
      dogEar: dogEar,
      fillHeight: true,
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox.shrink(),
          Column(
            children: [
              Text('EX LIBRIS', style: t.labelMedium?.copyWith(color: accent, letterSpacing: 5)),
              const SizedBox(height: 28),
              Semantics(
                header: true,
                child: Text('Recipe Journal', textAlign: TextAlign.center, style: _serif(38, c.contentPrimary)),
              ),
              const SizedBox(height: 10),
              Text(
                'A keepsake of everything you cook',
                textAlign: TextAlign.center,
                style: _serif(16, c.contentSecondary, italic: true),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 140,
                child: Row(
                  children: [
                    Expanded(child: Divider(color: accent.withValues(alpha: 0.35))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(LucideIcons.sparkle, size: 12, color: accent),
                    ),
                    Expanded(child: Divider(color: accent.withValues(alpha: 0.35))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${recipes.length} recipe${recipes.length == 1 ? '' : 's'}  ·  $favorites favorite${favorites == 1 ? '' : 's'}',
                style: t.labelLarge,
              ),
              if (since != null) ...[
                const SizedBox(height: 4),
                Text('Kept since $since', style: t.bodySmall?.copyWith(color: c.contentSecondary)),
              ],
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 28), child: _Folio(number: 1)),
        ],
      ),
    );
  }
}

/// Table of contents: every recipe with its page number.
class ContentsPage extends StatelessWidget {
  final List<Recipe> recipes;
  final ValueChanged<String> onOpen;
  final DogEar? dogEar;
  const ContentsPage({super.key, required this.recipes, required this.onOpen, this.dogEar});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final palette = JournalPalette.of(context, BookplatePage.theme);
    return JournalPaper(
      theme: BookplatePage.theme,
      dogEar: dogEar,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text('Contents', style: _serif(28, c.contentPrimary))),
          const SizedBox(height: 4),
          Text(
            '${recipes.length} recipe${recipes.length == 1 ? '' : 's'} · tap one to open it',
            style: t.bodySmall?.copyWith(color: c.contentSecondary),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < recipes.length; i++)
            Semantics(
              button: true,
              label: '${recipes[i].title}, page ${3 + 2 * i}',
              excludeSemantics: true,
              child: InkWell(
                onTap: () => onOpen(recipes[i].id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          (i + 1).toString().padLeft(2, '0'),
                          style: _serif(17, palette.ink(context, recipes[i].theme.accent(c))),
                        ),
                      ),
                      Expanded(
                        child: _LeaderTitle(text: recipes[i].title, style: t.titleSmall!, dots: palette.line),
                      ),
                      const SizedBox(width: 6),
                      if (recipes[i].isFavorite) ...[
                        Icon(Icons.favorite_rounded, size: 12, color: c.accentTomato),
                        const SizedBox(width: 6),
                      ],
                      Text('p. ${3 + 2 * i}', style: t.labelMedium?.copyWith(color: c.contentSecondary)),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 32),
          const _Folio(number: 2),
        ],
      ),
    );
  }
}
