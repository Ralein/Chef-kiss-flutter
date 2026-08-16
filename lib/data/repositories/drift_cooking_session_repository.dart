import 'package:drift/drift.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import 'package:uuid/uuid.dart';
import '../db/app_database.dart';

class DriftCookingSessionRepository implements CookingSessionRepository {
  final AppDatabase db;
  final Uuid _uuid = const Uuid();

  DriftCookingSessionRepository(this.db);

  @override
  Stream<CookingSession?> watchActiveSession() {
    return (db.select(db.cookingSessionsTable)
          ..where((s) => s.status.equals('active') | s.status.equals('paused'))
          ..orderBy([(s) => OrderingTerm.desc(s.lastResumedAt)])
          ..limit(1))
        .watchSingleOrNull()
        .asyncMap((row) async {
      if (row == null) return null;
      return await _loadSessionDetails(row);
    });
  }

  @override
  Future<Result<CookingSession?, AppFailure>> getSessionByRecipeId(String recipeId) async {
    try {
      final row = await (db.select(db.cookingSessionsTable)
            ..where((s) =>
                s.recipeId.equals(recipeId) &
                (s.status.equals('active') | s.status.equals('paused')))
            ..orderBy([(s) => OrderingTerm.desc(s.lastResumedAt)])
            ..limit(1))
          .getSingleOrNull();

      if (row == null) return Result.ok(null);
      final session = await _loadSessionDetails(row);
      return Result.ok(session);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to fetch session: $e', cause: e));
    }
  }

  @override
  Future<Result<CookingSession, AppFailure>> startSession({
    required String profileId,
    required String recipeId,
    String? recipeVersionId,
    required Rational selectedServings,
  }) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final sessionId = _uuid.v4();

      await db.transaction(() async {
        // Pause any previously active sessions
        await (db.update(db.cookingSessionsTable)
              ..where((s) => s.status.equals('active')))
            .write(const CookingSessionsTableCompanion(status: Value('paused')));

        // Insert new session
        await db.into(db.cookingSessionsTable).insert(
              CookingSessionsTableCompanion(
                id: Value(sessionId),
                profileId: Value(profileId.isEmpty ? 'default' : profileId),
                recipeId: Value(recipeId),
                recipeVersionId: Value(recipeVersionId),
                status: const Value('active'),
                selectedServingsNum: Value(selectedServings.numerator),
                selectedServingsDen: Value(selectedServings.denominator),
                activeStepPosition: const Value(1),
                startedAt: Value(now),
                lastResumedAt: Value(now),
                screenAwakeRequested: const Value(true),
                voiceMode: const Value(false),
              ),
            );
      });

