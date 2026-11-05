import 'dart:convert';
import 'package:meta/meta.dart';
import 'book_style.dart';
import 'recipe.dart';
import 'collection.dart';
import 'profile.dart';
import 'rational.dart';
import 'scaling_policy.dart';

enum DuplicatePolicy {
  replace,
  keepBoth,
  skip;
}

@immutable
class BackupManifest {
  final int schemaVersion;
  final String appVersion;
  final int exportedAt;
  final String profileId;
  final int recipeCount;
  final int collectionCount;
  final String sha256Checksum;

  const BackupManifest({
    this.schemaVersion = 1,
    this.appVersion = '1.0.0+1',
    required this.exportedAt,
    required this.profileId,
    required this.recipeCount,
    required this.collectionCount,
    required this.sha256Checksum,
  });

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'appVersion': appVersion,
        'exportedAt': exportedAt,
        'profileId': profileId,
        'recipeCount': recipeCount,
        'collectionCount': collectionCount,
        'sha256Checksum': sha256Checksum,
      };

  factory BackupManifest.fromJson(Map<String, dynamic> json) => BackupManifest(
        schemaVersion: json['schemaVersion'] as int? ?? 1,
        appVersion: json['appVersion'] as String? ?? '1.0.0+1',
        exportedAt: json['exportedAt'] as int? ?? DateTime.now().toUtc().millisecondsSinceEpoch,
        profileId: json['profileId'] as String? ?? 'default',
        recipeCount: json['recipeCount'] as int? ?? 0,
        collectionCount: json['collectionCount'] as int? ?? 0,
        sha256Checksum: json['sha256Checksum'] as String? ?? '',
      );
}

@immutable
class ChefBackupPackage {
  final BackupManifest manifest;
  final UserProfile profile;
  final List<Recipe> recipes;
  final List<RecipeCollection> collections;

  const ChefBackupPackage({
    required this.manifest,
    required this.profile,
    required this.recipes,
    required this.collections,
  });

  Map<String, dynamic> toJson() => {
        'manifest': manifest.toJson(),
        'profile': {
          'id': profile.id,
          'displayName': profile.displayName,
          'unitSystem': profile.unitSystem.name,
          'createdAt': profile.createdAt,
          'updatedAt': profile.updatedAt,
        },
        'recipes': recipes.map((r) => _recipeToJson(r)).toList(),
        'collections': collections
            .map((c) => {
                  'id': c.id,
                  'profileId': c.profileId,
                  'name': c.name,
                  'colorToken': c.colorToken,
                  'description': c.description,
                  'createdAt': c.createdAt,
                  'updatedAt': c.updatedAt,
                  'recipeIds': c.recipeIds,
                })
            .toList(),
      };

