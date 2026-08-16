import 'package:recipe_domain/recipe_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ChangeOperation Domain Model', () {
    test('serializes and deserializes correctly', () {
      final op = ChangeOperation(
        operationId: 'op_test_1',
        profileId: 'prof_1',
        entityType: 'recipe',
        entityId: 'rec_100',
        opType: OperationType.upsert,
        baseVersion: 2,
        payload: {
          'title': 'Garlic Bread',
          'difficulty': 'easy',
        },
        fieldPaths: const ['/title', '/difficulty'],
        occurredAt: 1700000000000,
        syncStatus: SyncStatus.pending,
        deviceId: 'macbook_pro',
      );

      final json = op.toJson();
      final fromJson = ChangeOperation.fromJson(json);

      expect(fromJson.operationId, equals('op_test_1'));
      expect(fromJson.profileId, equals('prof_1'));
      expect(fromJson.entityType, equals('recipe'));
      expect(fromJson.entityId, equals('rec_100'));
      expect(fromJson.opType, equals(OperationType.upsert));
      expect(fromJson.baseVersion, equals(2));
      expect(fromJson.payload['title'], equals('Garlic Bread'));
      expect(fromJson.fieldPaths, equals(['/title', '/difficulty']));
      expect(fromJson.syncStatus, equals(SyncStatus.pending));
      expect(fromJson.deviceId, equals('macbook_pro'));
      expect(fromJson, equals(op));
    });
  });

  group('SyncConflict Domain Model', () {
    test('serializes and deserializes conflict model', () {
      final localOp = ChangeOperation(
        operationId: 'op_local_1',
        profileId: 'prof_1',
        entityType: 'recipe',
        entityId: 'rec_1',
        opType: OperationType.upsert,
        baseVersion: 1,
        payload: {'title': 'My Version of Sauce'},
        fieldPaths: const ['/title'],
        occurredAt: 1700000001000,
      );

      final remoteOp = ChangeOperation(
        operationId: 'op_remote_1',
        profileId: 'prof_1',
        entityType: 'recipe',
        entityId: 'rec_1',
        opType: OperationType.upsert,
        baseVersion: 1,
        payload: {'title': 'Cloud Version of Sauce'},
        fieldPaths: const ['/title'],
        occurredAt: 1700000002000,
      );

      final conflict = SyncConflict(
        conflictId: 'conf_1',
        entityType: 'recipe',
        entityId: 'rec_1',
        localOperation: localOp,
        remoteOperation: remoteOp,
        localSnapshot: {'title': 'My Version of Sauce'},
        remoteSnapshot: {'title': 'Cloud Version of Sauce'},
        conflictingFields: const ['/title'],
        detectedAt: 1700000003000,
      );

      final json = conflict.toJson();
      final fromJson = SyncConflict.fromJson(json);

      expect(fromJson.conflictId, equals('conf_1'));
      expect(fromJson.conflictingFields, equals(['/title']));
      expect(fromJson.localOperation.operationId, equals('op_local_1'));
      expect(fromJson.remoteOperation.operationId, equals('op_remote_1'));
    });
  });

  group('EncryptedRemoteBackupEnvelope', () {
    test('serializes and deserializes envelope', () {
      const envelope = EncryptedRemoteBackupEnvelope(
        snapshotId: 'snap_001',
        userId: 'usr_1',
        profileId: 'default',
        createdAt: 1700000000000,
        algorithm: 'AES-256-GCM+PBKDF2',
        salt: 'c2FsdA==',
        iv: 'aXY=',
        ciphertext: 'Y2lwaGVydGV4dA==',
        sha256Digest: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        itemCount: 12,
      );

      final json = envelope.toJson();
      final fromJson = EncryptedRemoteBackupEnvelope.fromJson(json);

      expect(fromJson.snapshotId, equals('snap_001'));
      expect(fromJson.userId, equals('usr_1'));
      expect(fromJson.itemCount, equals(12));
      expect(fromJson.sha256Digest, equals('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'));
    });
  });
}
