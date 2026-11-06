import 'package:app_contracts/app_contracts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../core/ai/ai_connection.dart';
import '../core/platform/flutter_tts_speech_service.dart';
import '../core/platform/wakelock_screen_awake_service.dart';
import '../core/timers/kitchen_timers.dart';
import '../data/db/app_database.dart';
import '../data/repositories/drift_backup_repository.dart';
import '../data/repositories/drift_collection_repository.dart';
import '../data/repositories/drift_cooking_session_repository.dart';
import '../data/repositories/drift_food_log_repository.dart';
import '../data/repositories/drift_recipe_repository.dart';
import '../data/repositories/drift_settings_repository.dart';
import '../features/cook_mode/voice/voice_cook_assistant.dart';
import '../features/illustrations/data/illustration_governance_service.dart';
import '../features/illustrations/data/illustration_matcher.dart';
import '../features/imports/data/local_import_repository.dart';
import '../features/imports/services/ai_recipe_service.dart';
import '../features/imports/services/smart_recipe_extractor.dart';
import '../features/nutrition/data/ai_nutrition_service.dart';
import '../features/scan/data/food_vision_service.dart';
import '../features/sync/data/drift_sync_mediator.dart';
import '../features/sync/data/in_memory_cloud_sync_server.dart';
import '../features/sync/data/local_auth_repository.dart';
import '../features/sync/data/remote_backup_repository_impl.dart';
import '../features/sync/services/cloud_encryption_service.dart';
import '../features/voice/read_aloud_controller.dart';

// --- Environment & infrastructure ------------------------------------------

final appEnvironmentProvider = Provider<AppEnvironment>((ref) => AppEnvironment.resolve(isRelease: kReleaseMode));

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.defaults();
  ref.onDispose(db.close);
  return db;
});

final appLoggerProvider = Provider<AppLogger>((ref) => const StandardAppLogger());

// --- Platform capabilities ---------------------------------------------------

final screenAwakeServiceProvider = Provider<ScreenAwakeService>((ref) => WakelockScreenAwakeService());

final localAlertServiceProvider = Provider<LocalAlertService>((ref) => FakeLocalAlertService());

/// The device's text-to-speech voice. Tests override this with
/// [FakeSpeechOutputService].
final speechOutputServiceProvider = Provider<SpeechOutputService>((ref) {
  final service = FlutterTtsSpeechService();
  ref.onDispose(service.stop);
  return service;
});

final speechCommandServiceProvider = Provider<SpeechCommandService>((ref) => FakeSpeechCommandService());

