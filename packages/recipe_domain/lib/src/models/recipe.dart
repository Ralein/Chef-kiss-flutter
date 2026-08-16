import 'package:meta/meta.dart';
import 'rational.dart';
import 'scaling_policy.dart';

enum RecipeStatus {
  draft,
  ready,
  archived;

  static RecipeStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'ready':
        return RecipeStatus.ready;
      case 'archived':
        return RecipeStatus.archived;
      case 'draft':
      default:
        return RecipeStatus.draft;
    }
  }

  String toDbString() => name;
}

enum RecipeDifficulty {
  easy,
  medium,
  hard;

  static RecipeDifficulty fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'easy':
        return RecipeDifficulty.easy;
      case 'hard':
        return RecipeDifficulty.hard;
      case 'medium':
      default:
        return RecipeDifficulty.medium;
    }
  }

  String toDbString() => name;
}

enum Origin {
  manual,
  curated,
  imported,
  aiProposed,
  userEdited;

  static Origin fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'curated':
        return Origin.curated;
      case 'imported':
        return Origin.imported;
      case 'ai_proposed':
      case 'aiproposed':
        return Origin.aiProposed;
      case 'user_edited':
      case 'useredited':
        return Origin.userEdited;
      case 'manual':
      default:
        return Origin.manual;
    }
  }

  String toDbString() {
    switch (this) {
      case Origin.manual:
        return 'manual';
      case Origin.curated:
        return 'curated';
      case Origin.imported:
        return 'imported';
      case Origin.aiProposed:
        return 'ai_proposed';
      case Origin.userEdited:
        return 'user_edited';
    }
  }
}

enum ScrapbookTheme {
  terracottaClassic,
  matchaSage,
  artisanKraft,
  nordicSlate;

  String toKey() {
    switch (this) {
      case ScrapbookTheme.terracottaClassic:
        return 'terracotta-classic';
      case ScrapbookTheme.matchaSage:
        return 'matcha-sage';
      case ScrapbookTheme.artisanKraft:
        return 'artisan-kraft';
      case ScrapbookTheme.nordicSlate:
        return 'nordic-slate';
    }
  }

  static ScrapbookTheme fromKey(String? key) {
    switch (key?.toLowerCase().replaceAll('_', '-')) {
      case 'matcha-sage':
      case 'matchasage':
        return ScrapbookTheme.matchaSage;
      case 'artisan-kraft':
      case 'artisankraft':
        return ScrapbookTheme.artisanKraft;
      case 'nordic-slate':
      case 'nordicslate':
        return ScrapbookTheme.nordicSlate;
      case 'terracotta-classic':
      case 'terracottaclassic':
      default:
        return ScrapbookTheme.terracottaClassic;
    }
  }
}

@immutable
class ScrapbookSticker {
  final String id;
  final String content;
  final String type; // 'emoji' | 'stamp' | 'badge' | 'tape' | 'doodle' | 'icon'
  final String? iconId;
  final String? label;
  final String? color;
  final String? bgColor;
  final String pageSide; // 'left' | 'right'
  final double x;
  final double y;
  final double rotation;
  final double scale;
  final int zIndex;

  const ScrapbookSticker({
    required this.id,
    required this.content,
    this.type = 'stamp',
    this.iconId,
    this.label,
    this.color,
    this.bgColor,
    this.pageSide = 'left',
    this.x = 50.0,
    this.y = 50.0,
    this.rotation = 0.0,
    this.scale = 1.0,
    this.zIndex = 1,
  });

  ScrapbookSticker copyWith({
    String? id,
    String? content,
    String? type,
    String? iconId,
    String? label,
    String? color,
    String? bgColor,
    String? pageSide,
    double? x,
    double? y,
    double? rotation,
    double? scale,
    int? zIndex,
  }) {
    return ScrapbookSticker(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      iconId: iconId ?? this.iconId,
      label: label ?? this.label,
      color: color ?? this.color,
      bgColor: bgColor ?? this.bgColor,
      pageSide: pageSide ?? this.pageSide,
      x: x ?? this.x,
      y: y ?? this.y,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      zIndex: zIndex ?? this.zIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'type': type,
        if (iconId != null) 'iconId': iconId,
        if (label != null) 'label': label,
        if (color != null) 'color': color,
        if (bgColor != null) 'bgColor': bgColor,
        'pageSide': pageSide,
        'x': x,
        'y': y,
        'rotation': rotation,
        'scale': scale,
        'zIndex': zIndex,
      };

  factory ScrapbookSticker.fromJson(Map<String, dynamic> json) => ScrapbookSticker(
        id: json['id'] as String? ?? 'stk-${DateTime.now().millisecondsSinceEpoch}',
        content: json['content'] as String? ?? '',
        type: json['type'] as String? ?? 'stamp',
        iconId: json['iconId'] as String?,
        label: json['label'] as String?,
        color: json['color'] as String?,
        bgColor: json['bgColor'] as String?,
        pageSide: json['pageSide'] as String? ?? 'left',
        x: (json['x'] as num?)?.toDouble() ?? 50.0,
        y: (json['y'] as num?)?.toDouble() ?? 50.0,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
        zIndex: (json['zIndex'] as num?)?.toInt() ?? 1,
      );
}

@immutable
class WashiTapeDecoration {
  final String id;
  final String pattern; // 'terracotta' | 'sage' | 'kraft' | 'dots' | 'striped' | 'strawberry' | 'gingham' | 'glitter' | 'green' | 'peach'
  final String pageSide; // 'left' | 'right'
  final double x;
  final double y;
  final double width;
  final double rotation;

