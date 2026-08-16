import 'package:recipe_domain/recipe_domain.dart';
import '../result.dart';
import '../failures.dart';

abstract interface class BackupRepository {
  /// Generates a full portable JSON backup package
  Future<Result<String, AppFailure>> exportBackupJson({required String profileId});

  /// Validates a raw JSON backup string without writing to the active database
  Future<Result<BackupValidationResult, AppFailure>> validateBackupJson(String jsonStr);

  /// Restores recipes and collections from a validated JSON backup string
  Future<Result<int, AppFailure>> restoreBackupJson({
    required String jsonStr,
    required DuplicatePolicy duplicatePolicy,
    required String profileId,
  });

  /// Permanently deletes all local recipe, collection, and session data
  Future<Result<void, AppFailure>> resetAllData({required String profileId});
}
