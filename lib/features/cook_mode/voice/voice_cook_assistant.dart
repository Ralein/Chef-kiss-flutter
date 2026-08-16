import 'dart:async';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';

enum VoiceCookAction {
  nextStep,
  previousStep,
  repeatInstruction,
  startTimer,
  pauseTimer,
  readIngredients,
  finishCooking,
  unknown;
}

class VoiceCommandParser {
  const VoiceCommandParser();

  VoiceCookAction parse(String rawUtterance) {
    final clean = rawUtterance
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s]'), '');

    if (clean.isEmpty) return VoiceCookAction.unknown;

    // Next step triggers
    if (clean == 'next' ||
        clean == 'next step' ||
        clean == 'continue' ||
        clean == 'go forward' ||
        clean == 'forward' ||
        clean == 'done with step') {
      return VoiceCookAction.nextStep;
    }

    // Previous step triggers
    if (clean == 'back' ||
        clean == 'previous' ||
        clean == 'previous step' ||
        clean == 'go back' ||
        clean == 'last step') {
      return VoiceCookAction.previousStep;
    }

    // Repeat triggers
    if (clean == 'repeat' ||
        clean == 'repeat step' ||
        clean == 'say again' ||
        clean == 'read again' ||
        clean == 'again' ||
        clean == 'what did you say') {
      return VoiceCookAction.repeatInstruction;
    }

    // Timer triggers
    if (clean == 'start timer' ||
        clean == 'start timers' ||
        clean == 'timer start' ||
        clean == 'begin timer') {
      return VoiceCookAction.startTimer;
    }

    if (clean == 'pause timer' ||
        clean == 'stop timer' ||
        clean == 'timer pause' ||
        clean == 'cancel timer') {
      return VoiceCookAction.pauseTimer;
    }

    // Ingredients triggers
    if (clean == 'ingredients' ||
        clean == 'read ingredients' ||
        clean == 'what are the ingredients' ||
        clean == 'list ingredients') {
      return VoiceCookAction.readIngredients;
    }

    // Finish triggers
    if (clean == 'finish' ||
        clean == 'finish cooking' ||
        clean == 'all done' ||
        clean == 'complete recipe') {
      return VoiceCookAction.finishCooking;
    }

    return VoiceCookAction.unknown;
  }
}

class VoiceCookAssistant {
  final SpeechOutputService _tts;
  final SpeechCommandService _speechCommands;
  final AppLogger _logger;
  final VoiceCommandParser _parser;

  bool _isSessionActive = false;

  VoiceCookAssistant({
    required SpeechOutputService tts,
    required SpeechCommandService speechCommands,
    required AppLogger logger,
    VoiceCommandParser parser = const VoiceCommandParser(),
  })  : _tts = tts,
        _speechCommands = speechCommands,
        _logger = logger,
        _parser = parser;

  bool get isListening => _speechCommands.isListening;
  bool get isSpeaking => _tts.isSpeaking;
  bool get isSessionActive => _isSessionActive;

  /// Starts the hands-free voice cooking assistant loop
  Future<Result<void, AppFailure>> startVoiceSession({
    required void Function(VoiceCookAction action) onAction,
    required void Function(String? error) onError,
  }) async {
    _isSessionActive = true;
    _logger.info('Starting voice cook assistant session', feature: 'cook_voice');

    final res = await _speechCommands.startListening(
      onCommand: (rawText) {
        final action = _parser.parse(rawText);
        _logger.debug('Voice assistant parsed "$rawText" -> $action', feature: 'cook_voice');
        onAction(action);
      },
      onError: (err) {
        _logger.warning('Voice assistant recognition error: $err', feature: 'cook_voice');
        onError(err);
      },
    );

    return res;
  }

  /// Stops voice listening and any ongoing TTS output
  Future<Result<void, AppFailure>> stopVoiceSession() async {
    _isSessionActive = false;
    _logger.info('Stopping voice cook assistant session', feature: 'cook_voice');
    await _tts.stop();
    return _speechCommands.stopListening();
  }

  /// Narrates a specific recipe step instruction
  Future<Result<void, AppFailure>> speakStep(
    RecipeStep step, {
    int? stepIndex,
    int? totalSteps,
  }) async {
    final prefix = (stepIndex != null && totalSteps != null)
        ? 'Step $stepIndex of $totalSteps. '
        : (stepIndex != null ? 'Step $stepIndex. ' : '');

    final spokenText = (step.spokenInstruction != null && step.spokenInstruction!.isNotEmpty)
        ? step.spokenInstruction!
        : (step.instructionDetail ?? step.instructionShort);

    final fullSpeech = '$prefix$spokenText';
    return _tts.speak(fullSpeech);
  }

  /// Narrates all ingredients for the current recipe
  Future<Result<void, AppFailure>> speakIngredients(List<RecipeIngredient> ingredients) async {
    if (ingredients.isEmpty) {
      return _tts.speak('No ingredients listed for this recipe.');
    }

    final buffer = StringBuffer('Here are the ingredients: ');
    for (var i = 0; i < ingredients.length; i++) {
      final ing = ingredients[i];
      final qtyStr = ing.quantity != null ? '${ing.quantity!.toDisplayString()} ' : '';
      final unitStr = (ing.unitCode != null && ing.unitCode!.isNotEmpty) ? '${ing.unitCode} ' : '';
      buffer.write('$qtyStr$unitStr${ing.displayName}. ');
    }

    return _tts.speak(buffer.toString().trim());
  }

  /// Speaks a generic announcement (e.g. "Timer finished!")
  Future<Result<void, AppFailure>> speakMessage(String message) async {
    return _tts.speak(message);
  }
}
