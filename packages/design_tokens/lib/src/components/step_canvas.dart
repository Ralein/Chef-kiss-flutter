import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';
import '../tokens/chef_spacing.dart';
import '../tokens/chef_theme.dart';

class StepCanvas extends StatelessWidget {
  final RecipeStep step;
  final int totalSteps;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onStartTimer;

  const StepCanvas({
    super.key,
    required this.step,
    required this.totalSteps,
    this.isActive = true,
    this.isCompleted = false,
    this.onStartTimer,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    final actionVerb = step.actionKey != null && step.actionKey!.isNotEmpty
        ? step.actionKey!.toUpperCase()
        : 'STEP';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ChefSpacing.space5),
      decoration: BoxDecoration(
        color: colors.surfacePaper,
        borderRadius: BorderRadius.circular(ChefRadius.card),
        border: Border.all(
          color: isActive ? colors.accentTomato.withValues(alpha: 0.5) : colors.outlineSubtle,
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: colors.accentTomato.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Header: Step N of M + Action Verb Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space3, vertical: ChefSpacing.space1),
                decoration: BoxDecoration(
                  color: colors.accentTomato.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(ChefRadius.pill),
                ),
                child: Text(
                  'STEP ${step.position} OF $totalSteps',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.accentTomato,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space3, vertical: ChefSpacing.space1),
                decoration: BoxDecoration(
                  color: colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(ChefRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getActionIcon(step.actionKey), size: 14, color: colors.accentHerb),
                    const SizedBox(width: 4),
                    Text(
                      actionVerb,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.contentPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ChefSpacing.space4),

          // Short primary instruction (large, high contrast)
          Text(
            step.instructionShort,
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),

          // Optional detail instruction
          if (step.instructionDetail != null && step.instructionDetail!.isNotEmpty) ...[
            const SizedBox(height: ChefSpacing.space3),
            Text(
              step.instructionDetail!,
              style: textTheme.bodyLarge?.copyWith(
                color: colors.contentSecondary,
                height: 1.5,
              ),
            ),
          ],

          // Temperature & Safety callouts
          if (step.temperatureC != null || step.safetyJson != null) ...[
            const SizedBox(height: ChefSpacing.space4),
            Row(
              children: [
                if (step.temperatureC != null)
                  Container(
                    margin: const EdgeInsets.only(right: ChefSpacing.space2),
                    padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space3, vertical: ChefSpacing.space1 + 2),
                    decoration: BoxDecoration(
                      color: colors.accentYolk.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(ChefRadius.pill),
                      border: Border.all(color: colors.accentYolk.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thermostat, size: 16, color: colors.accentYolk),
                        const SizedBox(width: 4),
                        Text(
                          '${step.temperatureC}°C / ${step.temperatureF ?? (step.temperatureC! * 9 ~/ 5 + 32)}°F',
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.contentPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (step.safetyJson != null && step.safetyJson!.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space3, vertical: ChefSpacing.space1 + 2),
                      decoration: BoxDecoration(
                        color: colors.stateWarning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(ChefRadius.pill),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 16, color: colors.stateWarning),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              step.safetyJson!,
                              style: textTheme.labelSmall?.copyWith(
                                color: colors.stateWarning,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getActionIcon(String? action) {
    final act = action?.toLowerCase() ?? '';
    if (act.contains('chop') || act.contains('slice') || act.contains('dice') || act.contains('cut')) {
      return Icons.content_cut;
    }
    if (act.contains('sauté') || act.contains('fry') || act.contains('cook') || act.contains('pan')) {
      return Icons.outdoor_grill_outlined;
    }
    if (act.contains('bake') || act.contains('roast') || act.contains('oven')) {
      return Icons.local_fire_department_outlined;
    }
    if (act.contains('boil') || act.contains('simmer')) {
      return Icons.waves;
    }
    if (act.contains('mix') || act.contains('whisk') || act.contains('stir') || act.contains('fold')) {
      return Icons.sync_alt;
    }
    return Icons.check_circle_outline;
  }
}
