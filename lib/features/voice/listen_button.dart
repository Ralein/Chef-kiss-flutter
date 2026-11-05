import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../app/chef_toast_service.dart';
import '../../app/providers.dart';
import '../../app/widgets/kitchen_format.dart';
import '../recipe_detail/presentation/widgets/recipe_sections.dart';
import 'spoken_text.dart';

/// The full read-aloud script for a recipe: intro, ingredients scaled to
/// [servings], every step, then the chef's tip.
List<SpokenSegment> recipeScript(Recipe recipe, {required double servings, bool includeIntro = true}) {
  final lines = [
    for (final ing in recipe.ingredients)
      (amount: ingredientAmount(scaleFor(recipe, ing, servings)), name: ing.displayName, prep: ing.prepText),
  ];
  final count = KitchenFormat.quantity(servings, null);
  return [
    if (includeIntro) SpokenSegment(SpokenRecipe.introId, SpokenRecipe.intro(recipe)),
    SpokenSegment(
      SpokenRecipe.ingredientsId,
      SpokenRecipe.ingredients(lines, servings: '$count serving${servings == 1 ? '' : 's'}'),
    ),
    for (var i = 0; i < recipe.steps.length; i++)
      SpokenSegment(
        SpokenRecipe.stepId(recipe.steps[i]),
        SpokenRecipe.step(recipe.steps[i], number: i + 1, total: recipe.steps.length),
      ),
    SpokenSegment('tip', SpokenRecipe.tip(recipe)),
  ];
}

/// Just the ingredient list, for Cook Mode's ingredients sheet.
List<SpokenSegment> ingredientsScript(Recipe recipe, {required double servings}) => recipeScript(
  recipe,
  servings: servings,
  includeIntro: false,
).where((s) => s.id == SpokenRecipe.ingredientsId).toList();

/// Play/stop for one read-aloud session. Shows "Stop" while that session is
/// playing anywhere in the app.
class ListenButton extends ConsumerWidget {
  final String sessionId;
  final List<SpokenSegment> Function() script;
  final String label;
  final String stopLabel;

  /// Icon-only (with tooltip), for toolbars.
  final bool compact;

  /// Tonal filled button instead of outlined.
  final bool tonal;

  const ListenButton({
    super.key,
    required this.sessionId,
    required this.script,
    this.label = 'Listen',
    this.stopLabel = 'Stop',
    this.compact = false,
    this.tonal = false,
  });

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final failure = await ref.read(readAloudProvider).toggle(sessionId, script);
    if (failure != null && context.mounted) {
      ChefToastService.show(
        context: context,
        title: failure.message,
        description: failure.recoveryAction,
        type: ChefToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reading = ref.watch(readAloudProvider.select((c) => c.isReading(sessionId)));
    final icon = AnimatedSwitcher(
      duration: ChefMotion.quick,
      child: reading
          ? const SpeakingWaves(key: ValueKey('waves'))
          : const Icon(Icons.volume_up_rounded, key: ValueKey('speaker')),
    );
    if (compact) {
      return IconButton(
        tooltip: reading ? 'Stop reading' : 'Read aloud',
        isSelected: reading,
        onPressed: () => _toggle(context, ref),
        icon: icon,
      );
    }
    final text = Text(reading ? stopLabel : label);
    return Semantics(
      liveRegion: true,
      child: tonal
          ? FilledButton.tonalIcon(onPressed: () => _toggle(context, ref), icon: icon, label: text)
          : OutlinedButton.icon(onPressed: () => _toggle(context, ref), icon: icon, label: text),
    );
  }
}

/// Three bouncing bars: "the voice is speaking". Static when animations are
/// disabled in accessibility settings.
class SpeakingWaves extends StatefulWidget {
  final double size;
  final Color? color;
  const SpeakingWaves({super.key, this.size = 20, this.color});

  @override
  State<SpeakingWaves> createState() => _SpeakingWavesState();
}

class _SpeakingWavesState extends State<SpeakingWaves> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _c.stop();
      _c.value = 0.5;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? IconTheme.of(context).color ?? context.chefColors.contentPrimary;
    return Semantics(
      label: 'Reading aloud',
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(painter: _WavesPainter(_c.value, color)),
        ),
      ),
    );
  }
}

class _WavesPainter extends CustomPainter {
  final double t;
  final Color color;
  _WavesPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.16;
    const phases = [0.0, 0.33, 0.66];
    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.22 + i * 0.28);
      final wave = (1 - ((t + phases[i]) % 1.0 - 0.5).abs() * 2); // 0..1 triangle
      final h = size.height * (0.3 + 0.55 * wave);
      canvas.drawLine(Offset(x, (size.height - h) / 2), Offset(x, (size.height + h) / 2), paint);
    }
  }

  @override
  bool shouldRepaint(_WavesPainter old) => old.t != t || old.color != color;
}