  const WashiTapeDecoration({
    required this.id,
    this.pattern = 'terracotta',
    this.pageSide = 'left',
    this.x = 50.0,
    this.y = 50.0,
    this.width = 80.0,
    this.rotation = 0.0,
  });

  WashiTapeDecoration copyWith({
    String? id,
    String? pattern,
    String? pageSide,
    double? x,
    double? y,
    double? width,
    double? rotation,
  }) {
    return WashiTapeDecoration(
      id: id ?? this.id,
      pattern: pattern ?? this.pattern,
      pageSide: pageSide ?? this.pageSide,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      rotation: rotation ?? this.rotation,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pattern': pattern,
        'pageSide': pageSide,
        'x': x,
        'y': y,
        'width': width,
        'rotation': rotation,
      };

  factory WashiTapeDecoration.fromJson(Map<String, dynamic> json) => WashiTapeDecoration(
        id: json['id'] as String? ?? 'wash-${DateTime.now().millisecondsSinceEpoch}',
        pattern: json['pattern'] as String? ?? 'terracotta',
        pageSide: json['pageSide'] as String? ?? 'left',
        x: (json['x'] as num?)?.toDouble() ?? 50.0,
        y: (json['y'] as num?)?.toDouble() ?? 50.0,
        width: (json['width'] as num?)?.toDouble() ?? 80.0,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      );
}

@immutable
class RecipeIngredient {
  final String id;
  final String recipeId;
  final String? catalogIngredientId;
  final String displayName;
  final Rational? quantity;
  final String? unitCode;
  final String? authoredQuantity;
  final ScalingPolicy scalingPolicy;
  final String? prepText;
  final bool isOptional;
  final int position;
  final String? groupKey;
  final String? allergenOverrideJson;
  final String? illustrationKey;
  final String? icon;
  final String? iconColor;
  final double? x;
  final double? y;

  const RecipeIngredient({
    required this.id,
    required this.recipeId,
    this.catalogIngredientId,
    required this.displayName,
    this.quantity,
    this.unitCode,
    this.authoredQuantity,
    this.scalingPolicy = ScalingPolicy.scale,
    this.prepText,
    this.isOptional = false,
    required this.position,
    this.groupKey,
    this.allergenOverrideJson,
    this.illustrationKey,
    this.icon,
    this.iconColor,
    this.x,
    this.y,
  });

