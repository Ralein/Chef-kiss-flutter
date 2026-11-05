import 'dart:async';
import 'dart:math' as math;

import 'package:app_contracts/app_contracts.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/audio_chime_service.dart';
import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../../app/widgets/kitchen_format.dart';
import '../../../app/widgets/step_timer_button.dart';
import '../../recipe_detail/presentation/widgets/recipe_sections.dart';
import '../../voice/listen_button.dart';
import '../../voice/read_aloud_controller.dart';
import '../../voice/spoken_text.dart';

/// Distraction-free, step-by-step cooking.
///
/// Keeps the screen awake, shares timers with the rest of the app, records
/// progress in a cooking session (so leaving and returning resumes at the
/// same step), and lets you log what you ate when you're done.
class CookModeScreen extends ConsumerStatefulWidget {
  final String recipeId;
  final double? servings;

  const CookModeScreen({super.key, required this.recipeId, this.servings});

  @override
  ConsumerState<CookModeScreen> createState() => _CookModeScreenState();
}

class _CookModeScreenState extends ConsumerState<CookModeScreen> {
  final PageController _pages = PageController();
  int _index = 0;
  bool _finished = false;
  bool _night = false;
  String? _sessionId;
  late final ScreenAwakeService _awake = ref.read(screenAwakeServiceProvider);
  late final CookingSessionRepository _sessions = ref.read(cookingSessionRepositoryProvider);
  late final ReadAloudController _voice = ref.read(readAloudProvider);
  Recipe? _recipe;
  bool _sessionReady = false;
  bool _initialReadDone = false;
  bool _voiceFailureShown = false;

  String get _voicePrefix => 'cook:${widget.recipeId}';
  String _stepSession(int index) => '$_voicePrefix:step:$index';

  /// Set as soon as the toggle is tapped, so the next page turn already
  /// speaks even before the saved preference streams back.
  bool? _autoReadOverride;

  bool get _autoRead =>
      _autoReadOverride ?? (ref.read(voiceSettingsProvider).valueOrNull ?? const VoiceSettings()).readStepsInCookMode;

  @override
  void initState() {
    super.initState();
    _awake.enable();
    _resumeOrStartSession();
  }

  @override
  void dispose() {
    _awake.disable();
    unawaited(_voice.stopIfReadingPrefix(_voicePrefix));
    if (_sessionId != null && !_finished) _sessions.pauseSession(_sessionId!);
    _pages.dispose();
    super.dispose();
  }