      final row = await (db.select(db.cookingSessionsTable)..where((s) => s.id.equals(sessionId))).getSingle();
      final session = await _loadSessionDetails(row);
      return Result.ok(session);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to start session: $e', cause: e));
    }
  }

  @override
  Future<Result<CookingSession, AppFailure>> updateActiveStep({
    required String sessionId,
    required int stepPosition,
  }) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (db.update(db.cookingSessionsTable)..where((s) => s.id.equals(sessionId))).write(
        CookingSessionsTableCompanion(
          activeStepPosition: Value(stepPosition),
          lastResumedAt: Value(now),
        ),
      );

      final row = await (db.select(db.cookingSessionsTable)..where((s) => s.id.equals(sessionId))).getSingle();
      final session = await _loadSessionDetails(row);
      return Result.ok(session);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to advance step: $e', cause: e));
    }
  }

  @override
  Future<Result<SessionIngredientCheck, AppFailure>> setIngredientCheck({
    required String sessionId,
    required String recipeIngredientId,
    required bool isChecked,
  }) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final checkId = '${sessionId}_$recipeIngredientId';

      await db.into(db.sessionIngredientChecksTable).insertOnConflictUpdate(
            SessionIngredientChecksTableCompanion(
              id: Value(checkId),
              sessionId: Value(sessionId),
              recipeIngredientId: Value(recipeIngredientId),
              isChecked: Value(isChecked),
              checkedAt: Value(now),
            ),
          );

      return Result.ok(SessionIngredientCheck(
        id: checkId,
        sessionId: sessionId,
        recipeIngredientId: recipeIngredientId,
        isChecked: isChecked,
        checkedAt: now,
      ));
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to update ingredient check: $e', cause: e));
    }
  }

  @override
  Future<Result<SessionTimer, AppFailure>> createTimer({
    required String sessionId,
    String? recipeStepId,
    required String label,
    required int durationSeconds,
  }) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final timerId = _uuid.v4();
      final endsAt = now + (durationSeconds * 1000);

      await db.into(db.sessionTimersTable).insert(
            SessionTimersTableCompanion(
              id: Value(timerId),
              sessionId: Value(sessionId),
              recipeStepId: Value(recipeStepId),
              label: Value(label),
              durationSeconds: Value(durationSeconds),
              startedAt: Value(now),
              endsAt: Value(endsAt),
              status: const Value('running'),
            ),
          );

      return Result.ok(SessionTimer(
        id: timerId,
        sessionId: sessionId,
        recipeStepId: recipeStepId,
        label: label,
        durationSeconds: durationSeconds,
        startedAt: now,
        endsAt: endsAt,
        status: SessionTimerStatus.running,
      ));
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to create timer: $e', cause: e));
    }
  }

  @override
  Future<Result<void, AppFailure>> acknowledgeTimer(String timerId) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (db.update(db.sessionTimersTable)..where((t) => t.id.equals(timerId))).write(
        SessionTimersTableCompanion(
          status: const Value('acknowledged'),
          acknowledgedAt: Value(now),
        ),
      );
      return Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to acknowledge timer: $e', cause: e));
    }
  }

  @override
  Future<Result<void, AppFailure>> pauseSession(String sessionId) async {
    try {
      await (db.update(db.cookingSessionsTable)..where((s) => s.id.equals(sessionId))).write(
        const CookingSessionsTableCompanion(status: Value('paused')),
      );
      return Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to pause session: $e', cause: e));
    }
  }

  @override
  Future<Result<void, AppFailure>> completeSession(String sessionId) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (db.update(db.cookingSessionsTable)..where((s) => s.id.equals(sessionId))).write(
        CookingSessionsTableCompanion(
          status: const Value('completed'),
          completedAt: Value(now),
        ),
      );
      return Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to complete session: $e', cause: e));
    }
  }

  @override
  Future<Result<void, AppFailure>> abandonSession(String sessionId) async {
    try {
      await (db.update(db.cookingSessionsTable)..where((s) => s.id.equals(sessionId))).write(
        const CookingSessionsTableCompanion(status: Value('abandoned')),
      );
      return Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to abandon session: $e', cause: e));
    }
  }

  Future<CookingSession> _loadSessionDetails(CookingSessionsTableData row) async {
    // Checks
    final checkRows = await (db.select(db.sessionIngredientChecksTable)
          ..where((c) => c.sessionId.equals(row.id)))
        .get();
    final checks = checkRows
        .map((c) => SessionIngredientCheck(
              id: c.id,
              sessionId: c.sessionId,
              recipeIngredientId: c.recipeIngredientId,
              isChecked: c.isChecked,
              checkedAt: c.checkedAt,
            ))
        .toList();

    // Timers
    final timerRows = await (db.select(db.sessionTimersTable)
          ..where((t) => t.sessionId.equals(row.id)))
        .get();
    final timers = timerRows
        .map((t) => SessionTimer(
              id: t.id,
              sessionId: t.sessionId,
              recipeStepId: t.recipeStepId,
              label: t.label,
              durationSeconds: t.durationSeconds,
              startedAt: t.startedAt,
              endsAt: t.endsAt,
              status: SessionTimerStatus.fromString(t.status),
              notificationId: t.notificationId,
              acknowledgedAt: t.acknowledgedAt,
            ))
        .toList();

    return CookingSession(
      id: row.id,
      profileId: row.profileId,
      recipeId: row.recipeId,
      recipeVersionId: row.recipeVersionId,
      status: CookingSessionStatus.fromString(row.status),
      selectedServings: Rational(row.selectedServingsNum, row.selectedServingsDen),
      activeStepPosition: row.activeStepPosition,
      startedAt: row.startedAt,
      lastResumedAt: row.lastResumedAt,
      completedAt: row.completedAt,
      screenAwakeRequested: row.screenAwakeRequested,
      voiceMode: row.voiceMode,
      checks: checks,
      timers: timers,
    );
  }
}
