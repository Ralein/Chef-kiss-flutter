import 'package:test/test.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import 'package:chefs_kiss/features/cook_mode/voice/voice_cook_assistant.dart';

void main() {
  group('VoiceCommandParser', () {
    const parser = VoiceCommandParser();

    test('parses next step triggers', () {
      expect(parser.parse('next'), equals(VoiceCookAction.nextStep));
      expect(parser.parse('next step'), equals(VoiceCookAction.nextStep));
      expect(parser.parse('Continue!'), equals(VoiceCookAction.nextStep));
      expect(parser.parse('forward'), equals(VoiceCookAction.nextStep));
    });

    test('parses previous step triggers', () {
      expect(parser.parse('back'), equals(VoiceCookAction.previousStep));
      expect(parser.parse('previous step'), equals(VoiceCookAction.previousStep));
      expect(parser.parse('go back'), equals(VoiceCookAction.previousStep));
    });

    test('parses repeat triggers', () {
      expect(parser.parse('repeat'), equals(VoiceCookAction.repeatInstruction));
      expect(parser.parse('say again'), equals(VoiceCookAction.repeatInstruction));
      expect(parser.parse('what did you say?'), equals(VoiceCookAction.repeatInstruction));
    });

    test('parses timer triggers', () {
      expect(parser.parse('start timer'), equals(VoiceCookAction.startTimer));
      expect(parser.parse('pause timer'), equals(VoiceCookAction.pauseTimer));
    });

    test('parses ingredients and finish triggers', () {
      expect(parser.parse('ingredients'), equals(VoiceCookAction.readIngredients));
      expect(parser.parse('finish cooking'), equals(VoiceCookAction.finishCooking));
    });

    test('safely returns unknown on unmapped speech', () {
      expect(parser.parse('what is the weather in Paris'), equals(VoiceCookAction.unknown));
      expect(parser.parse('play music'), equals(VoiceCookAction.unknown));
      expect(parser.parse(''), equals(VoiceCookAction.unknown));
    });
  });

  group('VoiceCookAssistant Narration', () {
    late FakeSpeechOutputService fakeTts;
    late FakeSpeechCommandService fakeSpeechCommands;
    late VoiceCookAssistant assistant;

    setUp(() {
      fakeTts = FakeSpeechOutputService();
      fakeSpeechCommands = FakeSpeechCommandService();
      assistant = VoiceCookAssistant(
        tts: fakeTts,
        speechCommands: fakeSpeechCommands,
        logger: const StandardAppLogger(),
      );
    });

    test('speaks step with formatted prefix', () async {
      const step = RecipeStep(
        id: 's1',
        recipeId: 'r1',
        position: 1,
        instructionShort: 'Dice the onions finely.',
        spokenInstruction: 'Dice one yellow onion finely into small cubes.',
      );

      final res = await assistant.speakStep(step, stepIndex: 1, totalSteps: 5);
      expect(res.isSuccess, isTrue);
      expect(fakeTts.lastSpokenText, equals('Step 1 of 5. Dice one yellow onion finely into small cubes.'));
    });

    test('speaks ingredient list accurately', () async {
      final ingredients = [
        RecipeIngredient(
          id: 'i1',
          recipeId: 'r1',
          displayName: 'Olive Oil',
          quantity: Rational(2),
          unitCode: 'tbsp',
          position: 1,
        ),
        RecipeIngredient(
          id: 'i2',
          recipeId: 'r1',
          displayName: 'Garlic cloves',
          quantity: Rational(3),
          unitCode: '',
          position: 2,
        ),
      ];

      final res = await assistant.speakIngredients(ingredients);
      expect(res.isSuccess, isTrue);
      expect(fakeTts.lastSpokenText, contains('2 tbsp Olive Oil'));
      expect(fakeTts.lastSpokenText, contains('3 Garlic cloves'));
    });
  });
}
