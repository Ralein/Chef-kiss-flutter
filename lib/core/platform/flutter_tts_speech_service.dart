import 'dart:async';

import 'package:app_contracts/app_contracts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_voices.dart';

/// Text-to-speech through the platform engine: Android TextToSpeech,
/// AVSpeechSynthesizer on iOS/macOS, the Web Speech API in browsers.
///
/// flutter_tts's "await speak completion" mode is unreliable across platforms
/// (iOS never completes a stopped utterance, browsers never complete one that
/// errors, Android drops a new utterance while one is in flight), so it stays
/// off. Completion is tracked from the start/complete/cancel/error callbacks
/// instead, events from a superseded utterance are ignored, and a watchdog
/// covers engines that go silent.
class FlutterTtsSpeechService implements SpeechOutputService {
  FlutterTtsSpeechService({FlutterTts Function()? engineFactory}) : _engineFactory = engineFactory ?? FlutterTts.new;

  final FlutterTts Function() _engineFactory;
  FlutterTts? _engine;
  Future<bool>? _ready;

  Completer<Result<void, AppFailure>>? _pending;
  bool _started = false;
  bool _speaking = false;
  bool _firstUtterance = true;
  Timer? _watchdog;
  int _token = 0;

  /// The voice picked in Settings; null picks the most natural one.
  String? _preferred;
  TtsVoice? _previewing;
  bool _voiceDirty = true;
  List<TtsVoice>? _voices;

  /// The voice to read with, by name; null for the most natural available.
  set preferredVoice(String? name) {
    if (name == _preferred) return;
    _preferred = name;
    _voiceDirty = true;
  }

  /// English voices worth offering, most natural first.
  Future<List<TtsVoice>> voices() async {
    if (_voices != null) return _voices!;
    if (!await (_ready ??= _init())) return const [];
    try {
      final raw = await _engine!.getVoices;
      final all = raw is List ? raw.map(TtsVoice.fromPlatform).nonNulls : const <TtsVoice>[];
      return _voices = rankVoices(all, region: PlatformDispatcher.instance.locale.countryCode);
    } catch (_) {
      return const [];
    }
  }

  /// Reads [text] once in [voice], to hear it before choosing it.
  Future<Result<void, AppFailure>> preview(TtsVoice voice, String text) {
    _previewing = voice;
    _voiceDirty = true;
    return speak(text);
  }

  Future<void> _applyVoice(FlutterTts tts) async {
    if (!_voiceDirty) return;
    final previewing = _previewing;
    _previewing = null;
    final list = await voices();
    final pick =
        previewing ??
        list.where((v) => v.name == _preferred).firstOrNull ??
        // Automatic: the most natural voice that works offline.
        list.where((v) => !v.needsNetwork).firstOrNull ??
        list.firstOrNull;
    if (pick != null) {
      try {
        await tts.setVoice({'name': pick.name, 'locale': pick.locale});
      } catch (_) {
        // Keep the engine's voice.
      }
    }
    // After a preview, the chosen voice comes back next time.
    _voiceDirty = previewing != null;
  }

  /// Engines cap utterance length (Android: ~4000 chars); stay well below.
  static const maxChunkLength = 1200;

  @override
  bool get isSpeaking => _speaking;

  @override
  Future<Result<void, AppFailure>> speak(String text, {double rate = 1.0}) async {
    final clean = text.trim();
    final token = ++_token;
    _settle(null, force: true); // anything in flight is superseded
    if (clean.isEmpty) return const Result.ok(null);

    if (!await (_ready ??= _init())) return Result.err(_unavailable());
    final tts = _engine!;
    try {
      await tts.stop();
      await tts.setSpeechRate(_engineRate(rate));
    } catch (_) {
      return Result.err(_unavailable());
    }
    await _applyVoice(tts);

    for (final chunk in chunks(clean)) {
      if (token != _token) return const Result.ok(null); // stopped or superseded
      final res = await _speakChunk(tts, chunk);
      if (res.isFailure) {
        if (token == _token) _speaking = false;
        return res;
      }
    }
    if (token == _token) _speaking = false;
    return const Result.ok(null);
  }

  @override
  Future<Result<void, AppFailure>> stop() async {
    _token++;
    _settle(null, force: true);
    _speaking = false;
    final tts = _engine;
    if (tts != null) {
      try {
        await tts.stop();
      } catch (_) {
        // Nothing to stop if the engine is gone.
      }
    }
    return const Result.ok(null);
  }

