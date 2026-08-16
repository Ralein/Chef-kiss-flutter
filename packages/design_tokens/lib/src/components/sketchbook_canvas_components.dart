import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';
import '../tokens/chef_spacing.dart';
import '../tokens/chef_theme.dart';
import 'sketchbook_decorations.dart';

/// A decorative spiral binding strip to give pages the feel of an authentic artist sketchbook
class SpiralNotebookHeader extends StatelessWidget {
  final int holeCount;

  const SpiralNotebookHeader({super.key, this.holeCount = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(holeCount, (index) {
          return Container(
            width: 14,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF4A443F).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF2C2623).withValues(alpha: 0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 6,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2623),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// An illustrated action step card with minimal text and rich action visuals
class VisualActionStepCard extends StatelessWidget {
  final RecipeStep step;
  final int totalSteps;
  final bool isCookMode;
  final VoidCallback? onStartTimer;

  const VisualActionStepCard({
    super.key,
    required this.step,
    required this.totalSteps,
    this.isCookMode = false,
    this.onStartTimer,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    final actionVerb = step.actionKey != null && step.actionKey!.isNotEmpty
        ? step.actionKey!.toUpperCase()
        : 'STEP';

    final actionIcon = _getActionIcon(step.actionKey);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfacePaper,
        borderRadius: BorderRadius.circular(ChefRadius.card),
        border: Border.all(color: colors.outlineSubtle, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Corner washi tape
          Positioned(
            top: -4,
            left: 24,
            child: WashiTape(
              width: 48,
              height: 12,
              rotation: -0.05,
              color: colors.accentHerb.withValues(alpha: 0.6),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(ChefSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step header: Number + Action Verb Stamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space3, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.accentTomato.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(ChefRadius.pill),
                      ),
                      child: Text(
                        'STEP ${step.position} OF $totalSteps',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: colors.accentTomato,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    DoodleStamp(
                      label: actionVerb,
                      icon: actionIcon,
                      color: colors.accentHerb,
                    ),
                  ],
                ),
                const SizedBox(height: ChefSpacing.space3),

                // Main instruction
                Text(
                  step.instructionShort,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    fontSize: isCookMode ? 20 : 16,
                  ),
                ),

                if (step.instructionDetail != null &&
                    step.instructionDetail!.isNotEmpty &&
                    step.instructionDetail != step.instructionShort) ...[
                  const SizedBox(height: ChefSpacing.space2),
                  Container(
                    padding: const EdgeInsets.all(ChefSpacing.space2 + 2),
                    decoration: BoxDecoration(
                      color: colors.surfaceRaised.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(ChefRadius.tile),
                      border: Border.all(color: colors.outlineSubtle.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline, size: 16, color: colors.accentYolk),
                        const SizedBox(width: ChefSpacing.space2),
                        Expanded(
                          child: Text(
                            step.instructionDetail!,
                            style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Timers Row
                if (step.timers.isNotEmpty) ...[
                  const SizedBox(height: ChefSpacing.space3),
                  Wrap(
                    spacing: ChefSpacing.space2,
                    runSpacing: ChefSpacing.space2,
                    children: step.timers.map((timer) {
                      return FilledButton.tonalIcon(
                        icon: const Icon(Icons.timer_outlined, size: 16),
                        label: Text(
                          '${timer.label} (${timer.durationSeconds ~/ 60}m)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space3, vertical: 6),
                          backgroundColor: colors.accentTomato.withValues(alpha: 0.12),
                          foregroundColor: colors.accentTomato,
                        ),
                        onPressed: onStartTimer,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(String? actionKey) {
    if (actionKey == null) return Icons.restaurant;
    final k = actionKey.toLowerCase();
    if (k.contains('sauté') || k.contains('saute') || k.contains('fry')) return Icons.fireplace;
    if (k.contains('bake') || k.contains('roast') || k.contains('oven')) return Icons.outdoor_grill;
    if (k.contains('whisk') || k.contains('mix') || k.contains('blend')) return Icons.blender_outlined;
    if (k.contains('knead') || k.contains('roll') || k.contains('dough')) return Icons.pan_tool_outlined;
    if (k.contains('simmer') || k.contains('boil') || k.contains('soup')) return Icons.soup_kitchen;
    if (k.contains('slice') || k.contains('chop') || k.contains('dice')) return Icons.content_cut;
    if (k.contains('season') || k.contains('salt') || k.contains('garnish')) return Icons.grain;
    if (k.contains('fold') || k.contains('layer')) return Icons.layers_outlined;
    return Icons.lunch_dining_outlined;
  }
}
