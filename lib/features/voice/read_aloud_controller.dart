import 'dart:async';

import 'package:app_contracts/app_contracts.dart';
import 'package:flutter/foundation.dart';

import 'spoken_text.dart';

enum SpeechPace {
  slow(0.8, 'Slow'),
  normal(1.0, 'Normal'),
  fast(1.2, 'Fast');

  final double rate;
  final String label;
  const SpeechPace(this.rate, this.label);

  static SpeechPace fromKey(Object? key) =>
      SpeechPace.values.firstWhere((p) => p.name == key, orElse: () => SpeechPace.normal);
}

/// Read-aloud preferences, stored as JSON in app preferences.
@immutable
class VoiceSettings {
  final SpeechPace pace;

  /// Cook Mode reads each step when you turn to it.
  final bool readStepsInCookMode;

  /// Speak "Your pasta timer is done" when a kitchen timer finishes.
  final bool announceTimers;

  const VoiceSettings({this.pace = SpeechPace.normal, this.readStepsInCookMode = false, this.announceTimers = true});

  VoiceSettings copyWith({SpeechPace? pace, bool? readStepsInCookMode, bool? announceTimers}) => VoiceSettings(
    pace: pace ?? this.pace,
    readStepsInCookMode: readStepsInCookMode ?? this.readStepsInCookMode,
    announceTimers: announceTimers ?? this.announceTimers,
  );

  Map<String, dynamic> toJson() => {
    'pace': pace.name,
    'readStepsInCookMode': readStepsInCookMode,
    'announceTimers': announceTimers,
  };

  factory VoiceSettings.fromJson(Object? json) {
    if (json is! Map) return const VoiceSettings();
    return VoiceSettings(
      pace: SpeechPace.fromKey(json['pace']),
      readStepsInCookMode: json['readStepsInCookMode'] == true,
      announceTimers: json['announceTimers'] != false,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is VoiceSettings &&
      other.pace == pace &&
      other.readStepsInCookMode == readStepsInCookMode &&
      other.announceTimers == announceTimers;

  @override
  int get hashCode => Object.hash(pace, readStepsInCookMode, announceTimers);
}

/// Plays read-aloud "sessions" (a recipe, a step, the ingredient list) one
/// segment at a time and tells the UI what is being read, so screens can show
/// a stop button and highlight the current step.
///
/// Starting a new session stops the previous one; only one voice at a time.
class ReadAloudController extends ChangeNotifier {
  ReadAloudController(this._tts, {required VoiceSettings Function() settings}) : _settings = settings;

  final SpeechOutputService _tts;
  final VoiceSettings Function() _settings;

  int _generation = 0;
  String? _sessionId;
  String? _segmentId;
  AppFailure? _lastFailure;
  bool _disposed = false;

  /// Identifies what is being read, e.g. `recipe:<id>` or `cook:<id>:step:<n>`.
  String? get sessionId => _sessionId;

  /// The segment being spoken right now, e.g. `step:<stepId>`.
  String? get segmentId => _segmentId;

  bool get isSpeaking => _sessionId != null;

  /// The last failure, kept until the next successful start, so a screen can
  /// explain why nothing was heard.
  AppFailure? get lastFailure => _lastFailure;

  bool isReading(String sessionId) => _sessionId == sessionId;

  /// Speaks [segments] in order. Completes when finished, stopped or
  /// superseded; returns the failure if the engine could not speak.
  Future<AppFailure?> read(String sessionId, List<SpokenSegment> segments) async {
    final playable = segments.where((s) => s.text.trim().isNotEmpty).toList();
    final generation = ++_generation;
    if (playable.isEmpty) {
      await stop();
      return null;
    }
    _sessionId = sessionId;
    _segmentId = playable.first.id;
    _lastFailure = null;
    _notify();

    AppFailure? failure;
    for (final segment in playable) {
      if (generation != _generation) return null;
      _segmentId = segment.id;
      _notify();
      final res = await _tts.speak(segment.text, rate: _settings().pace.rate);
      if (res.isFailure) {
        failure = res.error;
        break;
      }
    }
    if (generation == _generation) {
      _sessionId = null;
      _segmentId = null;
      _lastFailure = failure;
      _notify();
    }
    return failure;
  }

  /// Reads one short message (for example a timer announcement).
  Future<AppFailure?> say(String sessionId, String text) => read(sessionId, [SpokenSegment(sessionId, text)]);

  /// Starts [sessionId], or stops it if it is the one playing.
  Future<AppFailure?> toggle(String sessionId, List<SpokenSegment> Function() segments) async {
    if (isReading(sessionId)) {
      await stop();
      return null;
    }
    return read(sessionId, segments());
  }

  Future<void> stop() async {
    _generation++;
    final wasActive = _sessionId != null;
    _sessionId = null;
    _segmentId = null;
    if (wasActive) _notify();
    await _tts.stop();
  }

  /// Stops [sessionId] only if it is still the one playing — screens call
  /// this on dispose without cutting off a newer session elsewhere.
  Future<void> stopIfReading(String sessionId) async {
    if (isReading(sessionId)) await stop();
  }

  /// Like [stopIfReading] for a family of sessions, e.g. every
  /// `cook:<recipeId>…` session when Cook Mode closes.
  Future<void> stopIfReadingPrefix(String prefix) async {
    if (_sessionId?.startsWith(prefix) ?? false) await stop();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    unawaited(_tts.stop());
    super.dispose();
  }
}
