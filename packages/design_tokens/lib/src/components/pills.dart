import 'package:flutter/material.dart';
import '../tokens/chef_spacing.dart';
import '../tokens/chef_theme.dart';

class TagPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const TagPill({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    final bg = isSelected ? colors.accentTomato : colors.surfaceRaised;
    final fg = isSelected ? colors.contentInverse : colors.contentPrimary;
    final border = isSelected ? colors.accentTomato : colors.outlineSubtle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ChefRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space3, vertical: ChefSpacing.space1 + 2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(ChefRadius.pill),
            border: Border.all(color: border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: fg),
                const SizedBox(width: ChefSpacing.space1),
              ],
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ToolPill extends StatelessWidget {
  final String displayName;
  final int quantity;

  const ToolPill({
    super.key,
    required this.displayName,
    this.quantity = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space3, vertical: ChefSpacing.space1 + 2),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(ChefRadius.pill),
        border: Border.all(color: colors.outlineSubtle, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.kitchen_outlined, size: 14, color: colors.contentSecondary),
          const SizedBox(width: ChefSpacing.space1),
          Text(
            quantity > 1 ? '$quantity× $displayName' : displayName,
            style: textTheme.labelSmall?.copyWith(color: colors.contentPrimary),
          ),
        ],
      ),
    );
  }
}

class ProvenanceBadge extends StatelessWidget {
  final String origin;
  final String? versionText;

  const ProvenanceBadge({
    super.key,
    required this.origin,
    this.versionText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    Color badgeColor = colors.accentHerb;
    String displayOrigin = 'Manual';

    switch (origin.toLowerCase()) {
      case 'curated':
        badgeColor = colors.accentTomato;
        displayOrigin = 'Curated';
        break;
      case 'imported':
        badgeColor = colors.accentYolk;
        displayOrigin = 'Imported';
        break;
      case 'ai_proposed':
        badgeColor = colors.accentYolk;
        displayOrigin = 'AI Draft';
        break;
      case 'user_edited':
        badgeColor = colors.accentHerb;
        displayOrigin = 'Edited';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space2 + 2, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(ChefRadius.pill),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        versionText != null ? '$displayOrigin • $versionText' : displayOrigin,
        style: textTheme.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
