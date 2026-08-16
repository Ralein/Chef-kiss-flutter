import 'package:recipe_domain/recipe_domain.dart';
import '../result.dart';
import '../failures.dart';

class PushResult {
  final List<String> ackedOperationIds;
  final Map<String, String> rejectedOperationIds;
  final int serverOccurredAt;
  final Map<String, String> newCursors;

  const PushResult({
    required this.ackedOperationIds,
    this.rejectedOperationIds = const {},
    required this.serverOccurredAt,
    this.newCursors = const {},
  });
}

class PullResult {
  final List<ChangeOperation> operations;
  final Map<String, String> newCursors;
  final bool hasMore;

  const PullResult({
    required this.operations,
    required this.newCursors,
    this.hasMore = false,
  });
}

enum SyncStatusPhase {
  idle,
  syncing,
  offline,
  error,
  conflictsPending,
}

class SyncEngineState {
  final SyncStatusPhase phase;
  final int? lastSyncAt;
  final int pendingOpCount;
  final int conflictCount;
  final String? lastErrorMessage;

  const SyncEngineState({
    this.phase = SyncStatusPhase.idle,
    this.lastSyncAt,
    this.pendingOpCount = 0,
    this.conflictCount = 0,
    this.lastErrorMessage,
  });

  bool get isSyncing => phase == SyncStatusPhase.syncing;
  bool get hasConflicts => conflictCount > 0;

  SyncEngineState copyWith({
    SyncStatusPhase? phase,
    int? lastSyncAt,
    int? pendingOpCount,
    int? conflictCount,
    String? lastErrorMessage,
  }) {
    return SyncEngineState(
      phase: phase ?? this.phase,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      pendingOpCount: pendingOpCount ?? this.pendingOpCount,
      conflictCount: conflictCount ?? this.conflictCount,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
    );
  }
}

class SyncSummary {
  final int pushedCount;
  final int pulledCount;
  final int conflictsCount;
  final int timestamp;

  const SyncSummary({
    required this.pushedCount,
    required this.pulledCount,
    required this.conflictsCount,
    required this.timestamp,
  });
}

abstract interface class SyncServerAdapter {
  Future<Result<PushResult, AppFailure>> pushOperations(
    AuthSession session,
    List<ChangeOperation> operations,
  );

  Future<Result<PullResult, AppFailure>> pullChanges(
    AuthSession session,
    Map<String, String> cursorsByScope,
  );

  Future<Result<String, AppFailure>> uploadEncryptedBackup(
    AuthSession session,
    EncryptedRemoteBackupEnvelope envelope,
  );

  Future<Result<List<RemoteBackupSnapshotMeta>, AppFailure>> listEncryptedBackups(
    AuthSession session,
  );

  Future<Result<EncryptedRemoteBackupEnvelope, AppFailure>> downloadEncryptedBackup(
    AuthSession session,
    String snapshotId,
  );

  Future<Result<bool, AppFailure>> deleteEncryptedBackup(
    AuthSession session,
    String snapshotId,
  );

  Future<Result<bool, AppFailure>> purgeUserData(
    AuthSession session,
  );
}

abstract interface class SyncMediator {
  Future<Result<SyncSummary, AppFailure>> synchronize({bool force = false});

  Future<Result<bool, AppFailure>> resolveConflict(
    String conflictId,
    SyncResolution resolution,
  );

  Stream<SyncEngineState> watchSyncState();

  Stream<List<SyncConflict>> watchPendingConflicts();

  Future<List<SyncConflict>> getPendingConflicts();
}

abstract interface class AuthRepository {
  Future<Result<AuthSession, AppFailure>> signIn({
    required String email,
    required String password,
  });

  Future<Result<AuthSession, AppFailure>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Result<void, AppFailure>> signOut();

  Stream<AuthSession> watchSession();

  AuthSession getCurrentSession();

  Future<Result<bool, AppFailure>> deleteAccount();
}

abstract interface class RemoteBackupRepository {
  Future<Result<RemoteBackupSnapshotMeta, AppFailure>> createAndUploadBackup({
    required String passphrase,
  });

  Future<Result<List<RemoteBackupSnapshotMeta>, AppFailure>> listSnapshots();

  Future<Result<int, AppFailure>> restoreSnapshot({
    required String snapshotId,
    required String passphrase,
    DuplicatePolicy duplicatePolicy = DuplicatePolicy.keepBoth,
  });

  Future<Result<bool, AppFailure>> deleteSnapshot(String snapshotId);
}