  Future<void> _resumeOrStartSession() async {
    final existing = (await _sessions.getSessionByRecipeId(widget.recipeId)).orNull;
    if (!mounted) return;
    if (existing != null) {
      _sessionId = existing.id;
      final resumeAt = math.max(0, existing.activeStepPosition - 1);
      if (resumeAt > 0) {
        setState(() => _index = resumeAt);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pages.hasClients) _pages.jumpToPage(resumeAt);
        });
        ChefToastService.show(context: context, title: 'Picking up at step ${resumeAt + 1}', duration: const Duration(seconds: 2));
      }
      setState(() => _sessionReady = true);
      return;
    }
    final started = await _sessions.startSession(
      profileId: 'default',
      recipeId: widget.recipeId,
      selectedServings: Rational.fromDouble(widget.servings ?? 2, 0.001),
    );
    _sessionId = started.orNull?.id;
    if (mounted) setState(() => _sessionReady = true);
  }

  /// Reads step [index] aloud. Failures are reported once per visit, so a
  /// device without a voice doesn't toast on every page turn.
  Future<void> _readStep(int index) async {
    final recipe = _recipe;
    if (recipe == null || index < 0 || index >= recipe.steps.length) return;
    final step = recipe.steps[index];
    final failure = await _voice.read(_stepSession(index), [
      SpokenSegment(SpokenRecipe.stepId(step), SpokenRecipe.step(step, number: index + 1, total: recipe.steps.length)),
    ]);
    if (failure != null && mounted && !_voiceFailureShown) {
      _voiceFailureShown = true;
      ChefToastService.show(
        context: context,
        title: failure.message,
        description: failure.recoveryAction,
        type: ChefToastType.error,
      );
    }
  }

  Future<void> _toggleAutoRead() async {
    final current = ref.read(voiceSettingsProvider).valueOrNull ?? const VoiceSettings();
    final enable = !_autoRead;
    setState(() => _autoReadOverride = enable);
    await saveVoiceSettings(ref, current.copyWith(readStepsInCookMode: enable));
    if (!mounted) return;
    // No toast: it would cover the step buttons. The toggle's icon and the
    // voice itself are the feedback.
    if (enable) {
      _voiceFailureShown = false;
      unawaited(_readStep(_index));
    } else {
      unawaited(_voice.stopIfReadingPrefix(_voicePrefix));
    }
  }

  void _goTo(int index, int total) {
    if (index < 0 || index >= total) return;
    audioChime.playPageFlip();
    _pages.animateToPage(index, duration: ChefMotion.standard, curve: ChefMotion.easeStandard);
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    if (_sessionId != null) _sessions.updateActiveStep(sessionId: _sessionId!, stepPosition: index + 1);
    if (_autoRead && _initialReadDone) unawaited(_readStep(index));
  }

  void _finish() {
    audioChime.playSuccessFanfare();
    setState(() => _finished = true);
    if (_sessionId != null) _sessions.completeSession(_sessionId!);
    if (_autoRead) {
      final title = _recipe?.title ?? 'your dish';
      unawaited(_voice.say('$_voicePrefix:finish', SpokenText.normalize('Chef’s kiss! Enjoy your $title.')));
    } else {
      unawaited(_voice.stopIfReadingPrefix(_voicePrefix));
    }
  }

  void _close() => context.canPop() ? context.pop() : context.go('/recipe/${widget.recipeId}');

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(singleRecipeProvider(widget.recipeId));
    final theme = _night ? ChefTheme.dark() : Theme.of(context);

    return Theme(
      data: theme,
      child: Builder(builder: (context) {
        return async.when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (e, _) => Scaffold(appBar: AppBar(), body: const ErrorView(message: 'This recipe could not be loaded.')),
          data: (recipe) {
            if (recipe == null) {
              return Scaffold(appBar: AppBar(), body: const ErrorView(title: 'Recipe not found', message: 'It may have been deleted.'));
            }
            return _buildCooking(context, recipe);
          },
        );
      }),
    );
  }

  Widget _buildCooking(BuildContext context, Recipe recipe) {
    final c = context.chefColors;
    final t = context.chefText;
    final steps = recipe.steps;
    final total = steps.length;
    final servings = widget.servings ?? recipe.baseServings.toDouble();
    _recipe = recipe;
    if (_sessionReady && !_initialReadDone) {
      _initialReadDone = true;
      if (_autoRead && total > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_readStep(_index));
        });
      }
    }
    final voiceOn =
        _autoReadOverride ?? (ref.watch(voiceSettingsProvider).valueOrNull ?? const VoiceSettings()).readStepsInCookMode;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _index < total - 1 ? _goTo(_index + 1, total) : _finish(),
        const SingleActivator(LogicalKeyboardKey.space): () => _index < total - 1 ? _goTo(_index + 1, total) : _finish(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _goTo(_index - 1, total),
        const SingleActivator(LogicalKeyboardKey.escape): _close,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(tooltip: 'Exit cook mode', icon: const Icon(Icons.close_rounded), onPressed: _close),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _finished ? 'All done' : (total == 0 ? 'Cook mode' : 'Step ${_index + 1} of $total'),
                  style: t.titleMedium,
                ),
                Text(recipe.title, style: t.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
            actions: [
              IconButton(
                tooltip: voiceOn ? 'Stop reading steps aloud' : 'Read steps aloud',
                isSelected: voiceOn,
                icon: Icon(voiceOn ? Icons.record_voice_over_rounded : Icons.voice_over_off_rounded),
                onPressed: total == 0 ? null : _toggleAutoRead,
              ),
              IconButton(
                tooltip: 'Ingredients',
                icon: const Icon(Icons.format_list_bulleted_rounded),
                onPressed: () => _showIngredients(context, recipe, servings),
              ),
              IconButton(
                tooltip: _night ? 'Light kitchen mode' : 'Night kitchen mode',
                icon: Icon(_night ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                onPressed: () => setState(() => _night = !_night),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(
            child: total == 0
                ? EmptyStateScene(
                    icon: Icons.format_list_numbered_rounded,
                    title: 'No steps yet',
                    message: 'Add the method to this recipe to cook it step by step.',
                    actionLabel: 'Edit recipe',
                    onAction: () => context.pushReplacement('/editor/${recipe.id}'),
                  )
                : _finished
                    ? _FinishView(recipe: recipe, servings: servings, onDone: _close, onAgain: () {
                        setState(() => _finished = false);
                        _goTo(0, total);
                      })
                    : Column(
                        children: [
                          Semantics(
                            label: 'Progress: step ${_index + 1} of $total',
                            child: LinearProgressIndicator(value: (_index + 1) / total, minHeight: 4),
                          ),
                          Expanded(
                            child: PageView.builder(
                              controller: _pages,
                              onPageChanged: _onPageChanged,
                              itemCount: total,
                              itemBuilder: (context, i) => _StepPage(
                                recipe: recipe,
                                step: steps[i],
                                number: i + 1,
                                total: total,
                                servings: servings,
                                voiceSession: _stepSession(i),
                              ),
                            ),
                          ),
                          _NavBar(
                            isFirst: _index == 0,
                            isLast: _index == total - 1,
                            onPrev: () => _goTo(_index - 1, total),
                            onNext: () => _index == total - 1 ? _finish() : _goTo(_index + 1, total),
                            background: c.surfacePaper,
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  void _showIngredients(BuildContext context, Recipe recipe, double servings) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (ctx, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ingredients', style: ctx.chefText.headlineSmall),
                      Text('For ${KitchenFormat.quantity(servings, null)} servings', style: ctx.chefText.bodySmall),
                    ],
                  ),
                ),
                ListenButton(
                  sessionId: '$_voicePrefix:ingredients',
                  script: () => ingredientsScript(recipe, servings: servings),
                  label: 'Read',
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final ing in recipe.ingredients)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                    text: '${ingredientAmount(scaleFor(recipe, ing, servings))}  ',
                    style: ctx.chefText.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ing.displayName, style: ctx.chefText.bodyLarge),
                  if (ing.prepText?.isNotEmpty ?? false)
                    TextSpan(text: ', ${ing.prepText}', style: ctx.chefText.bodyMedium?.copyWith(color: ctx.chefColors.contentSecondary)),
                ])),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepPage extends StatelessWidget {
  final Recipe recipe;
  final RecipeStep step;
  final int number;
  final int total;
  final double servings;
  final String voiceSession;

  const _StepPage({
    required this.recipe,
    required this.step,
    required this.number,
    required this.total,
    required this.servings,
    required this.voiceSession,
  });

  /// Ingredients whose head noun appears in this step's text.
  List<RecipeIngredient> _mentioned() {
    final text = ' ${FoodMatcher.normalizeWords('${step.instructionShort} ${step.instructionDetail ?? ''}').join(' ')} ';
    return recipe.ingredients.where((ing) {
      final words = FoodMatcher.normalizeWords(ing.displayName);
      return words.isNotEmpty && text.contains(' ${words.last} ');
    }).take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final mentioned = _mentioned();
    final temp = step.temperatureC != null
        ? '${step.temperatureC}°C / ${step.temperatureF ?? (step.temperatureC! * 9 / 5 + 32).round()}°F'
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  'STEP $number',
                  if (step.actionKey != null && step.actionKey!.isNotEmpty) step.actionKey!.toUpperCase(),
                ].join(' · '),
                style: t.labelLarge?.copyWith(color: c.accentTomato, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              Semantics(
                header: true,
                child: Text(step.instructionShort, style: t.headlineLarge?.copyWith(height: 1.3)),
              ),
              const SizedBox(height: 12),
              ListenButton(
                sessionId: voiceSession,
                label: 'Read step',
                tonal: true,
                script: () => [
                  SpokenSegment(SpokenRecipe.stepId(step), SpokenRecipe.step(step, number: number, total: total)),
                ],
              ),
              if (step.instructionDetail != null && step.instructionDetail!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(step.instructionDetail!, style: t.bodyLarge?.copyWith(fontSize: 18, color: c.contentSecondary)),
              ],
              if (temp != null) ...[
                const SizedBox(height: 18),
                Chip(avatar: Icon(Icons.thermostat_rounded, color: c.accentTomato), label: Text(temp)),
              ],
              if (mentioned.isNotEmpty) ...[
                const SizedBox(height: 22),
                Text('You’ll need', style: t.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final ing in mentioned)
                      Chip(
                        label: Text(
                          [ingredientAmount(scaleFor(recipe, ing, servings)), ing.displayName]
                              .where((s) => s.isNotEmpty)
                              .join(' '),
                        ),
                      ),
                  ],
                ),
              ],
              if (step.timers.isNotEmpty) ...[
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final timer in step.timers)
                      StepTimerButton(timer: timer, recipeId: recipe.id, recipeTitle: recipe.title, large: true),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final Color background;

  const _NavBar({required this.isFirst, required this.isLast, required this.onPrev, required this.onNext, required this.background});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    return Container(
      decoration: BoxDecoration(color: background, border: Border(top: BorderSide(color: c.outlineSubtle))),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isFirst ? null : onPrev,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: onNext,
                  icon: Icon(isLast ? Icons.check_rounded : Icons.arrow_forward_rounded),
                  label: Text(isLast ? 'Finish' : 'Next step'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinishView extends ConsumerWidget {
  final Recipe recipe;
  final double servings;
  final VoidCallback onDone;
  final VoidCallback onAgain;

  const _FinishView({required this.recipe, required this.servings, required this.onDone, required this.onAgain});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.chefText;
    final c = context.chefColors;
    final report = ref.watch(recipeNutritionProvider(recipe.id));
    final canLog = report != null && report.hasData && report.coverage >= 0.5;

    Future<void> log() async {
      final repo = ref.read(foodLogRepositoryProvider);
      final now = DateTime.now();
      final entry = FoodLogEntry(
        id: '${recipe.id}-${now.microsecondsSinceEpoch}',
        dayKey: dayKeyFor(now),
        mealSlot: MealSlot.forTime(now),
        title: recipe.title,
        source: FoodLogSource.recipe,
        recipeId: recipe.id,
        imagePath: recipe.coverImage,
        nutrition: report!.perServing,
        loggedAt: now.toUtc().millisecondsSinceEpoch,
      );
      final res = await repo.saveEntry(entry);
      ChefToastService.show(
        title: res.isSuccess ? 'Logged to ${entry.mealSlot.label}' : 'Could not log this meal',
        description: res.isSuccess ? '${KitchenFormat.kcal(entry.nutrition.calories)} kcal · 1 serving' : null,
        type: res.isSuccess ? ChefToastType.success : ChefToastType.error,
        actionLabel: res.isSuccess ? 'Undo' : null,
        onAction: res.isSuccess ? () => repo.deleteEntry(entry.id) : null,
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SvgWaxSealWidget(id: 'seal-michelin', size: 96),
              const SizedBox(height: 20),
              Text('Chef’s kiss!', style: t.displaySmall, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'You cooked ${recipe.title}. Enjoy every bite.',
                style: t.bodyLarge?.copyWith(color: c.contentSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              if (canLog) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: log,
                    icon: const Icon(Icons.add_task_rounded),
                    label: Text('Log a serving (${KitchenFormat.kcal(report.perServing.calories)} kcal)'),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(onPressed: onDone, child: const Text('Back to recipe')),
              ),
              TextButton(onPressed: onAgain, child: const Text('Start over')),
            ],
          ),
        ),
      ),
    );
  }
}
