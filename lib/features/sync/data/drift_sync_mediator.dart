import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import 'package:uuid/uuid.dart';
import '../../../data/db/app_database.dart';

class DriftSyncMediator implements SyncMediator {
  final AppDatabase _db;
  final SyncServerAdapter _server;
  final AuthRepository _authRepo;
  final Uuid _uuid = const Uuid();

  final StreamController<SyncEngineState> _stateController =
      StreamController<SyncEngineState>.broadcast();
  final StreamController<List<SyncConflict>> _conflictsController =
      StreamController<List<SyncConflict>>.broadcast();

  SyncEngineState _currentState = const SyncEngineState();
  final List<SyncConflict> _pendingConflicts = [];

  DriftSyncMediator({
    required AppDatabase db,
    required SyncServerAdapter server,
    required AuthRepository authRepo,
  })  : _db = db,
        _server = server,
        _authRepo = authRepo {
    _stateController.add(_currentState);
    _conflictsController.add(_pendingConflicts);
  }

  @override
  Stream<SyncEngineState> watchSyncState() async* {
    yield _currentState;
    yield* _stateController.stream;
  }

  @override
  Stream<List<SyncConflict>> watchPendingConflicts() async* {
    yield List.unmodifiable(_pendingConflicts);
    yield* _conflictsController.stream;
  }

  @override
  Future<List<SyncConflict>> getPendingConflicts() async {
    return List.unmodifiable(_pendingConflicts);
  }

  void _updateState(SyncEngineState newState) {
    _currentState = newState;
    _stateController.add(_currentState);
  }

  void _notifyConflicts() {
    _conflictsController.add(List.unmodifiable(_pendingConflicts));
  }

