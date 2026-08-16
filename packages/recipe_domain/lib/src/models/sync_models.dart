import 'package:meta/meta.dart';

enum SyncStatus {
  localOnly,
  pending,
  synced,
  conflict,
  rejected;

  String toDbString() => name;

  static SyncStatus fromDbString(String val) {
    return SyncStatus.values.firstWhere(
      (e) => e.name == val,
      orElse: () => SyncStatus.localOnly,
    );
  }
}

enum OperationType {
  upsert,
  delete,
  patch;

  String toDbString() => name;

  static OperationType fromDbString(String val) {
    return OperationType.values.firstWhere(
      (e) => e.name == val,
      orElse: () => OperationType.upsert,
    );
  }
}

@immutable
class ChangeOperation {
  final String operationId;
  final String profileId;
  final String entityType;
  final String entityId;
  final OperationType opType;
  final int baseVersion;
  final Map<String, dynamic> payload;
  final List<String> fieldPaths;
  final int occurredAt;
  final SyncStatus syncStatus;
  final String deviceId;
  final int attemptCount;
  final List<String> dependsOn;

  const ChangeOperation({
    required this.operationId,
    required this.profileId,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.baseVersion,
    required this.payload,
    this.fieldPaths = const ['/'],
    required this.occurredAt,
    this.syncStatus = SyncStatus.localOnly,
    this.deviceId = 'local_device',
    this.attemptCount = 0,
    this.dependsOn = const [],
  });

  ChangeOperation copyWith({
    String? operationId,
    String? profileId,
    String? entityType,
    String? entityId,
    OperationType? opType,
    int? baseVersion,
    Map<String, dynamic>? payload,
    List<String>? fieldPaths,
    int? occurredAt,
    SyncStatus? syncStatus,
    String? deviceId,
    int? attemptCount,
    List<String>? dependsOn,
  }) {
    return ChangeOperation(
      operationId: operationId ?? this.operationId,
      profileId: profileId ?? this.profileId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      opType: opType ?? this.opType,
      baseVersion: baseVersion ?? this.baseVersion,
      payload: payload ?? this.payload,
      fieldPaths: fieldPaths ?? this.fieldPaths,
      occurredAt: occurredAt ?? this.occurredAt,
      syncStatus: syncStatus ?? this.syncStatus,
      deviceId: deviceId ?? this.deviceId,
      attemptCount: attemptCount ?? this.attemptCount,
      dependsOn: dependsOn ?? this.dependsOn,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operation_id': operationId,
      'profile_id': profileId,
      'entity_type': entityType,
      'entity_id': entityId,
      'op_type': opType.name,
      'base_version': baseVersion,
      'payload': payload,
      'field_paths': fieldPaths,
      'occurred_at': occurredAt,
      'sync_status': syncStatus.name,
      'device_id': deviceId,
      'attempt_count': attemptCount,
      'depends_on': dependsOn,
    };
  }

