import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';
import '../tokens/chef_spacing.dart';
import '../tokens/chef_theme.dart';
import '../tokens/chef_typography.dart';

class IngredientTile extends StatelessWidget {
  final RecipeIngredient ingredient;
  final Rational? scaledQuantity;
  final bool isChecked;
  final ValueChanged<bool?>? onCheckChanged;
  final bool showCheckbox;

  const IngredientTile({
    super.key,
    required this.ingredient,
    this.scaledQuantity,
    this.isChecked = false,
    this.onCheckChanged,
    this.showCheckbox = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    final qty = scaledQuantity ?? ingredient.quantity;
    final qtyString = qty != null
        ? qty.toDisplayString()
        : (ingredient.authoredQuantity ?? '');

    final unitString = (ingredient.unitCode != null &&
            ingredient.unitCode!.isNotEmpty &&
            ingredient.unitCode != 'each')
        ? ingredient.unitCode!
        : '';

    // Semantic label for accessibility
    final semanticLabel =
        '${isChecked ? "Checked, " : ""}$qtyString $unitString ${ingredient.displayName}${ingredient.prepText != null ? ", ${ingredient.prepText}" : ""}';

    return Semantics(
      label: semanticLabel,
      checked: isChecked,
      child: AnimatedContainer(
        duration: ChefMotion.quick,
        margin: const EdgeInsets.only(bottom: ChefSpacing.space2),
        padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space3, vertical: ChefSpacing.space3),
        decoration: BoxDecoration(
          color: isChecked ? colors.surfaceRaised.withValues(alpha: 0.6) : colors.surfacePaper,
          borderRadius: BorderRadius.circular(ChefRadius.tile),
          border: Border.all(
            color: isChecked ? colors.accentHerb.withValues(alpha: 0.4) : colors.outlineSubtle,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            if (showCheckbox)
              Padding(
                padding: const EdgeInsets.only(right: ChefSpacing.space2),
                child: Checkbox(
                  value: isChecked,
                  activeColor: colors.accentHerb,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  onChanged: onCheckChanged,
                ),
              ),

            // Object illustration / fallback icon badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isChecked
                    ? colors.accentHerb.withValues(alpha: 0.15)
                    : colors.accentYolk.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  isChecked ? Icons.check : _getIngredientIcon(ingredient.displayName),
                  size: 20,
                  color: isChecked ? colors.accentHerb : colors.accentYolk,
                ),
              ),
            ),
            const SizedBox(width: ChefSpacing.space3),

            // Ingredient name & prep
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.displayName,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked ? colors.contentSecondary : colors.contentPrimary,
                    ),
                  ),
                  if (ingredient.prepText != null && ingredient.prepText!.isNotEmpty)
                    Text(
                      ingredient.prepText!,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: colors.contentSecondary,
                      ),
                    ),
                ],
              ),
            ),

            // Scaled Quantity & Unit (large tabular numeral)
            if (qtyString.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space2, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(ChefRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      qtyString,
                      style: ChefTypography.numeric(
                        isChecked ? colors.contentSecondary : colors.accentTomato,
                        size: 15,
                        weight: FontWeight.w700,
                      ),
                    ),
                    if (unitString.isNotEmpty) ...[
                      const SizedBox(width: 3),
                      Text(
                        unitString,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          color: colors.contentSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIngredientIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tomato') || lower.contains('pepper') || lower.contains('carrot')) {
      return Icons.spa_outlined;
    }
    if (lower.contains('flour') || lower.contains('sugar') || lower.contains('salt')) {
      return Icons.grain_outlined;
    }
    if (lower.contains('egg') || lower.contains('cheese') || lower.contains('milk') || lower.contains('butter')) {
      return Icons.egg_outlined;
    }
    if (lower.contains('oil') || lower.contains('vinegar') || lower.contains('sauce') || lower.contains('water')) {
      return Icons.water_drop_outlined;
    }
    if (lower.contains('garlic') || lower.contains('onion') || lower.contains('herb') || lower.contains('basil')) {
      return Icons.eco_outlined;
    }
    return Icons.lunch_dining_outlined;
  }
}
