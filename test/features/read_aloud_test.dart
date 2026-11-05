import 'dart:async';

import 'package:app_contracts/app_contracts.dart';
import 'package:chefs_kiss/core/platform/flutter_tts_speech_service.dart';
import 'package:chefs_kiss/features/voice/read_aloud_controller.dart';
import 'package:chefs_kiss/features/voice/spoken_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_domain/recipe_domain.dart';

/// Records what would be spoken; each utterance completes when [release]d,
/// so tests can observe the controller mid-session.
class _ScriptedTts implements SpeechOutputService {
  final spoken = <String>[];
  final _pending = <Completer<void>>[];
  bool fail = false;
  int stops = 0;

  @override
  bool get isSpeaking => _pending.isNotEmpty;

  @override
  Future<Result<void, AppFailure>> speak(String text, {double rate = 1.0}) async {
    if (fail) {
      return const Result.err(CapabilityUnavailableFailure(capability: 'tts', reason: 'test'));
    }
    spoken.add(text);
    final c = Completer<void>();
    _pending.add(c);
    await c.future;
    return const Result.ok(null);
  }

  void release() {
    if (_pending.isNotEmpty) _pending.removeAt(0).complete();
  }

  @override
  Future<Result<void, AppFailure>> stop() async {
    stops++;
    for (final c in _pending) {
      if (!c.isCompleted) c.complete();
    }
    _pending.clear();
    return const Result.ok(null);
  }
}

