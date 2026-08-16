import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import '../data/db/app_database.dart';
import '../data/repositories/drift_recipe_repository.dart';
import '../data/repositories/drift_cooking_session_repository.dart';
import '../data/repositories/drift_collection_repository.dart';
import '../data/repositories/drift_settings_repository.dart';
import '../data/repositories/drift_backup_repository.dart';
import '../features/illustrations/data/illustration_matcher.dart';
import '../features/illustrations/data/illustration_governance_service.dart';
import '../features/imports/services/heuristic_recipe_extractor.dart';
import '../features/imports/data/local_import_repository.dart';
import '../features/sync/services/cloud_encryption_service.dart';
import '../features/sync/data/in_memory_cloud_sync_server.dart';
import '../features/sync/data/local_auth_repository.dart';
import '../features/sync/data/drift_sync_mediator.dart';
import '../features/sync/data/remote_backup_repository_impl.dart';
import '../features/cook_mode/voice/voice_cook_assistant.dart';

// --- Database & Infrastructure ---

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.defaults();
  ref.onDispose(() => db.close());
  return db;
});

final appLoggerProvider = Provider<AppLogger>((ref) {
  return const StandardAppLogger();
});

// --- Capability Services (with platform fakes/implementations) ---

final screenAwakeServiceProvider = Provider<ScreenAwakeService>((ref) {
  return FakeScreenAwakeService();
});

final localAlertServiceProvider = Provider<LocalAlertService>((ref) {
  return FakeLocalAlertService();
});

final speechOutputServiceProvider = Provider<SpeechOutputService>((ref) {
  return FakeSpeechOutputService();
});

final speechCommandServiceProvider = Provider<SpeechCommandService>((ref) {
  return FakeSpeechCommandService();
});

final voiceCookAssistantProvider = Provider<VoiceCookAssistant>((ref) {
  final tts = ref.watch(speechOutputServiceProvider);
  final commands = ref.watch(speechCommandServiceProvider);
  final logger = ref.watch(appLoggerProvider);
  return VoiceCookAssistant(
    tts: tts,
    speechCommands: commands,
    logger: logger,
  );
});

final illustrationGovernanceServiceProvider = Provider<IllustrationGovernanceService>((ref) {
  final service = IllustrationGovernanceService();
  ref.onDispose(() => service.dispose());
  return service;
});

final illustrationCandidatesStreamProvider = StreamProvider<List<IllustrationCandidate>>((ref) {
  final service = ref.watch(illustrationGovernanceServiceProvider);
  return service.watchCandidates();
});

final illustrationMatcherProvider = Provider<IllustrationMatcher>((ref) {
  return IllustrationMatcher();
});

final recipeExtractionAdapterProvider = Provider<RecipeExtractionAdapter>((ref) {
  return HeuristicRecipeExtractor();
});

// --- Repositories ---

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftRecipeRepository(db);
});

final cookingSessionRepositoryProvider = Provider<CookingSessionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftCookingSessionRepository(db);
});

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftCollectionRepository(db);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftSettingsRepository(db);
});

final importRepositoryProvider = Provider<ImportRepository>((ref) {
  final recipeRepo = ref.watch(recipeRepositoryProvider);
  final extractor = ref.watch(recipeExtractionAdapterProvider);
  return LocalImportRepository(
    recipeRepo: recipeRepo,
    extractor: extractor,
  );
});

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftBackupRepository(db);
});

// --- Cloud Sync, Auth & Encryption Services ---

final cloudSyncServerProvider = Provider<InMemoryCloudSyncServer>((ref) {
  return InMemoryCloudSyncServer();
});

final cloudEncryptionServiceProvider = Provider<CloudEncryptionService>((ref) {
  return CloudEncryptionService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final server = ref.watch(cloudSyncServerProvider);
  final repo = LocalAuthRepository(server: server);
  ref.onDispose(() => repo.dispose());
  return repo;
});

final syncMediatorProvider = Provider<SyncMediator>((ref) {
  final db = ref.watch(databaseProvider);
  final server = ref.watch(cloudSyncServerProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  final mediator = DriftSyncMediator(
    db: db,
    server: server,
    authRepo: authRepo,
  );
  ref.onDispose(() => mediator.dispose());
  return mediator;
});

final remoteBackupRepositoryProvider = Provider<RemoteBackupRepository>((ref) {
  final localBackup = ref.watch(backupRepositoryProvider);
  final crypto = ref.watch(cloudEncryptionServiceProvider);
  final server = ref.watch(cloudSyncServerProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return RemoteBackupRepositoryImpl(
    localBackupRepo: localBackup,
    cryptoService: crypto,
    server: server,
    authRepo: authRepo,
  );
});

// --- Reactive State & Query Streams ---

final recipeFilterProvider = StateProvider<RecipeFilter>((ref) {
  return const RecipeFilter();
});

final recipesStreamProvider = StreamProvider<List<Recipe>>((ref) {
  final repo = ref.watch(recipeRepositoryProvider);
  final filter = ref.watch(recipeFilterProvider);
  return repo.watchRecipes(filter: filter);
});

final singleRecipeProvider = StreamProvider.family<Recipe?, String>((ref, id) {
  final repo = ref.watch(recipeRepositoryProvider);
  return repo.watchRecipeById(id);
});

final activeCookingSessionProvider = StreamProvider<CookingSession?>((ref) {
  final repo = ref.watch(cookingSessionRepositoryProvider);
  return repo.watchActiveSession();
});

final collectionsStreamProvider = StreamProvider<List<RecipeCollection>>((ref) {
  final repo = ref.watch(collectionRepositoryProvider);
  return repo.watchCollections();
});

final userProfileProvider = StreamProvider<UserProfile>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.watchProfile();
});

final capabilitiesProvider = StreamProvider<PlatformCapabilitySnapshot>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.watchCapabilities();
});

final singleImportJobProvider = FutureProvider.family<ImportJob?, String>((ref, jobId) async {
  final repo = ref.watch(importRepositoryProvider);
  final res = await repo.getJobById(jobId);
  return res.orNull;
});

final authSessionStreamProvider = StreamProvider<AuthSession>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.watchSession();
});

final syncStateStreamProvider = StreamProvider<SyncEngineState>((ref) {
  final mediator = ref.watch(syncMediatorProvider);
  return mediator.watchSyncState();
});

final pendingConflictsStreamProvider = StreamProvider<List<SyncConflict>>((ref) {
  final mediator = ref.watch(syncMediatorProvider);
  return mediator.watchPendingConflicts();
});
