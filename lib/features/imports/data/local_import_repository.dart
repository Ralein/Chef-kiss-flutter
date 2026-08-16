import 'dart:async';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import 'package:uuid/uuid.dart';

class LocalImportRepository implements ImportRepository {
  final RecipeRepository _recipeRepo;
  final RecipeExtractionAdapter _extractor;
  final SafetyDetector _safetyDetector;
  final Uuid _uuid;

  final Map<String, ImportJob> _jobs = {};
  final StreamController<List<ImportJob>> _jobsController = StreamController<List<ImportJob>>.broadcast();

  LocalImportRepository({
    required RecipeRepository recipeRepo,
    required RecipeExtractionAdapter extractor,
    SafetyDetector safetyDetector = const SafetyDetector(),
    Uuid uuid = const Uuid(),
  })  : _recipeRepo = recipeRepo,
        _extractor = extractor,
        _safetyDetector = safetyDetector,
        _uuid = uuid;

  void _emitJobs() {
    _jobsController.add(_jobs.values.toList());
  }

  @override
  Future<Result<ImportJob, AppFailure>> createJob({
    required String profileId,
    required ImportSource source,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final jobId = _uuid.v4();

    var job = ImportJob(
      id: jobId,
      profileId: profileId,
      source: source,
      status: ImportStatus.queued,
      createdAt: now,
      updatedAt: now,
    );

    _jobs[jobId] = job;
    _emitJobs();

    // Trigger extraction pipeline asynchronously
    _processJob(jobId);

    return Result.ok(job);
  }

  Future<void> _processJob(String jobId) async {
    final current = _jobs[jobId];
    if (current == null) return;

    // Transition to extracting
    _jobs[jobId] = current.copyWith(status: ImportStatus.extracting);
    _emitJobs();

    final extractRes = await _extractor.extractRecipe(
      source: current.source,
      profileId: current.profileId,
    );

    extractRes.when(
      ok: (extractedRecipe) {
        final alerts = _safetyDetector.analyzeRecipe(extractedRecipe);
        final warnings = alerts.map((a) => '${a.title}: ${a.message}').toList();

        _jobs[jobId] = _jobs[jobId]!.copyWith(
          status: ImportStatus.reviewRequired,
          extractedDraft: extractedRecipe,
          overallConfidence: 0.92,
          warnings: warnings,
          updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        );
        _emitJobs();
      },
      err: (failure) {
        _jobs[jobId] = _jobs[jobId]!.copyWith(
          status: ImportStatus.failed,
          failureReason: failure.message,
          updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        );
        _emitJobs();
      },
    );
  }

  @override
  Future<Result<ImportJob?, AppFailure>> getJobById(String jobId) async {
    return Result.ok(_jobs[jobId]);
  }

  @override
  Stream<List<ImportJob>> watchImportJobs({required String profileId}) {
    return _jobsController.stream;
  }

  @override
  Future<Result<ImportJob, AppFailure>> updateJob(ImportJob job) async {
    _jobs[job.id] = job;
    _emitJobs();
    return Result.ok(job);
  }

  @override
  Future<Result<Recipe, AppFailure>> acceptImportReview({
    required String jobId,
    required Recipe recipe,
  }) async {
    final saveRes = await _recipeRepo.saveRecipe(recipe);

    return saveRes.when(
      ok: (saved) {
        final existing = _jobs[jobId];
        if (existing != null) {
          _jobs[jobId] = existing.copyWith(
            status: ImportStatus.completed,
            extractedDraft: saved,
            updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
          );
          _emitJobs();
        }
        return Result.ok(saved);
      },
      err: (failure) => Result.err(failure),
    );
  }

  @override
  Future<Result<void, AppFailure>> cancelJob(String jobId) async {
    _jobs.remove(jobId);
    _emitJobs();
    return const Result.ok(null);
  }
}
