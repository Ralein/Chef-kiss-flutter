import 'dart:convert';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import 'package:uuid/uuid.dart';

class InMemoryCloudSyncServer implements SyncServerAdapter {
  final Uuid _uuid = const Uuid();

  // In-memory persistent data structures keyed by userId
  final Map<String, List<_ServerStoredOperation>> _userOperations = {};
  final Map<String, Map<String, EncryptedRemoteBackupEnvelope>> _userVaults = {};
  final Map<String, Map<String, String>> _userCredentials = {}; // email -> {password, userId, displayName}
  final Set<String> _activeSessions = {}; // token -> userId

  InMemoryCloudSyncServer() {
    // Seed a default test account
    _userCredentials['chef@example.com'] = {
      'userId': 'usr_test_default',
      'password': 'Password123!',
      'displayName': 'Head Chef',
    };
  }

  Result<String, AppFailure> _validateSession(AuthSession session) {
    if (!session.isAuthenticated || session.user == null) {
      return Result.err(const PermissionDeniedFailure(
        capability: 'cloud_sync',
        message: 'Valid authentication session required to access cloud services.',
      ));
    }
    return Result.ok(session.user!.id);
  }

  // Account helpers for testing / mock authentication
  Future<Result<AuthSession, AppFailure>> mockAuthenticate(String email, String password) async {
    final creds = _userCredentials[email.trim().toLowerCase()];
    if (creds == null || creds['password'] != password) {
      return Result.err(const ValidationFailure(
        message: 'Invalid email or password.',
      ));
    }

    final userId = creds['userId']!;
    final token = 'tok_${_uuid.v4()}';
    _activeSessions.add(token);

    final session = AuthSession(
      user: AuthUser(
        id: userId,
        email: email,
        displayName: creds['displayName'] ?? 'Cook',
        createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
      ),
      accessToken: token,
      status: AuthSessionStatus.authenticated,
    );

    return Result.ok(session);
  }

  Future<Result<AuthSession, AppFailure>> mockRegister(String email, String password, String displayName) async {
    final cleanEmail = email.trim().toLowerCase();
    if (_userCredentials.containsKey(cleanEmail)) {
      return Result.err(const ConflictFailure(
        conflictingVersionId: 'account_exists',
        message: 'An account with this email already exists.',
      ));
    }

    final userId = 'usr_${_uuid.v4().substring(0, 8)}';
    _userCredentials[cleanEmail] = {
      'userId': userId,
      'password': password,
      'displayName': displayName,
    };

    return mockAuthenticate(cleanEmail, password);
  }

  final Map<String, int> _entityVersions = {};

  @override
  Future<Result<PushResult, AppFailure>> pushOperations(
    AuthSession session,
    List<ChangeOperation> operations,
  ) async {
    final authRes = _validateSession(session);
    if (authRes.isFailure) return Result.err(authRes.error!);
    final userId = authRes.orNull!;

    final opList = _userOperations.putIfAbsent(userId, () => []);
    final acked = <String>[];
    final rejected = <String, String>{};
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    for (final op in operations) {
      // Deduplicate if already stored
      final existingIndex = opList.indexWhere((o) => o.operation.operationId == op.operationId);
      if (existingIndex != -1) {
        acked.add(op.operationId);
        continue;
      }

      final entityKey = '$userId:${op.entityType}:${op.entityId}';
      final currentServerVersion = _entityVersions[entityKey] ?? 0;

      // Check for remote conflict: has the entity advanced beyond the client's baseVersion?
      if (currentServerVersion > op.baseVersion) {
        final latestForEntity = opList
            .where((o) => o.operation.entityId == op.entityId && o.operation.entityType == op.entityType)
            .toList();

        if (latestForEntity.isNotEmpty) {
          final serverLatest = latestForEntity.last.operation;
          final overlaps = op.fieldPaths.any((p) => serverLatest.fieldPaths.contains(p)) ||
              op.fieldPaths.contains('/') ||
              serverLatest.fieldPaths.contains('/');
          if (overlaps) {
            rejected[op.operationId] = 'Version conflict on field paths ${op.fieldPaths}';
            continue;
          }
        }
      }

      _entityVersions[entityKey] = currentServerVersion == 0 ? op.baseVersion : (op.baseVersion + 1);
      final seq = opList.length + 1;
      final serverOp = _ServerStoredOperation(
        sequence: seq,
        operation: op.copyWith(
          syncStatus: SyncStatus.synced,
          occurredAt: now,
        ),
      );
      opList.add(serverOp);
      acked.add(op.operationId);
    }

    final currentSeq = opList.length.toString();
    final newCursors = {
      'recipes': currentSeq,
      'collections': currentSeq,
      'settings': currentSeq,
    };

    return Result.ok(PushResult(
      ackedOperationIds: acked,
      rejectedOperationIds: rejected,
      serverOccurredAt: now,
      newCursors: newCursors,
    ));
  }

