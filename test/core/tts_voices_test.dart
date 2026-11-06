import 'package:chefs_kiss/core/platform/tts_voices.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every installed English voice, the chosen accent first, the most natural first within it', () {
    final voices = [
      {'name': 'en-us-x-sfg-local', 'locale': 'en-US', 'quality': 300, 'network_required': '0'},
      {'name': 'en-in-x-ene-network', 'locale': 'en-IN', 'quality': 400, 'network_required': '1'},
      {'name': 'en-in-x-ena-local', 'locale': 'en-IN', 'quality': 400, 'network_required': '0'},
      {'name': 'en-gb-x-gbb-local', 'locale': 'en-GB', 'quality': 400, 'network_required': '0'},
      {'name': 'en-au-x-aua-local', 'locale': 'en-AU', 'quality': 500, 'features': 'notInstalled'},
      {'name': 'fr-fr-x-fra-local', 'locale': 'fr-FR', 'quality': 500},
      'junk',
    ].map(TtsVoice.fromPlatform).nonNulls;
    final ranked = rankVoices(voices, region: 'IN');
    expect(ranked.map((v) => v.name), [
      'en-in-x-ena-local', // natural, India, works offline
      'en-in-x-ene-network',
      'en-gb-x-gbb-local',
      'en-us-x-sfg-local',
    ]);
    // American by default: US voices lead, however good the others are.
    expect(rankVoices(voices).first.name, 'en-us-x-sfg-local');
    expect(rankVoices(voices), hasLength(4), reason: 'no cap on the list');
    expect(voiceLabels(ranked).values, [
      'English (India) · natural',
      'English (India) 2 · natural · online',
      'English (UK) · natural',
      'English (US)',
    ]);
  });

  test('iOS voices: premium and enhanced count as the most natural', () {
    final a = TtsVoice.fromPlatform({'name': 'Samantha', 'locale': 'en-US', 'quality': 'default'})!;
    final b = TtsVoice.fromPlatform({'name': 'Ava (Premium)', 'locale': 'en-US', 'quality': 'premium'})!;
    expect(rankVoices([a, b]).first, b);
  });
}