  @override
  Future<Result<SyncSummary, AppFailure>> synchronize({bool force = false}) async {
    final session = _authRepo.getCurrentSession();
    if (!session.isAuthenticated) {
      _updateState(_currentState.copyWith(
        phase: SyncStatusPhase.offline,
        lastErrorMessage: 'Not signed in. Connect account to sync.',
      ));
      return Result.err(const PermissionDeniedFailure(
        capability: 'cloud_sync',
        message: 'Must be authenticated to sync with cloud.',
      ));
    }

    _updateState(_currentState.copyWith(
      phase: SyncStatusPhase.syncing,
      lastErrorMessage: null,
    ));

    var pushedCount = 0;
    var pulledCount = 0;
    var newConflictsCount = 0;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    try {
      // 1. Gather pending local operations
      final localOpRows = await (_db.select(_db.changeOperationsTable)
            ..where((o) => o.syncStatus.isIn(['local_only', 'pending'])))
          .get();

      final pendingOps = localOpRows.map((row) {
        return ChangeOperation(
          operationId: row.operationId,
          profileId: row.profileId,
          entityType: row.entityType,
          entityId: row.entityId,
          opType: OperationType.fromDbString(row.opType),
          baseVersion: row.baseVersion,
          payload: jsonDecode(row.payloadJson) as Map<String, dynamic>,
          fieldPaths: (jsonDecode(row.fieldPathsJson) as List<dynamic>)
              .map((e) => e.toString())
              .toList(),
          occurredAt: row.occurredAt,
          syncStatus: SyncStatus.fromDbString(row.syncStatus),
        );
      }).toList();

      // 2. Push pending operations to server
      if (pendingOps.isNotEmpty) {
        final pushRes = await _server.pushOperations(session, pendingOps);
        if (pushRes.isFailure) {
          _updateState(_currentState.copyWith(
            phase: SyncStatusPhase.error,
            lastErrorMessage: pushRes.error?.message,
          ));
          return Result.err(pushRes.error!);
        }

        final pushResult = pushRes.orNull!;
        pushedCount = pushResult.ackedOperationIds.length;

        // Mark acked operations as synced
        for (final opId in pushResult.ackedOperationIds) {
          await (_db.update(_db.changeOperationsTable)
                ..where((o) => o.operationId.equals(opId)))
              .write(const ChangeOperationsTableCompanion(
            syncStatus: Value('synced'),
          ));
        }

        // Mark rejected operations as conflict
        for (final entry in pushResult.rejectedOperationIds.entries) {
          await (_db.update(_db.changeOperationsTable)
                ..where((o) => o.operationId.equals(entry.key)))
              .write(const ChangeOperationsTableCompanion(
            syncStatus: Value('conflict'),
          ));
        }
      }

      // 3. Read current local cursors
      final cursorRows = await _db.select(_db.syncCursorsTable).get();
      final cursorsByScope = <String, String>{};
      for (final r in cursorRows) {
        cursorsByScope[r.scope] = r.cursor;
      }

      // 4. Pull changes from server
      final pullRes = await _server.pullChanges(session, cursorsByScope);
      if (pullRes.isFailure) {
        _updateState(_currentState.copyWith(
          phase: SyncStatusPhase.error,
          lastErrorMessage: pullRes.error?.message,
        ));
        return Result.err(pullRes.error!);
      }

      final pullResult = pullRes.orNull!;
      pulledCount = pullResult.operations.length;

      // 5. Convergence Engine: Apply remote operations & detect 3-way conflicts
      for (final remoteOp in pullResult.operations) {
        // Skip operations we already know or authored
        final alreadyLocal = await (_db.select(_db.changeOperationsTable)
              ..where((o) => o.operationId.equals(remoteOp.operationId)))
            .getSingleOrNull();
        if (alreadyLocal != null) {
          continue;
        }

        // Find if local pending or conflicting unpushed op exists for same entity
        final localPendingRows = await (_db.select(_db.changeOperationsTable)
              ..where((o) =>
                  o.entityId.equals(remoteOp.entityId) &
                  o.entityType.equals(remoteOp.entityType) &
                  o.syncStatus.isIn(['local_only', 'pending', 'conflict']) &
                  o.operationId.isNotIn([remoteOp.operationId])))
            .get();

        if (localPendingRows.isEmpty) {
          // Clean fast-forward: No local concurrent edits
          await _applyRemoteOperation(remoteOp);
          await _recordRemoteOpAsSynced(remoteOp);
        } else {
          // Concurrent edits exist! Run field-level 3-way merge
          final localRow = localPendingRows.last;
          final localFieldPaths = (jsonDecode(localRow.fieldPathsJson) as List<dynamic>)
              .map((e) => e.toString())
              .toList();

          final conflictingFields = localFieldPaths
              .where((p) =>
                  remoteOp.fieldPaths.contains(p) ||
                  (p == '/' && remoteOp.fieldPaths.contains('/')))
              .toList();

          if (conflictingFields.isEmpty) {
            // Disjoint fields -> Clean auto-merge!
            final localOp = ChangeOperation(
              operationId: localRow.operationId,
              profileId: localRow.profileId,
              entityType: localRow.entityType,
              entityId: localRow.entityId,
              opType: OperationType.fromDbString(localRow.opType),
              baseVersion: localRow.baseVersion,
              payload: jsonDecode(localRow.payloadJson) as Map<String, dynamic>,
              fieldPaths: localFieldPaths,
              occurredAt: localRow.occurredAt,
            );
            await _applyDisjointFieldMerge(localOp, remoteOp);
            await _recordRemoteOpAsSynced(remoteOp);
          } else {
            // Overlapping fields -> Genuine Conflict!
            final localSnapshot = await _loadEntitySnapshot(remoteOp.entityType, remoteOp.entityId);
            final localOp = ChangeOperation(
              operationId: localRow.operationId,
              profileId: localRow.profileId,
              entityType: localRow.entityType,
              entityId: localRow.entityId,
              opType: OperationType.fromDbString(localRow.opType),
              baseVersion: localRow.baseVersion,
              payload: jsonDecode(localRow.payloadJson) as Map<String, dynamic>,
              fieldPaths: localFieldPaths,
              occurredAt: localRow.occurredAt,
            );

            final conflict = SyncConflict(
              conflictId: 'conf_${_uuid.v4().substring(0, 8)}',
              entityType: remoteOp.entityType,
              entityId: remoteOp.entityId,
              localOperation: localOp,
              remoteOperation: remoteOp,
              localSnapshot: localSnapshot ?? localOp.payload,
              remoteSnapshot: remoteOp.payload,
              conflictingFields: conflictingFields,
              detectedAt: now,
            );

            _pendingConflicts.add(conflict);
            newConflictsCount++;

            // Mark local op as conflict
            await (_db.update(_db.changeOperationsTable)
                  ..where((o) => o.operationId.equals(localRow.operationId)))
                .write(const ChangeOperationsTableCompanion(
              syncStatus: Value('conflict'),
            ));
          }
        }
      }

      // 6. Update local cursors
      for (final entry in pullResult.newCursors.entries) {
        await _db.into(_db.syncCursorsTable).insertOnConflictUpdate(
              SyncCursorsTableCompanion(
                profileId: Value(session.user?.id ?? 'default'),
                scope: Value(entry.key),
                cursor: Value(entry.value),
                lastSuccessAt: Value(now),
              ),
            );
      }

      final phase = _pendingConflicts.isNotEmpty
          ? SyncStatusPhase.conflictsPending
          : SyncStatusPhase.idle;

      _updateState(SyncEngineState(
        phase: phase,
        lastSyncAt: now,
        pendingOpCount: pendingOps.length - pushedCount,
        conflictCount: _pendingConflicts.length,
      ));
      _notifyConflicts();

      return Result.ok(SyncSummary(
        pushedCount: pushedCount,
        pulledCount: pulledCount,
        conflictsCount: newConflictsCount,
        timestamp: now,
      ));
    } catch (e) {
      _updateState(_currentState.copyWith(
        phase: SyncStatusPhase.error,
        lastErrorMessage: 'Sync error: $e',
      ));
      return Result.err(StorageFailure(message: 'Sync failed: $e', cause: e));
    }
  }