final voiceCookAssistantProvider = Provider<VoiceCookAssistant>((ref) {
  return VoiceCookAssistant(
    tts: ref.watch(speechOutputServiceProvider),
    speechCommands: ref.watch(speechCommandServiceProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

// --- Read aloud -----------------------------------------------------------------

const voiceSettingsKey = 'voice.settings';

final voiceSettingsProvider = StreamProvider<VoiceSettings>((ref) {
  return ref.watch(preferencesRepositoryProvider).watchJson(voiceSettingsKey).map(VoiceSettings.fromJson);
});

/// One shared voice for the whole app, so starting to read something new
/// always stops what was playing.
final readAloudProvider = ChangeNotifierProvider<ReadAloudController>((ref) {
  return ReadAloudController(
    ref.watch(speechOutputServiceProvider),
    settings: () => ref.read(voiceSettingsProvider).valueOrNull ?? const VoiceSettings(),
  );
});

Future<void> saveVoiceSettings(WidgetRef ref, VoiceSettings settings) =>
    ref.read(preferencesRepositoryProvider).writeJson(voiceSettingsKey, settings.toJson());

// --- Library ---------------------------------------------------------------------

/// The Recipes tab's last chosen view: `cards`, `shelf` or `journal`.
const libraryViewKey = 'library.view';

final libraryViewPrefProvider = StreamProvider<String?>((ref) {
  return ref.watch(preferencesRepositoryProvider).watchJson(libraryViewKey).map((v) => v is String ? v : null);
});

/// Shared countdowns for the recipe page and Cook Mode.
final kitchenTimersProvider = ChangeNotifierProvider<KitchenTimersController>((ref) => KitchenTimersController());

// --- Illustrations (internal tooling) -----------------------------------------

final illustrationGovernanceServiceProvider = Provider<IllustrationGovernanceService>((ref) {
  final service = IllustrationGovernanceService();
  ref.onDispose(service.dispose);
  return service;
});

final illustrationCandidatesStreamProvider = StreamProvider<List<IllustrationCandidate>>((ref) {
  return ref.watch(illustrationGovernanceServiceProvider).watchCandidates();
});

final illustrationMatcherProvider = Provider<IllustrationMatcher>((ref) => IllustrationMatcher());

// --- AI services (null until AI is configured) --------------------------------

final aiRecipeServiceProvider = Provider<AiRecipeService?>((ref) {
  final client = ref.watch(claudeClientProvider);
  return client == null ? null : AiRecipeService(client);
});

final foodVisionServiceProvider = Provider<FoodVisionService?>((ref) {
  final client = ref.watch(claudeClientProvider);
  return client == null ? null : FoodVisionService(client);
});

final aiNutritionServiceProvider = Provider<AiNutritionService?>((ref) {
  final client = ref.watch(claudeClientProvider);
  return client == null ? null : AiNutritionService(client);
});

/// Not watched: the extractor reads the *current* AI service per job, so the
/// import pipeline (and its in-flight jobs) survives AI being configured.
final recipeExtractionAdapterProvider = Provider<RecipeExtractionAdapter>((ref) {
  return SmartRecipeExtractor(ai: () => ref.read(aiRecipeServiceProvider));
});

// --- Repositories --------------------------------------------------------------

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) => DriftRecipeRepository(ref.watch(databaseProvider)));

final cookingSessionRepositoryProvider =
    Provider<CookingSessionRepository>((ref) => DriftCookingSessionRepository(ref.watch(databaseProvider)));

final collectionRepositoryProvider =
    Provider<CollectionRepository>((ref) => DriftCollectionRepository(ref.watch(databaseProvider)));

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => DriftSettingsRepository(ref.watch(databaseProvider)));

final foodLogRepositoryProvider = Provider<FoodLogRepository>((ref) => DriftFoodLogRepository(ref.watch(databaseProvider)));

final preferencesRepositoryProvider =
    Provider<PreferencesRepository>((ref) => DriftPreferencesRepository(ref.watch(databaseProvider)));

final importRepositoryProvider = Provider<ImportRepository>((ref) {
  final repo = LocalImportRepository(
    recipeRepo: ref.watch(recipeRepositoryProvider),
    extractor: ref.watch(recipeExtractionAdapterProvider),
  );
  ref.onDispose(repo.dispose);
  return repo;
});

final backupRepositoryProvider = Provider<BackupRepository>((ref) => DriftBackupRepository(ref.watch(databaseProvider)));

// --- Cloud sync (developer preview; in-memory server) -----------------------------

final cloudSyncServerProvider = Provider<InMemoryCloudSyncServer>((ref) => InMemoryCloudSyncServer());

final cloudEncryptionServiceProvider = Provider<CloudEncryptionService>((ref) => CloudEncryptionService());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repo = LocalAuthRepository(server: ref.watch(cloudSyncServerProvider));
  ref.onDispose(repo.dispose);
  return repo;
});

final syncMediatorProvider = Provider<SyncMediator>((ref) {
  final mediator = DriftSyncMediator(
    db: ref.watch(databaseProvider),
    server: ref.watch(cloudSyncServerProvider),
    authRepo: ref.watch(authRepositoryProvider),
  );
  ref.onDispose(mediator.dispose);
  return mediator;
});

