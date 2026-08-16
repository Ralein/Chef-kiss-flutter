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
