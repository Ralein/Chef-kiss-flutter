import 'package:meta/meta.dart';
import 'rational.dart';

enum CookingSessionStatus {
  active,
  paused,
  completed,
  abandoned;

  static CookingSessionStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'paused':
        return CookingSessionStatus.paused;
      case 'completed':
        return CookingSessionStatus.completed;
      case 'abandoned':
        return CookingSessionStatus.abandoned;
      case 'active':
      default:
        return CookingSessionStatus.active;
    }
  }

  String toDbString() => name;
}

enum SessionTimerStatus {
  idle,
  running,
  paused,
  expired,
  acknowledged;

  static SessionTimerStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'running':
        return SessionTimerStatus.running;
      case 'paused':
        return SessionTimerStatus.paused;
      case 'expired':
        return SessionTimerStatus.expired;
      case 'acknowledged':
        return SessionTimerStatus.acknowledged;
      case 'idle':
      default:
        return SessionTimerStatus.idle;
    }
  }

  String toDbString() => name;
}

@immutable
class SessionIngredientCheck {
  final String id;
  final String sessionId;
  final String recipeIngredientId;
  final bool isChecked;
  final int checkedAt;

  const SessionIngredientCheck({
    required this.id,
    required this.sessionId,
    required this.recipeIngredientId,
    required this.isChecked,
    required this.checkedAt,
  });

  SessionIngredientCheck copyWith({
    String? id,
    String? sessionId,
    String? recipeIngredientId,
    bool? isChecked,
    int? checkedAt,
  }) {
    return SessionIngredientCheck(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      recipeIngredientId: recipeIngredientId ?? this.recipeIngredientId,
      isChecked: isChecked ?? this.isChecked,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }
}

@immutable
class SessionTimer {
  final String id;
  final String sessionId;
  final String? recipeStepId;
  final String label;
  final int durationSeconds;
  final int startedAt;
  final int endsAt; // UTC milliseconds absolute end time
  final SessionTimerStatus status;
  final String? notificationId;
  final int? acknowledgedAt;

  const SessionTimer({
    required this.id,
    required this.sessionId,
    this.recipeStepId,
    required this.label,
    required this.durationSeconds,
    required this.startedAt,
    required this.endsAt,
    this.status = SessionTimerStatus.running,
    this.notificationId,
    this.acknowledgedAt,
  });

  int remainingSeconds([int? currentEpochMs]) {
    final now = currentEpochMs ?? DateTime.now().toUtc().millisecondsSinceEpoch;
    if (status != SessionTimerStatus.running) {
      if (status == SessionTimerStatus.expired) return 0;
    }
    final remainingMs = endsAt - now;
    if (remainingMs <= 0) return 0;
    return (remainingMs / 1000).ceil();
  }

  bool isOverdue([int? currentEpochMs]) {
    final now = currentEpochMs ?? DateTime.now().toUtc().millisecondsSinceEpoch;
    return endsAt <= now;
  }

  SessionTimer copyWith({
    String? id,
    String? sessionId,
    String? recipeStepId,
    String? label,
    int? durationSeconds,
    int? startedAt,
    int? endsAt,
    SessionTimerStatus? status,
    String? notificationId,
    int? acknowledgedAt,
  }) {
    return SessionTimer(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      recipeStepId: recipeStepId ?? this.recipeStepId,
      label: label ?? this.label,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      startedAt: startedAt ?? this.startedAt,
      endsAt: endsAt ?? this.endsAt,
      status: status ?? this.status,
      notificationId: notificationId ?? this.notificationId,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
    );
  }
}

@immutable
class CookingSession {
  final String id;
  final String profileId;
  final String recipeId;
  final String? recipeVersionId;
  final CookingSessionStatus status;
  final Rational selectedServings;
  final int activeStepPosition;
  final int startedAt;
  final int lastResumedAt;
  final int? completedAt;
  final bool screenAwakeRequested;
  final bool voiceMode;
  final List<SessionIngredientCheck> checks;
  final List<SessionTimer> timers;

  const CookingSession({
    required this.id,
    required this.profileId,
    required this.recipeId,
    this.recipeVersionId,
    this.status = CookingSessionStatus.active,
    required this.selectedServings,
    this.activeStepPosition = 1,
    required this.startedAt,
    required this.lastResumedAt,
    this.completedAt,
    this.screenAwakeRequested = true,
    this.voiceMode = false,
    this.checks = const [],
    this.timers = const [],
  });

  bool isIngredientChecked(String ingredientId) {
    return checks.any((c) => c.recipeIngredientId == ingredientId && c.isChecked);
  }

  CookingSession copyWith({
    String? id,
    String? profileId,
    String? recipeId,
    String? recipeVersionId,
    CookingSessionStatus? status,
    Rational? selectedServings,
    int? activeStepPosition,
    int? startedAt,
    int? lastResumedAt,
    int? completedAt,
    bool? screenAwakeRequested,
    bool? voiceMode,
    List<SessionIngredientCheck>? checks,
    List<SessionTimer>? timers,
  }) {
    return CookingSession(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      recipeId: recipeId ?? this.recipeId,
      recipeVersionId: recipeVersionId ?? this.recipeVersionId,
      status: status ?? this.status,
      selectedServings: selectedServings ?? this.selectedServings,
      activeStepPosition: activeStepPosition ?? this.activeStepPosition,
      startedAt: startedAt ?? this.startedAt,
      lastResumedAt: lastResumedAt ?? this.lastResumedAt,
      completedAt: completedAt ?? this.completedAt,
      screenAwakeRequested: screenAwakeRequested ?? this.screenAwakeRequested,
      voiceMode: voiceMode ?? this.voiceMode,
      checks: checks ?? this.checks,
      timers: timers ?? this.timers,
    );
  }
}
