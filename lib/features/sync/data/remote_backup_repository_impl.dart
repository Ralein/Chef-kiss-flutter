import 'dart:convert';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import '../services/cloud_encryption_service.dart';

class RemoteBackupRepositoryImpl implements RemoteBackupRepository {
  final BackupRepository _localBackupRepo;
  final CloudEncryptionService _cryptoService;
  final SyncServerAdapter _server;
  final AuthRepository _authRepo;

  RemoteBackupRepositoryImpl({
    required BackupRepository localBackupRepo,
    required CloudEncryptionService cryptoService,
    required SyncServerAdapter server,
    required AuthRepository authRepo,
  })  : _localBackupRepo = localBackupRepo,
        _cryptoService = cryptoService,
        _server = server,
        _authRepo = authRepo;

  Result<AuthSession, AppFailure> _getAuthenticatedSession() {
    final session = _authRepo.getCurrentSession();
    if (!session.isAuthenticated || session.user == null) {
      return Result.err(const PermissionDeniedFailure(
        capability: 'cloud_backup',
        message: 'Must be logged in to manage cloud backups.',
      ));
    }
    return Result.ok(session);
  }

  @override
  Future<Result<RemoteBackupSnapshotMeta, AppFailure>> createAndUploadBackup({
    required String passphrase,
  }) async {
    final sessionRes = _getAuthenticatedSession();
    if (sessionRes.isFailure) return Result.err(sessionRes.error!);
    final session = sessionRes.orNull!;

    try {
      // 1. Export local JSON backup
      final exportRes = await _localBackupRepo.exportBackupJson(profileId: 'default');
      if (exportRes.isFailure) return Result.err(exportRes.error!);
      final jsonStr = exportRes.orNull!;

      // 2. Parse into package
      final package = ChefBackupPackage.fromJsonString(jsonStr);

      // 3. Encrypt package with user passphrase
      final encRes = await _cryptoService.encryptBackupPackage(
        package: package,
        passphrase: passphrase,
        userId: session.user!.id,
      );
      if (encRes.isFailure) return Result.err(encRes.error!);
      final envelope = encRes.orNull!;

      // 4. Upload to remote vault
      final uploadRes = await _server.uploadEncryptedBackup(session, envelope);
      if (uploadRes.isFailure) return Result.err(uploadRes.error!);

      final meta = RemoteBackupSnapshotMeta(
        snapshotId: envelope.snapshotId,
        createdAt: envelope.createdAt,
        itemCount: envelope.itemCount,
        sha256Digest: envelope.sha256Digest,
        sizeBytes: envelope.ciphertext.length,
      );

      return Result.ok(meta);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to create remote backup: $e', cause: e));
    }
  }

  @override
  Future<Result<List<RemoteBackupSnapshotMeta>, AppFailure>> listSnapshots() async {
    final sessionRes = _getAuthenticatedSession();
    if (sessionRes.isFailure) return Result.err(sessionRes.error!);
    final session = sessionRes.orNull!;

    return _server.listEncryptedBackups(session);
  }

  @override
  Future<Result<int, AppFailure>> restoreSnapshot({
    required String snapshotId,
    required String passphrase,
    DuplicatePolicy duplicatePolicy = DuplicatePolicy.keepBoth,
  }) async {
    final sessionRes = _getAuthenticatedSession();
    if (sessionRes.isFailure) return Result.err(sessionRes.error!);
    final session = sessionRes.orNull!;

    try {
      // 1. Download envelope from vault
      final dlRes = await _server.downloadEncryptedBackup(session, snapshotId);
      if (dlRes.isFailure) return Result.err(dlRes.error!);
      final envelope = dlRes.orNull!;

      // 2. Decrypt envelope
      final decRes = await _cryptoService.decryptBackupPackage(
        envelope: envelope,
        passphrase: passphrase,
      );
      if (decRes.isFailure) return Result.err(decRes.error!);
      final package = decRes.orNull!;

      // 3. Restore to local DB
      final jsonStr = ChefBackupPackage(
        manifest: package.manifest,
        profile: package.profile,
        recipes: package.recipes,
        collections: package.collections,
      ).toJson();

      final restoreRes = await _localBackupRepo.restoreBackupJson(
        jsonStr: jsonEncode(jsonStr),
        duplicatePolicy: duplicatePolicy,
        profileId: 'default',
      );

      return restoreRes;
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to restore remote backup: $e', cause: e));
    }
  }

  @override
  Future<Result<bool, AppFailure>> deleteSnapshot(String snapshotId) async {
    final sessionRes = _getAuthenticatedSession();
    if (sessionRes.isFailure) return Result.err(sessionRes.error!);
    final session = sessionRes.orNull!;

    return _server.deleteEncryptedBackup(session, snapshotId);
  }
}
