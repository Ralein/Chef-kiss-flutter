import 'package:flutter/material.dart';
import '../tokens/chef_spacing.dart';
import '../tokens/chef_theme.dart';

class EmptyStateScene extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateScene({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ChefSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colors.accentTomato.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 44,
                  color: colors.accentTomato,
                ),
              ),
            ),
            const SizedBox(height: ChefSpacing.space4),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ChefSpacing.space2),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.contentSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: ChefSpacing.space5),
              FilledButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accentTomato,
                  foregroundColor: colors.contentInverse,
                  padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space5, vertical: ChefSpacing.space3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ChefRadius.pill),
                  ),
                ),
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
