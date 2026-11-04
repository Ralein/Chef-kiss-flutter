import 'dart:async';

import 'package:flutter/foundation.dart';

/// One countdown attached to a recipe step.
@immutable
class KitchenTimer {
  final String id;
  final String label;
  final String recipeId;
  final String recipeTitle;
  final int durationSeconds;

  /// Absolute end time while running. Using wall-clock time (instead of
  /// decrementing a counter) keeps timers correct when frames are skipped or
  /// the app is backgrounded.
  final DateTime? endsAt;
  final int pausedRemainingSeconds;
  final bool finished;

  const KitchenTimer({
    required this.id,
    required this.label,
    required this.recipeId,
    required this.recipeTitle,
    required this.durationSeconds,
    this.endsAt,
    required this.pausedRemainingSeconds,
    this.finished = false,
  });

  bool get isRunning => endsAt != null && !finished;

  int remainingSeconds(DateTime now) {
    if (finished) return 0;
    if (endsAt == null) return pausedRemainingSeconds;
    final ms = endsAt!.difference(now).inMilliseconds;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  double progress(DateTime now) =>
      durationSeconds <= 0 ? 1 : 1 - remainingSeconds(now) / durationSeconds;

  KitchenTimer _copy({DateTime? endsAt, bool clearEnd = false, int? paused, bool? finished}) => KitchenTimer(
        id: id,
        label: label,
        recipeId: recipeId,
        recipeTitle: recipeTitle,
        durationSeconds: durationSeconds,
        endsAt: clearEnd ? null : (endsAt ?? this.endsAt),
        pausedRemainingSeconds: paused ?? pausedRemainingSeconds,
        finished: finished ?? this.finished,
      );
}

/// App-wide timer registry shared by the recipe page and Cook Mode.
class KitchenTimersController extends ChangeNotifier {
  final DateTime Function() _now;
  final Map<String, KitchenTimer> _timers = {};
  Timer? _ticker;

  /// Called once when a running timer reaches zero.
  void Function(KitchenTimer timer)? onFinished;

  KitchenTimersController({DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  DateTime get now => _now();

  KitchenTimer? operator [](String id) => _timers[id];

  List<KitchenTimer> get running => _timers.values.where((t) => t.isRunning).toList(growable: false);

  /// Starts a new timer or resumes a paused one.
  void start({
    required String id,
    required String label,
    required int durationSeconds,
    required String recipeId,
    required String recipeTitle,
  }) {
    final existing = _timers[id];
    final remaining = (existing == null || existing.finished) ? durationSeconds : existing.pausedRemainingSeconds;
    _timers[id] = KitchenTimer(
      id: id,
      label: label,
      recipeId: recipeId,
      recipeTitle: recipeTitle,
      durationSeconds: durationSeconds,
      endsAt: _now().add(Duration(seconds: remaining)),
      pausedRemainingSeconds: remaining,
    );
    _ensureTicking();
    notifyListeners();
  }

  void pause(String id) {
    final t = _timers[id];
    if (t == null || !t.isRunning) return;
    _timers[id] = t._copy(clearEnd: true, paused: t.remainingSeconds(_now()));
    notifyListeners();
  }

  void toggle({
    required String id,
    required String label,
    required int durationSeconds,
    required String recipeId,
    required String recipeTitle,
  }) {
    if (_timers[id]?.isRunning ?? false) {
      pause(id);
    } else {
      start(id: id, label: label, durationSeconds: durationSeconds, recipeId: recipeId, recipeTitle: recipeTitle);
    }
  }

  void reset(String id) {
    if (_timers.remove(id) != null) notifyListeners();
  }

  void _ensureTicking() {
    _ticker ??= Timer.periodic(const Duration(milliseconds: 500), (_) => tick());
  }

  /// Advances state; exposed for tests.
  @visibleForTesting
  void tick() {
    final now = _now();
    final justFinished = <KitchenTimer>[];
    for (final entry in _timers.entries.toList()) {
      final t = entry.value;
      if (t.isRunning && t.remainingSeconds(now) == 0) {
        final done = t._copy(finished: true, paused: 0);
        _timers[entry.key] = done;
        justFinished.add(done);
      }
    }
    if (running.isEmpty) {
      _ticker?.cancel();
      _ticker = null;
    }
    notifyListeners();
    for (final t in justFinished) {
      onFinished?.call(t);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
