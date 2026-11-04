import 'package:meta/meta.dart';

enum AppFlavor {
  dev,
  staging,
  production;

  bool get isProduction => this == AppFlavor.production;
  bool get isDev => this == AppFlavor.dev;
}

@immutable
class FeatureFlags {
  final bool aiImportEnabled;
  final bool generatedIllustrationsEnabled;
  final bool voiceCommandsEnabled;
  final bool exportImportEnabled;
  final bool telemetryOptInDefault;

  /// The cloud sync/vault UI is backed by an in-memory demo server. It must
  /// never be shown to production users, who would believe data is backed up.
  final bool cloudSyncPreviewEnabled;

  /// Internal artwork moderation tooling.
  final bool illustrationGovernanceEnabled;

  const FeatureFlags({
    this.aiImportEnabled = false,
    this.generatedIllustrationsEnabled = false,
    this.voiceCommandsEnabled = true,
    this.exportImportEnabled = true,
    this.telemetryOptInDefault = false,
    this.cloudSyncPreviewEnabled = false,
    this.illustrationGovernanceEnabled = false,
  });

  FeatureFlags copyWith({
    bool? aiImportEnabled,
    bool? generatedIllustrationsEnabled,
    bool? voiceCommandsEnabled,
    bool? exportImportEnabled,
    bool? telemetryOptInDefault,
    bool? cloudSyncPreviewEnabled,
    bool? illustrationGovernanceEnabled,
  }) {
    return FeatureFlags(
      aiImportEnabled: aiImportEnabled ?? this.aiImportEnabled,
      generatedIllustrationsEnabled:
          generatedIllustrationsEnabled ?? this.generatedIllustrationsEnabled,
      voiceCommandsEnabled: voiceCommandsEnabled ?? this.voiceCommandsEnabled,
      exportImportEnabled: exportImportEnabled ?? this.exportImportEnabled,
      telemetryOptInDefault: telemetryOptInDefault ?? this.telemetryOptInDefault,
      cloudSyncPreviewEnabled: cloudSyncPreviewEnabled ?? this.cloudSyncPreviewEnabled,
      illustrationGovernanceEnabled: illustrationGovernanceEnabled ?? this.illustrationGovernanceEnabled,
    );
  }
}

@immutable
class AppEnvironment {
  final AppFlavor flavor;
  final String appName;
  final String version;
  final String assetPackVersion;
  final FeatureFlags flags;

  const AppEnvironment({
    required this.flavor,
    this.appName = "Chef's Kiss",
    this.version = '1.0.0-dev',
    this.assetPackVersion = 'v1',
    this.flags = const FeatureFlags(),
  });

  static const dev = AppEnvironment(
    flavor: AppFlavor.dev,
    version: '1.0.0-dev',
    flags: FeatureFlags(
      aiImportEnabled: true,
      voiceCommandsEnabled: true,
      exportImportEnabled: true,
      cloudSyncPreviewEnabled: true,
      illustrationGovernanceEnabled: true,
    ),
  );

  static const staging = AppEnvironment(
    flavor: AppFlavor.staging,
    version: '1.0.0-beta.1',
    flags: FeatureFlags(
      aiImportEnabled: true,
      voiceCommandsEnabled: true,
      exportImportEnabled: true,
    ),
  );

  static const production = AppEnvironment(
    flavor: AppFlavor.production,
    version: '1.0.0',
    flags: FeatureFlags(
      aiImportEnabled: true,
      voiceCommandsEnabled: true,
      exportImportEnabled: true,
    ),
  );

  /// Resolved from `--dart-define=APP_FLAVOR=dev|staging|production`.
  /// Release builds default to production so demo features can never leak.
  static AppEnvironment resolve({required bool isRelease}) {
    const flavor = String.fromEnvironment('APP_FLAVOR');
    switch (flavor) {
      case 'dev':
        return dev;
      case 'staging':
        return staging;
      case 'production':
        return production;
      default:
        return isRelease ? production : dev;
    }
  }
}
