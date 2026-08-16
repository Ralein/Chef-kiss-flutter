import 'package:recipe_domain/recipe_domain.dart';
import '../result.dart';
import '../failures.dart';
import '../capabilities/platform_capabilities.dart';

abstract interface class SettingsRepository {
  Stream<UserProfile> watchProfile();
  Future<Result<UserProfile, AppFailure>> getProfile();
  Future<Result<UserProfile, AppFailure>> updateProfile(UserProfile profile);

  Stream<PlatformCapabilitySnapshot> watchCapabilities();
  Future<Result<void, AppFailure>> recordCapabilityState(
    String capability,
    CapabilityStatus status,
  );

  Future<Result<String, AppFailure>> exportDataJson();
  Future<Result<int, AppFailure>> importDataJson(String jsonString);
}
