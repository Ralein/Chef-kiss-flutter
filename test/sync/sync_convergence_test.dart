import 'dart:convert';
import 'package:test/test.dart';
import 'package:drift/native.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/data/repositories/drift_recipe_repository.dart';
import 'package:chefs_kiss/data/repositories/drift_backup_repository.dart';
import 'package:chefs_kiss/features/sync/data/in_memory_cloud_sync_server.dart';
import 'package:chefs_kiss/features/sync/data/local_auth_repository.dart';
import 'package:chefs_kiss/features/sync/data/drift_sync_mediator.dart';
import 'package:chefs_kiss/features/sync/data/remote_backup_repository_impl.dart';
import 'package:chefs_kiss/features/sync/services/cloud_encryption_service.dart';

void main() {
  late InMemoryCloudSyncServer cloudServer;
  late CloudEncryptionService cryptoService;

  setUp(() {
    cloudServer = InMemoryCloudSyncServer();
    cryptoService = CloudEncryptionService();
  });

  group('Sync & 3-Way Convergence Engine', () {
    test('Device A creates recipe offline -> syncs -> Device B pulls and converges', () async {
      // 1. Setup Device A
      final dbA = AppDatabase(NativeDatabase.memory());
      final authA = LocalAuthRepository(server: cloudServer);
      final syncA = DriftSyncMediator(db: dbA, server: cloudServer, authRepo: authA);
      final recipeRepoA = DriftRecipeRepository(dbA);

      // Sign in on Device A
      final authResA = await authA.signIn(email: 'chef@example.com', password: 'Password123!');
      expect(authResA.isSuccess, isTrue);

      // Device A creates a recipe offline (saves to SQLite + logs ChangeOperation)
      final recipeA = Recipe(
        id: 'rec_cross_1',
        profileId: 'default',
        title: 'Authentic Carbonara',
        summary: 'Egg yolk and guanciale pasta.',
        status: RecipeStatus.ready,
        baseServings: Rational(2),
        difficulty: RecipeDifficulty.medium,
        totalMinutes: 20,
        createdAt: 1000,
        updatedAt: 1000,
        ingredients: [
          RecipeIngredient(
            id: 'ing_1',
            recipeId: 'rec_cross_1',
            displayName: 'Guanciale',
            quantity: Rational(150),
            unitCode: 'g',
            position: 1,
          ),
        ],
        steps: const [
          RecipeStep(
            id: 's_1',
            recipeId: 'rec_cross_1',
            position: 1,
            instructionShort: 'Crisp the guanciale.',
          ),
        ],
      );

      final saveResA = await recipeRepoA.saveRecipe(recipeA);
      expect(saveResA.isSuccess, isTrue);

      // Device A synchronizes with Cloud
      final syncResA = await syncA.synchronize();
      expect(syncResA.isSuccess, isTrue);
      expect(syncResA.orNull!.pushedCount, equals(1));

      // 2. Setup Device B
      final dbB = AppDatabase(NativeDatabase.memory());
      final authB = LocalAuthRepository(server: cloudServer);
      final syncB = DriftSyncMediator(db: dbB, server: cloudServer, authRepo: authB);
      final recipeRepoB = DriftRecipeRepository(dbB);

      // Sign in with same account on Device B
      final authResB = await authB.signIn(email: 'chef@example.com', password: 'Password123!');
      expect(authResB.isSuccess, isTrue);

      // Device B pulls changes from Cloud
      final syncResB = await syncB.synchronize();
      expect(syncResB.isSuccess, isTrue);
      expect(syncResB.orNull!.pulledCount, equals(1));

      // Verify Device B now has Authentic Carbonara in its SQLite database!
      final fetchedB = await recipeRepoB.getRecipeById('rec_cross_1');
      expect(fetchedB.isSuccess, isTrue);
      expect(fetchedB.orNull!.title, equals('Authentic Carbonara'));

      await dbA.close();
      await dbB.close();
    });

    test('2-Device concurrent edits with disjoint fields auto-merge cleanly without conflict', () async {
      final dbA = AppDatabase(NativeDatabase.memory());
      final dbB = AppDatabase(NativeDatabase.memory());
      final authA = LocalAuthRepository(server: cloudServer);
      final authB = LocalAuthRepository(server: cloudServer);
      final syncA = DriftSyncMediator(db: dbA, server: cloudServer, authRepo: authA);
      final syncB = DriftSyncMediator(db: dbB, server: cloudServer, authRepo: authB);

      await authA.signIn(email: 'chef@example.com', password: 'Password123!');
      await authB.signIn(email: 'chef@example.com', password: 'Password123!');

      // Base recipe on server
      final baseOp = ChangeOperation(
        operationId: 'op_base',
        profileId: 'default',
        entityType: 'recipe',
        entityId: 'rec_pasta',
        opType: OperationType.upsert,
        baseVersion: 1,
        payload: {
          'title': 'Penne Arrabbiata',
          'difficulty': 'easy',
          'totalMinutes': 15,
        },
        fieldPaths: const ['/'],
        occurredAt: 1000,
      );
      await cloudServer.pushOperations(authA.getCurrentSession(), [baseOp]);

      // Both devices sync base recipe
      await syncA.synchronize();
      await syncB.synchronize();

      // Device B modifies /totalMinutes -> pushes to Cloud
      final opB = ChangeOperation(
        operationId: 'op_b_mod',
        profileId: 'default',
        entityType: 'recipe',
        entityId: 'rec_pasta',
        opType: OperationType.upsert,
        baseVersion: 1,
        payload: {
          'title': 'Penne Arrabbiata',
          'difficulty': 'easy',
          'totalMinutes': 25,
        },
        fieldPaths: const ['/totalMinutes'],
        occurredAt: 2000,
      );
      await cloudServer.pushOperations(authB.getCurrentSession(), [opB]);

      // Device A modifies /difficulty locally offline
      final opA = ChangeOperation(
        operationId: 'op_a_mod',
        profileId: 'default',
        entityType: 'recipe',
        entityId: 'rec_pasta',
        opType: OperationType.upsert,
        baseVersion: 1,
        payload: {
          'title': 'Penne Arrabbiata',
          'difficulty': 'hard',
          'totalMinutes': 15,
        },
        fieldPaths: const ['/difficulty'],
        occurredAt: 2001,
        syncStatus: SyncStatus.pending,
      );
      await dbA.into(dbA.changeOperationsTable).insert(ChangeOperationsTableCompanion.insert(
        operationId: opA.operationId,
        profileId: opA.profileId,
        entityType: opA.entityType,
        entityId: opA.entityId,
        opType: opA.opType.name,
        baseVersion: opA.baseVersion,
        payloadJson: jsonEncode(opA.payload),
        fieldPathsJson: jsonEncode(opA.fieldPaths),
        occurredAt: opA.occurredAt,
      ));

      // Device A synchronizes -> Auto-merge disjoint fields
      final syncResA = await syncA.synchronize();
      expect(syncResA.isSuccess, isTrue);
      expect(syncResA.orNull!.conflictsCount, equals(0));

      final conflicts = await syncA.getPendingConflicts();
      expect(conflicts.isEmpty, isTrue);

      await dbA.close();
      await dbB.close();
    });

    test('2-Device concurrent edits on overlapping field creates SyncConflict and resolves via KeepLocal', () async {
      final dbA = AppDatabase(NativeDatabase.memory());
      final authA = LocalAuthRepository(server: cloudServer);
      final syncA = DriftSyncMediator(db: dbA, server: cloudServer, authRepo: authA);

      await authA.signIn(email: 'chef@example.com', password: 'Password123!');

      // Base recipe
      final baseOp = ChangeOperation(
        operationId: 'op_base_lasagna',
        profileId: 'default',
        entityType: 'recipe',
        entityId: 'rec_lasagna',
        opType: OperationType.upsert,
        baseVersion: 1,
        payload: {'title': 'Lasagna'},
        fieldPaths: const ['/title'],
        occurredAt: 1000,
      );
      await cloudServer.pushOperations(authA.getCurrentSession(), [baseOp]);
      await syncA.synchronize();

      // Cloud gets remote edit on /title from Device B
      final remoteOp = ChangeOperation(
        operationId: 'op_remote_edit',
        profileId: 'default',
        entityType: 'recipe',
        entityId: 'rec_lasagna',
        opType: OperationType.upsert,
        baseVersion: 1,
        payload: {'title': 'Remote Cloud Lasagna'},
        fieldPaths: const ['/title'],
        occurredAt: 2000,
      );
      await cloudServer.pushOperations(authA.getCurrentSession(), [remoteOp]);

      // Device A has local pending edit on same field /title
      await dbA.into(dbA.changeOperationsTable).insert(ChangeOperationsTableCompanion.insert(
        operationId: 'op_local_conflict',
        profileId: 'default',
        entityType: 'recipe',
        entityId: 'rec_lasagna',
        opType: 'upsert',
        baseVersion: 1,
        payloadJson: jsonEncode({'title': 'Local Favorite Lasagna'}),
        fieldPathsJson: jsonEncode(['/title']),
        occurredAt: 2005,
      ));

      // Device A syncs -> Overlapping field triggers conflict!
      final syncRes = await syncA.synchronize();
      expect(syncRes.isSuccess, isTrue);
      expect(syncRes.orNull!.conflictsCount, equals(1));

      final conflicts = await syncA.getPendingConflicts();
      expect(conflicts.length, equals(1));
      expect(conflicts.first.conflictingFields, contains('/title'));

      // User resolves conflict via keepLocal strategy
      final resolveRes = await syncA.resolveConflict(
        conflicts.first.conflictId,
        SyncResolution(
          strategy: SyncResolutionStrategy.keepLocal,
          resolvedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        ),
      );
      expect(resolveRes.isSuccess, isTrue);

      final remainingConflicts = await syncA.getPendingConflicts();
      expect(remainingConflicts.isEmpty, isTrue);

      await dbA.close();
    });
  });

  group('Encrypted Remote Backup Vault', () {
    test('exports, encrypts, uploads to cloud vault, lists, downloads, decrypts, and restores cleanly', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final authRepo = LocalAuthRepository(server: cloudServer);
      final backupRepo = DriftBackupRepository(db);
      final recipeRepo = DriftRecipeRepository(db);

      final remoteBackupRepo = RemoteBackupRepositoryImpl(
        localBackupRepo: backupRepo,
        cryptoService: cryptoService,
        server: cloudServer,
        authRepo: authRepo,
      );

      // Sign in
      await authRepo.signIn(email: 'chef@example.com', password: 'Password123!');

      // Seed a starter recipe in local DB
      await recipeRepo.saveRecipe(Recipe(
        id: 'rec_vault_1',
        profileId: 'default',
        title: 'Secret Sourdough',
        summary: 'Natural levain bread.',
        status: RecipeStatus.ready,
        baseServings: Rational(1),
        difficulty: RecipeDifficulty.hard,
        totalMinutes: 1440,
        createdAt: 1000,
        updatedAt: 1000,
        ingredients: [
          RecipeIngredient(
            id: 'ing_flour',
            recipeId: 'rec_vault_1',
            displayName: 'Bread Flour',
            quantity: Rational(500),
            unitCode: 'g',
            position: 1,
          ),
        ],
        steps: const [
          RecipeStep(
            id: 'st_1',
            recipeId: 'rec_vault_1',
            position: 1,
            instructionShort: 'Bulk ferment at 24C.',
          ),
        ],
      ));

      // 1. Create and upload encrypted backup to Cloud Vault
      const passphrase = 'MyMasterBackupPassword!2026';
      final uploadRes = await remoteBackupRepo.createAndUploadBackup(passphrase: passphrase);
      expect(uploadRes.isSuccess, isTrue);
      final snapshotMeta = uploadRes.orNull!;
      expect(snapshotMeta.itemCount, equals(1));
      expect(snapshotMeta.snapshotId.isNotEmpty, isTrue);

      // 2. List remote snapshots
      final listRes = await remoteBackupRepo.listSnapshots();
      expect(listRes.isSuccess, isTrue);
      expect(listRes.orNull!.length, equals(1));
      expect(listRes.orNull!.first.snapshotId, equals(snapshotMeta.snapshotId));

      // 3. Reset local database completely
      await backupRepo.resetAllData(profileId: 'default');
      final recipesAfterReset = await recipeRepo.getRecipes();
      expect(recipesAfterReset.orNull!.isEmpty, isTrue);

      // 4. Restore from Encrypted Cloud Vault
      final restoreRes = await remoteBackupRepo.restoreSnapshot(
        snapshotId: snapshotMeta.snapshotId,
        passphrase: passphrase,
      );
      expect(restoreRes.isSuccess, isTrue);
      expect(restoreRes.orNull!, equals(1));

      // 5. Verify restored recipe
      final restoredRecipe = await recipeRepo.getRecipeById('rec_vault_1');
      expect(restoredRecipe.isSuccess, isTrue);
      expect(restoredRecipe.orNull!.title, equals('Secret Sourdough'));

      // 6. Delete snapshot
      final delRes = await remoteBackupRepo.deleteSnapshot(snapshotMeta.snapshotId);
      expect(delRes.isSuccess, isTrue);
      final listAfterDel = await remoteBackupRepo.listSnapshots();
      expect(listAfterDel.orNull!.isEmpty, isTrue);

      await db.close();
    });

    test('GDPR account deletion purges all cloud data and resets session', () async {
      final authRepo = LocalAuthRepository(server: cloudServer);
      final regRes = await authRepo.signUp(
        email: 'privacy_user@example.com',
        password: 'PrivacyPassword123!',
        displayName: 'Privacy Cook',
      );
      expect(regRes.isSuccess, isTrue);
      expect(authRepo.getCurrentSession().isAuthenticated, isTrue);

      // Delete account (GDPR wipe)
      final delRes = await authRepo.deleteAccount();
      expect(delRes.isSuccess, isTrue);
      expect(authRepo.getCurrentSession().isAuthenticated, isFalse);

      // Attempting to log back in fails
      final reLogin = await authRepo.signIn(
        email: 'privacy_user@example.com',
        password: 'PrivacyPassword123!',
      );
      expect(reLogin.isFailure, isTrue);
    });
  });
}
