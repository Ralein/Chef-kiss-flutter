import 'package:flutter/material.dart';
import '../tokens/chef_spacing.dart';
import '../tokens/chef_theme.dart';

class CookControlBar extends StatelessWidget {
  final bool hasPrevious;
  final bool hasNext;
  final bool isLastStep;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onToggleIngredients;
  final VoidCallback? onOpenTimers;
  final VoidCallback? onVoiceTap;
  final bool isListening;

  const CookControlBar({
    super.key,
    required this.hasPrevious,
    required this.hasNext,
    this.isLastStep = false,
    this.onPrevious,
    this.onNext,
    this.onToggleIngredients,
    this.onOpenTimers,
    this.onVoiceTap,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space4, vertical: ChefSpacing.space3),
      decoration: BoxDecoration(
        color: colors.surfacePaper,
        border: Border(top: BorderSide(color: colors.outlineSubtle, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Back Button (large target >= 56 dp)
            SizedBox(
              width: 56,
              height: 56,
              child: IconButton.outlined(
                icon: const Icon(Icons.arrow_back, size: 24),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ChefRadius.card),
                  ),
                  side: BorderSide(color: colors.outlineSubtle),
                ),
                onPressed: hasPrevious ? onPrevious : null,
                tooltip: 'Previous Step',
              ),
            ),
            const SizedBox(width: ChefSpacing.space2),

            // Ingredients Drawer Button
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.format_list_bulleted, size: 20),
                label: const Text('Ingredients'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.contentPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ChefRadius.card),
                  ),
                  side: BorderSide(color: colors.outlineSubtle),
                ),
                onPressed: onToggleIngredients,
              ),
            ),
            const SizedBox(width: ChefSpacing.space2),

            // Voice Button
            if (onVoiceTap != null)
              SizedBox(
                width: 56,
                height: 56,
                child: IconButton.filled(
                  icon: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
                    size: 24,
                    color: isListening ? colors.contentInverse : colors.accentTomato,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isListening ? colors.accentTomato : colors.surfaceRaised,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ChefRadius.card),
                    ),
                  ),
                  onPressed: onVoiceTap,
                  tooltip: isListening ? 'Listening...' : 'Voice Guidance',
                ),
              ),
            const Spacer(),

            // Next / Complete Button (primary large call to action)
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                icon: Icon(isLastStep ? Icons.check_circle : Icons.arrow_forward, size: 22),
                label: Text(
                  isLastStep ? 'Finish Cooking' : 'Next Step',
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.contentInverse,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: isLastStep ? colors.accentHerb : colors.accentTomato,
                  padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ChefRadius.card),
                  ),
                ),
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
