import 'package:recipe_domain/recipe_domain.dart';
import '../result.dart';
import '../failures.dart';

abstract interface class CookingSessionRepository {
  /// Watch currently active or paused cooking session (at most 1 active)
  Stream<CookingSession?> watchActiveSession();

  /// Get active session by recipe ID if one exists
  Future<Result<CookingSession?, AppFailure>> getSessionByRecipeId(String recipeId);

  /// Start a new cooking session
  Future<Result<CookingSession, AppFailure>> startSession({
    required String profileId,
    required String recipeId,
    String? recipeVersionId,
    required Rational selectedServings,
  });

  /// Advance or move to active step
  Future<Result<CookingSession, AppFailure>> updateActiveStep({
    required String sessionId,
    required int stepPosition,
  });

  /// Toggle or set ingredient check state
  Future<Result<SessionIngredientCheck, AppFailure>> setIngredientCheck({
    required String sessionId,
    required String recipeIngredientId,
    required bool isChecked,
  });

  /// Add / start a session timer
  Future<Result<SessionTimer, AppFailure>> createTimer({
    required String sessionId,
    String? recipeStepId,
    required String label,
    required int durationSeconds,
  });

  /// Acknowledge or cancel timer
  Future<Result<void, AppFailure>> acknowledgeTimer(String timerId);

  /// Pause session
  Future<Result<void, AppFailure>> pauseSession(String sessionId);

  /// Complete session
  Future<Result<void, AppFailure>> completeSession(String sessionId);

  /// Abandon session
  Future<Result<void, AppFailure>> abandonSession(String sessionId);
}
