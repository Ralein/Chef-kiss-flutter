import 'dart:async';

import 'package:app_contracts/app_contracts.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:uuid/uuid.dart';

/// In-memory import job pipeline: capture → extract → review → accept.
///
/// Jobs are short-lived (they exist only while the user reviews a draft), so
/// they are intentionally not persisted.
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
    if (!_jobsController.isClosed) _jobsController.add(_jobs.values.toList());
  }

  void dispose() => _jobsController.close();

  @override
  Future<Result<ImportJob, AppFailure>> createJob({
    required String profileId,
    required ImportSource source,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final job = ImportJob(
      id: _uuid.v4(),
      profileId: profileId,
      source: source,
      status: ImportStatus.queued,
      createdAt: now,
      updatedAt: now,
    );
    _jobs[job.id] = job;
    _emitJobs();

    unawaited(_processJob(job.id));
    return Result.ok(job);
  }

  Future<void> _processJob(String jobId) async {
    final current = _jobs[jobId];
    if (current == null) return;
    _update(jobId, (j) => j.copyWith(status: ImportStatus.extracting));

    final Result<RecipeExtraction, AppFailure> outcome;
    final extractor = _extractor;
    if (extractor is DetailedRecipeExtractor) {
      outcome = await extractor.extractDetailed(source: current.source, profileId: current.profileId);
    } else {
      final res = await extractor.extractRecipe(source: current.source, profileId: current.profileId);
      outcome = res.map((recipe) => RecipeExtraction(
            recipe: recipe,
            confidence: estimateConfidence(recipe),
            engine: 'heuristic',
          ));
    }

    outcome.when(
      ok: (extraction) {
        final alerts = _safetyDetector.analyzeRecipe(extraction.recipe);
        _update(
          jobId,
          (j) => j.copyWith(
            status: ImportStatus.reviewRequired,
            extractedDraft: extraction.recipe,
            overallConfidence: extraction.confidence,
            warnings: alerts.map((a) => '${a.title}: ${a.message}').toList(),
            reviewQuestions: extraction.notes,
          ),
        );
      },
      err: (failure) {
        _update(
          jobId,
          (j) => j.copyWith(
            status: ImportStatus.failed,
            failureReason: [failure.message, if (failure.recoveryAction != null) failure.recoveryAction].join(' '),
          ),
        );
      },
    );
  }

  /// Applies [change] if the job still exists (the user may have cancelled
  /// while extraction was running).
  void _update(String jobId, ImportJob Function(ImportJob) change) {
    final existing = _jobs[jobId];
    if (existing == null) return;
    _jobs[jobId] = change(existing).copyWith(updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch);
    _emitJobs();
  }

  /// Completeness-based confidence for extractors that do not report one.
  static double estimateConfidence(Recipe recipe) {
    var score = 0.25;
    if (recipe.title.trim().isNotEmpty && recipe.title != 'Imported Recipe') score += 0.15;
    if (recipe.ingredients.length >= 2) score += 0.2;
    if (recipe.steps.isNotEmpty) score += 0.2;
    if (recipe.ingredients.isNotEmpty) {
      final quantified = recipe.ingredients.where((i) => i.quantity != null).length / recipe.ingredients.length;
      score += 0.2 * quantified;
    }
    return score.clamp(0.0, 0.95);
  }

  @override
  Future<Result<ImportJob?, AppFailure>> getJobById(String jobId) async => Result.ok(_jobs[jobId]);

  @override
  Stream<List<ImportJob>> watchImportJobs({required String profileId}) => _jobsController.stream;

  @override
  Stream<ImportJob?> watchJob(String jobId) async* {
    yield _jobs[jobId];
    await for (final _ in _jobsController.stream) {
      yield _jobs[jobId];
    }
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
        _update(jobId, (j) => j.copyWith(status: ImportStatus.completed, extractedDraft: saved));
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
