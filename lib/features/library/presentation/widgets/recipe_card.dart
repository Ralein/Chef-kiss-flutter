import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../../app/widgets/kitchen_format.dart';
import '../../../../app/widgets/recipe_image.dart';
import '../../../nutrition/presentation/recipe_insights.dart';

/// Library grid card. Sizes itself to its content, so it never overflows at
/// large accessibility text sizes.
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onLongPress;

  const RecipeCard({super.key, required this.recipe, required this.onTap, this.onToggleFavorite, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final kcal = RecipeInsights.kcalPerServing(recipe);
    final servings = recipe.baseServings.toDisplayString();

    return Semantics(
      button: true,
      label: '${recipe.title}. ${KitchenFormat.minutes(recipe.totalMinutes)}, serves $servings'
          '${kcal != null ? ', about ${kcal.round()} calories per serving' : ''}'
          '${recipe.isFavorite ? ', favorite' : ''}',
      excludeSemantics: true,
      child: Material(
        color: c.surfacePaper,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ChefRadius.tile),
          side: BorderSide(color: c.outlineSubtle),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RecipeImage(source: recipe.coverImage, theme: recipe.theme),
                    if (onToggleFavorite != null)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _FavoriteButton(isFavorite: recipe.isFavorite, onPressed: onToggleFavorite!),
                      ),
                    if (recipe.status == RecipeStatus.draft)
                      Positioned(
                        left: 10,
                        top: 10,
                        child: _Badge(label: 'Draft', background: c.surfacePaper.withValues(alpha: 0.92)),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.title, style: t.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (recipe.summary != null && recipe.summary!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        recipe.summary!,
                        style: t.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _Meta(icon: LucideIcons.clock, text: KitchenFormat.minutes(recipe.totalMinutes)),
                        _Meta(icon: LucideIcons.users, text: servings),
                        if (kcal != null) _Meta(icon: LucideIcons.flame, text: '${kcal.round()} kcal'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: c.contentSecondary),
        const SizedBox(width: 5),
        Text(text, style: context.chefText.labelMedium?.copyWith(color: c.contentSecondary)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color background;
  const _Badge({required this.label, required this.background});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(ChefRadius.pill)),
        child: Text(label, style: context.chefText.labelSmall?.copyWith(color: context.chefColors.contentPrimary)),
      );
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;
  const _FavoriteButton({required this.isFavorite, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    return Material(
      color: c.surfacePaper.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
        onPressed: onPressed,
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? c.accentTomato : c.contentSecondary,
        ),
      ),
    );
  }
}

/// Responsive, overflow-proof grid: rows of naturally-sized cards.
class RecipeGrid extends StatelessWidget {
  final List<Recipe> recipes;
  final void Function(Recipe) onOpen;
  final void Function(Recipe)? onToggleFavorite;
  final void Function(Recipe)? onLongPress;

  const RecipeGrid({super.key, required this.recipes, required this.onOpen, this.onToggleFavorite, this.onLongPress});

  static int columnsFor(double width) => (width / 320).floor().clamp(1, 4);

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(builder: (context, constraints) {
      final columns = columnsFor(constraints.crossAxisExtent);
      final rows = (recipes.length / columns).ceil();
      return SliverList.separated(
        itemCount: rows,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, row) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var col = 0; col < columns; col++) ...[
                if (col > 0) const SizedBox(width: 16),
                Expanded(
                  child: row * columns + col < recipes.length
                      ? RecipeCard(
                          key: ValueKey(recipes[row * columns + col].id),
                          recipe: recipes[row * columns + col],
                          onTap: () => onOpen(recipes[row * columns + col]),
                          onToggleFavorite: onToggleFavorite == null
                              ? null
                              : () => onToggleFavorite!(recipes[row * columns + col]),
                          onLongPress: onLongPress == null ? null : () => onLongPress!(recipes[row * columns + col]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          );
        },
      );
    });
  }
}
