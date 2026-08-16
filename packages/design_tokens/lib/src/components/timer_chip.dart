import 'package:flutter/material.dart';
import 'package:recipe_domain/recipe_domain.dart';
import '../tokens/chef_spacing.dart';
import '../tokens/chef_theme.dart';
import '../tokens/chef_typography.dart';

class TimerChip extends StatelessWidget {
  final String label;
  final int remainingSeconds;
  final int totalSeconds;
  final SessionTimerStatus status;
  final VoidCallback? onTap;
  final VoidCallback? onReset;

  const TimerChip({
    super.key,
    required this.label,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.status = SessionTimerStatus.idle,
    this.onTap,
    this.onReset,
  });

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    Color bg;
    Color fg;
    Color border;

    switch (status) {
      case SessionTimerStatus.running:
        bg = colors.accentTomato.withValues(alpha: 0.12);
        fg = colors.accentTomato;
        border = colors.accentTomato;
        break;
      case SessionTimerStatus.expired:
        bg = colors.stateDanger.withValues(alpha: 0.15);
        fg = colors.stateDanger;
        border = colors.stateDanger;
        break;
      case SessionTimerStatus.paused:
        bg = colors.accentYolk.withValues(alpha: 0.12);
        fg = colors.accentYolk;
        border = colors.accentYolk;
        break;
      case SessionTimerStatus.acknowledged:
        bg = colors.accentHerb.withValues(alpha: 0.12);
        fg = colors.accentHerb;
        border = colors.accentHerb;
        break;
      case SessionTimerStatus.idle:
        bg = colors.surfaceRaised;
        fg = colors.contentPrimary;
        border = colors.outlineSubtle;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ChefRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space3, vertical: ChefSpacing.space2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(ChefRadius.pill),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                status == SessionTimerStatus.running
                    ? Icons.timer
                    : (status == SessionTimerStatus.expired ? Icons.alarm_on : Icons.timer_outlined),
                size: 18,
                color: fg,
              ),
              const SizedBox(width: ChefSpacing.space2),
              if (label.isNotEmpty) ...[
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: ChefSpacing.space1),
                Text('•', style: TextStyle(color: fg)),
                const SizedBox(width: ChefSpacing.space1),
              ],
              Text(
                _formatTime(remainingSeconds > 0 ? remainingSeconds : totalSeconds),
                style: ChefTypography.numeric(
                  fg,
                  size: 15,
                  weight: FontWeight.w700,
                ),
              ),
              if (status == SessionTimerStatus.expired) ...[
                const SizedBox(width: ChefSpacing.space1),
                Text(
                  'DONE',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.stateDanger,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