  Future<void> _recordRemoteOpAsSynced(ChangeOperation remoteOp) async {
    await _db.into(_db.changeOperationsTable).insertOnConflictUpdate(
          ChangeOperationsTableCompanion(
            operationId: Value(remoteOp.operationId),
            profileId: Value(remoteOp.profileId),
            entityType: Value(remoteOp.entityType),
            entityId: Value(remoteOp.entityId),
            opType: Value(remoteOp.opType.name),
            baseVersion: Value(remoteOp.baseVersion),
            payloadJson: Value(jsonEncode(remoteOp.payload)),
            fieldPathsJson: Value(jsonEncode(remoteOp.fieldPaths)),
            occurredAt: Value(remoteOp.occurredAt),
            syncStatus: const Value('synced'),
          ),
        );
  }

  Future<void> _applyRemoteOperation(ChangeOperation remoteOp) async {
    if (remoteOp.entityType == 'recipe') {
      if (remoteOp.opType == OperationType.delete) {
        await (_db.update(_db.recipesTable)..where((r) => r.id.equals(remoteOp.entityId))).write(
          RecipesTableCompanion(
            deletedAt: Value(remoteOp.occurredAt),
            updatedAt: Value(remoteOp.occurredAt),
          ),
        );
      } else {
        final payload = remoteOp.payload;
        await _db.into(_db.recipesTable).insertOnConflictUpdate(
              RecipesTableCompanion(
                id: Value(remoteOp.entityId),
                profileId: Value(remoteOp.profileId),
                title: Value(payload['title'] as String? ?? 'Imported Recipe'),
                slug: Value((payload['title'] as String? ?? 'imported').toLowerCase().replaceAll(' ', '-')),
                summary: Value(payload['summary'] as String?),
                status: Value(payload['status'] as String? ?? 'ready'),
                difficulty: Value(payload['difficulty'] as String? ?? 'medium'),
                totalMinutes: Value((payload['totalMinutes'] as num?)?.toInt() ?? 30),
                baseServingsNum: Value((payload['baseServingsNum'] as num?)?.toInt() ?? 2),
                baseServingsDen: Value((payload['baseServingsDen'] as num?)?.toInt() ?? 1),
                createdAt: Value(remoteOp.occurredAt),
                updatedAt: Value(remoteOp.occurredAt),
                version: Value(remoteOp.baseVersion + 1),
                origin: const Value('remote_sync'),
              ),
            );
      }
    } else if (remoteOp.entityType == 'collection') {
      if (remoteOp.opType == OperationType.delete) {
        await (_db.delete(_db.collectionsTable)..where((c) => c.id.equals(remoteOp.entityId))).go();
      } else {
        final payload = remoteOp.payload;
        await _db.into(_db.collectionsTable).insertOnConflictUpdate(
              CollectionsTableCompanion(
                id: Value(remoteOp.entityId),
                profileId: Value(remoteOp.profileId),
                name: Value(payload['name'] as String? ?? 'Synced Collection'),
                colorToken: Value(payload['colorToken'] as String? ?? 'accent.herb'),
                description: Value(payload['description'] as String?),
                createdAt: Value(remoteOp.occurredAt),
                updatedAt: Value(remoteOp.occurredAt),
              ),
            );
      }
    }
  }

  Future<void> _applyDisjointFieldMerge(ChangeOperation localOp, ChangeOperation remoteOp) async {
    if (remoteOp.entityType == 'recipe') {
      final remotePayload = remoteOp.payload;
      final companion = RecipesTableCompanion(
        id: Value(remoteOp.entityId),
        updatedAt: Value(remoteOp.occurredAt),
        version: Value(remoteOp.baseVersion + 1),
      );

      // Only apply fields not touched by localOp
      if (!localOp.fieldPaths.contains('/difficulty') && remotePayload.containsKey('difficulty')) {
        companion.copyWith(difficulty: Value(remotePayload['difficulty'] as String));
      }
      if (!localOp.fieldPaths.contains('/totalMinutes') && remotePayload.containsKey('totalMinutes')) {
        companion.copyWith(totalMinutes: Value((remotePayload['totalMinutes'] as num).toInt()));
      }
      if (!localOp.fieldPaths.contains('/summary') && remotePayload.containsKey('summary')) {
        companion.copyWith(summary: Value(remotePayload['summary'] as String?));
      }

      await _db.into(_db.recipesTable).insertOnConflictUpdate(companion);
    }
  }