  RecipeIngredient copyWith({
    String? id,
    String? recipeId,
    String? catalogIngredientId,
    String? displayName,
    Rational? quantity,
    String? unitCode,
    String? authoredQuantity,
    ScalingPolicy? scalingPolicy,
    String? prepText,
    bool? isOptional,
    int? position,
    String? groupKey,
    String? allergenOverrideJson,
    String? illustrationKey,
    String? icon,
    String? iconColor,
    double? x,
    double? y,
  }) {
    return RecipeIngredient(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      catalogIngredientId: catalogIngredientId ?? this.catalogIngredientId,
      displayName: displayName ?? this.displayName,
      quantity: quantity ?? this.quantity,
      unitCode: unitCode ?? this.unitCode,
      authoredQuantity: authoredQuantity ?? this.authoredQuantity,
      scalingPolicy: scalingPolicy ?? this.scalingPolicy,
      prepText: prepText ?? this.prepText,
      isOptional: isOptional ?? this.isOptional,
      position: position ?? this.position,
      groupKey: groupKey ?? this.groupKey,
      allergenOverrideJson: allergenOverrideJson ?? this.allergenOverrideJson,
      illustrationKey: illustrationKey ?? this.illustrationKey,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  /// Formatted text representation for display: e.g. "2 cups chopped tomatoes"
  String formatDisplay([Rational? overrideQuantity]) {
    final qty = overrideQuantity ?? quantity;
    final buffer = StringBuffer();
    if (qty != null) {
      buffer.write(qty.toDisplayString());
      buffer.write(' ');
    } else if (authoredQuantity != null && authoredQuantity!.isNotEmpty) {
      buffer.write(authoredQuantity);
      buffer.write(' ');
    }

    if (unitCode != null && unitCode!.isNotEmpty && unitCode != 'each') {
      buffer.write(unitCode);
      buffer.write(' ');
    }

    buffer.write(displayName);

    if (prepText != null && prepText!.isNotEmpty) {
      buffer.write(', ');
      buffer.write(prepText);
    }

    if (isOptional) {
      buffer.write(' (optional)');
    }

    return buffer.toString();
  }
}

@immutable
class StepTimer {
  final String id;
  final String recipeStepId;
  final String label;
  final int durationSeconds;
  final bool autoStart;
  final int position;

  const StepTimer({
    required this.id,
    required this.recipeStepId,
    required this.label,
    required this.durationSeconds,
    this.autoStart = false,
    this.position = 1,
  });

  StepTimer copyWith({
    String? id,
    String? recipeStepId,
    String? label,
    int? durationSeconds,
    bool? autoStart,
    int? position,
  }) {
    return StepTimer(
      id: id ?? this.id,
      recipeStepId: recipeStepId ?? this.recipeStepId,
      label: label ?? this.label,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      autoStart: autoStart ?? this.autoStart,
      position: position ?? this.position,
    );
  }
}

@immutable
class RecipeStep {
  final String id;
  final String recipeId;
  final int position;
  final String instructionShort;
  final String? instructionDetail;
  final String? spokenInstruction;
  final String? actionKey;
  final String? iconKey;
  final String? iconColor;
  final String? cookwareKey;
  final int? durationSeconds;
  final int? temperatureC;
  final int? temperatureF;
  final String? layoutHint;
  final String? safetyJson;
  final double? x;
  final double? y;
  final List<StepTimer> timers;

  const RecipeStep({
    required this.id,
    required this.recipeId,
    required this.position,
    required this.instructionShort,
    this.instructionDetail,
    this.spokenInstruction,
    this.actionKey,
    this.iconKey,
    this.iconColor,
    this.cookwareKey,
    this.durationSeconds,
    this.temperatureC,
    this.temperatureF,
    this.layoutHint,
    this.safetyJson,
    this.x,
    this.y,
    this.timers = const [],
  });

  RecipeStep copyWith({
    String? id,
    String? recipeId,
    int? position,
    String? instructionShort,
    String? instructionDetail,
    String? spokenInstruction,
    String? actionKey,
    String? iconKey,
    String? iconColor,
    String? cookwareKey,
    int? durationSeconds,
    int? temperatureC,
    int? temperatureF,
    String? layoutHint,
    String? safetyJson,
    double? x,
    double? y,
    List<StepTimer>? timers,
  }) {
    return RecipeStep(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      position: position ?? this.position,
      instructionShort: instructionShort ?? this.instructionShort,
      instructionDetail: instructionDetail ?? this.instructionDetail,
      spokenInstruction: spokenInstruction ?? this.spokenInstruction,
      actionKey: actionKey ?? this.actionKey,
      iconKey: iconKey ?? this.iconKey,
      iconColor: iconColor ?? this.iconColor,
      cookwareKey: cookwareKey ?? this.cookwareKey,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      temperatureC: temperatureC ?? this.temperatureC,
      temperatureF: temperatureF ?? this.temperatureF,
      layoutHint: layoutHint ?? this.layoutHint,
      safetyJson: safetyJson ?? this.safetyJson,
      x: x ?? this.x,
      y: y ?? this.y,
      timers: timers ?? this.timers,
    );
  }
}

@immutable
class RecipeTool {
  final String id;
  final String recipeId;
  final String? toolId;
  final String displayName;
  final int quantity;
  final bool isRequired;
  final int position;

  const RecipeTool({
    required this.id,
    required this.recipeId,
    this.toolId,
    required this.displayName,
    this.quantity = 1,
    this.isRequired = true,
    required this.position,
  });
}

@immutable
class RecipeLabel {
  final String id;
  final String recipeId;
  final String labelId;
  final String kind; // tag, cuisine, dietary, allergen, difficulty
  final String canonicalKey;
  final String displayName;
  final double sourceConfidence;
  final bool isUserConfirmed;

  const RecipeLabel({
    required this.id,
    required this.recipeId,
    required this.labelId,
    required this.kind,
    required this.canonicalKey,
    required this.displayName,
    this.sourceConfidence = 1.0,
    this.isUserConfirmed = true,
  });
}

@immutable
class RecipeNote {
  final String id;
  final String recipeId;
  final String body;
  final String noteType; // user, ai_suggestion, tip
  final int position;

  const RecipeNote({
    required this.id,
    required this.recipeId,
    required this.body,
    this.noteType = 'user',
    required this.position,
  });
}

@immutable
class RecipeVersion {
  final String id;
  final String recipeId;
  final int sequence;
  final String snapshotJson;
  final String? changeSummary;
  final String authorKind;
  final String? parentVersionId;
  final int createdAt;

  const RecipeVersion({
    required this.id,
    required this.recipeId,
    required this.sequence,
    required this.snapshotJson,
    this.changeSummary,
    required this.authorKind,
    this.parentVersionId,
    required this.createdAt,
  });
}

@immutable
class Recipe {
  final String id;
  final String profileId;
  final String title;
  final String? slug;
  final String? summary;
  final RecipeStatus status;
  final Rational baseServings;
  final RecipeDifficulty difficulty;
  final int totalMinutes;
  final String? coverMediaId;
  final String? coverImage;
  final String? polaroidCaption;
  final double? polaroidRotation;
  final double? polaroidX;
  final double? polaroidY;
  final String? chefTip;
  final String? chefTipIcon;
  final String? chefTipIconColor;
  final ScrapbookTheme theme;
  final List<String> moodStamps;
  final List<ScrapbookSticker> stickers;
  final List<WashiTapeDecoration> washiTapes;
  final String? visualTemplate;
  final String visualStyleVersion;
  final bool isCurated;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int version;
  final Origin origin;
  final String? currentVersionId;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final List<RecipeTool> tools;
  final List<RecipeLabel> labels;
  final List<RecipeNote> notes;
  final bool isFavorite;

  const Recipe({
    required this.id,
    required this.profileId,
    required this.title,
    this.slug,
    this.summary,
    this.status = RecipeStatus.draft,
    required this.baseServings,
    this.difficulty = RecipeDifficulty.medium,
    this.totalMinutes = 0,
    this.coverMediaId,
    this.coverImage,
    this.polaroidCaption,
    this.polaroidRotation,
    this.polaroidX,
    this.polaroidY,
    this.chefTip,
    this.chefTipIcon,
    this.chefTipIconColor,
    this.theme = ScrapbookTheme.terracottaClassic,
    this.moodStamps = const [],
    this.stickers = const [],
    this.washiTapes = const [],
    this.visualTemplate,
    this.visualStyleVersion = 'v1',
    this.isCurated = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.version = 1,
    this.origin = Origin.manual,
    this.currentVersionId,
    this.ingredients = const [],
    this.steps = const [],
    this.tools = const [],
    this.labels = const [],
    this.notes = const [],
    this.isFavorite = false,
  });

  bool get isDeleted => deletedAt != null;

  Recipe copyWith({
    String? id,
    String? profileId,
    String? title,
    String? slug,
    String? summary,
    RecipeStatus? status,
    Rational? baseServings,
    RecipeDifficulty? difficulty,
    int? totalMinutes,
    String? coverMediaId,
    String? coverImage,
    String? polaroidCaption,
    double? polaroidRotation,
    double? polaroidX,
    double? polaroidY,
    String? chefTip,
    String? chefTipIcon,
    String? chefTipIconColor,
    ScrapbookTheme? theme,
    List<String>? moodStamps,
    List<ScrapbookSticker>? stickers,
    List<WashiTapeDecoration>? washiTapes,
    String? visualTemplate,
    String? visualStyleVersion,
    bool? isCurated,
    int? createdAt,
    int? updatedAt,
    int? deletedAt,
    int? version,
    Origin? origin,
    String? currentVersionId,
    List<RecipeIngredient>? ingredients,
    List<RecipeStep>? steps,
    List<RecipeTool>? tools,
    List<RecipeLabel>? labels,
    List<RecipeNote>? notes,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      baseServings: baseServings ?? this.baseServings,
      difficulty: difficulty ?? this.difficulty,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      coverMediaId: coverMediaId ?? this.coverMediaId,
      coverImage: coverImage ?? this.coverImage,
      polaroidCaption: polaroidCaption ?? this.polaroidCaption,
      polaroidRotation: polaroidRotation ?? this.polaroidRotation,
      polaroidX: polaroidX ?? this.polaroidX,
      polaroidY: polaroidY ?? this.polaroidY,
      chefTip: chefTip ?? this.chefTip,
      chefTipIcon: chefTipIcon ?? this.chefTipIcon,
      chefTipIconColor: chefTipIconColor ?? this.chefTipIconColor,
      theme: theme ?? this.theme,
      moodStamps: moodStamps ?? this.moodStamps,
      stickers: stickers ?? this.stickers,
      washiTapes: washiTapes ?? this.washiTapes,
      visualTemplate: visualTemplate ?? this.visualTemplate,
      visualStyleVersion: visualStyleVersion ?? this.visualStyleVersion,
      isCurated: isCurated ?? this.isCurated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      origin: origin ?? this.origin,
      currentVersionId: currentVersionId ?? this.currentVersionId,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      tools: tools ?? this.tools,
      labels: labels ?? this.labels,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
