import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:design_tokens/design_tokens.dart';
import '../../../app/providers.dart';
import '../../../app/audio_chime_service.dart';
import '../../../app/chef_toast_service.dart';

class CookModeScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const CookModeScreen({super.key, required this.recipeId});

  @override
  ConsumerState<CookModeScreen> createState() => _CookModeScreenState();
}

class _CookModeScreenState extends ConsumerState<CookModeScreen> {
  int _currentStepIndex = 0;
  bool _isKitchenDarkMode = false;
  bool _isFinished = false;

  // Step Timers
  final Map<String, int> _activeTimers = {};
  final Set<String> _runningTimers = {};
  Timer? _timerTicker;

  @override
  void initState() {
    super.initState();
    _startTimerTicker();
  }

  @override
  void dispose() {
    _timerTicker?.cancel();
    super.dispose();
  }

  void _startTimerTicker() {
    _timerTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_runningTimers.isEmpty) return;
      setState(() {
        for (final tId in _runningTimers.toList()) {
          if ((_activeTimers[tId] ?? 0) > 0) {
            _activeTimers[tId] = _activeTimers[tId]! - 1;
            if (_activeTimers[tId] == 0) {
              _runningTimers.remove(tId);
              audioChime.playTimerComplete();
              ChefToastService.show(
                context: context,
                title: 'Step Timer Finished!',
                description: 'Check your food and kitchen timing.',
                type: ChefToastType.alarm,
                duration: const Duration(seconds: 6),
              );
            }
          }
        }
      });
    });
  }

  void _toggleTimer(String timerId, int durationSeconds) {
    audioChime.playTap();
    setState(() {
      if (!_activeTimers.containsKey(timerId)) {
        _activeTimers[timerId] = durationSeconds;
      }
      if (_runningTimers.contains(timerId)) {
        _runningTimers.remove(timerId);
      } else {
        _runningTimers.add(timerId);
        audioChime.playTimerStart();
      }
    });
  }

  void _resetTimer(String timerId, int durationSeconds) {
    audioChime.playTap();
    setState(() {
      _runningTimers.remove(timerId);
      _activeTimers[timerId] = durationSeconds;
    });
  }

  void _nextStep(int totalSteps) {
    audioChime.playTap();
    if (_currentStepIndex < totalSteps - 1) {
      setState(() => _currentStepIndex++);
    } else {
      setState(() => _isFinished = true);
      audioChime.playSuccessFanfare();
    }
  }

  void _prevStep() {
    audioChime.playTap();
    if (_currentStepIndex > 0) {
      setState(() => _currentStepIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final recipeAsync = ref.watch(singleRecipeProvider(widget.recipeId));

    return recipeAsync.when(
      data: (recipe) {
        if (recipe == null) {
          return const Scaffold(body: Center(child: Text('Recipe not found.')));
        }

        final steps = recipe.steps;
        final totalSteps = steps.length;
        final currentStep = steps.isNotEmpty ? steps[_currentStepIndex] : null;

        final bgColor = _isKitchenDarkMode ? const Color(0xFF161514) : colors.surfaceCanvas;
        final cardColor = _isKitchenDarkMode ? const Color(0xFF22201E) : Colors.white;
        final textColor = _isKitchenDarkMode ? Colors.white : const Color(0xFF1E1A18);
        final subTextColor = _isKitchenDarkMode ? const Color(0xFFABA196) : colors.contentSecondary;

        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.arrowRight): () => _nextStep(totalSteps),
            const SingleActivator(LogicalKeyboardKey.space): () => _nextStep(totalSteps),
            const SingleActivator(LogicalKeyboardKey.arrowLeft): _prevStep,
            const SingleActivator(LogicalKeyboardKey.escape): () => context.pop(),
          },
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              backgroundColor: cardColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.close, color: textColor),
                onPressed: () {
                  audioChime.playTap();
                  context.pop();
                },
              ),
              title: Text(
                _isFinished ? 'Cooking Completed!' : 'Step ${_currentStepIndex + 1} of $totalSteps',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textColor),
              ),
              actions: [
                IconButton(
                  icon: Icon(_isKitchenDarkMode ? Icons.light_mode : Icons.dark_mode_outlined, color: textColor),
                  tooltip: 'Kitchen Night Mode',
                  onPressed: () {
                    audioChime.playTap();
                    setState(() => _isKitchenDarkMode = !_isKitchenDarkMode);
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(ChefSpacing.space4),
                child: _isFinished
                    ? _buildVictoryScreen(context, recipe, cardColor, textColor, subTextColor)
                    : _buildStepScreen(context, recipe, currentStep, totalSteps, cardColor, textColor, subTextColor),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildStepScreen(
    BuildContext context,
    Recipe recipe,
    RecipeStep? step,
    int totalSteps,
    Color cardColor,
    Color textColor,
    Color subTextColor,
  ) {
    final colors = context.chefColors;
    final progress = (_currentStepIndex + 1) / totalSteps;

    return Column(
      children: [
        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(ChefRadius.pill),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: colors.outlineSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(colors.accentTomato),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: ChefSpacing.space4),

        // Active Step Card
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ChefSpacing.space5),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(ChefRadius.modal),
              border: Border.all(color: const Color(0xFFE8E0D2).withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (step?.actionKey != null && step!.actionKey!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu, size: 18, color: colors.accentTomato),
                      const SizedBox(width: 6),
                      Text(
                        step.actionKey!.toUpperCase(),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: colors.accentTomato, letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: ChefSpacing.space3),
                ],

                Text(
                  step?.instructionShort ?? '',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: ChefSpacing.space3),

                if (step?.instructionDetail != null && step!.instructionDetail!.isNotEmpty)
                  Text(
                    step.instructionDetail!,
                    style: TextStyle(
                      fontSize: 15,
                      color: subTextColor,
                      height: 1.5,
                    ),
                  ),
                const Spacer(),

                // Live Visual Timer Rings
                if (step != null && step.timers.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  ...step.timers.map((timer) {
                    final timeLeft = _activeTimers[timer.id] ?? timer.durationSeconds;
                    final isRunning = _runningTimers.contains(timer.id);
                    final timerProgress = timer.durationSeconds > 0 ? (timeLeft / timer.durationSeconds) : 0.0;

                    final mins = timeLeft ~/ 60;
                    final secs = timeLeft % 60;
                    final timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isRunning ? colors.accentTomato.withValues(alpha: 0.12) : colors.surfaceRaised,
                        borderRadius: BorderRadius.circular(ChefRadius.card),
                        border: Border.all(color: isRunning ? colors.accentTomato : colors.outlineSubtle),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CircularProgressIndicator(
                                  value: timerProgress,
                                  strokeWidth: 3,
                                  backgroundColor: colors.outlineSubtle,
                                  valueColor: AlwaysStoppedAnimation<Color>(colors.accentTomato),
                                ),
                                Center(
                                  child: Icon(Icons.timer_outlined, size: 16, color: colors.accentTomato),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(timer.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                                Text(timeStr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: colors.accentTomato)),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isRunning ? const Color(0xFFC7382B) : colors.accentTomato,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ChefRadius.pill)),
                            ),
                            icon: Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 16),
                            label: Text(isRunning ? 'Pause' : 'Start'),
                            onPressed: () => _toggleTimer(timer.id, timer.durationSeconds),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 18),
                            onPressed: () => _resetTimer(timer.id, timer.durationSeconds),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: ChefSpacing.space4),

        // Step Navigation Bar
        Row(
          children: [
            if (_currentStepIndex > 0)
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: colors.outlineSubtle),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ChefRadius.card)),
                  ),
                  icon: const Icon(Icons.arrow_back_ios, size: 14),
                  label: const Text('Previous Step', style: TextStyle(fontWeight: FontWeight.w800)),
                  onPressed: _prevStep,
                ),
              ),
            if (_currentStepIndex > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accentTomato,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ChefRadius.card)),
                ),
                icon: Icon(_currentStepIndex == totalSteps - 1 ? Icons.check_circle : Icons.arrow_forward_ios, size: 16),
                label: Text(
                  _currentStepIndex == totalSteps - 1 ? 'Finish & Celebrate' : 'Next Step',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                onPressed: () => _nextStep(totalSteps),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVictoryScreen(
    BuildContext context,
    Recipe recipe,
    Color cardColor,
    Color textColor,
    Color subTextColor,
  ) {
    final colors = context.chefColors;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(ChefSpacing.space6),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(ChefRadius.modal),
          border: Border.all(color: colors.outlineSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SvgWaxSealWidget(id: 'seal-chef-kiss', size: 80),
            const SizedBox(height: ChefSpacing.space4),
            Text(
              "Chef's Kiss! Bon Appétit",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'You successfully cooked "${recipe.title}".',
              style: TextStyle(fontSize: 14, color: subTextColor, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ChefSpacing.space5),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accentTomato,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ChefRadius.pill)),
              ),
              icon: const Icon(Icons.menu_book, size: 18),
              label: const Text('Return to Cookbook Journal', style: TextStyle(fontWeight: FontWeight.w900)),
              onPressed: () {
                audioChime.playTap();
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
