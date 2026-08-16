import 'package:meta/meta.dart';
import '../result.dart';
import '../failures.dart';

enum CapabilityStatus {
  notRequested,
  granted,
  denied,
  restricted,
  unavailable;

  bool get isGranted => this == CapabilityStatus.granted;
  bool get isAvailable => this != CapabilityStatus.unavailable;
}

@immutable
class PlatformCapabilitySnapshot {
  final CapabilityStatus notifications;
  final CapabilityStatus screenAwake;
  final CapabilityStatus speechOutput;
  final CapabilityStatus speechRecognition;
  final CapabilityStatus camera;
  final CapabilityStatus filePicker;
  final CapabilityStatus secureStorage;

  const PlatformCapabilitySnapshot({
    this.notifications = CapabilityStatus.notRequested,
    this.screenAwake = CapabilityStatus.granted,
    this.speechOutput = CapabilityStatus.notRequested,
    this.speechRecognition = CapabilityStatus.notRequested,
    this.camera = CapabilityStatus.notRequested,
    this.filePicker = CapabilityStatus.granted,
    this.secureStorage = CapabilityStatus.granted,
  });

  PlatformCapabilitySnapshot copyWith({
    CapabilityStatus? notifications,
    CapabilityStatus? screenAwake,
    CapabilityStatus? speechOutput,
    CapabilityStatus? speechRecognition,
    CapabilityStatus? camera,
    CapabilityStatus? filePicker,
    CapabilityStatus? secureStorage,
  }) {
    return PlatformCapabilitySnapshot(
      notifications: notifications ?? this.notifications,
      screenAwake: screenAwake ?? this.screenAwake,
      speechOutput: speechOutput ?? this.speechOutput,
      speechRecognition: speechRecognition ?? this.speechRecognition,
      camera: camera ?? this.camera,
      filePicker: filePicker ?? this.filePicker,
      secureStorage: secureStorage ?? this.secureStorage,
    );
  }
}

/// Interface for keeping the screen on during cook mode
abstract interface class ScreenAwakeService {
  Future<Result<void, AppFailure>> enable();
  Future<Result<void, AppFailure>> disable();
  bool get isEnabled;
}

/// Interface for scheduling local timer alerts & notifications
abstract interface class LocalAlertService {
  Future<Result<void, AppFailure>> requestPermission();
  Future<CapabilityStatus> checkPermission();
  Future<Result<String, AppFailure>> scheduleTimerAlert({
    required String timerId,
    required String title,
    required String body,
    required int scheduledEpochMs,
  });
  Future<Result<void, AppFailure>> cancelTimerAlert(String alertId);
}

/// Interface for spoken recipe steps (Text to Speech)
abstract interface class SpeechOutputService {
  Future<Result<void, AppFailure>> speak(String text, {double rate = 1.0});
  Future<Result<void, AppFailure>> stop();
  bool get isSpeaking;
}

/// Interface for short hands-free voice command grammar
abstract interface class SpeechCommandService {
  Future<Result<void, AppFailure>> startListening({
    required void Function(String command) onCommand,
    required void Function(String? error) onError,
  });
  Future<Result<void, AppFailure>> stopListening();
  bool get isListening;
}

/// Fake implementations for testing & fallback platforms
class FakeScreenAwakeService implements ScreenAwakeService {
  bool _enabled = false;

  @override
  bool get isEnabled => _enabled;

  @override
  Future<Result<void, AppFailure>> enable() async {
    _enabled = true;
    return Result.ok(null);
  }

  @override
  Future<Result<void, AppFailure>> disable() async {
    _enabled = false;
    return Result.ok(null);
  }
}

class FakeLocalAlertService implements LocalAlertService {
  CapabilityStatus permission = CapabilityStatus.granted;
  final Map<String, int> scheduled = {};

  @override
  Future<CapabilityStatus> checkPermission() async => permission;

  @override
  Future<Result<void, AppFailure>> requestPermission() async {
    permission = CapabilityStatus.granted;
    return Result.ok(null);
  }

  @override
  Future<Result<String, AppFailure>> scheduleTimerAlert({
    required String timerId,
    required String title,
    required String body,
    required int scheduledEpochMs,
  }) async {
    final alertId = 'alert_$timerId';
    scheduled[alertId] = scheduledEpochMs;
    return Result.ok(alertId);
  }

  @override
  Future<Result<void, AppFailure>> cancelTimerAlert(String alertId) async {
    scheduled.remove(alertId);
    return Result.ok(null);
  }
}

class FakeSpeechOutputService implements SpeechOutputService {
  bool _speaking = false;
  String? lastSpokenText;

  @override
  bool get isSpeaking => _speaking;

  @override
  Future<Result<void, AppFailure>> speak(String text, {double rate = 1.0}) async {
    _speaking = true;
    lastSpokenText = text;
    return Result.ok(null);
  }

  @override
  Future<Result<void, AppFailure>> stop() async {
    _speaking = false;
    return Result.ok(null);
  }
}

class FakeSpeechCommandService implements SpeechCommandService {
  bool _listening = false;

  @override
  bool get isListening => _listening;

  @override
  Future<Result<void, AppFailure>> startListening({
    required void Function(String command) onCommand,
    required void Function(String? error) onError,
  }) async {
    _listening = true;
    return Result.ok(null);
  }

  @override
  Future<Result<void, AppFailure>> stopListening() async {
    _listening = false;
    return Result.ok(null);
  }
}