  Future<bool> _init() async {
    try {
      final tts = _engine = _engineFactory();
      tts.setStartHandler(() {
        _started = true;
        _speaking = true;
      });
      tts.setCompletionHandler(() => _settle(null));
      tts.setCancelHandler(() => _settle(null));
      tts.setErrorHandler((message) => _settle('$message'));
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        // Speak over the silent switch and duck music, like navigation apps.
        await tts.setSharedInstance(true);
        await tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
          IosTextToSpeechAudioCategoryOptions.duckOthers,
          IosTextToSpeechAudioCategoryOptions.interruptSpokenAudioAndMixWithOthers,
        ], IosTextToSpeechAudioMode.voicePrompt);
      }
      await tts.awaitSpeakCompletion(false);
      await tts.setVolume(1.0);
      await tts.setPitch(1.0);
      await _preferEnglishVoice(tts);
      return true;
    } catch (_) {
      // MissingPluginException (unsupported platform, tests) or engine failure.
      _ready = null; // allow a later retry
      return false;
    }
  }

  /// Recipes are written in English; a device set to another language would
  /// otherwise read them with a foreign voice.
  Future<void> _preferEnglishVoice(FlutterTts tts) async {
    if (PlatformDispatcher.instance.locale.languageCode == 'en') return;
    try {
      final available = await tts.isLanguageAvailable('en-US');
      if (available == true) await tts.setLanguage('en-US');
    } catch (_) {
      // Keep the engine default.
    }
  }

  Future<Result<void, AppFailure>> _speakChunk(FlutterTts tts, String chunk) async {
    final completer = Completer<Result<void, AppFailure>>();
    _pending = completer;
    _started = false;
    _watchdog?.cancel();
    final words = chunk.split(RegExp(r'\s+')).length;
    // Generous: slow speech is ~1.5 words/s, plus engine warm-up on first use.
    final limit = Duration(seconds: (_firstUtterance ? 12 : 6) + (words / 1.5).ceil());
    _firstUtterance = false;
    _watchdog = Timer(limit, () => _settle(_started ? null : 'The speech engine did not respond.', force: true));
    try {
      await tts.speak(chunk);
    } catch (e) {
      _settle('$e', force: true);
    }
    return completer.future;
  }

  /// Resolves the utterance in flight. Callbacks that arrive before the
  /// current utterance started belong to the previous (stopped) one and are
  /// ignored, unless [force] is set or it is a genuine error.
  void _settle(String? error, {bool force = false}) {
    final pending = _pending;
    if (pending == null || pending.isCompleted) return;
    if (!force && !_started) {
      final interrupted = error == null || error.contains('interrupt') || error.contains('cancel');
      if (interrupted) return;
    }
    _watchdog?.cancel();
    _watchdog = null;
    _pending = null;
    _started = false;
    pending.complete(error == null ? const Result.ok(null) : Result.err(_unavailable()));
  }

  /// 1.0 = normal. Mobile and macOS engines treat 0.5 as normal speed; the
  /// browser API uses 1.0.
  static double _engineRate(double rate) {
    final r = rate.clamp(0.5, 2.0);
    return kIsWeb ? r : (0.5 * r).clamp(0.1, 1.0);
  }

  static CapabilityUnavailableFailure _unavailable() => const CapabilityUnavailableFailure(
    capability: 'tts',
    reason: 'unavailable',
    message: 'Read aloud isn’t available on this device right now.',
    recoveryAction: 'Check that a text-to-speech voice is installed and the volume is up.',
  );

  /// Splits [text] into engine-sized chunks on sentence boundaries.
  @visibleForTesting
  static List<String> chunks(String text, {int max = maxChunkLength}) {
    final sentences = text.split(RegExp(r'(?<=[.!?;])\s+'));
    final out = <String>[];
    var current = StringBuffer();
    void flush() {
      final s = current.toString().trim();
      if (s.isNotEmpty) out.add(s);
      current = StringBuffer();
    }

    for (var sentence in sentences) {
      while (sentence.length > max) {
        var cut = sentence.lastIndexOf(RegExp(r'[,\s]'), max);
        if (cut <= 0) cut = max;
        flush();
        out.add(sentence.substring(0, cut).trim());
        sentence = sentence.substring(cut).trim();
      }
      if (current.length + sentence.length + 1 > max) flush();
      if (current.isNotEmpty) current.write(' ');
      current.write(sentence);
    }
    flush();
    return out;
  }
}
