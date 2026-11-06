import 'package:flutter/foundation.dart';

/// A text-to-speech voice installed on the device.
@immutable
class TtsVoice {
  final String name;

  /// BCP 47, e.g. `en-IN`.
  final String locale;

  /// How natural it sounds, 0–5: Android reports 100–500, iOS
  /// default / enhanced / premium.
  final int quality;
  final bool needsNetwork;
  final bool installed;

  const TtsVoice({
    required this.name,
    required this.locale,
    this.quality = 3,
    this.needsNetwork = false,
    this.installed = true,
  });

  /// Reads one entry of flutter_tts's `getVoices`; null when unusable.
  static TtsVoice? fromPlatform(Object? raw) {
    if (raw is! Map) return null;
    final name = raw['name']?.toString(), locale = raw['locale']?.toString();
    if (name == null || name.isEmpty || locale == null || locale.isEmpty) return null;
    final q = raw['quality'];
    final quality = switch (q) {
      final num n => (n / 100).round().clamp(0, 5),
      final String s when s.toLowerCase() == 'premium' => 5,
      final String s when s.toLowerCase() == 'enhanced' => 4,
      final String s when int.tryParse(s) != null => (int.parse(s) / 100).round().clamp(0, 5),
      _ => 3,
    };
    final network = raw['network_required'];
    return TtsVoice(
      name: name,
      locale: locale.replaceAll('_', '-'),
      quality: quality,
      needsNetwork: network == true || network?.toString() == '1' || name.contains('-network'),
      installed: !(raw['features']?.toString() ?? '').contains('notInstalled'),
    );
  }

  String get language => locale.split('-').first.toLowerCase();
  String get region => locale.contains('-') ? locale.split('-')[1].toUpperCase() : '';

  bool get sounds => quality >= 4 || RegExp('neural|natural|wavenet|premium|enhanced', caseSensitive: false).hasMatch(name);

  @override
  bool operator ==(Object other) => other is TtsVoice && other.name == name && other.locale == locale;

  @override
  int get hashCode => Object.hash(name, locale);
}

const _regions = {
  'US': 'US',
  'GB': 'UK',
  'IN': 'India',
  'AU': 'Australia',
  'CA': 'Canada',
  'IE': 'Ireland',
  'NZ': 'New Zealand',
  'ZA': 'South Africa',
  'NG': 'Nigeria',
  'SG': 'Singapore',
};

/// Every installed voice in [language]: [region]'s accent first (American
/// unless asked otherwise), then the others; within each, the most natural
/// first and voices that work offline before online ones. At most [limit].
List<TtsVoice> rankVoices(Iterable<TtsVoice> voices, {String language = 'en', String? region = 'US', int? limit}) {
  int score(TtsVoice v) =>
      (region != null && v.region == region.toUpperCase() ? 1000 : 0) +
      v.quality * 10 +
      (v.sounds ? 4 : 0) +
      (v.needsNetwork ? 0 : 3);
  final ranked = [
    for (final v in voices.toSet())
      if (v.installed && v.language == language) v,
  ]..sort((a, b) => score(b).compareTo(score(a)));
  return limit == null ? ranked : ranked.take(limit).toList();
}

/// Short names for a ranked list: "English (India)", "English (India) 2"…
/// with "natural" where the voice is one of the device's best.
Map<TtsVoice, String> voiceLabels(List<TtsVoice> voices) {
  final seen = <String, int>{};
  return {
    for (final v in voices)
      v: () {
        final base = v.region.isEmpty ? 'English' : 'English (${_regions[v.region] ?? v.region})';
        final n = seen[v.locale] = (seen[v.locale] ?? 0) + 1;
        return [
          '$base${n > 1 ? ' $n' : ''}',
          if (v.sounds) 'natural',
          if (v.needsNetwork) 'online',
        ].join(' · ');
      }(),
  };
}