final remoteBackupRepositoryProvider = Provider<RemoteBackupRepository>((ref) {
  return RemoteBackupRepositoryImpl(
    localBackupRepo: ref.watch(backupRepositoryProvider),
    cryptoService: ref.watch(cloudEncryptionServiceProvider),
    server: ref.watch(cloudSyncServerProvider),
    authRepo: ref.watch(authRepositoryProvider),
  );
});

// --- Reactive state & queries ------------------------------------------------------

final recipeFilterProvider = StateProvider<RecipeFilter>((ref) => const RecipeFilter());

/// True while a screen takes over the whole window — dressing the bookcase —
/// so the shell hides its navigation bar.
final immersiveModeProvider = StateProvider<bool>((ref) => false);

final recipesStreamProvider = StreamProvider<List<Recipe>>((ref) {
  return ref.watch(recipeRepositoryProvider).watchRecipes(filter: ref.watch(recipeFilterProvider));
});

/// All live recipes regardless of the library filter (search, recommendations).
final allRecipesProvider = StreamProvider<List<Recipe>>((ref) => ref.watch(recipeRepositoryProvider).watchRecipes());

final singleRecipeProvider = StreamProvider.family<Recipe?, String>((ref, id) {
  return ref.watch(recipeRepositoryProvider).watchRecipeById(id);
});

final recipeNutritionAnalyzerProvider = Provider<RecipeNutritionAnalyzer>((ref) => RecipeNutritionAnalyzer());

final recipeNutritionProvider = Provider.family<RecipeNutritionReport?, String>((ref, id) {
  final recipe = ref.watch(singleRecipeProvider(id)).valueOrNull;
  return recipe == null ? null : ref.watch(recipeNutritionAnalyzerProvider).analyze(recipe);
});

final activeCookingSessionProvider = StreamProvider<CookingSession?>((ref) {
  return ref.watch(cookingSessionRepositoryProvider).watchActiveSession();
});

final collectionsStreamProvider = StreamProvider<List<RecipeCollection>>((ref) {
  return ref.watch(collectionRepositoryProvider).watchCollections();
});

final userProfileProvider = StreamProvider<UserProfile>((ref) => ref.watch(settingsRepositoryProvider).watchProfile());

final capabilitiesProvider = StreamProvider<PlatformCapabilitySnapshot>((ref) {
  return ref.watch(settingsRepositoryProvider).watchCapabilities();
});

final singleImportJobProvider = StreamProvider.autoDispose.family<ImportJob?, String>((ref, jobId) {
  return ref.watch(importRepositoryProvider).watchJob(jobId);
});

// Food log ---------------------------------------------------------------------------

const nutritionGoalsKey = 'nutrition.goals';

final nutritionGoalsProvider = StreamProvider<NutritionGoals>((ref) {
  return ref.watch(preferencesRepositoryProvider).watchJson(nutritionGoalsKey).map(NutritionGoals.fromJson);
});

final foodLogDayProvider = StreamProvider.family<List<FoodLogEntry>, String>((ref, dayKey) {
  return ref.watch(foodLogRepositoryProvider).watchDay(dayKey);
});

/// Daily totals for the 7 days ending on [dayKey].
final foodLogWeekProvider = StreamProvider.family<List<DailyNutritionSummary>, String>((ref, dayKey) {
  final end = dateForDayKey(dayKey);
  final start = end.subtract(const Duration(days: 6));
  return ref.watch(foodLogRepositoryProvider).watchSummaries(fromDayKey: dayKeyFor(start), toDayKey: dayKey);
});

// Cloud sync streams (developer preview) ---------------------------------------------

final authSessionStreamProvider = StreamProvider<AuthSession>((ref) => ref.watch(authRepositoryProvider).watchSession());

final syncStateStreamProvider = StreamProvider<SyncEngineState>((ref) => ref.watch(syncMediatorProvider).watchSyncState());

final pendingConflictsStreamProvider = StreamProvider<List<SyncConflict>>((ref) {
  return ref.watch(syncMediatorProvider).watchPendingConflicts();
});
