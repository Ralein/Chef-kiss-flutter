import 'package:flutter/services.dart';

/// Tactile audio and haptic feedback service for Chef's Kiss
class AudioChimeService {
  const AudioChimeService();

  /// Tactile tap feedback (light wooden click sensation)
  void playTap() {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
  }

  /// Page flip paper swoosh tactile feel
  void playPageFlip() {
    HapticFeedback.mediumImpact();
  }

  /// Timer start gentle bell
  void playTimerStart() {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }

  /// Step timer complete alarm chime
  void playTimerComplete() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }

  /// Victory celebratory fanfare
  void playSuccessFanfare() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }
}

const audioChime = AudioChimeService();
