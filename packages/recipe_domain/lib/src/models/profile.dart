import 'package:meta/meta.dart';

enum UnitSystem {
  metric,
  usCustomary;

  static UnitSystem fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'us':
      case 'us_customary':
      case 'uscustomary':
      case 'imperial':
        return UnitSystem.usCustomary;
      case 'metric':
      default:
        return UnitSystem.metric;
    }
  }

  String toDbString() {
    switch (this) {
      case UnitSystem.metric:
        return 'metric';
      case UnitSystem.usCustomary:
        return 'us';
    }
  }
}

@immutable
class UserProfile {
  final String id;
  final String displayName;
  final String locale;
  final UnitSystem unitSystem;
  final int settingsVersion;
  final int createdAt;
  final int updatedAt;

  const UserProfile({
    required this.id,
    this.displayName = 'Local Cook',
    this.locale = 'en',
    this.unitSystem = UnitSystem.metric,
    this.settingsVersion = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? locale,
    UnitSystem? unitSystem,
    int? settingsVersion,
    int? createdAt,
    int? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      locale: locale ?? this.locale,
      unitSystem: unitSystem ?? this.unitSystem,
      settingsVersion: settingsVersion ?? this.settingsVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
