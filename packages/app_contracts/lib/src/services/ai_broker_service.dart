import 'package:recipe_domain/recipe_domain.dart';
import '../result.dart';
import '../failures.dart';

/// Provider-neutral recipe extraction adapter interface
abstract interface class RecipeExtractionAdapter {
  /// Extracts structured recipe draft and confidence metrics from source
  Future<Result<Recipe, AppFailure>> extractRecipe({
    required ImportSource source,
    required String profileId,
    String? localeHint,
  });

  /// Check remaining daily quota for profile
  Future<int> getRemainingDailyQuota(String profileId);
}

/// Client configuration for AI broker service
class AiBrokerConfig {
  final String endpointUrl;
  final String promptVersion;
  final int maxDailyQuota;
  final Duration timeout;

  const AiBrokerConfig({
    this.endpointUrl = 'https://api.chefskiss.local/v1/extract',
    this.promptVersion = 'RecipeExtraction.v1',
    this.maxDailyQuota = 3,
    this.timeout = const Duration(seconds: 30),
  });
}

/// Outcome of an extraction with provenance the review screen can show.
class RecipeExtraction {
  final Recipe recipe;

  /// 0..1 estimate of how faithfully the source was understood.
  final double confidence;

  /// Points the cook should double-check ("Servings were not stated").
  final List<String> notes;

  /// Which engine produced the draft: `json-ld`, `heuristic` or `ai`.
  final String engine;

  const RecipeExtraction({
    required this.recipe,
    required this.confidence,
    this.notes = const [],
    required this.engine,
  });
}

/// An extractor that also reports confidence and review notes.
abstract interface class DetailedRecipeExtractor implements RecipeExtractionAdapter {
  Future<Result<RecipeExtraction, AppFailure>> extractDetailed({
    required ImportSource source,
    required String profileId,
  });
}