  @override
  Future<Result<PullResult, AppFailure>> pullChanges(
    AuthSession session,
    Map<String, String> cursorsByScope,
  ) async {
    final authRes = _validateSession(session);
    if (authRes.isFailure) return Result.err(authRes.error!);
    final userId = authRes.orNull!;

    final opList = _userOperations[userId] ?? [];

    // Determine highest cursor across scopes
    var minCursorSeq = 0;
    for (final c in cursorsByScope.values) {
      final parsed = int.tryParse(c) ?? 0;
      if (parsed > minCursorSeq) minCursorSeq = parsed;
    }

    final newOps = opList
        .where((o) => o.sequence > minCursorSeq)
        .map((o) => o.operation)
        .toList();

    final maxSeq = opList.length.toString();
    final newCursors = {
      'recipes': maxSeq,
      'collections': maxSeq,
      'settings': maxSeq,
    };

    return Result.ok(PullResult(
      operations: newOps,
      newCursors: newCursors,
      hasMore: false,
    ));
  }

  @override
  Future<Result<String, AppFailure>> uploadEncryptedBackup(
    AuthSession session,
    EncryptedRemoteBackupEnvelope envelope,
  ) async {
    final authRes = _validateSession(session);
    if (authRes.isFailure) return Result.err(authRes.error!);
    final userId = authRes.orNull!;

    final vault = _userVaults.putIfAbsent(userId, () => {});
    vault[envelope.snapshotId] = envelope;

    return Result.ok(envelope.snapshotId);
  }

  @override
  Future<Result<List<RemoteBackupSnapshotMeta>, AppFailure>> listEncryptedBackups(
    AuthSession session,
  ) async {
    final authRes = _validateSession(session);
    if (authRes.isFailure) return Result.err(authRes.error!);
    final userId = authRes.orNull!;

    final vault = _userVaults[userId] ?? {};
    final list = vault.values.map((env) {
      final size = utf8.encode(env.ciphertext).length;
      return RemoteBackupSnapshotMeta(
        snapshotId: env.snapshotId,
        createdAt: env.createdAt,
        itemCount: env.itemCount,
        sha256Digest: env.sha256Digest,
        sizeBytes: size,
      );
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Result.ok(list);
  }

  @override
  Future<Result<EncryptedRemoteBackupEnvelope, AppFailure>> downloadEncryptedBackup(
    AuthSession session,
    String snapshotId,
  ) async {
    final authRes = _validateSession(session);
    if (authRes.isFailure) return Result.err(authRes.error!);
    final userId = authRes.orNull!;

    final vault = _userVaults[userId] ?? {};
    final env = vault[snapshotId];
    if (env == null) {
      return Result.err(NotFoundFailure(resourceType: 'RemoteBackup', resourceId: snapshotId));
    }

    return Result.ok(env);
  }

  @override
  Future<Result<bool, AppFailure>> deleteEncryptedBackup(
    AuthSession session,
    String snapshotId,
  ) async {
    final authRes = _validateSession(session);
    if (authRes.isFailure) return Result.err(authRes.error!);
    final userId = authRes.orNull!;

    final vault = _userVaults[userId];
    if (vault != null) {
      vault.remove(snapshotId);
    }
    return Result.ok(true);
  }

  @override
  Future<Result<bool, AppFailure>> purgeUserData(AuthSession session) async {
    final authRes = _validateSession(session);
    if (authRes.isFailure) return Result.err(authRes.error!);
    final userId = authRes.orNull!;

    _userOperations.remove(userId);
    _userVaults.remove(userId);
    _userCredentials.removeWhere((_, creds) => creds['userId'] == userId);
    _activeSessions.remove(session.accessToken);

    return Result.ok(true);
  }
}

class _ServerStoredOperation {
  final int sequence;
  final ChangeOperation operation;

  const _ServerStoredOperation({
    required this.sequence,
    required this.operation,
  });
}
