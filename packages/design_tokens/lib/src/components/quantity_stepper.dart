import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';
import '../tokens/chef_spacing.dart';
import '../tokens/chef_theme.dart';
import '../tokens/chef_typography.dart';

class QuantityStepper extends StatelessWidget {
  final Rational value;
  final ValueChanged<Rational> onChanged;
  final Rational min;
  final Rational max;
  final Rational step;
  final String label;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = Rational.half,
    this.max = const Rational.constant(32),
    this.step = Rational.one,
    this.label = 'Servings',
  });

  bool get canDecrement => (value - step) >= min;
  bool get canIncrement => (value + step) <= max;

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    return Semantics(
      label: '$label: ${value.toSpokenString()}',
      value: value.toDisplayString(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space2, vertical: ChefSpacing.space1),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(ChefRadius.pill),
          border: Border.all(color: colors.outlineSubtle, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decrement button
            IconButton(
              icon: const Icon(Icons.remove, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              color: canDecrement ? colors.contentPrimary : colors.contentSecondary.withValues(alpha: 0.4),
              onPressed: canDecrement
                  ? () {
                      final next = value - step;
                      if (next >= min) onChanged(next);
                    }
                  : null,
              tooltip: 'Decrease $label',
            ),

            // Number display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value.toDisplayString(),
                    style: ChefTypography.numeric(
                      colors.accentTomato,
                      size: 17,
                      weight: FontWeight.w700,
                    ),
                  ),
                  if (label.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.contentSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Increment button
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              color: canIncrement ? colors.contentPrimary : colors.contentSecondary.withValues(alpha: 0.4),
              onPressed: canIncrement
                  ? () {
                      final next = value + step;
                      if (next <= max) onChanged(next);
                    }
                  : null,
              tooltip: 'Increase $label',
            ),
          ],
        ),
      ),
    );
  }
}