  factory ChangeOperation.fromJson(Map<String, dynamic> json) {
    return ChangeOperation(
      operationId: json['operation_id'] as String,
      profileId: (json['profile_id'] as String?) ?? 'default',
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      opType: OperationType.fromDbString((json['op_type'] as String?) ?? 'upsert'),
      baseVersion: (json['base_version'] as num?)?.toInt() ?? 1,
      payload: (json['payload'] as Map<String, dynamic>?) ?? {},
      fieldPaths: (json['field_paths'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const ['/'],
      occurredAt: (json['occurred_at'] as num?)?.toInt() ?? DateTime.now().toUtc().millisecondsSinceEpoch,
      syncStatus: SyncStatus.fromDbString((json['sync_status'] as String?) ?? 'local_only'),
      deviceId: (json['device_id'] as String?) ?? 'unknown_device',
      attemptCount: (json['attempt_count'] as num?)?.toInt() ?? 0,
      dependsOn: (json['depends_on'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeOperation &&
          runtimeType == other.runtimeType &&
          operationId == other.operationId;

  @override
  int get hashCode => operationId.hashCode;
}

@immutable
class SyncCursor {
  final String profileId;
  final String scope;
  final String cursor;
  final int? lastSuccessAt;
  final String? lastErrorCode;

  const SyncCursor({
    required this.profileId,
    required this.scope,
    required this.cursor,
    this.lastSuccessAt,
    this.lastErrorCode,
  });

  Map<String, dynamic> toJson() => {
        'profile_id': profileId,
        'scope': scope,
        'cursor': cursor,
        'last_success_at': lastSuccessAt,
        'last_error_code': lastErrorCode,
      };

  factory SyncCursor.fromJson(Map<String, dynamic> json) => SyncCursor(
        profileId: json['profile_id'] as String,
        scope: json['scope'] as String,
        cursor: json['cursor'] as String,
        lastSuccessAt: (json['last_success_at'] as num?)?.toInt(),
        lastErrorCode: json['last_error_code'] as String?,
      );
}

@immutable
class SyncConflict {
  final String conflictId;
  final String entityType;
  final String entityId;
  final ChangeOperation localOperation;
  final ChangeOperation remoteOperation;
  final Map<String, dynamic> localSnapshot;
  final Map<String, dynamic> remoteSnapshot;
  final List<String> conflictingFields;
  final int detectedAt;
  final bool isResolved;

  const SyncConflict({
    required this.conflictId,
    required this.entityType,
    required this.entityId,
    required this.localOperation,
    required this.remoteOperation,
    required this.localSnapshot,
    required this.remoteSnapshot,
    required this.conflictingFields,
    required this.detectedAt,
    this.isResolved = false,
  });

  SyncConflict copyWith({
    String? conflictId,
    String? entityType,
    String? entityId,
    ChangeOperation? localOperation,
    ChangeOperation? remoteOperation,
    Map<String, dynamic>? localSnapshot,
    Map<String, dynamic>? remoteSnapshot,
    List<String>? conflictingFields,
    int? detectedAt,
    bool? isResolved,
  }) {
    return SyncConflict(
      conflictId: conflictId ?? this.conflictId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      localOperation: localOperation ?? this.localOperation,
      remoteOperation: remoteOperation ?? this.remoteOperation,
      localSnapshot: localSnapshot ?? this.localSnapshot,
      remoteSnapshot: remoteSnapshot ?? this.remoteSnapshot,
      conflictingFields: conflictingFields ?? this.conflictingFields,
      detectedAt: detectedAt ?? this.detectedAt,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  Map<String, dynamic> toJson() => {
        'conflict_id': conflictId,
        'entity_type': entityType,
        'entity_id': entityId,
        'local_operation': localOperation.toJson(),
        'remote_operation': remoteOperation.toJson(),
        'local_snapshot': localSnapshot,
        'remote_snapshot': remoteSnapshot,
        'conflicting_fields': conflictingFields,
        'detected_at': detectedAt,
        'is_resolved': isResolved,
      };

  factory SyncConflict.fromJson(Map<String, dynamic> json) => SyncConflict(
        conflictId: json['conflict_id'] as String,
        entityType: json['entity_type'] as String,
        entityId: json['entity_id'] as String,
        localOperation: ChangeOperation.fromJson(json['local_operation'] as Map<String, dynamic>),
        remoteOperation: ChangeOperation.fromJson(json['remote_operation'] as Map<String, dynamic>),
        localSnapshot: (json['local_snapshot'] as Map<String, dynamic>?) ?? {},
        remoteSnapshot: (json['remote_snapshot'] as Map<String, dynamic>?) ?? {},
        conflictingFields: (json['conflicting_fields'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
        detectedAt: (json['detected_at'] as num?)?.toInt() ?? 0,
        isResolved: (json['is_resolved'] as bool?) ?? false,
      );
}

enum SyncResolutionStrategy {
  keepLocal,
  keepRemote,
  fieldMerge,
}

@immutable
class SyncResolution {
  final SyncResolutionStrategy strategy;
  final Map<String, dynamic>? mergedSnapshot;
  final String? resolvedBy;
  final int resolvedAt;

  const SyncResolution({
    required this.strategy,
    this.mergedSnapshot,
    this.resolvedBy,
    required this.resolvedAt,
  });
}

enum AuthSessionStatus {
  unauthenticated,
  authenticating,
  authenticated,
  offline,
}

@immutable
class AuthUser {
  final String id;
  final String email;
  final String displayName;
  final int createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'created_at': createdAt,
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: (json['display_name'] as String?) ?? '',
        createdAt: (json['created_at'] as num?)?.toInt() ?? 0,
      );
}

@immutable
class AuthSession {
  final AuthUser? user;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresAt;
  final AuthSessionStatus status;

  const AuthSession({
    this.user,
    this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.status = AuthSessionStatus.unauthenticated,
  });

  bool get isAuthenticated => status == AuthSessionStatus.authenticated && user != null;

  AuthSession copyWith({
    AuthUser? user,
    String? accessToken,
    String? refreshToken,
    int? expiresAt,
    AuthSessionStatus? status,
  }) {
    return AuthSession(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user?.toJson(),
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_at': expiresAt,
        'status': status.name,
      };

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        user: json['user'] != null ? AuthUser.fromJson(json['user'] as Map<String, dynamic>) : null,
        accessToken: json['access_token'] as String?,
        refreshToken: json['refresh_token'] as String?,
        expiresAt: (json['expires_at'] as num?)?.toInt(),
        status: AuthSessionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => AuthSessionStatus.unauthenticated,
        ),
      );

  static const unauthenticated = AuthSession(status: AuthSessionStatus.unauthenticated);
}

@immutable
class EncryptedRemoteBackupEnvelope {
  final String snapshotId;
  final String userId;
  final String profileId;
  final int createdAt;
  final String algorithm;
  final String salt;
  final String iv;
  final String ciphertext;
  final String sha256Digest;
  final int itemCount;
  final int schemaVersion;

  const EncryptedRemoteBackupEnvelope({
    required this.snapshotId,
    required this.userId,
    required this.profileId,
    required this.createdAt,
    this.algorithm = 'AES-256-GCM+PBKDF2',
    required this.salt,
    required this.iv,
    required this.ciphertext,
    required this.sha256Digest,
    required this.itemCount,
    this.schemaVersion = 1,
  });

  Map<String, dynamic> toJson() => {
        'snapshot_id': snapshotId,
        'user_id': userId,
        'profile_id': profileId,
        'created_at': createdAt,
        'algorithm': algorithm,
        'salt': salt,
        'iv': iv,
        'ciphertext': ciphertext,
        'sha256_digest': sha256Digest,
        'item_count': itemCount,
        'schema_version': schemaVersion,
      };

  factory EncryptedRemoteBackupEnvelope.fromJson(Map<String, dynamic> json) =>
      EncryptedRemoteBackupEnvelope(
        snapshotId: json['snapshot_id'] as String,
        userId: json['user_id'] as String,
        profileId: (json['profile_id'] as String?) ?? 'default',
        createdAt: (json['created_at'] as num?)?.toInt() ?? 0,
        algorithm: (json['algorithm'] as String?) ?? 'AES-256-GCM+PBKDF2',
        salt: json['salt'] as String,
        iv: json['iv'] as String,
        ciphertext: json['ciphertext'] as String,
        sha256Digest: json['sha256_digest'] as String,
        itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
        schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 1,
      );
}

@immutable
class RemoteBackupSnapshotMeta {
  final String snapshotId;
  final int createdAt;
  final int itemCount;
  final String sha256Digest;
  final int sizeBytes;

  const RemoteBackupSnapshotMeta({
    required this.snapshotId,
    required this.createdAt,
    required this.itemCount,
    required this.sha256Digest,
    required this.sizeBytes,
  });

  Map<String, dynamic> toJson() => {
        'snapshot_id': snapshotId,
        'created_at': createdAt,
        'item_count': itemCount,
        'sha256_digest': sha256Digest,
        'size_bytes': sizeBytes,
      };

  factory RemoteBackupSnapshotMeta.fromJson(Map<String, dynamic> json) =>
      RemoteBackupSnapshotMeta(
        snapshotId: json['snapshot_id'] as String,
        createdAt: (json['created_at'] as num?)?.toInt() ?? 0,
        itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
        sha256Digest: json['sha256_digest'] as String,
        sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
      );
}
