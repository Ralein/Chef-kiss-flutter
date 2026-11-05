import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../audio_chime_service.dart';
import '../providers.dart';
import 'kitchen_format.dart';

/// Start/pause/reset control for one step timer, backed by the app-wide
/// [kitchenTimersProvider] so it stays in sync between the recipe page and
/// Cook Mode and keeps running while you navigate.
class StepTimerButton extends ConsumerWidget {
  final StepTimer timer;
  final String recipeId;
  final String recipeTitle;
  final bool large;

  const StepTimerButton({
    super.key,
    required this.timer,
    required this.recipeId,
    required this.recipeTitle,
    this.large = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.chefColors;
    final t = context.chefText;
    final s = ref.watch(kitchenTimersProvider.select((ctl) {
      final kt = ctl[timer.id];
      return (
        started: kt != null,
        running: kt?.isRunning ?? false,
        finished: kt?.finished ?? false,
        remaining: kt?.remainingSeconds(ctl.now) ?? timer.durationSeconds,
      );
    }));
    final controller = ref.read(kitchenTimersProvider);

    void toggle() {
      if (s.running) {
        audioChime.playTap();
      } else {
        audioChime.playTimerStart();
      }
      controller.toggle(
        id: timer.id,
        label: timer.label,
        durationSeconds: timer.durationSeconds,
        recipeId: recipeId,
        recipeTitle: recipeTitle,
      );
    }

    final accent = s.finished ? c.stateSuccess : c.accentTomato;
    final status = s.finished ? 'done' : (s.running ? 'running' : (s.started ? 'paused' : 'not started'));
    final timeText = s.finished ? 'Done' : KitchenFormat.clock(s.remaining);

    return Semantics(
      label: '${timer.label} timer, $timeText, $status',
      child: Container(
        decoration: BoxDecoration(
          color: s.running || s.finished ? c.meterTrack(accent) : c.surfaceRaised,
          borderRadius: BorderRadius.circular(ChefRadius.pill),
          border: Border.all(color: s.running || s.finished ? accent : c.outlineSubtle),
        ),
        padding: EdgeInsets.only(left: large ? 6 : 2, right: large ? 14 : 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: s.running ? 'Pause ${timer.label}' : 'Start ${timer.label}',
              onPressed: toggle,
              iconSize: large ? 30 : 22,
              color: accent,
              icon: Icon(
                s.finished
                    ? Icons.replay_rounded
                    : (s.running ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded),
              ),
            ),
            Flexible(
              child: Text(
                timer.label,
                style: (large ? t.titleSmall : t.labelLarge)?.copyWith(color: c.contentPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeText,
              style: ChefTypography.numeric(c.contentPrimary, size: large ? 22 : 15, weight: FontWeight.w700),
            ),
            if (s.started && !s.finished)
              IconButton(
                tooltip: 'Reset ${timer.label}',
                visualDensity: VisualDensity.compact,
                onPressed: () => controller.reset(timer.id),
                icon: Icon(Icons.restart_alt_rounded, size: large ? 24 : 18, color: c.contentSecondary),
              ),
          ],
        ),
      ),
    );
  }
}
