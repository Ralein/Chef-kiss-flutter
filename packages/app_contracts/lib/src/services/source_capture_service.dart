import 'package:recipe_domain/recipe_domain.dart';
import '../result.dart';
import '../failures.dart';

abstract interface class RecipeSourceCaptureService {
  /// Captures and creates an ImportSource from raw pasted text
  Future<Result<ImportSource, AppFailure>> captureFromText(String rawText);

  /// Captures and creates an ImportSource from a web URL
  Future<Result<ImportSource, AppFailure>> captureFromUrl(String url);

  /// Safely copies local file to managed storage, strips metadata, and computes SHA-256
  Future<Result<ImportSource, AppFailure>> captureFromFile({
    required String filePath,
    required ImportSourceKind kind,
  });
}
