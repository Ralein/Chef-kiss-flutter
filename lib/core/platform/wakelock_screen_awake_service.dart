import 'package:app_contracts/app_contracts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Keeps the display on while cooking (hands are busy, the screen must not
/// sleep mid-step).
class WakelockScreenAwakeService implements ScreenAwakeService {
  bool _enabled = false;

  @override
  bool get isEnabled => _enabled;

  @override
  Future<Result<void, AppFailure>> enable() async {
    try {
      await WakelockPlus.enable();
      _enabled = true;
      return const Result.ok(null);
    } catch (e) {
      return Result.err(CapabilityUnavailableFailure(capability: 'screen_awake', reason: '$e'));
    }
  }

  @override
  Future<Result<void, AppFailure>> disable() async {
    try {
      await WakelockPlus.disable();
    } catch (_) {
      // Best effort: the OS releases the lock when the app is backgrounded.
    }
    _enabled = false;
    return const Result.ok(null);
  }
}