  factory ChefBackupPackage.fromJsonString(String jsonStr) {
    final dynamic parsed = jsonDecode(jsonStr);
    if (parsed is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup package: root must be a JSON object');
    }

    final manifest = BackupManifest.fromJson(parsed['manifest'] as Map<String, dynamic>? ?? {});
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    final profileMap = parsed['profile'] as Map<String, dynamic>? ?? {};
    final profile = UserProfile(
      id: profileMap['id'] as String? ?? 'default',
      displayName: profileMap['displayName'] as String? ?? 'Chef',
      unitSystem: UnitSystem.fromString(profileMap['unitSystem'] as String?),
      createdAt: profileMap['createdAt'] as int? ?? now,
      updatedAt: profileMap['updatedAt'] as int? ?? now,
    );

    final rawRecipes = (parsed['recipes'] as List<dynamic>?) ?? [];
    final recipes = rawRecipes.map((item) => _recipeFromJson(item as Map<String, dynamic>)).toList();

    final rawCollections = (parsed['collections'] as List<dynamic>?) ?? [];
    final List<RecipeCollection> collections = rawCollections.map<RecipeCollection>((item) {
      final m = item as Map<String, dynamic>;
      return RecipeCollection(
        id: m['id'] as String,
        profileId: m['profileId'] as String? ?? 'default',
        name: m['name'] as String,
        colorToken: m['colorToken'] as String? ?? 'accent.herb',
        description: m['description'] as String?,
        createdAt: m['createdAt'] as int? ?? now,
        updatedAt: m['updatedAt'] as int? ?? now,
        recipeIds: (m['recipeIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );
    }).toList();

    return ChefBackupPackage(
      manifest: manifest,
      profile: profile,
      recipes: recipes,
      collections: collections,
    );
  }

  static Map<String, dynamic> _recipeToJson(Recipe r) => {
        'id': r.id,
        'profileId': r.profileId,
        'title': r.title,
        'slug': r.slug,
        'summary': r.summary,
        'status': r.status.toDbString(),
        'baseServingsNum': r.baseServings.numerator,
        'baseServingsDen': r.baseServings.denominator,
        'difficulty': r.difficulty.name,
        'totalMinutes': r.totalMinutes,
        'origin': r.origin.toDbString(),
        'isFavorite': r.isFavorite,
        'isCurated': r.isCurated,
        'createdAt': r.createdAt,
        'updatedAt': r.updatedAt,
        'visual': {
          'coverImage': r.coverImage,
          'polaroidCaption': r.polaroidCaption,
          'polaroidRotation': r.polaroidRotation,
          'chefTip': r.chefTip,
          'chefTipIcon': r.chefTipIcon,
          'chefTipIconColor': r.chefTipIconColor,
          'theme': r.theme.toKey(),
          'moodStamps': r.moodStamps,
          'stickers': r.stickers.map((s) => s.toJson()).toList(),
          'washiTapes': r.washiTapes.map((w) => w.toJson()).toList(),
          if (!r.bookStyle.isDefault) 'bookStyle': r.bookStyle.toJson(),
        },
        'ingredients': r.ingredients
            .map((i) => {
                  'id': i.id,
                  'displayName': i.displayName,
                  'quantityNum': i.quantity?.numerator,
                  'quantityDen': i.quantity?.denominator,
                  'unitCode': i.unitCode,
                  'authoredQuantity': i.authoredQuantity,
                  'scalingPolicy': i.scalingPolicy.toDbString(),
                  'prepText': i.prepText,
                  'position': i.position,
                  if (i.icon != null) 'icon': i.icon,
                  if (i.iconColor != null) 'iconColor': i.iconColor,
                })
            .toList(),
        'steps': r.steps
            .map((s) => {
                  'id': s.id,
                  'position': s.position,
                  'instructionShort': s.instructionShort,
                  'instructionDetail': s.instructionDetail,
                  'actionKey': s.actionKey,
                  'durationSeconds': s.durationSeconds,
                  'temperatureC': s.temperatureC,
                  'temperatureF': s.temperatureF,
                  if (s.iconKey != null) 'iconKey': s.iconKey,
                  if (s.iconColor != null) 'iconColor': s.iconColor,
                  'timers': s.timers
                      .map((t) => {
                            'id': t.id,
                            'label': t.label,
                            'durationSeconds': t.durationSeconds,
                            'position': t.position,
                          })
                      .toList(),
                })
            .toList(),
      };

  static Recipe _recipeFromJson(Map<String, dynamic> json) {
    final recipeId = json['id'] as String;

    final ingredients = (json['ingredients'] as List<dynamic>?)?.map((i) {
          final m = i as Map<String, dynamic>;
          return RecipeIngredient(
            id: m['id'] as String,
            recipeId: recipeId,
            displayName: m['displayName'] as String,
            quantity: m['quantityNum'] != null
                ? Rational(m['quantityNum'] as int, m['quantityDen'] as int? ?? 1)
                : null,
            unitCode: m['unitCode'] as String?,
            authoredQuantity: m['authoredQuantity'] as String?,
            scalingPolicy: ScalingPolicy.fromString(m['scalingPolicy'] as String?),
            prepText: m['prepText'] as String?,
            position: m['position'] as int? ?? 1,
            icon: m['icon'] as String?,
            iconColor: m['iconColor'] as String?,
          );
        }).toList() ??
        [];

    final steps = (json['steps'] as List<dynamic>?)?.map((s) {
          final m = s as Map<String, dynamic>;
          final stepId = m['id'] as String;
          final timers = (m['timers'] as List<dynamic>?)?.map((t) {
                final tm = t as Map<String, dynamic>;
                return StepTimer(
                  id: tm['id'] as String,
                  recipeStepId: stepId,
                  label: tm['label'] as String,
                  durationSeconds: tm['durationSeconds'] as int,
                  position: tm['position'] as int? ?? 1,
                );
              }).toList() ??
              [];

          return RecipeStep(
            id: stepId,
            recipeId: recipeId,
            position: m['position'] as int? ?? 1,
            instructionShort: m['instructionShort'] as String,
            instructionDetail: m['instructionDetail'] as String?,
            actionKey: m['actionKey'] as String?,
            durationSeconds: m['durationSeconds'] as int?,
            temperatureC: m['temperatureC'] as int?,
            temperatureF: m['temperatureF'] as int?,
            iconKey: m['iconKey'] as String?,
            iconColor: m['iconColor'] as String?,
            timers: timers,
          );
        }).toList() ??
        [];

    final visual = json['visual'] is Map ? (json['visual'] as Map).cast<String, dynamic>() : const <String, dynamic>{};
    List<T> list<T>(Object? raw, T Function(Map<String, dynamic>) parse) => raw is List
        ? raw.whereType<Map>().map((e) => parse(e.cast<String, dynamic>())).toList()
        : <T>[];

    return Recipe(
      id: recipeId,
      coverImage: visual['coverImage'] as String?,
      polaroidCaption: visual['polaroidCaption'] as String?,
      polaroidRotation: (visual['polaroidRotation'] as num?)?.toDouble(),
      chefTip: visual['chefTip'] as String?,
      chefTipIcon: visual['chefTipIcon'] as String?,
      chefTipIconColor: visual['chefTipIconColor'] as String?,
      theme: ScrapbookTheme.fromKey(visual['theme'] as String?),
      moodStamps: (visual['moodStamps'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      stickers: list(visual['stickers'], ScrapbookSticker.fromJson),
      washiTapes: list(visual['washiTapes'], WashiTapeDecoration.fromJson),
      bookStyle: BookStyle.fromJson(visual['bookStyle']),
      profileId: json['profileId'] as String? ?? 'default',
      title: json['title'] as String,
      slug: json['slug'] as String?,
      summary: json['summary'] as String?,
      status: RecipeStatus.fromString(json['status'] as String?),
      baseServings: Rational(
        json['baseServingsNum'] as int? ?? 2,
        json['baseServingsDen'] as int? ?? 1,
      ),
      difficulty: RecipeDifficulty.fromString(json['difficulty'] as String?),
      totalMinutes: json['totalMinutes'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isCurated: json['isCurated'] as bool? ?? false,
      origin: Origin.fromString(json['origin'] as String?),
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int? ?? 0,
      ingredients: ingredients,
      steps: steps,
    );
  }
}

class BackupValidationResult {
  final bool isValid;
  final int recipeCount;
  final int collectionCount;
  final List<String> duplicateRecipeTitles;
  final List<String> blockingErrors;

  const BackupValidationResult({
    required this.isValid,
    required this.recipeCount,
    required this.collectionCount,
    this.duplicateRecipeTitles = const [],
    this.blockingErrors = const [],
  });
}
