import 'package:recipe_domain/recipe_domain.dart';
import '../result.dart';
import '../failures.dart';

abstract interface class ImportRepository {
  /// Create a new import job with captured source
  Future<Result<ImportJob, AppFailure>> createJob({
    required String profileId,
    required ImportSource source,
  });

  /// Get an import job by ID
  Future<Result<ImportJob?, AppFailure>> getJobById(String jobId);

  /// Watch all active/recent import jobs
  Stream<List<ImportJob>> watchImportJobs({required String profileId});

  /// Emits the job's current state immediately, then every change. Emits
  /// null if the job does not exist or is cancelled.
  Stream<ImportJob?> watchJob(String jobId);

  /// Update the status or extracted draft of an import job
  Future<Result<ImportJob, AppFailure>> updateJob(ImportJob job);

  /// Atomically accept an import review and commit to a saved Recipe draft
  Future<Result<Recipe, AppFailure>> acceptImportReview({
    required String jobId,
    required Recipe recipe,
  });

  /// Reject or cancel an import job
  Future<Result<void, AppFailure>> cancelJob(String jobId);
}