void main() {
  group('SpokenText.normalize', () {
    final cases = {
      '1 ½ cups flour': '1 and a half cups flour.',
      '½ cup milk': 'half a cup milk.',
      '¼ tsp salt': 'a quarter teaspoon salt.',
      '1 1/2 tbsp butter': '1 and a half tablespoons butter.',
      '1 tbsp oil': '1 tablespoon oil.',
      '200g spaghetti': '200 grams spaghetti.',
      'Bake at 180°C for 10–12 min': 'Bake at 180 degrees Celsius for 10 to 12 minutes.',
      'Heat to 350 °F': 'Heat to 350 degrees Fahrenheit.',
      '~2 cups stock': 'about 2 cups stock.',
      'Salt & pepper': 'Salt and pepper.',
      'Rest 1 h': 'Rest 1 hour.',
      'Add 2 tsp. salt, then stir': 'Add 2 teaspoons salt, then stir.',
      'Cook 5 min.\nServe hot': 'Cook 5 minutes. Serve hot.',
      'Add the can of beans': 'Add the can of beans.',
      'Whisk 2 large eggs': 'Whisk 2 large eggs.',
      'Done! 🍝': 'Done!',
    };
    cases.forEach((input, expected) {
      test(input, () => expect(SpokenText.normalize(input), expected));
    });

    test('blank input stays empty', () => expect(SpokenText.normalize('  \n '), ''));
  });

  group('SpokenRecipe', () {
    const step = RecipeStep(
      id: 's2',
      recipeId: 'r',
      position: 2,
      instructionShort: 'Simmer the sauce',
      instructionDetail: 'Stir every 5 min',
      timers: [StepTimer(id: 't', recipeStepId: 's2', label: 'Sauce', durationSeconds: 900)],
    );

    test('step reads number, text and timers', () {
      expect(
        SpokenRecipe.step(step, number: 2, total: 5),
        'Step 2 of 5. Simmer the sauce. Stir every 5 minutes. Timer for Sauce: 15 minutes.',
      );
    });

    test('spoken instruction from the author wins', () {
      const authored = RecipeStep(
        id: 's',
        recipeId: 'r',
        position: 1,
        instructionShort: 'Boil 2L water',
        spokenInstruction: 'Bring a big pot of water to the boil',
      );
      expect(SpokenRecipe.step(authored, number: 1, total: 1), 'Step 1 of 1. Bring a big pot of water to the boil.');
    });

    test('ingredients use "of" after measures only', () {
      final text = SpokenRecipe.ingredients([
        (amount: '2 tbsp', name: 'olive oil', prep: null),
        (amount: '3', name: 'eggs', prep: 'beaten'),
        (amount: 'To taste', name: 'salt', prep: null),
      ], servings: '2 servings');
      expect(text, 'For 2 servings, you will need: 2 tablespoons of olive oil; 3 eggs, beaten; salt to taste.');
    });

    test('timer announcement', () {
      expect(SpokenRecipe.timerDone('Pasta', recipeTitle: 'Cacio e pepe'), 'Your Pasta timer for Cacio e pepe is done.');
    });
  });

  group('FlutterTtsSpeechService.chunks', () {
    test('splits on sentences under the limit', () {
      final text = List.generate(20, (i) => 'Sentence number $i is here.').join(' ');
      final chunks = FlutterTtsSpeechService.chunks(text, max: 120);
      expect(chunks.every((c) => c.length <= 120), isTrue);
      expect(chunks.join(' '), text);
    });

    test('hard-splits a single enormous sentence', () {
      final text = List.filled(400, 'word').join(' ');
      final chunks = FlutterTtsSpeechService.chunks(text, max: 100);
      expect(chunks.every((c) => c.length <= 100), isTrue);
      expect(chunks.join(' ').split(' ').length, 400);
    });
  });

  group('ReadAloudController', () {
    late _ScriptedTts tts;
    late ReadAloudController voice;

    setUp(() {
      tts = _ScriptedTts();
      voice = ReadAloudController(tts, settings: () => const VoiceSettings());
    });

    test('reads segments in order and tracks the current one', () async {
      final done = voice.read('recipe:1', const [
        SpokenSegment('intro', 'Hello.'),
        SpokenSegment('step:a', 'Step 1.'),
        SpokenSegment('empty', '   '),
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(voice.isReading('recipe:1'), isTrue);
      expect(voice.segmentId, 'intro');
      tts.release();
      await Future<void>.delayed(Duration.zero);
      expect(voice.segmentId, 'step:a');
      tts.release();
      expect(await done, isNull);
      expect(tts.spoken, ['Hello.', 'Step 1.']);
      expect(voice.isSpeaking, isFalse);
    });

    test('a new session stops the old one', () async {
      final first = voice.read('a', const [SpokenSegment('1', 'One.'), SpokenSegment('2', 'Two.')]);
      await Future<void>.delayed(Duration.zero);
      final second = voice.say('b', 'Timer done.');
      await Future<void>.delayed(Duration.zero);
      expect(voice.sessionId, 'b');
      tts.release(); // finishes "One." — the old session must not continue to "Two."
      tts.release();
      await Future.wait([first, second]);
      expect(tts.spoken, ['One.', 'Timer done.']);
    });

    test('toggle stops the playing session', () async {
      unawaited(voice.toggle('x', () => const [SpokenSegment('1', 'Hi.')]));
      await Future<void>.delayed(Duration.zero);
      expect(voice.isReading('x'), isTrue);
      await voice.toggle('x', () => const []);
      expect(voice.isSpeaking, isFalse);
      expect(tts.stops, greaterThan(0));
    });

    test('engine failure is reported and remembered', () async {
      tts.fail = true;
      final failure = await voice.read('x', const [SpokenSegment('1', 'Hi.')]);
      expect(failure, isA<CapabilityUnavailableFailure>());
      expect(voice.lastFailure, failure);
      expect(voice.isSpeaking, isFalse);
    });

    test('stopIfReadingPrefix only stops matching sessions', () async {
      unawaited(voice.read('cook:r1:step:0', const [SpokenSegment('s', 'Step.')]));
      await Future<void>.delayed(Duration.zero);
      await voice.stopIfReadingPrefix('cook:r2');
      expect(voice.isSpeaking, isTrue);
      await voice.stopIfReadingPrefix('cook:r1');
      expect(voice.isSpeaking, isFalse);
    });
  });

  test('VoiceSettings round-trips and defaults safely', () {
    const s = VoiceSettings(pace: SpeechPace.fast, readStepsInCookMode: true, announceTimers: false);
    expect(VoiceSettings.fromJson(s.toJson()), s);
    expect(VoiceSettings.fromJson(null), const VoiceSettings());
    expect(VoiceSettings.fromJson({'pace': 'warp'}).pace, SpeechPace.normal);
  });
}