  Future<Map<String, dynamic>?> _loadEntitySnapshot(String entityType, String entityId) async {
    if (entityType == 'recipe') {
      final row = await (_db.select(_db.recipesTable)..where((r) => r.id.equals(entityId))).getSingleOrNull();
      if (row == null) return null;
      return {
        'id': row.id,
        'title': row.title,
        'summary': row.summary,
        'difficulty': row.difficulty,
        'totalMinutes': row.totalMinutes,
        'servings': '${row.baseServingsNum}/${row.baseServingsDen}',
        'version': row.version,
      };
    }
    return null;
  }

  @override
  Future<Result<bool, AppFailure>> resolveConflict(
    String conflictId,
    SyncResolution resolution,
  ) async {
    final idx = _pendingConflicts.indexWhere((c) => c.conflictId == conflictId);
    if (idx == -1) {
      return Result.err(NotFoundFailure(resourceType: 'SyncConflict', resourceId: conflictId));
    }

    final conflict = _pendingConflicts[idx];
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    try {
      if (resolution.strategy == SyncResolutionStrategy.keepLocal) {
        // Re-queue local operation with higher base version to overwrite server
        await (_db.update(_db.changeOperationsTable)
              ..where((o) => o.operationId.equals(conflict.localOperation.operationId)))
            .write(ChangeOperationsTableCompanion(
          syncStatus: const Value('pending'),
          baseVersion: Value(conflict.remoteOperation.baseVersion + 1),
          occurredAt: Value(now),
        ));
      } else if (resolution.strategy == SyncResolutionStrategy.keepRemote) {
        // Apply remote snapshot to local DB
        await _applyRemoteOperation(conflict.remoteOperation);

        // Mark local conflicting operation as synced/resolved
        await (_db.update(_db.changeOperationsTable)
              ..where((o) => o.operationId.equals(conflict.localOperation.operationId)))
            .write(const ChangeOperationsTableCompanion(
          syncStatus: Value('synced'),
        ));
      } else if (resolution.strategy == SyncResolutionStrategy.fieldMerge) {
        final merged = resolution.mergedSnapshot ?? {};
        if (conflict.entityType == 'recipe') {
          await (_db.update(_db.recipesTable)..where((r) => r.id.equals(conflict.entityId)))
              .write(RecipesTableCompanion(
            title: merged.containsKey('title') ? Value(merged['title'] as String) : const Value.absent(),
            summary: merged.containsKey('summary') ? Value(merged['summary'] as String?) : const Value.absent(),
            difficulty: merged.containsKey('difficulty') ? Value(merged['difficulty'] as String) : const Value.absent(),
            totalMinutes: merged.containsKey('totalMinutes') ? Value((merged['totalMinutes'] as num).toInt()) : const Value.absent(),
            updatedAt: Value(now),
            version: Value(conflict.remoteOperation.baseVersion + 1),
          ));

          // Log new resolved operation
          await _db.into(_db.changeOperationsTable).insert(
                ChangeOperationsTableCompanion(
                  operationId: Value(_uuid.v4()),
                  profileId: Value(conflict.localOperation.profileId),
                  entityType: const Value('recipe'),
                  entityId: Value(conflict.entityId),
                  opType: const Value('upsert'),
                  baseVersion: Value(conflict.remoteOperation.baseVersion + 1),
                  payloadJson: Value(jsonEncode(merged)),
                  fieldPathsJson: const Value('["/"]'),
                  occurredAt: Value(now),
                  syncStatus: const Value('pending'),
                ),
              );
        }
      }

      _pendingConflicts.removeAt(idx);
      _notifyConflicts();

      final phase = _pendingConflicts.isNotEmpty
          ? SyncStatusPhase.conflictsPending
          : SyncStatusPhase.idle;

      _updateState(_currentState.copyWith(
        phase: phase,
        conflictCount: _pendingConflicts.length,
      ));

      return Result.ok(true);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to resolve conflict: $e', cause: e));
    }
  }

  void dispose() {
    _stateController.close();
    _conflictsController.close();
  }
}
