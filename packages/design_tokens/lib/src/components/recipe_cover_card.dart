import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';
import '../tokens/chef_spacing.dart';
import '../tokens/chef_theme.dart';
import 'pills.dart';
import 'sketchbook_decorations.dart';

class RecipeCoverCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isCompact;

  const RecipeCoverCard({
    super.key,
    required this.recipe,
    this.onTap,
    this.onFavoriteToggle,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    // Pick visual accent from template/title hash for delightful variation
    final accents = [colors.accentTomato, colors.accentHerb, colors.accentYolk];
    final cardAccent = accents[recipe.title.hashCode.abs() % accents.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ChefRadius.card),
        child: Ink(
          decoration: BoxDecoration(
            color: colors.surfacePaper,
            borderRadius: BorderRadius.circular(ChefRadius.card),
            border: Border.all(color: colors.outlineSubtle, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero cover region
              Stack(
                children: [
                  Container(
                    height: isCompact ? 130 : 165,
                    decoration: BoxDecoration(
                      color: cardAccent.withValues(alpha: 0.12),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(ChefRadius.card),
                        topRight: Radius.circular(ChefRadius.card),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildFallbackHero(cardAccent, isCompact, recipe, textTheme),
                  ),

                  // Washi Tape accent in top-left
                  const Positioned(
                    top: -4,
                    left: 20,
                    child: WashiTape(width: 50, height: 14, rotation: -0.06),
                  ),

                  // Provenance / Curated tag on top-left below tape
                  Positioned(
                    top: ChefSpacing.space3,
                    left: ChefSpacing.space3,
                    child: ProvenanceBadge(
                      origin: recipe.origin.toDbString(),
                    ),
                  ),

                  // Favorite Heart button on top-right with parchment circle background
                  Positioned(
                    top: ChefSpacing.space2,
                    right: ChefSpacing.space2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surfacePaper.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: recipe.isFavorite ? colors.accentTomato : colors.contentSecondary,
                          size: 20,
                        ),
                        onPressed: onFavoriteToggle,
                        tooltip: recipe.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                      ),
                    ),
                  ),
                ],
              ),

              // Content info
              Padding(
                padding: const EdgeInsets.all(ChefSpacing.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: isCompact ? 15 : 17,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (recipe.summary != null && recipe.summary!.isNotEmpty) ...[
                      const SizedBox(height: ChefSpacing.space1),
                      Text(
                        recipe.summary!,
                        style: textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: ChefSpacing.space3),

                    // Meta chips row: Time, Servings, Difficulty
                    Wrap(
                      spacing: ChefSpacing.space2,
                      runSpacing: ChefSpacing.space1,
                      children: [
                        if (recipe.totalMinutes > 0)
                          _buildMetaChip(
                            context,
                            Icons.timer_outlined,
                            '${recipe.totalMinutes}m',
                          ),
                        _buildMetaChip(
                          context,
                          Icons.people_outline,
                          '${recipe.baseServings.toDisplayString()} serv',
                        ),
                        _buildMetaChip(
                          context,
                          Icons.speed,
                          recipe.difficulty.name.toUpperCase(),
                        ),
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

  Widget _buildMetaChip(BuildContext context, IconData icon, String text) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space2, vertical: 2),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(ChefRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.contentSecondary),
          const SizedBox(width: 3),
          Text(
            text,
            style: textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackHero(Color cardAccent, bool isCompact, Recipe recipe, dynamic textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(recipe),
            size: isCompact ? 40 : 54,
            color: cardAccent,
          ),
          const SizedBox(height: ChefSpacing.space1),
          Text(
            recipe.ingredients.length > 3
                ? '${recipe.ingredients.length} ingredients'
                : 'Simple meal',
            style: textTheme.labelSmall?.copyWith(
              color: cardAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(Recipe recipe) {
    final title = recipe.title.toLowerCase();
    if (title.contains('pasta') || title.contains('noodle')) return Icons.ramen_dining;
    if (title.contains('bread') || title.contains('toast') || title.contains('bake')) return Icons.bakery_dining;
    if (title.contains('soup') || title.contains('stew')) return Icons.soup_kitchen;
    if (title.contains('salad') || title.contains('herb')) return Icons.eco;
    if (title.contains('egg') || title.contains('shakshuka')) return Icons.egg_alt;
    return Icons.restaurant;
  }
}
