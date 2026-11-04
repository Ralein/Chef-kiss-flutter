// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTableTable extends ProfilesTable
    with TableInfo<$ProfilesTableTable, ProfilesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Local Cook'),
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _unitSystemMeta = const VerificationMeta(
    'unitSystem',
  );
  @override
  late final GeneratedColumn<String> unitSystem = GeneratedColumn<String>(
    'unit_system',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('metric'),
  );
  static const VerificationMeta _settingsVersionMeta = const VerificationMeta(
    'settingsVersion',
  );
  @override
  late final GeneratedColumn<int> settingsVersion = GeneratedColumn<int>(
    'settings_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    locale,
    unitSystem,
    settingsVersion,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfilesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('unit_system')) {
      context.handle(
        _unitSystemMeta,
        unitSystem.isAcceptableOrUnknown(data['unit_system']!, _unitSystemMeta),
      );
    }
    if (data.containsKey('settings_version')) {
      context.handle(
        _settingsVersionMeta,
        settingsVersion.isAcceptableOrUnknown(
          data['settings_version']!,
          _settingsVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfilesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfilesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      unitSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_system'],
      )!,
      settingsVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}settings_version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProfilesTableTable createAlias(String alias) {
    return $ProfilesTableTable(attachedDatabase, alias);
  }
}

class ProfilesTableData extends DataClass
    implements Insertable<ProfilesTableData> {
  final String id;
  final String displayName;
  final String locale;
  final String unitSystem;
  final int settingsVersion;
  final int createdAt;
  final int updatedAt;
  const ProfilesTableData({
    required this.id,
    required this.displayName,
    required this.locale,
    required this.unitSystem,
    required this.settingsVersion,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['locale'] = Variable<String>(locale);
    map['unit_system'] = Variable<String>(unitSystem);
    map['settings_version'] = Variable<int>(settingsVersion);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ProfilesTableCompanion toCompanion(bool nullToAbsent) {
    return ProfilesTableCompanion(
      id: Value(id),
      displayName: Value(displayName),
      locale: Value(locale),
      unitSystem: Value(unitSystem),
      settingsVersion: Value(settingsVersion),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProfilesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfilesTableData(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      locale: serializer.fromJson<String>(json['locale']),
      unitSystem: serializer.fromJson<String>(json['unitSystem']),
      settingsVersion: serializer.fromJson<int>(json['settingsVersion']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'locale': serializer.toJson<String>(locale),
      'unitSystem': serializer.toJson<String>(unitSystem),
      'settingsVersion': serializer.toJson<int>(settingsVersion),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ProfilesTableData copyWith({
    String? id,
    String? displayName,
    String? locale,
    String? unitSystem,
    int? settingsVersion,
    int? createdAt,
    int? updatedAt,
  }) => ProfilesTableData(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    locale: locale ?? this.locale,
    unitSystem: unitSystem ?? this.unitSystem,
    settingsVersion: settingsVersion ?? this.settingsVersion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProfilesTableData copyWithCompanion(ProfilesTableCompanion data) {
    return ProfilesTableData(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      locale: data.locale.present ? data.locale.value : this.locale,
      unitSystem: data.unitSystem.present
          ? data.unitSystem.value
          : this.unitSystem,
      settingsVersion: data.settingsVersion.present
          ? data.settingsVersion.value
          : this.settingsVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesTableData(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('locale: $locale, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('settingsVersion: $settingsVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    locale,
    unitSystem,
    settingsVersion,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfilesTableData &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.locale == this.locale &&
          other.unitSystem == this.unitSystem &&
          other.settingsVersion == this.settingsVersion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProfilesTableCompanion extends UpdateCompanion<ProfilesTableData> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> locale;
  final Value<String> unitSystem;
  final Value<int> settingsVersion;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ProfilesTableCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.locale = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.settingsVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesTableCompanion.insert({
    required String id,
    this.displayName = const Value.absent(),
    this.locale = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.settingsVersion = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProfilesTableData> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? locale,
    Expression<String>? unitSystem,
    Expression<int>? settingsVersion,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (locale != null) 'locale': locale,
      if (unitSystem != null) 'unit_system': unitSystem,
      if (settingsVersion != null) 'settings_version': settingsVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String>? locale,
    Value<String>? unitSystem,
    Value<int>? settingsVersion,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProfilesTableCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      locale: locale ?? this.locale,
      unitSystem: unitSystem ?? this.unitSystem,
      settingsVersion: settingsVersion ?? this.settingsVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (unitSystem.present) {
      map['unit_system'] = Variable<String>(unitSystem.value);
    }
    if (settingsVersion.present) {
      map['settings_version'] = Variable<int>(settingsVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesTableCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('locale: $locale, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('settingsVersion: $settingsVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipesTableTable extends RecipesTable
    with TableInfo<$RecipesTableTable, RecipesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentVersionIdMeta = const VerificationMeta(
    'currentVersionId',
  );
  @override
  late final GeneratedColumn<String> currentVersionId = GeneratedColumn<String>(
    'current_version_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _baseServingsNumMeta = const VerificationMeta(
    'baseServingsNum',
  );
  @override
  late final GeneratedColumn<int> baseServingsNum = GeneratedColumn<int>(
    'base_servings_num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _baseServingsDenMeta = const VerificationMeta(
    'baseServingsDen',
  );
  @override
  late final GeneratedColumn<int> baseServingsDen = GeneratedColumn<int>(
    'base_servings_den',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  );
  static const VerificationMeta _totalMinutesMeta = const VerificationMeta(
    'totalMinutes',
  );
  @override
  late final GeneratedColumn<int> totalMinutes = GeneratedColumn<int>(
    'total_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _coverMediaIdMeta = const VerificationMeta(
    'coverMediaId',
  );
  @override
  late final GeneratedColumn<String> coverMediaId = GeneratedColumn<String>(
    'cover_media_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visualTemplateMeta = const VerificationMeta(
    'visualTemplate',
  );
  @override
  late final GeneratedColumn<String> visualTemplate = GeneratedColumn<String>(
    'visual_template',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visualStyleVersionMeta =
      const VerificationMeta('visualStyleVersion');
  @override
  late final GeneratedColumn<String> visualStyleVersion =
      GeneratedColumn<String>(
        'visual_style_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('v1'),
      );
  static const VerificationMeta _isCuratedMeta = const VerificationMeta(
    'isCurated',
  );
  @override
  late final GeneratedColumn<bool> isCurated = GeneratedColumn<bool>(
    'is_curated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_curated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _provenanceJsonMeta = const VerificationMeta(
    'provenanceJson',
  );
  @override
  late final GeneratedColumn<String> provenanceJson = GeneratedColumn<String>(
    'provenance_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    currentVersionId,
    title,
    slug,
    summary,
    status,
    baseServingsNum,
    baseServingsDen,
    difficulty,
    totalMinutes,
    coverMediaId,
    visualTemplate,
    visualStyleVersion,
    isCurated,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    origin,
    provenanceJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('current_version_id')) {
      context.handle(
        _currentVersionIdMeta,
        currentVersionId.isAcceptableOrUnknown(
          data['current_version_id']!,
          _currentVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('base_servings_num')) {
      context.handle(
        _baseServingsNumMeta,
        baseServingsNum.isAcceptableOrUnknown(
          data['base_servings_num']!,
          _baseServingsNumMeta,
        ),
      );
    }
    if (data.containsKey('base_servings_den')) {
      context.handle(
        _baseServingsDenMeta,
        baseServingsDen.isAcceptableOrUnknown(
          data['base_servings_den']!,
          _baseServingsDenMeta,
        ),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('total_minutes')) {
      context.handle(
        _totalMinutesMeta,
        totalMinutes.isAcceptableOrUnknown(
          data['total_minutes']!,
          _totalMinutesMeta,
        ),
      );
    }
    if (data.containsKey('cover_media_id')) {
      context.handle(
        _coverMediaIdMeta,
        coverMediaId.isAcceptableOrUnknown(
          data['cover_media_id']!,
          _coverMediaIdMeta,
        ),
      );
    }
    if (data.containsKey('visual_template')) {
      context.handle(
        _visualTemplateMeta,
        visualTemplate.isAcceptableOrUnknown(
          data['visual_template']!,
          _visualTemplateMeta,
        ),
      );
    }
    if (data.containsKey('visual_style_version')) {
      context.handle(
        _visualStyleVersionMeta,
        visualStyleVersion.isAcceptableOrUnknown(
          data['visual_style_version']!,
          _visualStyleVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_curated')) {
      context.handle(
        _isCuratedMeta,
        isCurated.isAcceptableOrUnknown(data['is_curated']!, _isCuratedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('provenance_json')) {
      context.handle(
        _provenanceJsonMeta,
        provenanceJson.isAcceptableOrUnknown(
          data['provenance_json']!,
          _provenanceJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      currentVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_version_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      baseServingsNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_servings_num'],
      )!,
      baseServingsDen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_servings_den'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      )!,
      totalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_minutes'],
      )!,
      coverMediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_media_id'],
      ),
      visualTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visual_template'],
      ),
      visualStyleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visual_style_version'],
      )!,
      isCurated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_curated'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      provenanceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provenance_json'],
      )!,
    );
  }

  @override
  $RecipesTableTable createAlias(String alias) {
    return $RecipesTableTable(attachedDatabase, alias);
  }
}

class RecipesTableData extends DataClass
    implements Insertable<RecipesTableData> {
  final String id;
  final String profileId;
  final String? currentVersionId;
  final String title;
  final String? slug;
  final String? summary;
  final String status;
  final int baseServingsNum;
  final int baseServingsDen;
  final String difficulty;
  final int totalMinutes;
  final String? coverMediaId;
  final String? visualTemplate;
  final String visualStyleVersion;
  final bool isCurated;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int version;
  final String origin;
  final String provenanceJson;
  const RecipesTableData({
    required this.id,
    required this.profileId,
    this.currentVersionId,
    required this.title,
    this.slug,
    this.summary,
    required this.status,
    required this.baseServingsNum,
    required this.baseServingsDen,
    required this.difficulty,
    required this.totalMinutes,
    this.coverMediaId,
    this.visualTemplate,
    required this.visualStyleVersion,
    required this.isCurated,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.origin,
    required this.provenanceJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    if (!nullToAbsent || currentVersionId != null) {
      map['current_version_id'] = Variable<String>(currentVersionId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || slug != null) {
      map['slug'] = Variable<String>(slug);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    map['status'] = Variable<String>(status);
    map['base_servings_num'] = Variable<int>(baseServingsNum);
    map['base_servings_den'] = Variable<int>(baseServingsDen);
    map['difficulty'] = Variable<String>(difficulty);
    map['total_minutes'] = Variable<int>(totalMinutes);
    if (!nullToAbsent || coverMediaId != null) {
      map['cover_media_id'] = Variable<String>(coverMediaId);
    }
    if (!nullToAbsent || visualTemplate != null) {
      map['visual_template'] = Variable<String>(visualTemplate);
    }
    map['visual_style_version'] = Variable<String>(visualStyleVersion);
    map['is_curated'] = Variable<bool>(isCurated);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['origin'] = Variable<String>(origin);
    map['provenance_json'] = Variable<String>(provenanceJson);
    return map;
  }

  RecipesTableCompanion toCompanion(bool nullToAbsent) {
    return RecipesTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      currentVersionId: currentVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentVersionId),
      title: Value(title),
      slug: slug == null && nullToAbsent ? const Value.absent() : Value(slug),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      status: Value(status),
      baseServingsNum: Value(baseServingsNum),
      baseServingsDen: Value(baseServingsDen),
      difficulty: Value(difficulty),
      totalMinutes: Value(totalMinutes),
      coverMediaId: coverMediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(coverMediaId),
      visualTemplate: visualTemplate == null && nullToAbsent
          ? const Value.absent()
          : Value(visualTemplate),
      visualStyleVersion: Value(visualStyleVersion),
      isCurated: Value(isCurated),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      origin: Value(origin),
      provenanceJson: Value(provenanceJson),
    );
  }

  factory RecipesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipesTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      currentVersionId: serializer.fromJson<String?>(json['currentVersionId']),
      title: serializer.fromJson<String>(json['title']),
      slug: serializer.fromJson<String?>(json['slug']),
      summary: serializer.fromJson<String?>(json['summary']),
      status: serializer.fromJson<String>(json['status']),
      baseServingsNum: serializer.fromJson<int>(json['baseServingsNum']),
      baseServingsDen: serializer.fromJson<int>(json['baseServingsDen']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      totalMinutes: serializer.fromJson<int>(json['totalMinutes']),
      coverMediaId: serializer.fromJson<String?>(json['coverMediaId']),
      visualTemplate: serializer.fromJson<String?>(json['visualTemplate']),
      visualStyleVersion: serializer.fromJson<String>(
        json['visualStyleVersion'],
      ),
      isCurated: serializer.fromJson<bool>(json['isCurated']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      origin: serializer.fromJson<String>(json['origin']),
      provenanceJson: serializer.fromJson<String>(json['provenanceJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'currentVersionId': serializer.toJson<String?>(currentVersionId),
      'title': serializer.toJson<String>(title),
      'slug': serializer.toJson<String?>(slug),
      'summary': serializer.toJson<String?>(summary),
      'status': serializer.toJson<String>(status),
      'baseServingsNum': serializer.toJson<int>(baseServingsNum),
      'baseServingsDen': serializer.toJson<int>(baseServingsDen),
      'difficulty': serializer.toJson<String>(difficulty),
      'totalMinutes': serializer.toJson<int>(totalMinutes),
      'coverMediaId': serializer.toJson<String?>(coverMediaId),
      'visualTemplate': serializer.toJson<String?>(visualTemplate),
      'visualStyleVersion': serializer.toJson<String>(visualStyleVersion),
      'isCurated': serializer.toJson<bool>(isCurated),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'origin': serializer.toJson<String>(origin),
      'provenanceJson': serializer.toJson<String>(provenanceJson),
    };
  }

  RecipesTableData copyWith({
    String? id,
    String? profileId,
    Value<String?> currentVersionId = const Value.absent(),
    String? title,
    Value<String?> slug = const Value.absent(),
    Value<String?> summary = const Value.absent(),
    String? status,
    int? baseServingsNum,
    int? baseServingsDen,
    String? difficulty,
    int? totalMinutes,
    Value<String?> coverMediaId = const Value.absent(),
    Value<String?> visualTemplate = const Value.absent(),
    String? visualStyleVersion,
    bool? isCurated,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? version,
    String? origin,
    String? provenanceJson,
  }) => RecipesTableData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    currentVersionId: currentVersionId.present
        ? currentVersionId.value
        : this.currentVersionId,
    title: title ?? this.title,
    slug: slug.present ? slug.value : this.slug,
    summary: summary.present ? summary.value : this.summary,
    status: status ?? this.status,
    baseServingsNum: baseServingsNum ?? this.baseServingsNum,
    baseServingsDen: baseServingsDen ?? this.baseServingsDen,
    difficulty: difficulty ?? this.difficulty,
    totalMinutes: totalMinutes ?? this.totalMinutes,
    coverMediaId: coverMediaId.present ? coverMediaId.value : this.coverMediaId,
    visualTemplate: visualTemplate.present
        ? visualTemplate.value
        : this.visualTemplate,
    visualStyleVersion: visualStyleVersion ?? this.visualStyleVersion,
    isCurated: isCurated ?? this.isCurated,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    origin: origin ?? this.origin,
    provenanceJson: provenanceJson ?? this.provenanceJson,
  );
  RecipesTableData copyWithCompanion(RecipesTableCompanion data) {
    return RecipesTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      currentVersionId: data.currentVersionId.present
          ? data.currentVersionId.value
          : this.currentVersionId,
      title: data.title.present ? data.title.value : this.title,
      slug: data.slug.present ? data.slug.value : this.slug,
      summary: data.summary.present ? data.summary.value : this.summary,
      status: data.status.present ? data.status.value : this.status,
      baseServingsNum: data.baseServingsNum.present
          ? data.baseServingsNum.value
          : this.baseServingsNum,
      baseServingsDen: data.baseServingsDen.present
          ? data.baseServingsDen.value
          : this.baseServingsDen,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      totalMinutes: data.totalMinutes.present
          ? data.totalMinutes.value
          : this.totalMinutes,
      coverMediaId: data.coverMediaId.present
          ? data.coverMediaId.value
          : this.coverMediaId,
      visualTemplate: data.visualTemplate.present
          ? data.visualTemplate.value
          : this.visualTemplate,
      visualStyleVersion: data.visualStyleVersion.present
          ? data.visualStyleVersion.value
          : this.visualStyleVersion,
      isCurated: data.isCurated.present ? data.isCurated.value : this.isCurated,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      origin: data.origin.present ? data.origin.value : this.origin,
      provenanceJson: data.provenanceJson.present
          ? data.provenanceJson.value
          : this.provenanceJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipesTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('currentVersionId: $currentVersionId, ')
          ..write('title: $title, ')
          ..write('slug: $slug, ')
          ..write('summary: $summary, ')
          ..write('status: $status, ')
          ..write('baseServingsNum: $baseServingsNum, ')
          ..write('baseServingsDen: $baseServingsDen, ')
          ..write('difficulty: $difficulty, ')
          ..write('totalMinutes: $totalMinutes, ')
          ..write('coverMediaId: $coverMediaId, ')
          ..write('visualTemplate: $visualTemplate, ')
          ..write('visualStyleVersion: $visualStyleVersion, ')
          ..write('isCurated: $isCurated, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('origin: $origin, ')
          ..write('provenanceJson: $provenanceJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    profileId,
    currentVersionId,
    title,
    slug,
    summary,
    status,
    baseServingsNum,
    baseServingsDen,
    difficulty,
    totalMinutes,
    coverMediaId,
    visualTemplate,
    visualStyleVersion,
    isCurated,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    origin,
    provenanceJson,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipesTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.currentVersionId == this.currentVersionId &&
          other.title == this.title &&
          other.slug == this.slug &&
          other.summary == this.summary &&
          other.status == this.status &&
          other.baseServingsNum == this.baseServingsNum &&
          other.baseServingsDen == this.baseServingsDen &&
          other.difficulty == this.difficulty &&
          other.totalMinutes == this.totalMinutes &&
          other.coverMediaId == this.coverMediaId &&
          other.visualTemplate == this.visualTemplate &&
          other.visualStyleVersion == this.visualStyleVersion &&
          other.isCurated == this.isCurated &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.origin == this.origin &&
          other.provenanceJson == this.provenanceJson);
}

class RecipesTableCompanion extends UpdateCompanion<RecipesTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String?> currentVersionId;
  final Value<String> title;
  final Value<String?> slug;
  final Value<String?> summary;
  final Value<String> status;
  final Value<int> baseServingsNum;
  final Value<int> baseServingsDen;
  final Value<String> difficulty;
  final Value<int> totalMinutes;
  final Value<String?> coverMediaId;
  final Value<String?> visualTemplate;
  final Value<String> visualStyleVersion;
  final Value<bool> isCurated;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> version;
  final Value<String> origin;
  final Value<String> provenanceJson;
  final Value<int> rowid;
  const RecipesTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.currentVersionId = const Value.absent(),
    this.title = const Value.absent(),
    this.slug = const Value.absent(),
    this.summary = const Value.absent(),
    this.status = const Value.absent(),
    this.baseServingsNum = const Value.absent(),
    this.baseServingsDen = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.totalMinutes = const Value.absent(),
    this.coverMediaId = const Value.absent(),
    this.visualTemplate = const Value.absent(),
    this.visualStyleVersion = const Value.absent(),
    this.isCurated = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.origin = const Value.absent(),
    this.provenanceJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesTableCompanion.insert({
    required String id,
    required String profileId,
    this.currentVersionId = const Value.absent(),
    required String title,
    this.slug = const Value.absent(),
    this.summary = const Value.absent(),
    this.status = const Value.absent(),
    this.baseServingsNum = const Value.absent(),
    this.baseServingsDen = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.totalMinutes = const Value.absent(),
    this.coverMediaId = const Value.absent(),
    this.visualTemplate = const Value.absent(),
    this.visualStyleVersion = const Value.absent(),
    this.isCurated = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.origin = const Value.absent(),
    this.provenanceJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RecipesTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? currentVersionId,
    Expression<String>? title,
    Expression<String>? slug,
    Expression<String>? summary,
    Expression<String>? status,
    Expression<int>? baseServingsNum,
    Expression<int>? baseServingsDen,
    Expression<String>? difficulty,
    Expression<int>? totalMinutes,
    Expression<String>? coverMediaId,
    Expression<String>? visualTemplate,
    Expression<String>? visualStyleVersion,
    Expression<bool>? isCurated,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? version,
    Expression<String>? origin,
    Expression<String>? provenanceJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (currentVersionId != null) 'current_version_id': currentVersionId,
      if (title != null) 'title': title,
      if (slug != null) 'slug': slug,
      if (summary != null) 'summary': summary,
      if (status != null) 'status': status,
      if (baseServingsNum != null) 'base_servings_num': baseServingsNum,
      if (baseServingsDen != null) 'base_servings_den': baseServingsDen,
      if (difficulty != null) 'difficulty': difficulty,
      if (totalMinutes != null) 'total_minutes': totalMinutes,
      if (coverMediaId != null) 'cover_media_id': coverMediaId,
      if (visualTemplate != null) 'visual_template': visualTemplate,
      if (visualStyleVersion != null)
        'visual_style_version': visualStyleVersion,
      if (isCurated != null) 'is_curated': isCurated,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (origin != null) 'origin': origin,
      if (provenanceJson != null) 'provenance_json': provenanceJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String?>? currentVersionId,
    Value<String>? title,
    Value<String?>? slug,
    Value<String?>? summary,
    Value<String>? status,
    Value<int>? baseServingsNum,
    Value<int>? baseServingsDen,
    Value<String>? difficulty,
    Value<int>? totalMinutes,
    Value<String?>? coverMediaId,
    Value<String?>? visualTemplate,
    Value<String>? visualStyleVersion,
    Value<bool>? isCurated,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? version,
    Value<String>? origin,
    Value<String>? provenanceJson,
    Value<int>? rowid,
  }) {
    return RecipesTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      currentVersionId: currentVersionId ?? this.currentVersionId,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      baseServingsNum: baseServingsNum ?? this.baseServingsNum,
      baseServingsDen: baseServingsDen ?? this.baseServingsDen,
      difficulty: difficulty ?? this.difficulty,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      coverMediaId: coverMediaId ?? this.coverMediaId,
      visualTemplate: visualTemplate ?? this.visualTemplate,
      visualStyleVersion: visualStyleVersion ?? this.visualStyleVersion,
      isCurated: isCurated ?? this.isCurated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      origin: origin ?? this.origin,
      provenanceJson: provenanceJson ?? this.provenanceJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (currentVersionId.present) {
      map['current_version_id'] = Variable<String>(currentVersionId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (baseServingsNum.present) {
      map['base_servings_num'] = Variable<int>(baseServingsNum.value);
    }
    if (baseServingsDen.present) {
      map['base_servings_den'] = Variable<int>(baseServingsDen.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (totalMinutes.present) {
      map['total_minutes'] = Variable<int>(totalMinutes.value);
    }
    if (coverMediaId.present) {
      map['cover_media_id'] = Variable<String>(coverMediaId.value);
    }
    if (visualTemplate.present) {
      map['visual_template'] = Variable<String>(visualTemplate.value);
    }
    if (visualStyleVersion.present) {
      map['visual_style_version'] = Variable<String>(visualStyleVersion.value);
    }
    if (isCurated.present) {
      map['is_curated'] = Variable<bool>(isCurated.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (provenanceJson.present) {
      map['provenance_json'] = Variable<String>(provenanceJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('currentVersionId: $currentVersionId, ')
          ..write('title: $title, ')
          ..write('slug: $slug, ')
          ..write('summary: $summary, ')
          ..write('status: $status, ')
          ..write('baseServingsNum: $baseServingsNum, ')
          ..write('baseServingsDen: $baseServingsDen, ')
          ..write('difficulty: $difficulty, ')
          ..write('totalMinutes: $totalMinutes, ')
          ..write('coverMediaId: $coverMediaId, ')
          ..write('visualTemplate: $visualTemplate, ')
          ..write('visualStyleVersion: $visualStyleVersion, ')
          ..write('isCurated: $isCurated, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('origin: $origin, ')
          ..write('provenanceJson: $provenanceJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeVersionsTableTable extends RecipeVersionsTable
    with TableInfo<$RecipeVersionsTableTable, RecipeVersionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeVersionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snapshotJsonMeta = const VerificationMeta(
    'snapshotJson',
  );
  @override
  late final GeneratedColumn<String> snapshotJson = GeneratedColumn<String>(
    'snapshot_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeSummaryMeta = const VerificationMeta(
    'changeSummary',
  );
  @override
  late final GeneratedColumn<String> changeSummary = GeneratedColumn<String>(
    'change_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorKindMeta = const VerificationMeta(
    'authorKind',
  );
  @override
  late final GeneratedColumn<String> authorKind = GeneratedColumn<String>(
    'author_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _parentVersionIdMeta = const VerificationMeta(
    'parentVersionId',
  );
  @override
  late final GeneratedColumn<String> parentVersionId = GeneratedColumn<String>(
    'parent_version_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    sequence,
    snapshotJson,
    changeSummary,
    authorKind,
    parentVersionId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_versions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeVersionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('snapshot_json')) {
      context.handle(
        _snapshotJsonMeta,
        snapshotJson.isAcceptableOrUnknown(
          data['snapshot_json']!,
          _snapshotJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotJsonMeta);
    }
    if (data.containsKey('change_summary')) {
      context.handle(
        _changeSummaryMeta,
        changeSummary.isAcceptableOrUnknown(
          data['change_summary']!,
          _changeSummaryMeta,
        ),
      );
    }
    if (data.containsKey('author_kind')) {
      context.handle(
        _authorKindMeta,
        authorKind.isAcceptableOrUnknown(data['author_kind']!, _authorKindMeta),
      );
    }
    if (data.containsKey('parent_version_id')) {
      context.handle(
        _parentVersionIdMeta,
        parentVersionId.isAcceptableOrUnknown(
          data['parent_version_id']!,
          _parentVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeVersionsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeVersionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      snapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_json'],
      )!,
      changeSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_summary'],
      ),
      authorKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_kind'],
      )!,
      parentVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_version_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecipeVersionsTableTable createAlias(String alias) {
    return $RecipeVersionsTableTable(attachedDatabase, alias);
  }
}

class RecipeVersionsTableData extends DataClass
    implements Insertable<RecipeVersionsTableData> {
  final String id;
  final String recipeId;
  final int sequence;
  final String snapshotJson;
  final String? changeSummary;
  final String authorKind;
  final String? parentVersionId;
  final int createdAt;
  const RecipeVersionsTableData({
    required this.id,
    required this.recipeId,
    required this.sequence,
    required this.snapshotJson,
    this.changeSummary,
    required this.authorKind,
    this.parentVersionId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['sequence'] = Variable<int>(sequence);
    map['snapshot_json'] = Variable<String>(snapshotJson);
    if (!nullToAbsent || changeSummary != null) {
      map['change_summary'] = Variable<String>(changeSummary);
    }
    map['author_kind'] = Variable<String>(authorKind);
    if (!nullToAbsent || parentVersionId != null) {
      map['parent_version_id'] = Variable<String>(parentVersionId);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  RecipeVersionsTableCompanion toCompanion(bool nullToAbsent) {
    return RecipeVersionsTableCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      sequence: Value(sequence),
      snapshotJson: Value(snapshotJson),
      changeSummary: changeSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(changeSummary),
      authorKind: Value(authorKind),
      parentVersionId: parentVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentVersionId),
      createdAt: Value(createdAt),
    );
  }

  factory RecipeVersionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeVersionsTableData(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      snapshotJson: serializer.fromJson<String>(json['snapshotJson']),
      changeSummary: serializer.fromJson<String?>(json['changeSummary']),
      authorKind: serializer.fromJson<String>(json['authorKind']),
      parentVersionId: serializer.fromJson<String?>(json['parentVersionId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'sequence': serializer.toJson<int>(sequence),
      'snapshotJson': serializer.toJson<String>(snapshotJson),
      'changeSummary': serializer.toJson<String?>(changeSummary),
      'authorKind': serializer.toJson<String>(authorKind),
      'parentVersionId': serializer.toJson<String?>(parentVersionId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  RecipeVersionsTableData copyWith({
    String? id,
    String? recipeId,
    int? sequence,
    String? snapshotJson,
    Value<String?> changeSummary = const Value.absent(),
    String? authorKind,
    Value<String?> parentVersionId = const Value.absent(),
    int? createdAt,
  }) => RecipeVersionsTableData(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    sequence: sequence ?? this.sequence,
    snapshotJson: snapshotJson ?? this.snapshotJson,
    changeSummary: changeSummary.present
        ? changeSummary.value
        : this.changeSummary,
    authorKind: authorKind ?? this.authorKind,
    parentVersionId: parentVersionId.present
        ? parentVersionId.value
        : this.parentVersionId,
    createdAt: createdAt ?? this.createdAt,
  );
  RecipeVersionsTableData copyWithCompanion(RecipeVersionsTableCompanion data) {
    return RecipeVersionsTableData(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      snapshotJson: data.snapshotJson.present
          ? data.snapshotJson.value
          : this.snapshotJson,
      changeSummary: data.changeSummary.present
          ? data.changeSummary.value
          : this.changeSummary,
      authorKind: data.authorKind.present
          ? data.authorKind.value
          : this.authorKind,
      parentVersionId: data.parentVersionId.present
          ? data.parentVersionId.value
          : this.parentVersionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeVersionsTableData(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('sequence: $sequence, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('changeSummary: $changeSummary, ')
          ..write('authorKind: $authorKind, ')
          ..write('parentVersionId: $parentVersionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recipeId,
    sequence,
    snapshotJson,
    changeSummary,
    authorKind,
    parentVersionId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeVersionsTableData &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.sequence == this.sequence &&
          other.snapshotJson == this.snapshotJson &&
          other.changeSummary == this.changeSummary &&
          other.authorKind == this.authorKind &&
          other.parentVersionId == this.parentVersionId &&
          other.createdAt == this.createdAt);
}

class RecipeVersionsTableCompanion
    extends UpdateCompanion<RecipeVersionsTableData> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<int> sequence;
  final Value<String> snapshotJson;
  final Value<String?> changeSummary;
  final Value<String> authorKind;
  final Value<String?> parentVersionId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const RecipeVersionsTableCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.snapshotJson = const Value.absent(),
    this.changeSummary = const Value.absent(),
    this.authorKind = const Value.absent(),
    this.parentVersionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeVersionsTableCompanion.insert({
    required String id,
    required String recipeId,
    required int sequence,
    required String snapshotJson,
    this.changeSummary = const Value.absent(),
    this.authorKind = const Value.absent(),
    this.parentVersionId = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recipeId = Value(recipeId),
       sequence = Value(sequence),
       snapshotJson = Value(snapshotJson),
       createdAt = Value(createdAt);
  static Insertable<RecipeVersionsTableData> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<int>? sequence,
    Expression<String>? snapshotJson,
    Expression<String>? changeSummary,
    Expression<String>? authorKind,
    Expression<String>? parentVersionId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (sequence != null) 'sequence': sequence,
      if (snapshotJson != null) 'snapshot_json': snapshotJson,
      if (changeSummary != null) 'change_summary': changeSummary,
      if (authorKind != null) 'author_kind': authorKind,
      if (parentVersionId != null) 'parent_version_id': parentVersionId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeVersionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? recipeId,
    Value<int>? sequence,
    Value<String>? snapshotJson,
    Value<String?>? changeSummary,
    Value<String>? authorKind,
    Value<String?>? parentVersionId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return RecipeVersionsTableCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      sequence: sequence ?? this.sequence,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      changeSummary: changeSummary ?? this.changeSummary,
      authorKind: authorKind ?? this.authorKind,
      parentVersionId: parentVersionId ?? this.parentVersionId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (snapshotJson.present) {
      map['snapshot_json'] = Variable<String>(snapshotJson.value);
    }
    if (changeSummary.present) {
      map['change_summary'] = Variable<String>(changeSummary.value);
    }
    if (authorKind.present) {
      map['author_kind'] = Variable<String>(authorKind.value);
    }
    if (parentVersionId.present) {
      map['parent_version_id'] = Variable<String>(parentVersionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeVersionsTableCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('sequence: $sequence, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('changeSummary: $changeSummary, ')
          ..write('authorKind: $authorKind, ')
          ..write('parentVersionId: $parentVersionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeNotesTableTable extends RecipeNotesTable
    with TableInfo<$RecipeNotesTableTable, RecipeNotesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeNotesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteTypeMeta = const VerificationMeta(
    'noteType',
  );
  @override
  late final GeneratedColumn<String> noteType = GeneratedColumn<String>(
    'note_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user'),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    body,
    noteType,
    position,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_notes_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeNotesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('note_type')) {
      context.handle(
        _noteTypeMeta,
        noteType.isAcceptableOrUnknown(data['note_type']!, _noteTypeMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeNotesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeNotesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      noteType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_type'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecipeNotesTableTable createAlias(String alias) {
    return $RecipeNotesTableTable(attachedDatabase, alias);
  }
}

class RecipeNotesTableData extends DataClass
    implements Insertable<RecipeNotesTableData> {
  final String id;
  final String recipeId;
  final String body;
  final String noteType;
  final int position;
  final int createdAt;
  const RecipeNotesTableData({
    required this.id,
    required this.recipeId,
    required this.body,
    required this.noteType,
    required this.position,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['body'] = Variable<String>(body);
    map['note_type'] = Variable<String>(noteType);
    map['position'] = Variable<int>(position);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  RecipeNotesTableCompanion toCompanion(bool nullToAbsent) {
    return RecipeNotesTableCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      body: Value(body),
      noteType: Value(noteType),
      position: Value(position),
      createdAt: Value(createdAt),
    );
  }

  factory RecipeNotesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeNotesTableData(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      body: serializer.fromJson<String>(json['body']),
      noteType: serializer.fromJson<String>(json['noteType']),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'body': serializer.toJson<String>(body),
      'noteType': serializer.toJson<String>(noteType),
      'position': serializer.toJson<int>(position),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  RecipeNotesTableData copyWith({
    String? id,
    String? recipeId,
    String? body,
    String? noteType,
    int? position,
    int? createdAt,
  }) => RecipeNotesTableData(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    body: body ?? this.body,
    noteType: noteType ?? this.noteType,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
  );
  RecipeNotesTableData copyWithCompanion(RecipeNotesTableCompanion data) {
    return RecipeNotesTableData(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      body: data.body.present ? data.body.value : this.body,
      noteType: data.noteType.present ? data.noteType.value : this.noteType,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeNotesTableData(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('body: $body, ')
          ..write('noteType: $noteType, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recipeId, body, noteType, position, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeNotesTableData &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.body == this.body &&
          other.noteType == this.noteType &&
          other.position == this.position &&
          other.createdAt == this.createdAt);
}

class RecipeNotesTableCompanion extends UpdateCompanion<RecipeNotesTableData> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<String> body;
  final Value<String> noteType;
  final Value<int> position;
  final Value<int> createdAt;
  final Value<int> rowid;
  const RecipeNotesTableCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.body = const Value.absent(),
    this.noteType = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeNotesTableCompanion.insert({
    required String id,
    required String recipeId,
    required String body,
    this.noteType = const Value.absent(),
    required int position,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recipeId = Value(recipeId),
       body = Value(body),
       position = Value(position),
       createdAt = Value(createdAt);
  static Insertable<RecipeNotesTableData> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<String>? body,
    Expression<String>? noteType,
    Expression<int>? position,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (body != null) 'body': body,
      if (noteType != null) 'note_type': noteType,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeNotesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? recipeId,
    Value<String>? body,
    Value<String>? noteType,
    Value<int>? position,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return RecipeNotesTableCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      body: body ?? this.body,
      noteType: noteType ?? this.noteType,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (noteType.present) {
      map['note_type'] = Variable<String>(noteType.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeNotesTableCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('body: $body, ')
          ..write('noteType: $noteType, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientsCatalogTableTable extends IngredientsCatalogTable
    with TableInfo<$IngredientsCatalogTableTable, IngredientsCatalogTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsCatalogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalNameMeta = const VerificationMeta(
    'canonicalName',
  );
  @override
  late final GeneratedColumn<String> canonicalName = GeneratedColumn<String>(
    'canonical_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pluralNameMeta = const VerificationMeta(
    'pluralName',
  );
  @override
  late final GeneratedColumn<String> pluralName = GeneratedColumn<String>(
    'plural_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synonymsJsonMeta = const VerificationMeta(
    'synonymsJson',
  );
  @override
  late final GeneratedColumn<String> synonymsJson = GeneratedColumn<String>(
    'synonyms_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _defaultScalingPolicyMeta =
      const VerificationMeta('defaultScalingPolicy');
  @override
  late final GeneratedColumn<String> defaultScalingPolicy =
      GeneratedColumn<String>(
        'default_scaling_policy',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('scale'),
      );
  static const VerificationMeta _allergenJsonMeta = const VerificationMeta(
    'allergenJson',
  );
  @override
  late final GeneratedColumn<String> allergenJson = GeneratedColumn<String>(
    'allergen_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _searchTermsMeta = const VerificationMeta(
    'searchTerms',
  );
  @override
  late final GeneratedColumn<String> searchTerms = GeneratedColumn<String>(
    'search_terms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    canonicalName,
    pluralName,
    category,
    synonymsJson,
    defaultScalingPolicy,
    allergenJson,
    searchTerms,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients_catalog_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngredientsCatalogTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('canonical_name')) {
      context.handle(
        _canonicalNameMeta,
        canonicalName.isAcceptableOrUnknown(
          data['canonical_name']!,
          _canonicalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalNameMeta);
    }
    if (data.containsKey('plural_name')) {
      context.handle(
        _pluralNameMeta,
        pluralName.isAcceptableOrUnknown(data['plural_name']!, _pluralNameMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('synonyms_json')) {
      context.handle(
        _synonymsJsonMeta,
        synonymsJson.isAcceptableOrUnknown(
          data['synonyms_json']!,
          _synonymsJsonMeta,
        ),
      );
    }
    if (data.containsKey('default_scaling_policy')) {
      context.handle(
        _defaultScalingPolicyMeta,
        defaultScalingPolicy.isAcceptableOrUnknown(
          data['default_scaling_policy']!,
          _defaultScalingPolicyMeta,
        ),
      );
    }
    if (data.containsKey('allergen_json')) {
      context.handle(
        _allergenJsonMeta,
        allergenJson.isAcceptableOrUnknown(
          data['allergen_json']!,
          _allergenJsonMeta,
        ),
      );
    }
    if (data.containsKey('search_terms')) {
      context.handle(
        _searchTermsMeta,
        searchTerms.isAcceptableOrUnknown(
          data['search_terms']!,
          _searchTermsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IngredientsCatalogTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientsCatalogTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      canonicalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_name'],
      )!,
      pluralName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plural_name'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      synonymsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synonyms_json'],
      )!,
      defaultScalingPolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_scaling_policy'],
      )!,
      allergenJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergen_json'],
      )!,
      searchTerms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_terms'],
      ),
    );
  }

  @override
  $IngredientsCatalogTableTable createAlias(String alias) {
    return $IngredientsCatalogTableTable(attachedDatabase, alias);
  }
}

class IngredientsCatalogTableData extends DataClass
    implements Insertable<IngredientsCatalogTableData> {
  final String id;
  final String canonicalName;
  final String? pluralName;
  final String? category;
  final String synonymsJson;
  final String defaultScalingPolicy;
  final String allergenJson;
  final String? searchTerms;
  const IngredientsCatalogTableData({
    required this.id,
    required this.canonicalName,
    this.pluralName,
    this.category,
    required this.synonymsJson,
    required this.defaultScalingPolicy,
    required this.allergenJson,
    this.searchTerms,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['canonical_name'] = Variable<String>(canonicalName);
    if (!nullToAbsent || pluralName != null) {
      map['plural_name'] = Variable<String>(pluralName);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['synonyms_json'] = Variable<String>(synonymsJson);
    map['default_scaling_policy'] = Variable<String>(defaultScalingPolicy);
    map['allergen_json'] = Variable<String>(allergenJson);
    if (!nullToAbsent || searchTerms != null) {
      map['search_terms'] = Variable<String>(searchTerms);
    }
    return map;
  }

  IngredientsCatalogTableCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCatalogTableCompanion(
      id: Value(id),
      canonicalName: Value(canonicalName),
      pluralName: pluralName == null && nullToAbsent
          ? const Value.absent()
          : Value(pluralName),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      synonymsJson: Value(synonymsJson),
      defaultScalingPolicy: Value(defaultScalingPolicy),
      allergenJson: Value(allergenJson),
      searchTerms: searchTerms == null && nullToAbsent
          ? const Value.absent()
          : Value(searchTerms),
    );
  }

  factory IngredientsCatalogTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientsCatalogTableData(
      id: serializer.fromJson<String>(json['id']),
      canonicalName: serializer.fromJson<String>(json['canonicalName']),
      pluralName: serializer.fromJson<String?>(json['pluralName']),
      category: serializer.fromJson<String?>(json['category']),
      synonymsJson: serializer.fromJson<String>(json['synonymsJson']),
      defaultScalingPolicy: serializer.fromJson<String>(
        json['defaultScalingPolicy'],
      ),
      allergenJson: serializer.fromJson<String>(json['allergenJson']),
      searchTerms: serializer.fromJson<String?>(json['searchTerms']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'canonicalName': serializer.toJson<String>(canonicalName),
      'pluralName': serializer.toJson<String?>(pluralName),
      'category': serializer.toJson<String?>(category),
      'synonymsJson': serializer.toJson<String>(synonymsJson),
      'defaultScalingPolicy': serializer.toJson<String>(defaultScalingPolicy),
      'allergenJson': serializer.toJson<String>(allergenJson),
      'searchTerms': serializer.toJson<String?>(searchTerms),
    };
  }

  IngredientsCatalogTableData copyWith({
    String? id,
    String? canonicalName,
    Value<String?> pluralName = const Value.absent(),
    Value<String?> category = const Value.absent(),
    String? synonymsJson,
    String? defaultScalingPolicy,
    String? allergenJson,
    Value<String?> searchTerms = const Value.absent(),
  }) => IngredientsCatalogTableData(
    id: id ?? this.id,
    canonicalName: canonicalName ?? this.canonicalName,
    pluralName: pluralName.present ? pluralName.value : this.pluralName,
    category: category.present ? category.value : this.category,
    synonymsJson: synonymsJson ?? this.synonymsJson,
    defaultScalingPolicy: defaultScalingPolicy ?? this.defaultScalingPolicy,
    allergenJson: allergenJson ?? this.allergenJson,
    searchTerms: searchTerms.present ? searchTerms.value : this.searchTerms,
  );
  IngredientsCatalogTableData copyWithCompanion(
    IngredientsCatalogTableCompanion data,
  ) {
    return IngredientsCatalogTableData(
      id: data.id.present ? data.id.value : this.id,
      canonicalName: data.canonicalName.present
          ? data.canonicalName.value
          : this.canonicalName,
      pluralName: data.pluralName.present
          ? data.pluralName.value
          : this.pluralName,
      category: data.category.present ? data.category.value : this.category,
      synonymsJson: data.synonymsJson.present
          ? data.synonymsJson.value
          : this.synonymsJson,
      defaultScalingPolicy: data.defaultScalingPolicy.present
          ? data.defaultScalingPolicy.value
          : this.defaultScalingPolicy,
      allergenJson: data.allergenJson.present
          ? data.allergenJson.value
          : this.allergenJson,
      searchTerms: data.searchTerms.present
          ? data.searchTerms.value
          : this.searchTerms,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCatalogTableData(')
          ..write('id: $id, ')
          ..write('canonicalName: $canonicalName, ')
          ..write('pluralName: $pluralName, ')
          ..write('category: $category, ')
          ..write('synonymsJson: $synonymsJson, ')
          ..write('defaultScalingPolicy: $defaultScalingPolicy, ')
          ..write('allergenJson: $allergenJson, ')
          ..write('searchTerms: $searchTerms')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    canonicalName,
    pluralName,
    category,
    synonymsJson,
    defaultScalingPolicy,
    allergenJson,
    searchTerms,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientsCatalogTableData &&
          other.id == this.id &&
          other.canonicalName == this.canonicalName &&
          other.pluralName == this.pluralName &&
          other.category == this.category &&
          other.synonymsJson == this.synonymsJson &&
          other.defaultScalingPolicy == this.defaultScalingPolicy &&
          other.allergenJson == this.allergenJson &&
          other.searchTerms == this.searchTerms);
}

class IngredientsCatalogTableCompanion
    extends UpdateCompanion<IngredientsCatalogTableData> {
  final Value<String> id;
  final Value<String> canonicalName;
  final Value<String?> pluralName;
  final Value<String?> category;
  final Value<String> synonymsJson;
  final Value<String> defaultScalingPolicy;
  final Value<String> allergenJson;
  final Value<String?> searchTerms;
  final Value<int> rowid;
  const IngredientsCatalogTableCompanion({
    this.id = const Value.absent(),
    this.canonicalName = const Value.absent(),
    this.pluralName = const Value.absent(),
    this.category = const Value.absent(),
    this.synonymsJson = const Value.absent(),
    this.defaultScalingPolicy = const Value.absent(),
    this.allergenJson = const Value.absent(),
    this.searchTerms = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientsCatalogTableCompanion.insert({
    required String id,
    required String canonicalName,
    this.pluralName = const Value.absent(),
    this.category = const Value.absent(),
    this.synonymsJson = const Value.absent(),
    this.defaultScalingPolicy = const Value.absent(),
    this.allergenJson = const Value.absent(),
    this.searchTerms = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       canonicalName = Value(canonicalName);
  static Insertable<IngredientsCatalogTableData> custom({
    Expression<String>? id,
    Expression<String>? canonicalName,
    Expression<String>? pluralName,
    Expression<String>? category,
    Expression<String>? synonymsJson,
    Expression<String>? defaultScalingPolicy,
    Expression<String>? allergenJson,
    Expression<String>? searchTerms,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (canonicalName != null) 'canonical_name': canonicalName,
      if (pluralName != null) 'plural_name': pluralName,
      if (category != null) 'category': category,
      if (synonymsJson != null) 'synonyms_json': synonymsJson,
      if (defaultScalingPolicy != null)
        'default_scaling_policy': defaultScalingPolicy,
      if (allergenJson != null) 'allergen_json': allergenJson,
      if (searchTerms != null) 'search_terms': searchTerms,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientsCatalogTableCompanion copyWith({
    Value<String>? id,
    Value<String>? canonicalName,
    Value<String?>? pluralName,
    Value<String?>? category,
    Value<String>? synonymsJson,
    Value<String>? defaultScalingPolicy,
    Value<String>? allergenJson,
    Value<String?>? searchTerms,
    Value<int>? rowid,
  }) {
    return IngredientsCatalogTableCompanion(
      id: id ?? this.id,
      canonicalName: canonicalName ?? this.canonicalName,
      pluralName: pluralName ?? this.pluralName,
      category: category ?? this.category,
      synonymsJson: synonymsJson ?? this.synonymsJson,
      defaultScalingPolicy: defaultScalingPolicy ?? this.defaultScalingPolicy,
      allergenJson: allergenJson ?? this.allergenJson,
      searchTerms: searchTerms ?? this.searchTerms,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (canonicalName.present) {
      map['canonical_name'] = Variable<String>(canonicalName.value);
    }
    if (pluralName.present) {
      map['plural_name'] = Variable<String>(pluralName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (synonymsJson.present) {
      map['synonyms_json'] = Variable<String>(synonymsJson.value);
    }
    if (defaultScalingPolicy.present) {
      map['default_scaling_policy'] = Variable<String>(
        defaultScalingPolicy.value,
      );
    }
    if (allergenJson.present) {
      map['allergen_json'] = Variable<String>(allergenJson.value);
    }
    if (searchTerms.present) {
      map['search_terms'] = Variable<String>(searchTerms.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCatalogTableCompanion(')
          ..write('id: $id, ')
          ..write('canonicalName: $canonicalName, ')
          ..write('pluralName: $pluralName, ')
          ..write('category: $category, ')
          ..write('synonymsJson: $synonymsJson, ')
          ..write('defaultScalingPolicy: $defaultScalingPolicy, ')
          ..write('allergenJson: $allergenJson, ')
          ..write('searchTerms: $searchTerms, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnitsCatalogTableTable extends UnitsCatalogTable
    with TableInfo<$UnitsCatalogTableTable, UnitsCatalogTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitsCatalogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dimensionMeta = const VerificationMeta(
    'dimension',
  );
  @override
  late final GeneratedColumn<String> dimension = GeneratedColumn<String>(
    'dimension',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayMetricMeta = const VerificationMeta(
    'displayMetric',
  );
  @override
  late final GeneratedColumn<String> displayMetric = GeneratedColumn<String>(
    'display_metric',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayUsMeta = const VerificationMeta(
    'displayUs',
  );
  @override
  late final GeneratedColumn<String> displayUs = GeneratedColumn<String>(
    'display_us',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toBaseNumMeta = const VerificationMeta(
    'toBaseNum',
  );
  @override
  late final GeneratedColumn<int> toBaseNum = GeneratedColumn<int>(
    'to_base_num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _toBaseDenMeta = const VerificationMeta(
    'toBaseDen',
  );
  @override
  late final GeneratedColumn<int> toBaseDen = GeneratedColumn<int>(
    'to_base_den',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isScalableMeta = const VerificationMeta(
    'isScalable',
  );
  @override
  late final GeneratedColumn<bool> isScalable = GeneratedColumn<bool>(
    'is_scalable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_scalable" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    dimension,
    displayMetric,
    displayUs,
    toBaseNum,
    toBaseDen,
    isScalable,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'units_catalog_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnitsCatalogTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('dimension')) {
      context.handle(
        _dimensionMeta,
        dimension.isAcceptableOrUnknown(data['dimension']!, _dimensionMeta),
      );
    } else if (isInserting) {
      context.missing(_dimensionMeta);
    }
    if (data.containsKey('display_metric')) {
      context.handle(
        _displayMetricMeta,
        displayMetric.isAcceptableOrUnknown(
          data['display_metric']!,
          _displayMetricMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayMetricMeta);
    }
    if (data.containsKey('display_us')) {
      context.handle(
        _displayUsMeta,
        displayUs.isAcceptableOrUnknown(data['display_us']!, _displayUsMeta),
      );
    } else if (isInserting) {
      context.missing(_displayUsMeta);
    }
    if (data.containsKey('to_base_num')) {
      context.handle(
        _toBaseNumMeta,
        toBaseNum.isAcceptableOrUnknown(data['to_base_num']!, _toBaseNumMeta),
      );
    }
    if (data.containsKey('to_base_den')) {
      context.handle(
        _toBaseDenMeta,
        toBaseDen.isAcceptableOrUnknown(data['to_base_den']!, _toBaseDenMeta),
      );
    }
    if (data.containsKey('is_scalable')) {
      context.handle(
        _isScalableMeta,
        isScalable.isAcceptableOrUnknown(data['is_scalable']!, _isScalableMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnitsCatalogTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnitsCatalogTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      dimension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dimension'],
      )!,
      displayMetric: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_metric'],
      )!,
      displayUs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_us'],
      )!,
      toBaseNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_base_num'],
      )!,
      toBaseDen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_base_den'],
      )!,
      isScalable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_scalable'],
      )!,
    );
  }

  @override
  $UnitsCatalogTableTable createAlias(String alias) {
    return $UnitsCatalogTableTable(attachedDatabase, alias);
  }
}

class UnitsCatalogTableData extends DataClass
    implements Insertable<UnitsCatalogTableData> {
  final String id;
  final String code;
  final String dimension;
  final String displayMetric;
  final String displayUs;
  final int toBaseNum;
  final int toBaseDen;
  final bool isScalable;
  const UnitsCatalogTableData({
    required this.id,
    required this.code,
    required this.dimension,
    required this.displayMetric,
    required this.displayUs,
    required this.toBaseNum,
    required this.toBaseDen,
    required this.isScalable,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['dimension'] = Variable<String>(dimension);
    map['display_metric'] = Variable<String>(displayMetric);
    map['display_us'] = Variable<String>(displayUs);
    map['to_base_num'] = Variable<int>(toBaseNum);
    map['to_base_den'] = Variable<int>(toBaseDen);
    map['is_scalable'] = Variable<bool>(isScalable);
    return map;
  }

  UnitsCatalogTableCompanion toCompanion(bool nullToAbsent) {
    return UnitsCatalogTableCompanion(
      id: Value(id),
      code: Value(code),
      dimension: Value(dimension),
      displayMetric: Value(displayMetric),
      displayUs: Value(displayUs),
      toBaseNum: Value(toBaseNum),
      toBaseDen: Value(toBaseDen),
      isScalable: Value(isScalable),
    );
  }

  factory UnitsCatalogTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnitsCatalogTableData(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      dimension: serializer.fromJson<String>(json['dimension']),
      displayMetric: serializer.fromJson<String>(json['displayMetric']),
      displayUs: serializer.fromJson<String>(json['displayUs']),
      toBaseNum: serializer.fromJson<int>(json['toBaseNum']),
      toBaseDen: serializer.fromJson<int>(json['toBaseDen']),
      isScalable: serializer.fromJson<bool>(json['isScalable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'dimension': serializer.toJson<String>(dimension),
      'displayMetric': serializer.toJson<String>(displayMetric),
      'displayUs': serializer.toJson<String>(displayUs),
      'toBaseNum': serializer.toJson<int>(toBaseNum),
      'toBaseDen': serializer.toJson<int>(toBaseDen),
      'isScalable': serializer.toJson<bool>(isScalable),
    };
  }

  UnitsCatalogTableData copyWith({
    String? id,
    String? code,
    String? dimension,
    String? displayMetric,
    String? displayUs,
    int? toBaseNum,
    int? toBaseDen,
    bool? isScalable,
  }) => UnitsCatalogTableData(
    id: id ?? this.id,
    code: code ?? this.code,
    dimension: dimension ?? this.dimension,
    displayMetric: displayMetric ?? this.displayMetric,
    displayUs: displayUs ?? this.displayUs,
    toBaseNum: toBaseNum ?? this.toBaseNum,
    toBaseDen: toBaseDen ?? this.toBaseDen,
    isScalable: isScalable ?? this.isScalable,
  );
  UnitsCatalogTableData copyWithCompanion(UnitsCatalogTableCompanion data) {
    return UnitsCatalogTableData(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      dimension: data.dimension.present ? data.dimension.value : this.dimension,
      displayMetric: data.displayMetric.present
          ? data.displayMetric.value
          : this.displayMetric,
      displayUs: data.displayUs.present ? data.displayUs.value : this.displayUs,
      toBaseNum: data.toBaseNum.present ? data.toBaseNum.value : this.toBaseNum,
      toBaseDen: data.toBaseDen.present ? data.toBaseDen.value : this.toBaseDen,
      isScalable: data.isScalable.present
          ? data.isScalable.value
          : this.isScalable,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnitsCatalogTableData(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('dimension: $dimension, ')
          ..write('displayMetric: $displayMetric, ')
          ..write('displayUs: $displayUs, ')
          ..write('toBaseNum: $toBaseNum, ')
          ..write('toBaseDen: $toBaseDen, ')
          ..write('isScalable: $isScalable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    dimension,
    displayMetric,
    displayUs,
    toBaseNum,
    toBaseDen,
    isScalable,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnitsCatalogTableData &&
          other.id == this.id &&
          other.code == this.code &&
          other.dimension == this.dimension &&
          other.displayMetric == this.displayMetric &&
          other.displayUs == this.displayUs &&
          other.toBaseNum == this.toBaseNum &&
          other.toBaseDen == this.toBaseDen &&
          other.isScalable == this.isScalable);
}

class UnitsCatalogTableCompanion
    extends UpdateCompanion<UnitsCatalogTableData> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> dimension;
  final Value<String> displayMetric;
  final Value<String> displayUs;
  final Value<int> toBaseNum;
  final Value<int> toBaseDen;
  final Value<bool> isScalable;
  final Value<int> rowid;
  const UnitsCatalogTableCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.dimension = const Value.absent(),
    this.displayMetric = const Value.absent(),
    this.displayUs = const Value.absent(),
    this.toBaseNum = const Value.absent(),
    this.toBaseDen = const Value.absent(),
    this.isScalable = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnitsCatalogTableCompanion.insert({
    required String id,
    required String code,
    required String dimension,
    required String displayMetric,
    required String displayUs,
    this.toBaseNum = const Value.absent(),
    this.toBaseDen = const Value.absent(),
    this.isScalable = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       dimension = Value(dimension),
       displayMetric = Value(displayMetric),
       displayUs = Value(displayUs);
  static Insertable<UnitsCatalogTableData> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? dimension,
    Expression<String>? displayMetric,
    Expression<String>? displayUs,
    Expression<int>? toBaseNum,
    Expression<int>? toBaseDen,
    Expression<bool>? isScalable,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (dimension != null) 'dimension': dimension,
      if (displayMetric != null) 'display_metric': displayMetric,
      if (displayUs != null) 'display_us': displayUs,
      if (toBaseNum != null) 'to_base_num': toBaseNum,
      if (toBaseDen != null) 'to_base_den': toBaseDen,
      if (isScalable != null) 'is_scalable': isScalable,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnitsCatalogTableCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? dimension,
    Value<String>? displayMetric,
    Value<String>? displayUs,
    Value<int>? toBaseNum,
    Value<int>? toBaseDen,
    Value<bool>? isScalable,
    Value<int>? rowid,
  }) {
    return UnitsCatalogTableCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      dimension: dimension ?? this.dimension,
      displayMetric: displayMetric ?? this.displayMetric,
      displayUs: displayUs ?? this.displayUs,
      toBaseNum: toBaseNum ?? this.toBaseNum,
      toBaseDen: toBaseDen ?? this.toBaseDen,
      isScalable: isScalable ?? this.isScalable,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (dimension.present) {
      map['dimension'] = Variable<String>(dimension.value);
    }
    if (displayMetric.present) {
      map['display_metric'] = Variable<String>(displayMetric.value);
    }
    if (displayUs.present) {
      map['display_us'] = Variable<String>(displayUs.value);
    }
    if (toBaseNum.present) {
      map['to_base_num'] = Variable<int>(toBaseNum.value);
    }
    if (toBaseDen.present) {
      map['to_base_den'] = Variable<int>(toBaseDen.value);
    }
    if (isScalable.present) {
      map['is_scalable'] = Variable<bool>(isScalable.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitsCatalogTableCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('dimension: $dimension, ')
          ..write('displayMetric: $displayMetric, ')
          ..write('displayUs: $displayUs, ')
          ..write('toBaseNum: $toBaseNum, ')
          ..write('toBaseDen: $toBaseDen, ')
          ..write('isScalable: $isScalable, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeIngredientsTableTable extends RecipeIngredientsTable
    with TableInfo<$RecipeIngredientsTableTable, RecipeIngredientsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeIngredientsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catalogIngredientIdMeta =
      const VerificationMeta('catalogIngredientId');
  @override
  late final GeneratedColumn<String> catalogIngredientId =
      GeneratedColumn<String>(
        'catalog_ingredient_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityNumMeta = const VerificationMeta(
    'quantityNum',
  );
  @override
  late final GeneratedColumn<int> quantityNum = GeneratedColumn<int>(
    'quantity_num',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityDenMeta = const VerificationMeta(
    'quantityDen',
  );
  @override
  late final GeneratedColumn<int> quantityDen = GeneratedColumn<int>(
    'quantity_den',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitCodeMeta = const VerificationMeta(
    'unitCode',
  );
  @override
  late final GeneratedColumn<String> unitCode = GeneratedColumn<String>(
    'unit_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authoredQuantityMeta = const VerificationMeta(
    'authoredQuantity',
  );
  @override
  late final GeneratedColumn<String> authoredQuantity = GeneratedColumn<String>(
    'authored_quantity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scalingPolicyMeta = const VerificationMeta(
    'scalingPolicy',
  );
  @override
  late final GeneratedColumn<String> scalingPolicy = GeneratedColumn<String>(
    'scaling_policy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('scale'),
  );
  static const VerificationMeta _prepTextMeta = const VerificationMeta(
    'prepText',
  );
  @override
  late final GeneratedColumn<String> prepText = GeneratedColumn<String>(
    'prep_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isOptionalMeta = const VerificationMeta(
    'isOptional',
  );
  @override
  late final GeneratedColumn<bool> isOptional = GeneratedColumn<bool>(
    'is_optional',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_optional" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupKeyMeta = const VerificationMeta(
    'groupKey',
  );
  @override
  late final GeneratedColumn<String> groupKey = GeneratedColumn<String>(
    'group_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allergenOverrideJsonMeta =
      const VerificationMeta('allergenOverrideJson');
  @override
  late final GeneratedColumn<String> allergenOverrideJson =
      GeneratedColumn<String>(
        'allergen_override_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _illustrationKeyMeta = const VerificationMeta(
    'illustrationKey',
  );
  @override
  late final GeneratedColumn<String> illustrationKey = GeneratedColumn<String>(
    'illustration_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    catalogIngredientId,
    displayName,
    quantityNum,
    quantityDen,
    unitCode,
    authoredQuantity,
    scalingPolicy,
    prepText,
    isOptional,
    position,
    groupKey,
    allergenOverrideJson,
    illustrationKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_ingredients_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeIngredientsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('catalog_ingredient_id')) {
      context.handle(
        _catalogIngredientIdMeta,
        catalogIngredientId.isAcceptableOrUnknown(
          data['catalog_ingredient_id']!,
          _catalogIngredientIdMeta,
        ),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('quantity_num')) {
      context.handle(
        _quantityNumMeta,
        quantityNum.isAcceptableOrUnknown(
          data['quantity_num']!,
          _quantityNumMeta,
        ),
      );
    }
    if (data.containsKey('quantity_den')) {
      context.handle(
        _quantityDenMeta,
        quantityDen.isAcceptableOrUnknown(
          data['quantity_den']!,
          _quantityDenMeta,
        ),
      );
    }
    if (data.containsKey('unit_code')) {
      context.handle(
        _unitCodeMeta,
        unitCode.isAcceptableOrUnknown(data['unit_code']!, _unitCodeMeta),
      );
    }
    if (data.containsKey('authored_quantity')) {
      context.handle(
        _authoredQuantityMeta,
        authoredQuantity.isAcceptableOrUnknown(
          data['authored_quantity']!,
          _authoredQuantityMeta,
        ),
      );
    }
    if (data.containsKey('scaling_policy')) {
      context.handle(
        _scalingPolicyMeta,
        scalingPolicy.isAcceptableOrUnknown(
          data['scaling_policy']!,
          _scalingPolicyMeta,
        ),
      );
    }
    if (data.containsKey('prep_text')) {
      context.handle(
        _prepTextMeta,
        prepText.isAcceptableOrUnknown(data['prep_text']!, _prepTextMeta),
      );
    }
    if (data.containsKey('is_optional')) {
      context.handle(
        _isOptionalMeta,
        isOptional.isAcceptableOrUnknown(data['is_optional']!, _isOptionalMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('group_key')) {
      context.handle(
        _groupKeyMeta,
        groupKey.isAcceptableOrUnknown(data['group_key']!, _groupKeyMeta),
      );
    }
    if (data.containsKey('allergen_override_json')) {
      context.handle(
        _allergenOverrideJsonMeta,
        allergenOverrideJson.isAcceptableOrUnknown(
          data['allergen_override_json']!,
          _allergenOverrideJsonMeta,
        ),
      );
    }
    if (data.containsKey('illustration_key')) {
      context.handle(
        _illustrationKeyMeta,
        illustrationKey.isAcceptableOrUnknown(
          data['illustration_key']!,
          _illustrationKeyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeIngredientsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeIngredientsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      catalogIngredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_ingredient_id'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      quantityNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_num'],
      ),
      quantityDen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_den'],
      ),
      unitCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_code'],
      ),
      authoredQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authored_quantity'],
      ),
      scalingPolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scaling_policy'],
      )!,
      prepText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prep_text'],
      ),
      isOptional: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_optional'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      groupKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_key'],
      ),
      allergenOverrideJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergen_override_json'],
      ),
      illustrationKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}illustration_key'],
      ),
    );
  }

  @override
  $RecipeIngredientsTableTable createAlias(String alias) {
    return $RecipeIngredientsTableTable(attachedDatabase, alias);
  }
}

class RecipeIngredientsTableData extends DataClass
    implements Insertable<RecipeIngredientsTableData> {
  final String id;
  final String recipeId;
  final String? catalogIngredientId;
  final String displayName;
  final int? quantityNum;
  final int? quantityDen;
  final String? unitCode;
  final String? authoredQuantity;
  final String scalingPolicy;
  final String? prepText;
  final bool isOptional;
  final int position;
  final String? groupKey;
  final String? allergenOverrideJson;
  final String? illustrationKey;
  const RecipeIngredientsTableData({
    required this.id,
    required this.recipeId,
    this.catalogIngredientId,
    required this.displayName,
    this.quantityNum,
    this.quantityDen,
    this.unitCode,
    this.authoredQuantity,
    required this.scalingPolicy,
    this.prepText,
    required this.isOptional,
    required this.position,
    this.groupKey,
    this.allergenOverrideJson,
    this.illustrationKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    if (!nullToAbsent || catalogIngredientId != null) {
      map['catalog_ingredient_id'] = Variable<String>(catalogIngredientId);
    }
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || quantityNum != null) {
      map['quantity_num'] = Variable<int>(quantityNum);
    }
    if (!nullToAbsent || quantityDen != null) {
      map['quantity_den'] = Variable<int>(quantityDen);
    }
    if (!nullToAbsent || unitCode != null) {
      map['unit_code'] = Variable<String>(unitCode);
    }
    if (!nullToAbsent || authoredQuantity != null) {
      map['authored_quantity'] = Variable<String>(authoredQuantity);
    }
    map['scaling_policy'] = Variable<String>(scalingPolicy);
    if (!nullToAbsent || prepText != null) {
      map['prep_text'] = Variable<String>(prepText);
    }
    map['is_optional'] = Variable<bool>(isOptional);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || groupKey != null) {
      map['group_key'] = Variable<String>(groupKey);
    }
    if (!nullToAbsent || allergenOverrideJson != null) {
      map['allergen_override_json'] = Variable<String>(allergenOverrideJson);
    }
    if (!nullToAbsent || illustrationKey != null) {
      map['illustration_key'] = Variable<String>(illustrationKey);
    }
    return map;
  }

  RecipeIngredientsTableCompanion toCompanion(bool nullToAbsent) {
    return RecipeIngredientsTableCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      catalogIngredientId: catalogIngredientId == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogIngredientId),
      displayName: Value(displayName),
      quantityNum: quantityNum == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityNum),
      quantityDen: quantityDen == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityDen),
      unitCode: unitCode == null && nullToAbsent
          ? const Value.absent()
          : Value(unitCode),
      authoredQuantity: authoredQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(authoredQuantity),
      scalingPolicy: Value(scalingPolicy),
      prepText: prepText == null && nullToAbsent
          ? const Value.absent()
          : Value(prepText),
      isOptional: Value(isOptional),
      position: Value(position),
      groupKey: groupKey == null && nullToAbsent
          ? const Value.absent()
          : Value(groupKey),
      allergenOverrideJson: allergenOverrideJson == null && nullToAbsent
          ? const Value.absent()
          : Value(allergenOverrideJson),
      illustrationKey: illustrationKey == null && nullToAbsent
          ? const Value.absent()
          : Value(illustrationKey),
    );
  }

  factory RecipeIngredientsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeIngredientsTableData(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      catalogIngredientId: serializer.fromJson<String?>(
        json['catalogIngredientId'],
      ),
      displayName: serializer.fromJson<String>(json['displayName']),
      quantityNum: serializer.fromJson<int?>(json['quantityNum']),
      quantityDen: serializer.fromJson<int?>(json['quantityDen']),
      unitCode: serializer.fromJson<String?>(json['unitCode']),
      authoredQuantity: serializer.fromJson<String?>(json['authoredQuantity']),
      scalingPolicy: serializer.fromJson<String>(json['scalingPolicy']),
      prepText: serializer.fromJson<String?>(json['prepText']),
      isOptional: serializer.fromJson<bool>(json['isOptional']),
      position: serializer.fromJson<int>(json['position']),
      groupKey: serializer.fromJson<String?>(json['groupKey']),
      allergenOverrideJson: serializer.fromJson<String?>(
        json['allergenOverrideJson'],
      ),
      illustrationKey: serializer.fromJson<String?>(json['illustrationKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'catalogIngredientId': serializer.toJson<String?>(catalogIngredientId),
      'displayName': serializer.toJson<String>(displayName),
      'quantityNum': serializer.toJson<int?>(quantityNum),
      'quantityDen': serializer.toJson<int?>(quantityDen),
      'unitCode': serializer.toJson<String?>(unitCode),
      'authoredQuantity': serializer.toJson<String?>(authoredQuantity),
      'scalingPolicy': serializer.toJson<String>(scalingPolicy),
      'prepText': serializer.toJson<String?>(prepText),
      'isOptional': serializer.toJson<bool>(isOptional),
      'position': serializer.toJson<int>(position),
      'groupKey': serializer.toJson<String?>(groupKey),
      'allergenOverrideJson': serializer.toJson<String?>(allergenOverrideJson),
      'illustrationKey': serializer.toJson<String?>(illustrationKey),
    };
  }

  RecipeIngredientsTableData copyWith({
    String? id,
    String? recipeId,
    Value<String?> catalogIngredientId = const Value.absent(),
    String? displayName,
    Value<int?> quantityNum = const Value.absent(),
    Value<int?> quantityDen = const Value.absent(),
    Value<String?> unitCode = const Value.absent(),
    Value<String?> authoredQuantity = const Value.absent(),
    String? scalingPolicy,
    Value<String?> prepText = const Value.absent(),
    bool? isOptional,
    int? position,
    Value<String?> groupKey = const Value.absent(),
    Value<String?> allergenOverrideJson = const Value.absent(),
    Value<String?> illustrationKey = const Value.absent(),
  }) => RecipeIngredientsTableData(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    catalogIngredientId: catalogIngredientId.present
        ? catalogIngredientId.value
        : this.catalogIngredientId,
    displayName: displayName ?? this.displayName,
    quantityNum: quantityNum.present ? quantityNum.value : this.quantityNum,
    quantityDen: quantityDen.present ? quantityDen.value : this.quantityDen,
    unitCode: unitCode.present ? unitCode.value : this.unitCode,
    authoredQuantity: authoredQuantity.present
        ? authoredQuantity.value
        : this.authoredQuantity,
    scalingPolicy: scalingPolicy ?? this.scalingPolicy,
    prepText: prepText.present ? prepText.value : this.prepText,
    isOptional: isOptional ?? this.isOptional,
    position: position ?? this.position,
    groupKey: groupKey.present ? groupKey.value : this.groupKey,
    allergenOverrideJson: allergenOverrideJson.present
        ? allergenOverrideJson.value
        : this.allergenOverrideJson,
    illustrationKey: illustrationKey.present
        ? illustrationKey.value
        : this.illustrationKey,
  );
  RecipeIngredientsTableData copyWithCompanion(
    RecipeIngredientsTableCompanion data,
  ) {
    return RecipeIngredientsTableData(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      catalogIngredientId: data.catalogIngredientId.present
          ? data.catalogIngredientId.value
          : this.catalogIngredientId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      quantityNum: data.quantityNum.present
          ? data.quantityNum.value
          : this.quantityNum,
      quantityDen: data.quantityDen.present
          ? data.quantityDen.value
          : this.quantityDen,
      unitCode: data.unitCode.present ? data.unitCode.value : this.unitCode,
      authoredQuantity: data.authoredQuantity.present
          ? data.authoredQuantity.value
          : this.authoredQuantity,
      scalingPolicy: data.scalingPolicy.present
          ? data.scalingPolicy.value
          : this.scalingPolicy,
      prepText: data.prepText.present ? data.prepText.value : this.prepText,
      isOptional: data.isOptional.present
          ? data.isOptional.value
          : this.isOptional,
      position: data.position.present ? data.position.value : this.position,
      groupKey: data.groupKey.present ? data.groupKey.value : this.groupKey,
      allergenOverrideJson: data.allergenOverrideJson.present
          ? data.allergenOverrideJson.value
          : this.allergenOverrideJson,
      illustrationKey: data.illustrationKey.present
          ? data.illustrationKey.value
          : this.illustrationKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsTableData(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('catalogIngredientId: $catalogIngredientId, ')
          ..write('displayName: $displayName, ')
          ..write('quantityNum: $quantityNum, ')
          ..write('quantityDen: $quantityDen, ')
          ..write('unitCode: $unitCode, ')
          ..write('authoredQuantity: $authoredQuantity, ')
          ..write('scalingPolicy: $scalingPolicy, ')
          ..write('prepText: $prepText, ')
          ..write('isOptional: $isOptional, ')
          ..write('position: $position, ')
          ..write('groupKey: $groupKey, ')
          ..write('allergenOverrideJson: $allergenOverrideJson, ')
          ..write('illustrationKey: $illustrationKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recipeId,
    catalogIngredientId,
    displayName,
    quantityNum,
    quantityDen,
    unitCode,
    authoredQuantity,
    scalingPolicy,
    prepText,
    isOptional,
    position,
    groupKey,
    allergenOverrideJson,
    illustrationKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeIngredientsTableData &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.catalogIngredientId == this.catalogIngredientId &&
          other.displayName == this.displayName &&
          other.quantityNum == this.quantityNum &&
          other.quantityDen == this.quantityDen &&
          other.unitCode == this.unitCode &&
          other.authoredQuantity == this.authoredQuantity &&
          other.scalingPolicy == this.scalingPolicy &&
          other.prepText == this.prepText &&
          other.isOptional == this.isOptional &&
          other.position == this.position &&
          other.groupKey == this.groupKey &&
          other.allergenOverrideJson == this.allergenOverrideJson &&
          other.illustrationKey == this.illustrationKey);
}

class RecipeIngredientsTableCompanion
    extends UpdateCompanion<RecipeIngredientsTableData> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<String?> catalogIngredientId;
  final Value<String> displayName;
  final Value<int?> quantityNum;
  final Value<int?> quantityDen;
  final Value<String?> unitCode;
  final Value<String?> authoredQuantity;
  final Value<String> scalingPolicy;
  final Value<String?> prepText;
  final Value<bool> isOptional;
  final Value<int> position;
  final Value<String?> groupKey;
  final Value<String?> allergenOverrideJson;
  final Value<String?> illustrationKey;
  final Value<int> rowid;
  const RecipeIngredientsTableCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.catalogIngredientId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.quantityNum = const Value.absent(),
    this.quantityDen = const Value.absent(),
    this.unitCode = const Value.absent(),
    this.authoredQuantity = const Value.absent(),
    this.scalingPolicy = const Value.absent(),
    this.prepText = const Value.absent(),
    this.isOptional = const Value.absent(),
    this.position = const Value.absent(),
    this.groupKey = const Value.absent(),
    this.allergenOverrideJson = const Value.absent(),
    this.illustrationKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeIngredientsTableCompanion.insert({
    required String id,
    required String recipeId,
    this.catalogIngredientId = const Value.absent(),
    required String displayName,
    this.quantityNum = const Value.absent(),
    this.quantityDen = const Value.absent(),
    this.unitCode = const Value.absent(),
    this.authoredQuantity = const Value.absent(),
    this.scalingPolicy = const Value.absent(),
    this.prepText = const Value.absent(),
    this.isOptional = const Value.absent(),
    required int position,
    this.groupKey = const Value.absent(),
    this.allergenOverrideJson = const Value.absent(),
    this.illustrationKey = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recipeId = Value(recipeId),
       displayName = Value(displayName),
       position = Value(position);
  static Insertable<RecipeIngredientsTableData> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<String>? catalogIngredientId,
    Expression<String>? displayName,
    Expression<int>? quantityNum,
    Expression<int>? quantityDen,
    Expression<String>? unitCode,
    Expression<String>? authoredQuantity,
    Expression<String>? scalingPolicy,
    Expression<String>? prepText,
    Expression<bool>? isOptional,
    Expression<int>? position,
    Expression<String>? groupKey,
    Expression<String>? allergenOverrideJson,
    Expression<String>? illustrationKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (catalogIngredientId != null)
        'catalog_ingredient_id': catalogIngredientId,
      if (displayName != null) 'display_name': displayName,
      if (quantityNum != null) 'quantity_num': quantityNum,
      if (quantityDen != null) 'quantity_den': quantityDen,
      if (unitCode != null) 'unit_code': unitCode,
      if (authoredQuantity != null) 'authored_quantity': authoredQuantity,
      if (scalingPolicy != null) 'scaling_policy': scalingPolicy,
      if (prepText != null) 'prep_text': prepText,
      if (isOptional != null) 'is_optional': isOptional,
      if (position != null) 'position': position,
      if (groupKey != null) 'group_key': groupKey,
      if (allergenOverrideJson != null)
        'allergen_override_json': allergenOverrideJson,
      if (illustrationKey != null) 'illustration_key': illustrationKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeIngredientsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? recipeId,
    Value<String?>? catalogIngredientId,
    Value<String>? displayName,
    Value<int?>? quantityNum,
    Value<int?>? quantityDen,
    Value<String?>? unitCode,
    Value<String?>? authoredQuantity,
    Value<String>? scalingPolicy,
    Value<String?>? prepText,
    Value<bool>? isOptional,
    Value<int>? position,
    Value<String?>? groupKey,
    Value<String?>? allergenOverrideJson,
    Value<String?>? illustrationKey,
    Value<int>? rowid,
  }) {
    return RecipeIngredientsTableCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      catalogIngredientId: catalogIngredientId ?? this.catalogIngredientId,
      displayName: displayName ?? this.displayName,
      quantityNum: quantityNum ?? this.quantityNum,
      quantityDen: quantityDen ?? this.quantityDen,
      unitCode: unitCode ?? this.unitCode,
      authoredQuantity: authoredQuantity ?? this.authoredQuantity,
      scalingPolicy: scalingPolicy ?? this.scalingPolicy,
      prepText: prepText ?? this.prepText,
      isOptional: isOptional ?? this.isOptional,
      position: position ?? this.position,
      groupKey: groupKey ?? this.groupKey,
      allergenOverrideJson: allergenOverrideJson ?? this.allergenOverrideJson,
      illustrationKey: illustrationKey ?? this.illustrationKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (catalogIngredientId.present) {
      map['catalog_ingredient_id'] = Variable<String>(
        catalogIngredientId.value,
      );
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (quantityNum.present) {
      map['quantity_num'] = Variable<int>(quantityNum.value);
    }
    if (quantityDen.present) {
      map['quantity_den'] = Variable<int>(quantityDen.value);
    }
    if (unitCode.present) {
      map['unit_code'] = Variable<String>(unitCode.value);
    }
    if (authoredQuantity.present) {
      map['authored_quantity'] = Variable<String>(authoredQuantity.value);
    }
    if (scalingPolicy.present) {
      map['scaling_policy'] = Variable<String>(scalingPolicy.value);
    }
    if (prepText.present) {
      map['prep_text'] = Variable<String>(prepText.value);
    }
    if (isOptional.present) {
      map['is_optional'] = Variable<bool>(isOptional.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (groupKey.present) {
      map['group_key'] = Variable<String>(groupKey.value);
    }
    if (allergenOverrideJson.present) {
      map['allergen_override_json'] = Variable<String>(
        allergenOverrideJson.value,
      );
    }
    if (illustrationKey.present) {
      map['illustration_key'] = Variable<String>(illustrationKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsTableCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('catalogIngredientId: $catalogIngredientId, ')
          ..write('displayName: $displayName, ')
          ..write('quantityNum: $quantityNum, ')
          ..write('quantityDen: $quantityDen, ')
          ..write('unitCode: $unitCode, ')
          ..write('authoredQuantity: $authoredQuantity, ')
          ..write('scalingPolicy: $scalingPolicy, ')
          ..write('prepText: $prepText, ')
          ..write('isOptional: $isOptional, ')
          ..write('position: $position, ')
          ..write('groupKey: $groupKey, ')
          ..write('allergenOverrideJson: $allergenOverrideJson, ')
          ..write('illustrationKey: $illustrationKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeStepsTableTable extends RecipeStepsTable
    with TableInfo<$RecipeStepsTableTable, RecipeStepsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeStepsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instructionShortMeta = const VerificationMeta(
    'instructionShort',
  );
  @override
  late final GeneratedColumn<String> instructionShort = GeneratedColumn<String>(
    'instruction_short',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instructionDetailMeta = const VerificationMeta(
    'instructionDetail',
  );
  @override
  late final GeneratedColumn<String> instructionDetail =
      GeneratedColumn<String>(
        'instruction_detail',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _spokenInstructionMeta = const VerificationMeta(
    'spokenInstruction',
  );
  @override
  late final GeneratedColumn<String> spokenInstruction =
      GeneratedColumn<String>(
        'spoken_instruction',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _actionKeyMeta = const VerificationMeta(
    'actionKey',
  );
  @override
  late final GeneratedColumn<String> actionKey = GeneratedColumn<String>(
    'action_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureCMeta = const VerificationMeta(
    'temperatureC',
  );
  @override
  late final GeneratedColumn<int> temperatureC = GeneratedColumn<int>(
    'temperature_c',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureFMeta = const VerificationMeta(
    'temperatureF',
  );
  @override
  late final GeneratedColumn<int> temperatureF = GeneratedColumn<int>(
    'temperature_f',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _layoutHintMeta = const VerificationMeta(
    'layoutHint',
  );
  @override
  late final GeneratedColumn<String> layoutHint = GeneratedColumn<String>(
    'layout_hint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _safetyJsonMeta = const VerificationMeta(
    'safetyJson',
  );
  @override
  late final GeneratedColumn<String> safetyJson = GeneratedColumn<String>(
    'safety_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    position,
    instructionShort,
    instructionDetail,
    spokenInstruction,
    actionKey,
    durationSeconds,
    temperatureC,
    temperatureF,
    layoutHint,
    safetyJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_steps_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeStepsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('instruction_short')) {
      context.handle(
        _instructionShortMeta,
        instructionShort.isAcceptableOrUnknown(
          data['instruction_short']!,
          _instructionShortMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instructionShortMeta);
    }
    if (data.containsKey('instruction_detail')) {
      context.handle(
        _instructionDetailMeta,
        instructionDetail.isAcceptableOrUnknown(
          data['instruction_detail']!,
          _instructionDetailMeta,
        ),
      );
    }
    if (data.containsKey('spoken_instruction')) {
      context.handle(
        _spokenInstructionMeta,
        spokenInstruction.isAcceptableOrUnknown(
          data['spoken_instruction']!,
          _spokenInstructionMeta,
        ),
      );
    }
    if (data.containsKey('action_key')) {
      context.handle(
        _actionKeyMeta,
        actionKey.isAcceptableOrUnknown(data['action_key']!, _actionKeyMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('temperature_c')) {
      context.handle(
        _temperatureCMeta,
        temperatureC.isAcceptableOrUnknown(
          data['temperature_c']!,
          _temperatureCMeta,
        ),
      );
    }
    if (data.containsKey('temperature_f')) {
      context.handle(
        _temperatureFMeta,
        temperatureF.isAcceptableOrUnknown(
          data['temperature_f']!,
          _temperatureFMeta,
        ),
      );
    }
    if (data.containsKey('layout_hint')) {
      context.handle(
        _layoutHintMeta,
        layoutHint.isAcceptableOrUnknown(data['layout_hint']!, _layoutHintMeta),
      );
    }
    if (data.containsKey('safety_json')) {
      context.handle(
        _safetyJsonMeta,
        safetyJson.isAcceptableOrUnknown(data['safety_json']!, _safetyJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeStepsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeStepsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      instructionShort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instruction_short'],
      )!,
      instructionDetail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instruction_detail'],
      ),
      spokenInstruction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spoken_instruction'],
      ),
      actionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_key'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      temperatureC: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temperature_c'],
      ),
      temperatureF: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temperature_f'],
      ),
      layoutHint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}layout_hint'],
      ),
      safetyJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}safety_json'],
      ),
    );
  }

  @override
  $RecipeStepsTableTable createAlias(String alias) {
    return $RecipeStepsTableTable(attachedDatabase, alias);
  }
}

class RecipeStepsTableData extends DataClass
    implements Insertable<RecipeStepsTableData> {
  final String id;
  final String recipeId;
  final int position;
  final String instructionShort;
  final String? instructionDetail;
  final String? spokenInstruction;
  final String? actionKey;
  final int? durationSeconds;
  final int? temperatureC;
  final int? temperatureF;
  final String? layoutHint;
  final String? safetyJson;
  const RecipeStepsTableData({
    required this.id,
    required this.recipeId,
    required this.position,
    required this.instructionShort,
    this.instructionDetail,
    this.spokenInstruction,
    this.actionKey,
    this.durationSeconds,
    this.temperatureC,
    this.temperatureF,
    this.layoutHint,
    this.safetyJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['position'] = Variable<int>(position);
    map['instruction_short'] = Variable<String>(instructionShort);
    if (!nullToAbsent || instructionDetail != null) {
      map['instruction_detail'] = Variable<String>(instructionDetail);
    }
    if (!nullToAbsent || spokenInstruction != null) {
      map['spoken_instruction'] = Variable<String>(spokenInstruction);
    }
    if (!nullToAbsent || actionKey != null) {
      map['action_key'] = Variable<String>(actionKey);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || temperatureC != null) {
      map['temperature_c'] = Variable<int>(temperatureC);
    }
    if (!nullToAbsent || temperatureF != null) {
      map['temperature_f'] = Variable<int>(temperatureF);
    }
    if (!nullToAbsent || layoutHint != null) {
      map['layout_hint'] = Variable<String>(layoutHint);
    }
    if (!nullToAbsent || safetyJson != null) {
      map['safety_json'] = Variable<String>(safetyJson);
    }
    return map;
  }

  RecipeStepsTableCompanion toCompanion(bool nullToAbsent) {
    return RecipeStepsTableCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      position: Value(position),
      instructionShort: Value(instructionShort),
      instructionDetail: instructionDetail == null && nullToAbsent
          ? const Value.absent()
          : Value(instructionDetail),
      spokenInstruction: spokenInstruction == null && nullToAbsent
          ? const Value.absent()
          : Value(spokenInstruction),
      actionKey: actionKey == null && nullToAbsent
          ? const Value.absent()
          : Value(actionKey),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      temperatureC: temperatureC == null && nullToAbsent
          ? const Value.absent()
          : Value(temperatureC),
      temperatureF: temperatureF == null && nullToAbsent
          ? const Value.absent()
          : Value(temperatureF),
      layoutHint: layoutHint == null && nullToAbsent
          ? const Value.absent()
          : Value(layoutHint),
      safetyJson: safetyJson == null && nullToAbsent
          ? const Value.absent()
          : Value(safetyJson),
    );
  }

  factory RecipeStepsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeStepsTableData(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      position: serializer.fromJson<int>(json['position']),
      instructionShort: serializer.fromJson<String>(json['instructionShort']),
      instructionDetail: serializer.fromJson<String?>(
        json['instructionDetail'],
      ),
      spokenInstruction: serializer.fromJson<String?>(
        json['spokenInstruction'],
      ),
      actionKey: serializer.fromJson<String?>(json['actionKey']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      temperatureC: serializer.fromJson<int?>(json['temperatureC']),
      temperatureF: serializer.fromJson<int?>(json['temperatureF']),
      layoutHint: serializer.fromJson<String?>(json['layoutHint']),
      safetyJson: serializer.fromJson<String?>(json['safetyJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'position': serializer.toJson<int>(position),
      'instructionShort': serializer.toJson<String>(instructionShort),
      'instructionDetail': serializer.toJson<String?>(instructionDetail),
      'spokenInstruction': serializer.toJson<String?>(spokenInstruction),
      'actionKey': serializer.toJson<String?>(actionKey),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'temperatureC': serializer.toJson<int?>(temperatureC),
      'temperatureF': serializer.toJson<int?>(temperatureF),
      'layoutHint': serializer.toJson<String?>(layoutHint),
      'safetyJson': serializer.toJson<String?>(safetyJson),
    };
  }

  RecipeStepsTableData copyWith({
    String? id,
    String? recipeId,
    int? position,
    String? instructionShort,
    Value<String?> instructionDetail = const Value.absent(),
    Value<String?> spokenInstruction = const Value.absent(),
    Value<String?> actionKey = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    Value<int?> temperatureC = const Value.absent(),
    Value<int?> temperatureF = const Value.absent(),
    Value<String?> layoutHint = const Value.absent(),
    Value<String?> safetyJson = const Value.absent(),
  }) => RecipeStepsTableData(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    position: position ?? this.position,
    instructionShort: instructionShort ?? this.instructionShort,
    instructionDetail: instructionDetail.present
        ? instructionDetail.value
        : this.instructionDetail,
    spokenInstruction: spokenInstruction.present
        ? spokenInstruction.value
        : this.spokenInstruction,
    actionKey: actionKey.present ? actionKey.value : this.actionKey,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    temperatureC: temperatureC.present ? temperatureC.value : this.temperatureC,
    temperatureF: temperatureF.present ? temperatureF.value : this.temperatureF,
    layoutHint: layoutHint.present ? layoutHint.value : this.layoutHint,
    safetyJson: safetyJson.present ? safetyJson.value : this.safetyJson,
  );
  RecipeStepsTableData copyWithCompanion(RecipeStepsTableCompanion data) {
    return RecipeStepsTableData(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      position: data.position.present ? data.position.value : this.position,
      instructionShort: data.instructionShort.present
          ? data.instructionShort.value
          : this.instructionShort,
      instructionDetail: data.instructionDetail.present
          ? data.instructionDetail.value
          : this.instructionDetail,
      spokenInstruction: data.spokenInstruction.present
          ? data.spokenInstruction.value
          : this.spokenInstruction,
      actionKey: data.actionKey.present ? data.actionKey.value : this.actionKey,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      temperatureC: data.temperatureC.present
          ? data.temperatureC.value
          : this.temperatureC,
      temperatureF: data.temperatureF.present
          ? data.temperatureF.value
          : this.temperatureF,
      layoutHint: data.layoutHint.present
          ? data.layoutHint.value
          : this.layoutHint,
      safetyJson: data.safetyJson.present
          ? data.safetyJson.value
          : this.safetyJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeStepsTableData(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('instructionShort: $instructionShort, ')
          ..write('instructionDetail: $instructionDetail, ')
          ..write('spokenInstruction: $spokenInstruction, ')
          ..write('actionKey: $actionKey, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('temperatureC: $temperatureC, ')
          ..write('temperatureF: $temperatureF, ')
          ..write('layoutHint: $layoutHint, ')
          ..write('safetyJson: $safetyJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recipeId,
    position,
    instructionShort,
    instructionDetail,
    spokenInstruction,
    actionKey,
    durationSeconds,
    temperatureC,
    temperatureF,
    layoutHint,
    safetyJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeStepsTableData &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.position == this.position &&
          other.instructionShort == this.instructionShort &&
          other.instructionDetail == this.instructionDetail &&
          other.spokenInstruction == this.spokenInstruction &&
          other.actionKey == this.actionKey &&
          other.durationSeconds == this.durationSeconds &&
          other.temperatureC == this.temperatureC &&
          other.temperatureF == this.temperatureF &&
          other.layoutHint == this.layoutHint &&
          other.safetyJson == this.safetyJson);
}

class RecipeStepsTableCompanion extends UpdateCompanion<RecipeStepsTableData> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<int> position;
  final Value<String> instructionShort;
  final Value<String?> instructionDetail;
  final Value<String?> spokenInstruction;
  final Value<String?> actionKey;
  final Value<int?> durationSeconds;
  final Value<int?> temperatureC;
  final Value<int?> temperatureF;
  final Value<String?> layoutHint;
  final Value<String?> safetyJson;
  final Value<int> rowid;
  const RecipeStepsTableCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.position = const Value.absent(),
    this.instructionShort = const Value.absent(),
    this.instructionDetail = const Value.absent(),
    this.spokenInstruction = const Value.absent(),
    this.actionKey = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.temperatureC = const Value.absent(),
    this.temperatureF = const Value.absent(),
    this.layoutHint = const Value.absent(),
    this.safetyJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeStepsTableCompanion.insert({
    required String id,
    required String recipeId,
    required int position,
    required String instructionShort,
    this.instructionDetail = const Value.absent(),
    this.spokenInstruction = const Value.absent(),
    this.actionKey = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.temperatureC = const Value.absent(),
    this.temperatureF = const Value.absent(),
    this.layoutHint = const Value.absent(),
    this.safetyJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recipeId = Value(recipeId),
       position = Value(position),
       instructionShort = Value(instructionShort);
  static Insertable<RecipeStepsTableData> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<int>? position,
    Expression<String>? instructionShort,
    Expression<String>? instructionDetail,
    Expression<String>? spokenInstruction,
    Expression<String>? actionKey,
    Expression<int>? durationSeconds,
    Expression<int>? temperatureC,
    Expression<int>? temperatureF,
    Expression<String>? layoutHint,
    Expression<String>? safetyJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (position != null) 'position': position,
      if (instructionShort != null) 'instruction_short': instructionShort,
      if (instructionDetail != null) 'instruction_detail': instructionDetail,
      if (spokenInstruction != null) 'spoken_instruction': spokenInstruction,
      if (actionKey != null) 'action_key': actionKey,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (temperatureC != null) 'temperature_c': temperatureC,
      if (temperatureF != null) 'temperature_f': temperatureF,
      if (layoutHint != null) 'layout_hint': layoutHint,
      if (safetyJson != null) 'safety_json': safetyJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeStepsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? recipeId,
    Value<int>? position,
    Value<String>? instructionShort,
    Value<String?>? instructionDetail,
    Value<String?>? spokenInstruction,
    Value<String?>? actionKey,
    Value<int?>? durationSeconds,
    Value<int?>? temperatureC,
    Value<int?>? temperatureF,
    Value<String?>? layoutHint,
    Value<String?>? safetyJson,
    Value<int>? rowid,
  }) {
    return RecipeStepsTableCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      position: position ?? this.position,
      instructionShort: instructionShort ?? this.instructionShort,
      instructionDetail: instructionDetail ?? this.instructionDetail,
      spokenInstruction: spokenInstruction ?? this.spokenInstruction,
      actionKey: actionKey ?? this.actionKey,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      temperatureC: temperatureC ?? this.temperatureC,
      temperatureF: temperatureF ?? this.temperatureF,
      layoutHint: layoutHint ?? this.layoutHint,
      safetyJson: safetyJson ?? this.safetyJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (instructionShort.present) {
      map['instruction_short'] = Variable<String>(instructionShort.value);
    }
    if (instructionDetail.present) {
      map['instruction_detail'] = Variable<String>(instructionDetail.value);
    }
    if (spokenInstruction.present) {
      map['spoken_instruction'] = Variable<String>(spokenInstruction.value);
    }
    if (actionKey.present) {
      map['action_key'] = Variable<String>(actionKey.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (temperatureC.present) {
      map['temperature_c'] = Variable<int>(temperatureC.value);
    }
    if (temperatureF.present) {
      map['temperature_f'] = Variable<int>(temperatureF.value);
    }
    if (layoutHint.present) {
      map['layout_hint'] = Variable<String>(layoutHint.value);
    }
    if (safetyJson.present) {
      map['safety_json'] = Variable<String>(safetyJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeStepsTableCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('instructionShort: $instructionShort, ')
          ..write('instructionDetail: $instructionDetail, ')
          ..write('spokenInstruction: $spokenInstruction, ')
          ..write('actionKey: $actionKey, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('temperatureC: $temperatureC, ')
          ..write('temperatureF: $temperatureF, ')
          ..write('layoutHint: $layoutHint, ')
          ..write('safetyJson: $safetyJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StepTimersTableTable extends StepTimersTable
    with TableInfo<$StepTimersTableTable, StepTimersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StepTimersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeStepIdMeta = const VerificationMeta(
    'recipeStepId',
  );
  @override
  late final GeneratedColumn<String> recipeStepId = GeneratedColumn<String>(
    'recipe_step_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _autoStartMeta = const VerificationMeta(
    'autoStart',
  );
  @override
  late final GeneratedColumn<bool> autoStart = GeneratedColumn<bool>(
    'auto_start',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_start" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeStepId,
    label,
    durationSeconds,
    autoStart,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'step_timers_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<StepTimersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_step_id')) {
      context.handle(
        _recipeStepIdMeta,
        recipeStepId.isAcceptableOrUnknown(
          data['recipe_step_id']!,
          _recipeStepIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recipeStepIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('auto_start')) {
      context.handle(
        _autoStartMeta,
        autoStart.isAcceptableOrUnknown(data['auto_start']!, _autoStartMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StepTimersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StepTimersTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeStepId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_step_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      autoStart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_start'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $StepTimersTableTable createAlias(String alias) {
    return $StepTimersTableTable(attachedDatabase, alias);
  }
}

class StepTimersTableData extends DataClass
    implements Insertable<StepTimersTableData> {
  final String id;
  final String recipeStepId;
  final String label;
  final int durationSeconds;
  final bool autoStart;
  final int position;
  const StepTimersTableData({
    required this.id,
    required this.recipeStepId,
    required this.label,
    required this.durationSeconds,
    required this.autoStart,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_step_id'] = Variable<String>(recipeStepId);
    map['label'] = Variable<String>(label);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['auto_start'] = Variable<bool>(autoStart);
    map['position'] = Variable<int>(position);
    return map;
  }

  StepTimersTableCompanion toCompanion(bool nullToAbsent) {
    return StepTimersTableCompanion(
      id: Value(id),
      recipeStepId: Value(recipeStepId),
      label: Value(label),
      durationSeconds: Value(durationSeconds),
      autoStart: Value(autoStart),
      position: Value(position),
    );
  }

  factory StepTimersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StepTimersTableData(
      id: serializer.fromJson<String>(json['id']),
      recipeStepId: serializer.fromJson<String>(json['recipeStepId']),
      label: serializer.fromJson<String>(json['label']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      autoStart: serializer.fromJson<bool>(json['autoStart']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeStepId': serializer.toJson<String>(recipeStepId),
      'label': serializer.toJson<String>(label),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'autoStart': serializer.toJson<bool>(autoStart),
      'position': serializer.toJson<int>(position),
    };
  }

  StepTimersTableData copyWith({
    String? id,
    String? recipeStepId,
    String? label,
    int? durationSeconds,
    bool? autoStart,
    int? position,
  }) => StepTimersTableData(
    id: id ?? this.id,
    recipeStepId: recipeStepId ?? this.recipeStepId,
    label: label ?? this.label,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    autoStart: autoStart ?? this.autoStart,
    position: position ?? this.position,
  );
  StepTimersTableData copyWithCompanion(StepTimersTableCompanion data) {
    return StepTimersTableData(
      id: data.id.present ? data.id.value : this.id,
      recipeStepId: data.recipeStepId.present
          ? data.recipeStepId.value
          : this.recipeStepId,
      label: data.label.present ? data.label.value : this.label,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      autoStart: data.autoStart.present ? data.autoStart.value : this.autoStart,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StepTimersTableData(')
          ..write('id: $id, ')
          ..write('recipeStepId: $recipeStepId, ')
          ..write('label: $label, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('autoStart: $autoStart, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recipeStepId,
    label,
    durationSeconds,
    autoStart,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StepTimersTableData &&
          other.id == this.id &&
          other.recipeStepId == this.recipeStepId &&
          other.label == this.label &&
          other.durationSeconds == this.durationSeconds &&
          other.autoStart == this.autoStart &&
          other.position == this.position);
}

class StepTimersTableCompanion extends UpdateCompanion<StepTimersTableData> {
  final Value<String> id;
  final Value<String> recipeStepId;
  final Value<String> label;
  final Value<int> durationSeconds;
  final Value<bool> autoStart;
  final Value<int> position;
  final Value<int> rowid;
  const StepTimersTableCompanion({
    this.id = const Value.absent(),
    this.recipeStepId = const Value.absent(),
    this.label = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.autoStart = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StepTimersTableCompanion.insert({
    required String id,
    required String recipeStepId,
    required String label,
    required int durationSeconds,
    this.autoStart = const Value.absent(),
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recipeStepId = Value(recipeStepId),
       label = Value(label),
       durationSeconds = Value(durationSeconds),
       position = Value(position);
  static Insertable<StepTimersTableData> custom({
    Expression<String>? id,
    Expression<String>? recipeStepId,
    Expression<String>? label,
    Expression<int>? durationSeconds,
    Expression<bool>? autoStart,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeStepId != null) 'recipe_step_id': recipeStepId,
      if (label != null) 'label': label,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (autoStart != null) 'auto_start': autoStart,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StepTimersTableCompanion copyWith({
    Value<String>? id,
    Value<String>? recipeStepId,
    Value<String>? label,
    Value<int>? durationSeconds,
    Value<bool>? autoStart,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return StepTimersTableCompanion(
      id: id ?? this.id,
      recipeStepId: recipeStepId ?? this.recipeStepId,
      label: label ?? this.label,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      autoStart: autoStart ?? this.autoStart,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeStepId.present) {
      map['recipe_step_id'] = Variable<String>(recipeStepId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (autoStart.present) {
      map['auto_start'] = Variable<bool>(autoStart.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StepTimersTableCompanion(')
          ..write('id: $id, ')
          ..write('recipeStepId: $recipeStepId, ')
          ..write('label: $label, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('autoStart: $autoStart, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ToolsCatalogTableTable extends ToolsCatalogTable
    with TableInfo<$ToolsCatalogTableTable, ToolsCatalogTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ToolsCatalogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalNameMeta = const VerificationMeta(
    'canonicalName',
  );
  @override
  late final GeneratedColumn<String> canonicalName = GeneratedColumn<String>(
    'canonical_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synonymsJsonMeta = const VerificationMeta(
    'synonymsJson',
  );
  @override
  late final GeneratedColumn<String> synonymsJson = GeneratedColumn<String>(
    'synonyms_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _illustrationKeyMeta = const VerificationMeta(
    'illustrationKey',
  );
  @override
  late final GeneratedColumn<String> illustrationKey = GeneratedColumn<String>(
    'illustration_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    canonicalName,
    category,
    synonymsJson,
    illustrationKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tools_catalog_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ToolsCatalogTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('canonical_name')) {
      context.handle(
        _canonicalNameMeta,
        canonicalName.isAcceptableOrUnknown(
          data['canonical_name']!,
          _canonicalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalNameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('synonyms_json')) {
      context.handle(
        _synonymsJsonMeta,
        synonymsJson.isAcceptableOrUnknown(
          data['synonyms_json']!,
          _synonymsJsonMeta,
        ),
      );
    }
    if (data.containsKey('illustration_key')) {
      context.handle(
        _illustrationKeyMeta,
        illustrationKey.isAcceptableOrUnknown(
          data['illustration_key']!,
          _illustrationKeyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ToolsCatalogTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ToolsCatalogTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      canonicalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      synonymsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synonyms_json'],
      )!,
      illustrationKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}illustration_key'],
      ),
    );
  }

  @override
  $ToolsCatalogTableTable createAlias(String alias) {
    return $ToolsCatalogTableTable(attachedDatabase, alias);
  }
}

class ToolsCatalogTableData extends DataClass
    implements Insertable<ToolsCatalogTableData> {
  final String id;
  final String canonicalName;
  final String? category;
  final String synonymsJson;
  final String? illustrationKey;
  const ToolsCatalogTableData({
    required this.id,
    required this.canonicalName,
    this.category,
    required this.synonymsJson,
    this.illustrationKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['canonical_name'] = Variable<String>(canonicalName);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['synonyms_json'] = Variable<String>(synonymsJson);
    if (!nullToAbsent || illustrationKey != null) {
      map['illustration_key'] = Variable<String>(illustrationKey);
    }
    return map;
  }

  ToolsCatalogTableCompanion toCompanion(bool nullToAbsent) {
    return ToolsCatalogTableCompanion(
      id: Value(id),
      canonicalName: Value(canonicalName),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      synonymsJson: Value(synonymsJson),
      illustrationKey: illustrationKey == null && nullToAbsent
          ? const Value.absent()
          : Value(illustrationKey),
    );
  }

  factory ToolsCatalogTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ToolsCatalogTableData(
      id: serializer.fromJson<String>(json['id']),
      canonicalName: serializer.fromJson<String>(json['canonicalName']),
      category: serializer.fromJson<String?>(json['category']),
      synonymsJson: serializer.fromJson<String>(json['synonymsJson']),
      illustrationKey: serializer.fromJson<String?>(json['illustrationKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'canonicalName': serializer.toJson<String>(canonicalName),
      'category': serializer.toJson<String?>(category),
      'synonymsJson': serializer.toJson<String>(synonymsJson),
      'illustrationKey': serializer.toJson<String?>(illustrationKey),
    };
  }

  ToolsCatalogTableData copyWith({
    String? id,
    String? canonicalName,
    Value<String?> category = const Value.absent(),
    String? synonymsJson,
    Value<String?> illustrationKey = const Value.absent(),
  }) => ToolsCatalogTableData(
    id: id ?? this.id,
    canonicalName: canonicalName ?? this.canonicalName,
    category: category.present ? category.value : this.category,
    synonymsJson: synonymsJson ?? this.synonymsJson,
    illustrationKey: illustrationKey.present
        ? illustrationKey.value
        : this.illustrationKey,
  );
  ToolsCatalogTableData copyWithCompanion(ToolsCatalogTableCompanion data) {
    return ToolsCatalogTableData(
      id: data.id.present ? data.id.value : this.id,
      canonicalName: data.canonicalName.present
          ? data.canonicalName.value
          : this.canonicalName,
      category: data.category.present ? data.category.value : this.category,
      synonymsJson: data.synonymsJson.present
          ? data.synonymsJson.value
          : this.synonymsJson,
      illustrationKey: data.illustrationKey.present
          ? data.illustrationKey.value
          : this.illustrationKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ToolsCatalogTableData(')
          ..write('id: $id, ')
          ..write('canonicalName: $canonicalName, ')
          ..write('category: $category, ')
          ..write('synonymsJson: $synonymsJson, ')
          ..write('illustrationKey: $illustrationKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, canonicalName, category, synonymsJson, illustrationKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ToolsCatalogTableData &&
          other.id == this.id &&
          other.canonicalName == this.canonicalName &&
          other.category == this.category &&
          other.synonymsJson == this.synonymsJson &&
          other.illustrationKey == this.illustrationKey);
}

class ToolsCatalogTableCompanion
    extends UpdateCompanion<ToolsCatalogTableData> {
  final Value<String> id;
  final Value<String> canonicalName;
  final Value<String?> category;
  final Value<String> synonymsJson;
  final Value<String?> illustrationKey;
  final Value<int> rowid;
  const ToolsCatalogTableCompanion({
    this.id = const Value.absent(),
    this.canonicalName = const Value.absent(),
    this.category = const Value.absent(),
    this.synonymsJson = const Value.absent(),
    this.illustrationKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ToolsCatalogTableCompanion.insert({
    required String id,
    required String canonicalName,
    this.category = const Value.absent(),
    this.synonymsJson = const Value.absent(),
    this.illustrationKey = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       canonicalName = Value(canonicalName);
  static Insertable<ToolsCatalogTableData> custom({
    Expression<String>? id,
    Expression<String>? canonicalName,
    Expression<String>? category,
    Expression<String>? synonymsJson,
    Expression<String>? illustrationKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (canonicalName != null) 'canonical_name': canonicalName,
      if (category != null) 'category': category,
      if (synonymsJson != null) 'synonyms_json': synonymsJson,
      if (illustrationKey != null) 'illustration_key': illustrationKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ToolsCatalogTableCompanion copyWith({
    Value<String>? id,
    Value<String>? canonicalName,
    Value<String?>? category,
    Value<String>? synonymsJson,
    Value<String?>? illustrationKey,
    Value<int>? rowid,
  }) {
    return ToolsCatalogTableCompanion(
      id: id ?? this.id,
      canonicalName: canonicalName ?? this.canonicalName,
      category: category ?? this.category,
      synonymsJson: synonymsJson ?? this.synonymsJson,
      illustrationKey: illustrationKey ?? this.illustrationKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (canonicalName.present) {
      map['canonical_name'] = Variable<String>(canonicalName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (synonymsJson.present) {
      map['synonyms_json'] = Variable<String>(synonymsJson.value);
    }
    if (illustrationKey.present) {
      map['illustration_key'] = Variable<String>(illustrationKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ToolsCatalogTableCompanion(')
          ..write('id: $id, ')
          ..write('canonicalName: $canonicalName, ')
          ..write('category: $category, ')
          ..write('synonymsJson: $synonymsJson, ')
          ..write('illustrationKey: $illustrationKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeToolsTableTable extends RecipeToolsTable
    with TableInfo<$RecipeToolsTableTable, RecipeToolsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeToolsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toolIdMeta = const VerificationMeta('toolId');
  @override
  late final GeneratedColumn<String> toolId = GeneratedColumn<String>(
    'tool_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isRequiredMeta = const VerificationMeta(
    'isRequired',
  );
  @override
  late final GeneratedColumn<bool> isRequired = GeneratedColumn<bool>(
    'is_required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_required" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    toolId,
    displayName,
    quantity,
    isRequired,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_tools_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeToolsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('tool_id')) {
      context.handle(
        _toolIdMeta,
        toolId.isAcceptableOrUnknown(data['tool_id']!, _toolIdMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('is_required')) {
      context.handle(
        _isRequiredMeta,
        isRequired.isAcceptableOrUnknown(data['is_required']!, _isRequiredMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeToolsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeToolsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      toolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_id'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      isRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_required'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $RecipeToolsTableTable createAlias(String alias) {
    return $RecipeToolsTableTable(attachedDatabase, alias);
  }
}

class RecipeToolsTableData extends DataClass
    implements Insertable<RecipeToolsTableData> {
  final String id;
  final String recipeId;
  final String? toolId;
  final String displayName;
  final int quantity;
  final bool isRequired;
  final int position;
  const RecipeToolsTableData({
    required this.id,
    required this.recipeId,
    this.toolId,
    required this.displayName,
    required this.quantity,
    required this.isRequired,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    if (!nullToAbsent || toolId != null) {
      map['tool_id'] = Variable<String>(toolId);
    }
    map['display_name'] = Variable<String>(displayName);
    map['quantity'] = Variable<int>(quantity);
    map['is_required'] = Variable<bool>(isRequired);
    map['position'] = Variable<int>(position);
    return map;
  }

  RecipeToolsTableCompanion toCompanion(bool nullToAbsent) {
    return RecipeToolsTableCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      toolId: toolId == null && nullToAbsent
          ? const Value.absent()
          : Value(toolId),
      displayName: Value(displayName),
      quantity: Value(quantity),
      isRequired: Value(isRequired),
      position: Value(position),
    );
  }

  factory RecipeToolsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeToolsTableData(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      toolId: serializer.fromJson<String?>(json['toolId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      quantity: serializer.fromJson<int>(json['quantity']),
      isRequired: serializer.fromJson<bool>(json['isRequired']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'toolId': serializer.toJson<String?>(toolId),
      'displayName': serializer.toJson<String>(displayName),
      'quantity': serializer.toJson<int>(quantity),
      'isRequired': serializer.toJson<bool>(isRequired),
      'position': serializer.toJson<int>(position),
    };
  }

  RecipeToolsTableData copyWith({
    String? id,
    String? recipeId,
    Value<String?> toolId = const Value.absent(),
    String? displayName,
    int? quantity,
    bool? isRequired,
    int? position,
  }) => RecipeToolsTableData(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    toolId: toolId.present ? toolId.value : this.toolId,
    displayName: displayName ?? this.displayName,
    quantity: quantity ?? this.quantity,
    isRequired: isRequired ?? this.isRequired,
    position: position ?? this.position,
  );
  RecipeToolsTableData copyWithCompanion(RecipeToolsTableCompanion data) {
    return RecipeToolsTableData(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      toolId: data.toolId.present ? data.toolId.value : this.toolId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      isRequired: data.isRequired.present
          ? data.isRequired.value
          : this.isRequired,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeToolsTableData(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('toolId: $toolId, ')
          ..write('displayName: $displayName, ')
          ..write('quantity: $quantity, ')
          ..write('isRequired: $isRequired, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recipeId,
    toolId,
    displayName,
    quantity,
    isRequired,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeToolsTableData &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.toolId == this.toolId &&
          other.displayName == this.displayName &&
          other.quantity == this.quantity &&
          other.isRequired == this.isRequired &&
          other.position == this.position);
}

class RecipeToolsTableCompanion extends UpdateCompanion<RecipeToolsTableData> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<String?> toolId;
  final Value<String> displayName;
  final Value<int> quantity;
  final Value<bool> isRequired;
  final Value<int> position;
  final Value<int> rowid;
  const RecipeToolsTableCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.toolId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeToolsTableCompanion.insert({
    required String id,
    required String recipeId,
    this.toolId = const Value.absent(),
    required String displayName,
    this.quantity = const Value.absent(),
    this.isRequired = const Value.absent(),
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recipeId = Value(recipeId),
       displayName = Value(displayName),
       position = Value(position);
  static Insertable<RecipeToolsTableData> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<String>? toolId,
    Expression<String>? displayName,
    Expression<int>? quantity,
    Expression<bool>? isRequired,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (toolId != null) 'tool_id': toolId,
      if (displayName != null) 'display_name': displayName,
      if (quantity != null) 'quantity': quantity,
      if (isRequired != null) 'is_required': isRequired,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeToolsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? recipeId,
    Value<String?>? toolId,
    Value<String>? displayName,
    Value<int>? quantity,
    Value<bool>? isRequired,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return RecipeToolsTableCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      toolId: toolId ?? this.toolId,
      displayName: displayName ?? this.displayName,
      quantity: quantity ?? this.quantity,
      isRequired: isRequired ?? this.isRequired,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (toolId.present) {
      map['tool_id'] = Variable<String>(toolId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (isRequired.present) {
      map['is_required'] = Variable<bool>(isRequired.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeToolsTableCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('toolId: $toolId, ')
          ..write('displayName: $displayName, ')
          ..write('quantity: $quantity, ')
          ..write('isRequired: $isRequired, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LabelsTableTable extends LabelsTable
    with TableInfo<$LabelsTableTable, LabelsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LabelsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalKeyMeta = const VerificationMeta(
    'canonicalKey',
  );
  @override
  late final GeneratedColumn<String> canonicalKey = GeneratedColumn<String>(
    'canonical_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    canonicalKey,
    displayName,
    iconKey,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'labels_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LabelsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('canonical_key')) {
      context.handle(
        _canonicalKeyMeta,
        canonicalKey.isAcceptableOrUnknown(
          data['canonical_key']!,
          _canonicalKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalKeyMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LabelsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LabelsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      canonicalKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_key'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $LabelsTableTable createAlias(String alias) {
    return $LabelsTableTable(attachedDatabase, alias);
  }
}

class LabelsTableData extends DataClass implements Insertable<LabelsTableData> {
  final String id;
  final String kind;
  final String canonicalKey;
  final String displayName;
  final String? iconKey;
  final int sortOrder;
  const LabelsTableData({
    required this.id,
    required this.kind,
    required this.canonicalKey,
    required this.displayName,
    this.iconKey,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['canonical_key'] = Variable<String>(canonicalKey);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || iconKey != null) {
      map['icon_key'] = Variable<String>(iconKey);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LabelsTableCompanion toCompanion(bool nullToAbsent) {
    return LabelsTableCompanion(
      id: Value(id),
      kind: Value(kind),
      canonicalKey: Value(canonicalKey),
      displayName: Value(displayName),
      iconKey: iconKey == null && nullToAbsent
          ? const Value.absent()
          : Value(iconKey),
      sortOrder: Value(sortOrder),
    );
  }

  factory LabelsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LabelsTableData(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      canonicalKey: serializer.fromJson<String>(json['canonicalKey']),
      displayName: serializer.fromJson<String>(json['displayName']),
      iconKey: serializer.fromJson<String?>(json['iconKey']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'canonicalKey': serializer.toJson<String>(canonicalKey),
      'displayName': serializer.toJson<String>(displayName),
      'iconKey': serializer.toJson<String?>(iconKey),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LabelsTableData copyWith({
    String? id,
    String? kind,
    String? canonicalKey,
    String? displayName,
    Value<String?> iconKey = const Value.absent(),
    int? sortOrder,
  }) => LabelsTableData(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    canonicalKey: canonicalKey ?? this.canonicalKey,
    displayName: displayName ?? this.displayName,
    iconKey: iconKey.present ? iconKey.value : this.iconKey,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LabelsTableData copyWithCompanion(LabelsTableCompanion data) {
    return LabelsTableData(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      canonicalKey: data.canonicalKey.present
          ? data.canonicalKey.value
          : this.canonicalKey,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LabelsTableData(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('canonicalKey: $canonicalKey, ')
          ..write('displayName: $displayName, ')
          ..write('iconKey: $iconKey, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, canonicalKey, displayName, iconKey, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LabelsTableData &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.canonicalKey == this.canonicalKey &&
          other.displayName == this.displayName &&
          other.iconKey == this.iconKey &&
          other.sortOrder == this.sortOrder);
}

class LabelsTableCompanion extends UpdateCompanion<LabelsTableData> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> canonicalKey;
  final Value<String> displayName;
  final Value<String?> iconKey;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LabelsTableCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.canonicalKey = const Value.absent(),
    this.displayName = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LabelsTableCompanion.insert({
    required String id,
    required String kind,
    required String canonicalKey,
    required String displayName,
    this.iconKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       canonicalKey = Value(canonicalKey),
       displayName = Value(displayName);
  static Insertable<LabelsTableData> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? canonicalKey,
    Expression<String>? displayName,
    Expression<String>? iconKey,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (canonicalKey != null) 'canonical_key': canonicalKey,
      if (displayName != null) 'display_name': displayName,
      if (iconKey != null) 'icon_key': iconKey,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LabelsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? canonicalKey,
    Value<String>? displayName,
    Value<String?>? iconKey,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LabelsTableCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      canonicalKey: canonicalKey ?? this.canonicalKey,
      displayName: displayName ?? this.displayName,
      iconKey: iconKey ?? this.iconKey,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (canonicalKey.present) {
      map['canonical_key'] = Variable<String>(canonicalKey.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LabelsTableCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('canonicalKey: $canonicalKey, ')
          ..write('displayName: $displayName, ')
          ..write('iconKey: $iconKey, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeLabelsTableTable extends RecipeLabelsTable
    with TableInfo<$RecipeLabelsTableTable, RecipeLabelsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeLabelsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelIdMeta = const VerificationMeta(
    'labelId',
  );
  @override
  late final GeneratedColumn<String> labelId = GeneratedColumn<String>(
    'label_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceConfidenceMeta = const VerificationMeta(
    'sourceConfidence',
  );
  @override
  late final GeneratedColumn<double> sourceConfidence = GeneratedColumn<double>(
    'source_confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _isUserConfirmedMeta = const VerificationMeta(
    'isUserConfirmed',
  );
  @override
  late final GeneratedColumn<bool> isUserConfirmed = GeneratedColumn<bool>(
    'is_user_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_user_confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    labelId,
    sourceConfidence,
    isUserConfirmed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_labels_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeLabelsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('label_id')) {
      context.handle(
        _labelIdMeta,
        labelId.isAcceptableOrUnknown(data['label_id']!, _labelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_labelIdMeta);
    }
    if (data.containsKey('source_confidence')) {
      context.handle(
        _sourceConfidenceMeta,
        sourceConfidence.isAcceptableOrUnknown(
          data['source_confidence']!,
          _sourceConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('is_user_confirmed')) {
      context.handle(
        _isUserConfirmedMeta,
        isUserConfirmed.isAcceptableOrUnknown(
          data['is_user_confirmed']!,
          _isUserConfirmedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeLabelsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeLabelsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      labelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label_id'],
      )!,
      sourceConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}source_confidence'],
      )!,
      isUserConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_user_confirmed'],
      )!,
    );
  }

  @override
  $RecipeLabelsTableTable createAlias(String alias) {
    return $RecipeLabelsTableTable(attachedDatabase, alias);
  }
}

class RecipeLabelsTableData extends DataClass
    implements Insertable<RecipeLabelsTableData> {
  final String id;
  final String recipeId;
  final String labelId;
  final double sourceConfidence;
  final bool isUserConfirmed;
  const RecipeLabelsTableData({
    required this.id,
    required this.recipeId,
    required this.labelId,
    required this.sourceConfidence,
    required this.isUserConfirmed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['label_id'] = Variable<String>(labelId);
    map['source_confidence'] = Variable<double>(sourceConfidence);
    map['is_user_confirmed'] = Variable<bool>(isUserConfirmed);
    return map;
  }

  RecipeLabelsTableCompanion toCompanion(bool nullToAbsent) {
    return RecipeLabelsTableCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      labelId: Value(labelId),
      sourceConfidence: Value(sourceConfidence),
      isUserConfirmed: Value(isUserConfirmed),
    );
  }

  factory RecipeLabelsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeLabelsTableData(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      labelId: serializer.fromJson<String>(json['labelId']),
      sourceConfidence: serializer.fromJson<double>(json['sourceConfidence']),
      isUserConfirmed: serializer.fromJson<bool>(json['isUserConfirmed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'labelId': serializer.toJson<String>(labelId),
      'sourceConfidence': serializer.toJson<double>(sourceConfidence),
      'isUserConfirmed': serializer.toJson<bool>(isUserConfirmed),
    };
  }

  RecipeLabelsTableData copyWith({
    String? id,
    String? recipeId,
    String? labelId,
    double? sourceConfidence,
    bool? isUserConfirmed,
  }) => RecipeLabelsTableData(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    labelId: labelId ?? this.labelId,
    sourceConfidence: sourceConfidence ?? this.sourceConfidence,
    isUserConfirmed: isUserConfirmed ?? this.isUserConfirmed,
  );
  RecipeLabelsTableData copyWithCompanion(RecipeLabelsTableCompanion data) {
    return RecipeLabelsTableData(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      labelId: data.labelId.present ? data.labelId.value : this.labelId,
      sourceConfidence: data.sourceConfidence.present
          ? data.sourceConfidence.value
          : this.sourceConfidence,
      isUserConfirmed: data.isUserConfirmed.present
          ? data.isUserConfirmed.value
          : this.isUserConfirmed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeLabelsTableData(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('labelId: $labelId, ')
          ..write('sourceConfidence: $sourceConfidence, ')
          ..write('isUserConfirmed: $isUserConfirmed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recipeId, labelId, sourceConfidence, isUserConfirmed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeLabelsTableData &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.labelId == this.labelId &&
          other.sourceConfidence == this.sourceConfidence &&
          other.isUserConfirmed == this.isUserConfirmed);
}

class RecipeLabelsTableCompanion
    extends UpdateCompanion<RecipeLabelsTableData> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<String> labelId;
  final Value<double> sourceConfidence;
  final Value<bool> isUserConfirmed;
  final Value<int> rowid;
  const RecipeLabelsTableCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.labelId = const Value.absent(),
    this.sourceConfidence = const Value.absent(),
    this.isUserConfirmed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeLabelsTableCompanion.insert({
    required String id,
    required String recipeId,
    required String labelId,
    this.sourceConfidence = const Value.absent(),
    this.isUserConfirmed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recipeId = Value(recipeId),
       labelId = Value(labelId);
  static Insertable<RecipeLabelsTableData> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<String>? labelId,
    Expression<double>? sourceConfidence,
    Expression<bool>? isUserConfirmed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (labelId != null) 'label_id': labelId,
      if (sourceConfidence != null) 'source_confidence': sourceConfidence,
      if (isUserConfirmed != null) 'is_user_confirmed': isUserConfirmed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeLabelsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? recipeId,
    Value<String>? labelId,
    Value<double>? sourceConfidence,
    Value<bool>? isUserConfirmed,
    Value<int>? rowid,
  }) {
    return RecipeLabelsTableCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      labelId: labelId ?? this.labelId,
      sourceConfidence: sourceConfidence ?? this.sourceConfidence,
      isUserConfirmed: isUserConfirmed ?? this.isUserConfirmed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (labelId.present) {
      map['label_id'] = Variable<String>(labelId.value);
    }
    if (sourceConfidence.present) {
      map['source_confidence'] = Variable<double>(sourceConfidence.value);
    }
    if (isUserConfirmed.present) {
      map['is_user_confirmed'] = Variable<bool>(isUserConfirmed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeLabelsTableCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('labelId: $labelId, ')
          ..write('sourceConfidence: $sourceConfidence, ')
          ..write('isUserConfirmed: $isUserConfirmed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeMediaTableTable extends RecipeMediaTable
    with TableInfo<$RecipeMediaTableTable, RecipeMediaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeMediaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storageKindMeta = const VerificationMeta(
    'storageKind',
  );
  @override
  late final GeneratedColumn<String> storageKind = GeneratedColumn<String>(
    'storage_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altTextMeta = const VerificationMeta(
    'altText',
  );
  @override
  late final GeneratedColumn<String> altText = GeneratedColumn<String>(
    'alt_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    kind,
    storageKind,
    relativePath,
    mimeType,
    width,
    height,
    sha256,
    caption,
    altText,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_media_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeMediaTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('storage_kind')) {
      context.handle(
        _storageKindMeta,
        storageKind.isAcceptableOrUnknown(
          data['storage_kind']!,
          _storageKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storageKindMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('alt_text')) {
      context.handle(
        _altTextMeta,
        altText.isAcceptableOrUnknown(data['alt_text']!, _altTextMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeMediaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeMediaTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      storageKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_kind'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      ),
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
      altText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alt_text'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $RecipeMediaTableTable createAlias(String alias) {
    return $RecipeMediaTableTable(attachedDatabase, alias);
  }
}

class RecipeMediaTableData extends DataClass
    implements Insertable<RecipeMediaTableData> {
  final String id;
  final String recipeId;
  final String kind;
  final String storageKind;
  final String relativePath;
  final String mimeType;
  final int? width;
  final int? height;
  final String? sha256;
  final String? caption;
  final String? altText;
  final int position;
  const RecipeMediaTableData({
    required this.id,
    required this.recipeId,
    required this.kind,
    required this.storageKind,
    required this.relativePath,
    required this.mimeType,
    this.width,
    this.height,
    this.sha256,
    this.caption,
    this.altText,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['kind'] = Variable<String>(kind);
    map['storage_kind'] = Variable<String>(storageKind);
    map['relative_path'] = Variable<String>(relativePath);
    map['mime_type'] = Variable<String>(mimeType);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || sha256 != null) {
      map['sha256'] = Variable<String>(sha256);
    }
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    if (!nullToAbsent || altText != null) {
      map['alt_text'] = Variable<String>(altText);
    }
    map['position'] = Variable<int>(position);
    return map;
  }

  RecipeMediaTableCompanion toCompanion(bool nullToAbsent) {
    return RecipeMediaTableCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      kind: Value(kind),
      storageKind: Value(storageKind),
      relativePath: Value(relativePath),
      mimeType: Value(mimeType),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      sha256: sha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      altText: altText == null && nullToAbsent
          ? const Value.absent()
          : Value(altText),
      position: Value(position),
    );
  }

  factory RecipeMediaTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeMediaTableData(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      kind: serializer.fromJson<String>(json['kind']),
      storageKind: serializer.fromJson<String>(json['storageKind']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      sha256: serializer.fromJson<String?>(json['sha256']),
      caption: serializer.fromJson<String?>(json['caption']),
      altText: serializer.fromJson<String?>(json['altText']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'kind': serializer.toJson<String>(kind),
      'storageKind': serializer.toJson<String>(storageKind),
      'relativePath': serializer.toJson<String>(relativePath),
      'mimeType': serializer.toJson<String>(mimeType),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'sha256': serializer.toJson<String?>(sha256),
      'caption': serializer.toJson<String?>(caption),
      'altText': serializer.toJson<String?>(altText),
      'position': serializer.toJson<int>(position),
    };
  }

  RecipeMediaTableData copyWith({
    String? id,
    String? recipeId,
    String? kind,
    String? storageKind,
    String? relativePath,
    String? mimeType,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<String?> sha256 = const Value.absent(),
    Value<String?> caption = const Value.absent(),
    Value<String?> altText = const Value.absent(),
    int? position,
  }) => RecipeMediaTableData(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    kind: kind ?? this.kind,
    storageKind: storageKind ?? this.storageKind,
    relativePath: relativePath ?? this.relativePath,
    mimeType: mimeType ?? this.mimeType,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    sha256: sha256.present ? sha256.value : this.sha256,
    caption: caption.present ? caption.value : this.caption,
    altText: altText.present ? altText.value : this.altText,
    position: position ?? this.position,
  );
  RecipeMediaTableData copyWithCompanion(RecipeMediaTableCompanion data) {
    return RecipeMediaTableData(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      kind: data.kind.present ? data.kind.value : this.kind,
      storageKind: data.storageKind.present
          ? data.storageKind.value
          : this.storageKind,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      caption: data.caption.present ? data.caption.value : this.caption,
      altText: data.altText.present ? data.altText.value : this.altText,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeMediaTableData(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('kind: $kind, ')
          ..write('storageKind: $storageKind, ')
          ..write('relativePath: $relativePath, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('sha256: $sha256, ')
          ..write('caption: $caption, ')
          ..write('altText: $altText, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recipeId,
    kind,
    storageKind,
    relativePath,
    mimeType,
    width,
    height,
    sha256,
    caption,
    altText,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeMediaTableData &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.kind == this.kind &&
          other.storageKind == this.storageKind &&
          other.relativePath == this.relativePath &&
          other.mimeType == this.mimeType &&
          other.width == this.width &&
          other.height == this.height &&
          other.sha256 == this.sha256 &&
          other.caption == this.caption &&
          other.altText == this.altText &&
          other.position == this.position);
}

class RecipeMediaTableCompanion extends UpdateCompanion<RecipeMediaTableData> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<String> kind;
  final Value<String> storageKind;
  final Value<String> relativePath;
  final Value<String> mimeType;
  final Value<int?> width;
  final Value<int?> height;
  final Value<String?> sha256;
  final Value<String?> caption;
  final Value<String?> altText;
  final Value<int> position;
  final Value<int> rowid;
  const RecipeMediaTableCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.kind = const Value.absent(),
    this.storageKind = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.caption = const Value.absent(),
    this.altText = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeMediaTableCompanion.insert({
    required String id,
    required String recipeId,
    required String kind,
    required String storageKind,
    required String relativePath,
    required String mimeType,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.caption = const Value.absent(),
    this.altText = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recipeId = Value(recipeId),
       kind = Value(kind),
       storageKind = Value(storageKind),
       relativePath = Value(relativePath),
       mimeType = Value(mimeType);
  static Insertable<RecipeMediaTableData> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<String>? kind,
    Expression<String>? storageKind,
    Expression<String>? relativePath,
    Expression<String>? mimeType,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? sha256,
    Expression<String>? caption,
    Expression<String>? altText,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (kind != null) 'kind': kind,
      if (storageKind != null) 'storage_kind': storageKind,
      if (relativePath != null) 'relative_path': relativePath,
      if (mimeType != null) 'mime_type': mimeType,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (sha256 != null) 'sha256': sha256,
      if (caption != null) 'caption': caption,
      if (altText != null) 'alt_text': altText,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeMediaTableCompanion copyWith({
    Value<String>? id,
    Value<String>? recipeId,
    Value<String>? kind,
    Value<String>? storageKind,
    Value<String>? relativePath,
    Value<String>? mimeType,
    Value<int?>? width,
    Value<int?>? height,
    Value<String?>? sha256,
    Value<String?>? caption,
    Value<String?>? altText,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return RecipeMediaTableCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      kind: kind ?? this.kind,
      storageKind: storageKind ?? this.storageKind,
      relativePath: relativePath ?? this.relativePath,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      sha256: sha256 ?? this.sha256,
      caption: caption ?? this.caption,
      altText: altText ?? this.altText,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (storageKind.present) {
      map['storage_kind'] = Variable<String>(storageKind.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (altText.present) {
      map['alt_text'] = Variable<String>(altText.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeMediaTableCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('kind: $kind, ')
          ..write('storageKind: $storageKind, ')
          ..write('relativePath: $relativePath, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('sha256: $sha256, ')
          ..write('caption: $caption, ')
          ..write('altText: $altText, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTableTable extends CollectionsTable
    with TableInfo<$CollectionsTableTable, CollectionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorTokenMeta = const VerificationMeta(
    'colorToken',
  );
  @override
  late final GeneratedColumn<String> colorToken = GeneratedColumn<String>(
    'color_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('accent.herb'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    colorToken,
    description,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_token')) {
      context.handle(
        _colorTokenMeta,
        colorToken.isAcceptableOrUnknown(data['color_token']!, _colorTokenMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_token'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CollectionsTableTable createAlias(String alias) {
    return $CollectionsTableTable(attachedDatabase, alias);
  }
}

class CollectionsTableData extends DataClass
    implements Insertable<CollectionsTableData> {
  final String id;
  final String profileId;
  final String name;
  final String colorToken;
  final String? description;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const CollectionsTableData({
    required this.id,
    required this.profileId,
    required this.name,
    required this.colorToken,
    this.description,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['name'] = Variable<String>(name);
    map['color_token'] = Variable<String>(colorToken);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  CollectionsTableCompanion toCompanion(bool nullToAbsent) {
    return CollectionsTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      colorToken: Value(colorToken),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CollectionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionsTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      colorToken: serializer.fromJson<String>(json['colorToken']),
      description: serializer.fromJson<String?>(json['description']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'name': serializer.toJson<String>(name),
      'colorToken': serializer.toJson<String>(colorToken),
      'description': serializer.toJson<String?>(description),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  CollectionsTableData copyWith({
    String? id,
    String? profileId,
    String? name,
    String? colorToken,
    Value<String?> description = const Value.absent(),
    int? sortOrder,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => CollectionsTableData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    colorToken: colorToken ?? this.colorToken,
    description: description.present ? description.value : this.description,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  CollectionsTableData copyWithCompanion(CollectionsTableCompanion data) {
    return CollectionsTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      colorToken: data.colorToken.present
          ? data.colorToken.value
          : this.colorToken,
      description: data.description.present
          ? data.description.value
          : this.description,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('colorToken: $colorToken, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    name,
    colorToken,
    description,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionsTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.colorToken == this.colorToken &&
          other.description == this.description &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CollectionsTableCompanion extends UpdateCompanion<CollectionsTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> name;
  final Value<String> colorToken;
  final Value<String?> description;
  final Value<int> sortOrder;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const CollectionsTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.colorToken = const Value.absent(),
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsTableCompanion.insert({
    required String id,
    required String profileId,
    required String name,
    this.colorToken = const Value.absent(),
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CollectionsTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? name,
    Expression<String>? colorToken,
    Expression<String>? description,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (colorToken != null) 'color_token': colorToken,
      if (description != null) 'description': description,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? name,
    Value<String>? colorToken,
    Value<String?>? description,
    Value<int>? sortOrder,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return CollectionsTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      colorToken: colorToken ?? this.colorToken,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorToken.present) {
      map['color_token'] = Variable<String>(colorToken.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('colorToken: $colorToken, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionRecipesTableTable extends CollectionRecipesTable
    with TableInfo<$CollectionRecipesTableTable, CollectionRecipesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionRecipesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<int> addedAt = GeneratedColumn<int>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    collectionId,
    recipeId,
    position,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_recipes_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionRecipesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionRecipesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionRecipesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $CollectionRecipesTableTable createAlias(String alias) {
    return $CollectionRecipesTableTable(attachedDatabase, alias);
  }
}

class CollectionRecipesTableData extends DataClass
    implements Insertable<CollectionRecipesTableData> {
  final String id;
  final String collectionId;
  final String recipeId;
  final int position;
  final int addedAt;
  const CollectionRecipesTableData({
    required this.id,
    required this.collectionId,
    required this.recipeId,
    required this.position,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['collection_id'] = Variable<String>(collectionId);
    map['recipe_id'] = Variable<String>(recipeId);
    map['position'] = Variable<int>(position);
    map['added_at'] = Variable<int>(addedAt);
    return map;
  }

  CollectionRecipesTableCompanion toCompanion(bool nullToAbsent) {
    return CollectionRecipesTableCompanion(
      id: Value(id),
      collectionId: Value(collectionId),
      recipeId: Value(recipeId),
      position: Value(position),
      addedAt: Value(addedAt),
    );
  }

  factory CollectionRecipesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionRecipesTableData(
      id: serializer.fromJson<String>(json['id']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      position: serializer.fromJson<int>(json['position']),
      addedAt: serializer.fromJson<int>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'collectionId': serializer.toJson<String>(collectionId),
      'recipeId': serializer.toJson<String>(recipeId),
      'position': serializer.toJson<int>(position),
      'addedAt': serializer.toJson<int>(addedAt),
    };
  }

  CollectionRecipesTableData copyWith({
    String? id,
    String? collectionId,
    String? recipeId,
    int? position,
    int? addedAt,
  }) => CollectionRecipesTableData(
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    recipeId: recipeId ?? this.recipeId,
    position: position ?? this.position,
    addedAt: addedAt ?? this.addedAt,
  );
  CollectionRecipesTableData copyWithCompanion(
    CollectionRecipesTableCompanion data,
  ) {
    return CollectionRecipesTableData(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      position: data.position.present ? data.position.value : this.position,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionRecipesTableData(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, collectionId, recipeId, position, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionRecipesTableData &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.recipeId == this.recipeId &&
          other.position == this.position &&
          other.addedAt == this.addedAt);
}

class CollectionRecipesTableCompanion
    extends UpdateCompanion<CollectionRecipesTableData> {
  final Value<String> id;
  final Value<String> collectionId;
  final Value<String> recipeId;
  final Value<int> position;
  final Value<int> addedAt;
  final Value<int> rowid;
  const CollectionRecipesTableCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.position = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionRecipesTableCompanion.insert({
    required String id,
    required String collectionId,
    required String recipeId,
    this.position = const Value.absent(),
    required int addedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       collectionId = Value(collectionId),
       recipeId = Value(recipeId),
       addedAt = Value(addedAt);
  static Insertable<CollectionRecipesTableData> custom({
    Expression<String>? id,
    Expression<String>? collectionId,
    Expression<String>? recipeId,
    Expression<int>? position,
    Expression<int>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (position != null) 'position': position,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionRecipesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? collectionId,
    Value<String>? recipeId,
    Value<int>? position,
    Value<int>? addedAt,
    Value<int>? rowid,
  }) {
    return CollectionRecipesTableCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      recipeId: recipeId ?? this.recipeId,
      position: position ?? this.position,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionRecipesTableCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTableTable extends FavoritesTable
    with TableInfo<$FavoritesTableTable, FavoritesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _favoritedAtMeta = const VerificationMeta(
    'favoritedAt',
  );
  @override
  late final GeneratedColumn<int> favoritedAt = GeneratedColumn<int>(
    'favorited_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, profileId, recipeId, favoritedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoritesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('favorited_at')) {
      context.handle(
        _favoritedAtMeta,
        favoritedAt.isAcceptableOrUnknown(
          data['favorited_at']!,
          _favoritedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_favoritedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoritesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoritesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      favoritedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}favorited_at'],
      )!,
    );
  }

  @override
  $FavoritesTableTable createAlias(String alias) {
    return $FavoritesTableTable(attachedDatabase, alias);
  }
}

class FavoritesTableData extends DataClass
    implements Insertable<FavoritesTableData> {
  final String id;
  final String profileId;
  final String recipeId;
  final int favoritedAt;
  const FavoritesTableData({
    required this.id,
    required this.profileId,
    required this.recipeId,
    required this.favoritedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['recipe_id'] = Variable<String>(recipeId);
    map['favorited_at'] = Variable<int>(favoritedAt);
    return map;
  }

  FavoritesTableCompanion toCompanion(bool nullToAbsent) {
    return FavoritesTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      recipeId: Value(recipeId),
      favoritedAt: Value(favoritedAt),
    );
  }

  factory FavoritesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoritesTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      favoritedAt: serializer.fromJson<int>(json['favoritedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'recipeId': serializer.toJson<String>(recipeId),
      'favoritedAt': serializer.toJson<int>(favoritedAt),
    };
  }

  FavoritesTableData copyWith({
    String? id,
    String? profileId,
    String? recipeId,
    int? favoritedAt,
  }) => FavoritesTableData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    recipeId: recipeId ?? this.recipeId,
    favoritedAt: favoritedAt ?? this.favoritedAt,
  );
  FavoritesTableData copyWithCompanion(FavoritesTableCompanion data) {
    return FavoritesTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      favoritedAt: data.favoritedAt.present
          ? data.favoritedAt.value
          : this.favoritedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recipeId: $recipeId, ')
          ..write('favoritedAt: $favoritedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, recipeId, favoritedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoritesTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.recipeId == this.recipeId &&
          other.favoritedAt == this.favoritedAt);
}

class FavoritesTableCompanion extends UpdateCompanion<FavoritesTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> recipeId;
  final Value<int> favoritedAt;
  final Value<int> rowid;
  const FavoritesTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.favoritedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesTableCompanion.insert({
    required String id,
    required String profileId,
    required String recipeId,
    required int favoritedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       recipeId = Value(recipeId),
       favoritedAt = Value(favoritedAt);
  static Insertable<FavoritesTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? recipeId,
    Expression<int>? favoritedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (favoritedAt != null) 'favorited_at': favoritedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? recipeId,
    Value<int>? favoritedAt,
    Value<int>? rowid,
  }) {
    return FavoritesTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      recipeId: recipeId ?? this.recipeId,
      favoritedAt: favoritedAt ?? this.favoritedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (favoritedAt.present) {
      map['favorited_at'] = Variable<int>(favoritedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recipeId: $recipeId, ')
          ..write('favoritedAt: $favoritedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CookingSessionsTableTable extends CookingSessionsTable
    with TableInfo<$CookingSessionsTableTable, CookingSessionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CookingSessionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeVersionIdMeta = const VerificationMeta(
    'recipeVersionId',
  );
  @override
  late final GeneratedColumn<String> recipeVersionId = GeneratedColumn<String>(
    'recipe_version_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _selectedServingsNumMeta =
      const VerificationMeta('selectedServingsNum');
  @override
  late final GeneratedColumn<int> selectedServingsNum = GeneratedColumn<int>(
    'selected_servings_num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _selectedServingsDenMeta =
      const VerificationMeta('selectedServingsDen');
  @override
  late final GeneratedColumn<int> selectedServingsDen = GeneratedColumn<int>(
    'selected_servings_den',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _activeStepPositionMeta =
      const VerificationMeta('activeStepPosition');
  @override
  late final GeneratedColumn<int> activeStepPosition = GeneratedColumn<int>(
    'active_step_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastResumedAtMeta = const VerificationMeta(
    'lastResumedAt',
  );
  @override
  late final GeneratedColumn<int> lastResumedAt = GeneratedColumn<int>(
    'last_resumed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _screenAwakeRequestedMeta =
      const VerificationMeta('screenAwakeRequested');
  @override
  late final GeneratedColumn<bool> screenAwakeRequested = GeneratedColumn<bool>(
    'screen_awake_requested',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("screen_awake_requested" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _voiceModeMeta = const VerificationMeta(
    'voiceMode',
  );
  @override
  late final GeneratedColumn<bool> voiceMode = GeneratedColumn<bool>(
    'voice_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("voice_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    recipeId,
    recipeVersionId,
    status,
    selectedServingsNum,
    selectedServingsDen,
    activeStepPosition,
    startedAt,
    lastResumedAt,
    completedAt,
    screenAwakeRequested,
    voiceMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cooking_sessions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CookingSessionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('recipe_version_id')) {
      context.handle(
        _recipeVersionIdMeta,
        recipeVersionId.isAcceptableOrUnknown(
          data['recipe_version_id']!,
          _recipeVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('selected_servings_num')) {
      context.handle(
        _selectedServingsNumMeta,
        selectedServingsNum.isAcceptableOrUnknown(
          data['selected_servings_num']!,
          _selectedServingsNumMeta,
        ),
      );
    }
    if (data.containsKey('selected_servings_den')) {
      context.handle(
        _selectedServingsDenMeta,
        selectedServingsDen.isAcceptableOrUnknown(
          data['selected_servings_den']!,
          _selectedServingsDenMeta,
        ),
      );
    }
    if (data.containsKey('active_step_position')) {
      context.handle(
        _activeStepPositionMeta,
        activeStepPosition.isAcceptableOrUnknown(
          data['active_step_position']!,
          _activeStepPositionMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('last_resumed_at')) {
      context.handle(
        _lastResumedAtMeta,
        lastResumedAt.isAcceptableOrUnknown(
          data['last_resumed_at']!,
          _lastResumedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastResumedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('screen_awake_requested')) {
      context.handle(
        _screenAwakeRequestedMeta,
        screenAwakeRequested.isAcceptableOrUnknown(
          data['screen_awake_requested']!,
          _screenAwakeRequestedMeta,
        ),
      );
    }
    if (data.containsKey('voice_mode')) {
      context.handle(
        _voiceModeMeta,
        voiceMode.isAcceptableOrUnknown(data['voice_mode']!, _voiceModeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CookingSessionsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CookingSessionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      recipeVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_version_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      selectedServingsNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_servings_num'],
      )!,
      selectedServingsDen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_servings_den'],
      )!,
      activeStepPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_step_position'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      lastResumedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_resumed_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      screenAwakeRequested: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}screen_awake_requested'],
      )!,
      voiceMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}voice_mode'],
      )!,
    );
  }

  @override
  $CookingSessionsTableTable createAlias(String alias) {
    return $CookingSessionsTableTable(attachedDatabase, alias);
  }
}

class CookingSessionsTableData extends DataClass
    implements Insertable<CookingSessionsTableData> {
  final String id;
  final String profileId;
  final String recipeId;
  final String? recipeVersionId;
  final String status;
  final int selectedServingsNum;
  final int selectedServingsDen;
  final int activeStepPosition;
  final int startedAt;
  final int lastResumedAt;
  final int? completedAt;
  final bool screenAwakeRequested;
  final bool voiceMode;
  const CookingSessionsTableData({
    required this.id,
    required this.profileId,
    required this.recipeId,
    this.recipeVersionId,
    required this.status,
    required this.selectedServingsNum,
    required this.selectedServingsDen,
    required this.activeStepPosition,
    required this.startedAt,
    required this.lastResumedAt,
    this.completedAt,
    required this.screenAwakeRequested,
    required this.voiceMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['recipe_id'] = Variable<String>(recipeId);
    if (!nullToAbsent || recipeVersionId != null) {
      map['recipe_version_id'] = Variable<String>(recipeVersionId);
    }
    map['status'] = Variable<String>(status);
    map['selected_servings_num'] = Variable<int>(selectedServingsNum);
    map['selected_servings_den'] = Variable<int>(selectedServingsDen);
    map['active_step_position'] = Variable<int>(activeStepPosition);
    map['started_at'] = Variable<int>(startedAt);
    map['last_resumed_at'] = Variable<int>(lastResumedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['screen_awake_requested'] = Variable<bool>(screenAwakeRequested);
    map['voice_mode'] = Variable<bool>(voiceMode);
    return map;
  }

  CookingSessionsTableCompanion toCompanion(bool nullToAbsent) {
    return CookingSessionsTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      recipeId: Value(recipeId),
      recipeVersionId: recipeVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeVersionId),
      status: Value(status),
      selectedServingsNum: Value(selectedServingsNum),
      selectedServingsDen: Value(selectedServingsDen),
      activeStepPosition: Value(activeStepPosition),
      startedAt: Value(startedAt),
      lastResumedAt: Value(lastResumedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      screenAwakeRequested: Value(screenAwakeRequested),
      voiceMode: Value(voiceMode),
    );
  }

  factory CookingSessionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CookingSessionsTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      recipeVersionId: serializer.fromJson<String?>(json['recipeVersionId']),
      status: serializer.fromJson<String>(json['status']),
      selectedServingsNum: serializer.fromJson<int>(
        json['selectedServingsNum'],
      ),
      selectedServingsDen: serializer.fromJson<int>(
        json['selectedServingsDen'],
      ),
      activeStepPosition: serializer.fromJson<int>(json['activeStepPosition']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      lastResumedAt: serializer.fromJson<int>(json['lastResumedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      screenAwakeRequested: serializer.fromJson<bool>(
        json['screenAwakeRequested'],
      ),
      voiceMode: serializer.fromJson<bool>(json['voiceMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'recipeId': serializer.toJson<String>(recipeId),
      'recipeVersionId': serializer.toJson<String?>(recipeVersionId),
      'status': serializer.toJson<String>(status),
      'selectedServingsNum': serializer.toJson<int>(selectedServingsNum),
      'selectedServingsDen': serializer.toJson<int>(selectedServingsDen),
      'activeStepPosition': serializer.toJson<int>(activeStepPosition),
      'startedAt': serializer.toJson<int>(startedAt),
      'lastResumedAt': serializer.toJson<int>(lastResumedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
      'screenAwakeRequested': serializer.toJson<bool>(screenAwakeRequested),
      'voiceMode': serializer.toJson<bool>(voiceMode),
    };
  }

  CookingSessionsTableData copyWith({
    String? id,
    String? profileId,
    String? recipeId,
    Value<String?> recipeVersionId = const Value.absent(),
    String? status,
    int? selectedServingsNum,
    int? selectedServingsDen,
    int? activeStepPosition,
    int? startedAt,
    int? lastResumedAt,
    Value<int?> completedAt = const Value.absent(),
    bool? screenAwakeRequested,
    bool? voiceMode,
  }) => CookingSessionsTableData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    recipeId: recipeId ?? this.recipeId,
    recipeVersionId: recipeVersionId.present
        ? recipeVersionId.value
        : this.recipeVersionId,
    status: status ?? this.status,
    selectedServingsNum: selectedServingsNum ?? this.selectedServingsNum,
    selectedServingsDen: selectedServingsDen ?? this.selectedServingsDen,
    activeStepPosition: activeStepPosition ?? this.activeStepPosition,
    startedAt: startedAt ?? this.startedAt,
    lastResumedAt: lastResumedAt ?? this.lastResumedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    screenAwakeRequested: screenAwakeRequested ?? this.screenAwakeRequested,
    voiceMode: voiceMode ?? this.voiceMode,
  );
  CookingSessionsTableData copyWithCompanion(
    CookingSessionsTableCompanion data,
  ) {
    return CookingSessionsTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      recipeVersionId: data.recipeVersionId.present
          ? data.recipeVersionId.value
          : this.recipeVersionId,
      status: data.status.present ? data.status.value : this.status,
      selectedServingsNum: data.selectedServingsNum.present
          ? data.selectedServingsNum.value
          : this.selectedServingsNum,
      selectedServingsDen: data.selectedServingsDen.present
          ? data.selectedServingsDen.value
          : this.selectedServingsDen,
      activeStepPosition: data.activeStepPosition.present
          ? data.activeStepPosition.value
          : this.activeStepPosition,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      lastResumedAt: data.lastResumedAt.present
          ? data.lastResumedAt.value
          : this.lastResumedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      screenAwakeRequested: data.screenAwakeRequested.present
          ? data.screenAwakeRequested.value
          : this.screenAwakeRequested,
      voiceMode: data.voiceMode.present ? data.voiceMode.value : this.voiceMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CookingSessionsTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recipeId: $recipeId, ')
          ..write('recipeVersionId: $recipeVersionId, ')
          ..write('status: $status, ')
          ..write('selectedServingsNum: $selectedServingsNum, ')
          ..write('selectedServingsDen: $selectedServingsDen, ')
          ..write('activeStepPosition: $activeStepPosition, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastResumedAt: $lastResumedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('screenAwakeRequested: $screenAwakeRequested, ')
          ..write('voiceMode: $voiceMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    recipeId,
    recipeVersionId,
    status,
    selectedServingsNum,
    selectedServingsDen,
    activeStepPosition,
    startedAt,
    lastResumedAt,
    completedAt,
    screenAwakeRequested,
    voiceMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CookingSessionsTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.recipeId == this.recipeId &&
          other.recipeVersionId == this.recipeVersionId &&
          other.status == this.status &&
          other.selectedServingsNum == this.selectedServingsNum &&
          other.selectedServingsDen == this.selectedServingsDen &&
          other.activeStepPosition == this.activeStepPosition &&
          other.startedAt == this.startedAt &&
          other.lastResumedAt == this.lastResumedAt &&
          other.completedAt == this.completedAt &&
          other.screenAwakeRequested == this.screenAwakeRequested &&
          other.voiceMode == this.voiceMode);
}

class CookingSessionsTableCompanion
    extends UpdateCompanion<CookingSessionsTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> recipeId;
  final Value<String?> recipeVersionId;
  final Value<String> status;
  final Value<int> selectedServingsNum;
  final Value<int> selectedServingsDen;
  final Value<int> activeStepPosition;
  final Value<int> startedAt;
  final Value<int> lastResumedAt;
  final Value<int?> completedAt;
  final Value<bool> screenAwakeRequested;
  final Value<bool> voiceMode;
  final Value<int> rowid;
  const CookingSessionsTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.recipeVersionId = const Value.absent(),
    this.status = const Value.absent(),
    this.selectedServingsNum = const Value.absent(),
    this.selectedServingsDen = const Value.absent(),
    this.activeStepPosition = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastResumedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.screenAwakeRequested = const Value.absent(),
    this.voiceMode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CookingSessionsTableCompanion.insert({
    required String id,
    required String profileId,
    required String recipeId,
    this.recipeVersionId = const Value.absent(),
    this.status = const Value.absent(),
    this.selectedServingsNum = const Value.absent(),
    this.selectedServingsDen = const Value.absent(),
    this.activeStepPosition = const Value.absent(),
    required int startedAt,
    required int lastResumedAt,
    this.completedAt = const Value.absent(),
    this.screenAwakeRequested = const Value.absent(),
    this.voiceMode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       recipeId = Value(recipeId),
       startedAt = Value(startedAt),
       lastResumedAt = Value(lastResumedAt);
  static Insertable<CookingSessionsTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? recipeId,
    Expression<String>? recipeVersionId,
    Expression<String>? status,
    Expression<int>? selectedServingsNum,
    Expression<int>? selectedServingsDen,
    Expression<int>? activeStepPosition,
    Expression<int>? startedAt,
    Expression<int>? lastResumedAt,
    Expression<int>? completedAt,
    Expression<bool>? screenAwakeRequested,
    Expression<bool>? voiceMode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (recipeVersionId != null) 'recipe_version_id': recipeVersionId,
      if (status != null) 'status': status,
      if (selectedServingsNum != null)
        'selected_servings_num': selectedServingsNum,
      if (selectedServingsDen != null)
        'selected_servings_den': selectedServingsDen,
      if (activeStepPosition != null)
        'active_step_position': activeStepPosition,
      if (startedAt != null) 'started_at': startedAt,
      if (lastResumedAt != null) 'last_resumed_at': lastResumedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (screenAwakeRequested != null)
        'screen_awake_requested': screenAwakeRequested,
      if (voiceMode != null) 'voice_mode': voiceMode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CookingSessionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? recipeId,
    Value<String?>? recipeVersionId,
    Value<String>? status,
    Value<int>? selectedServingsNum,
    Value<int>? selectedServingsDen,
    Value<int>? activeStepPosition,
    Value<int>? startedAt,
    Value<int>? lastResumedAt,
    Value<int?>? completedAt,
    Value<bool>? screenAwakeRequested,
    Value<bool>? voiceMode,
    Value<int>? rowid,
  }) {
    return CookingSessionsTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      recipeId: recipeId ?? this.recipeId,
      recipeVersionId: recipeVersionId ?? this.recipeVersionId,
      status: status ?? this.status,
      selectedServingsNum: selectedServingsNum ?? this.selectedServingsNum,
      selectedServingsDen: selectedServingsDen ?? this.selectedServingsDen,
      activeStepPosition: activeStepPosition ?? this.activeStepPosition,
      startedAt: startedAt ?? this.startedAt,
      lastResumedAt: lastResumedAt ?? this.lastResumedAt,
      completedAt: completedAt ?? this.completedAt,
      screenAwakeRequested: screenAwakeRequested ?? this.screenAwakeRequested,
      voiceMode: voiceMode ?? this.voiceMode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (recipeVersionId.present) {
      map['recipe_version_id'] = Variable<String>(recipeVersionId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (selectedServingsNum.present) {
      map['selected_servings_num'] = Variable<int>(selectedServingsNum.value);
    }
    if (selectedServingsDen.present) {
      map['selected_servings_den'] = Variable<int>(selectedServingsDen.value);
    }
    if (activeStepPosition.present) {
      map['active_step_position'] = Variable<int>(activeStepPosition.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (lastResumedAt.present) {
      map['last_resumed_at'] = Variable<int>(lastResumedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (screenAwakeRequested.present) {
      map['screen_awake_requested'] = Variable<bool>(
        screenAwakeRequested.value,
      );
    }
    if (voiceMode.present) {
      map['voice_mode'] = Variable<bool>(voiceMode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CookingSessionsTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recipeId: $recipeId, ')
          ..write('recipeVersionId: $recipeVersionId, ')
          ..write('status: $status, ')
          ..write('selectedServingsNum: $selectedServingsNum, ')
          ..write('selectedServingsDen: $selectedServingsDen, ')
          ..write('activeStepPosition: $activeStepPosition, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastResumedAt: $lastResumedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('screenAwakeRequested: $screenAwakeRequested, ')
          ..write('voiceMode: $voiceMode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionIngredientChecksTableTable extends SessionIngredientChecksTable
    with
        TableInfo<
          $SessionIngredientChecksTableTable,
          SessionIngredientChecksTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionIngredientChecksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIngredientIdMeta =
      const VerificationMeta('recipeIngredientId');
  @override
  late final GeneratedColumn<String> recipeIngredientId =
      GeneratedColumn<String>(
        'recipe_ingredient_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isCheckedMeta = const VerificationMeta(
    'isChecked',
  );
  @override
  late final GeneratedColumn<bool> isChecked = GeneratedColumn<bool>(
    'is_checked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_checked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _checkedAtMeta = const VerificationMeta(
    'checkedAt',
  );
  @override
  late final GeneratedColumn<int> checkedAt = GeneratedColumn<int>(
    'checked_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    recipeIngredientId,
    isChecked,
    checkedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_ingredient_checks_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionIngredientChecksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('recipe_ingredient_id')) {
      context.handle(
        _recipeIngredientIdMeta,
        recipeIngredientId.isAcceptableOrUnknown(
          data['recipe_ingredient_id']!,
          _recipeIngredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recipeIngredientIdMeta);
    }
    if (data.containsKey('is_checked')) {
      context.handle(
        _isCheckedMeta,
        isChecked.isAcceptableOrUnknown(data['is_checked']!, _isCheckedMeta),
      );
    }
    if (data.containsKey('checked_at')) {
      context.handle(
        _checkedAtMeta,
        checkedAt.isAcceptableOrUnknown(data['checked_at']!, _checkedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_checkedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionIngredientChecksTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionIngredientChecksTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      recipeIngredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_ingredient_id'],
      )!,
      isChecked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_checked'],
      )!,
      checkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}checked_at'],
      )!,
    );
  }

  @override
  $SessionIngredientChecksTableTable createAlias(String alias) {
    return $SessionIngredientChecksTableTable(attachedDatabase, alias);
  }
}

class SessionIngredientChecksTableData extends DataClass
    implements Insertable<SessionIngredientChecksTableData> {
  final String id;
  final String sessionId;
  final String recipeIngredientId;
  final bool isChecked;
  final int checkedAt;
  const SessionIngredientChecksTableData({
    required this.id,
    required this.sessionId,
    required this.recipeIngredientId,
    required this.isChecked,
    required this.checkedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['recipe_ingredient_id'] = Variable<String>(recipeIngredientId);
    map['is_checked'] = Variable<bool>(isChecked);
    map['checked_at'] = Variable<int>(checkedAt);
    return map;
  }

  SessionIngredientChecksTableCompanion toCompanion(bool nullToAbsent) {
    return SessionIngredientChecksTableCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      recipeIngredientId: Value(recipeIngredientId),
      isChecked: Value(isChecked),
      checkedAt: Value(checkedAt),
    );
  }

  factory SessionIngredientChecksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionIngredientChecksTableData(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      recipeIngredientId: serializer.fromJson<String>(
        json['recipeIngredientId'],
      ),
      isChecked: serializer.fromJson<bool>(json['isChecked']),
      checkedAt: serializer.fromJson<int>(json['checkedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'recipeIngredientId': serializer.toJson<String>(recipeIngredientId),
      'isChecked': serializer.toJson<bool>(isChecked),
      'checkedAt': serializer.toJson<int>(checkedAt),
    };
  }

  SessionIngredientChecksTableData copyWith({
    String? id,
    String? sessionId,
    String? recipeIngredientId,
    bool? isChecked,
    int? checkedAt,
  }) => SessionIngredientChecksTableData(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    recipeIngredientId: recipeIngredientId ?? this.recipeIngredientId,
    isChecked: isChecked ?? this.isChecked,
    checkedAt: checkedAt ?? this.checkedAt,
  );
  SessionIngredientChecksTableData copyWithCompanion(
    SessionIngredientChecksTableCompanion data,
  ) {
    return SessionIngredientChecksTableData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      recipeIngredientId: data.recipeIngredientId.present
          ? data.recipeIngredientId.value
          : this.recipeIngredientId,
      isChecked: data.isChecked.present ? data.isChecked.value : this.isChecked,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionIngredientChecksTableData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('recipeIngredientId: $recipeIngredientId, ')
          ..write('isChecked: $isChecked, ')
          ..write('checkedAt: $checkedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, recipeIngredientId, isChecked, checkedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionIngredientChecksTableData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.recipeIngredientId == this.recipeIngredientId &&
          other.isChecked == this.isChecked &&
          other.checkedAt == this.checkedAt);
}

class SessionIngredientChecksTableCompanion
    extends UpdateCompanion<SessionIngredientChecksTableData> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> recipeIngredientId;
  final Value<bool> isChecked;
  final Value<int> checkedAt;
  final Value<int> rowid;
  const SessionIngredientChecksTableCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.recipeIngredientId = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionIngredientChecksTableCompanion.insert({
    required String id,
    required String sessionId,
    required String recipeIngredientId,
    this.isChecked = const Value.absent(),
    required int checkedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       recipeIngredientId = Value(recipeIngredientId),
       checkedAt = Value(checkedAt);
  static Insertable<SessionIngredientChecksTableData> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? recipeIngredientId,
    Expression<bool>? isChecked,
    Expression<int>? checkedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (recipeIngredientId != null)
        'recipe_ingredient_id': recipeIngredientId,
      if (isChecked != null) 'is_checked': isChecked,
      if (checkedAt != null) 'checked_at': checkedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionIngredientChecksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? recipeIngredientId,
    Value<bool>? isChecked,
    Value<int>? checkedAt,
    Value<int>? rowid,
  }) {
    return SessionIngredientChecksTableCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      recipeIngredientId: recipeIngredientId ?? this.recipeIngredientId,
      isChecked: isChecked ?? this.isChecked,
      checkedAt: checkedAt ?? this.checkedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (recipeIngredientId.present) {
      map['recipe_ingredient_id'] = Variable<String>(recipeIngredientId.value);
    }
    if (isChecked.present) {
      map['is_checked'] = Variable<bool>(isChecked.value);
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<int>(checkedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionIngredientChecksTableCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('recipeIngredientId: $recipeIngredientId, ')
          ..write('isChecked: $isChecked, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionTimersTableTable extends SessionTimersTable
    with TableInfo<$SessionTimersTableTable, SessionTimersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionTimersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeStepIdMeta = const VerificationMeta(
    'recipeStepId',
  );
  @override
  late final GeneratedColumn<String> recipeStepId = GeneratedColumn<String>(
    'recipe_step_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsAtMeta = const VerificationMeta('endsAt');
  @override
  late final GeneratedColumn<int> endsAt = GeneratedColumn<int>(
    'ends_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('running'),
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<String> notificationId = GeneratedColumn<String>(
    'notification_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acknowledgedAtMeta = const VerificationMeta(
    'acknowledgedAt',
  );
  @override
  late final GeneratedColumn<int> acknowledgedAt = GeneratedColumn<int>(
    'acknowledged_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    recipeStepId,
    label,
    durationSeconds,
    startedAt,
    endsAt,
    status,
    notificationId,
    acknowledgedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_timers_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionTimersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('recipe_step_id')) {
      context.handle(
        _recipeStepIdMeta,
        recipeStepId.isAcceptableOrUnknown(
          data['recipe_step_id']!,
          _recipeStepIdMeta,
        ),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ends_at')) {
      context.handle(
        _endsAtMeta,
        endsAt.isAcceptableOrUnknown(data['ends_at']!, _endsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endsAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    }
    if (data.containsKey('acknowledged_at')) {
      context.handle(
        _acknowledgedAtMeta,
        acknowledgedAt.isAcceptableOrUnknown(
          data['acknowledged_at']!,
          _acknowledgedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionTimersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionTimersTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      recipeStepId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_step_id'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ends_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_id'],
      ),
      acknowledgedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}acknowledged_at'],
      ),
    );
  }

  @override
  $SessionTimersTableTable createAlias(String alias) {
    return $SessionTimersTableTable(attachedDatabase, alias);
  }
}

class SessionTimersTableData extends DataClass
    implements Insertable<SessionTimersTableData> {
  final String id;
  final String sessionId;
  final String? recipeStepId;
  final String label;
  final int durationSeconds;
  final int startedAt;
  final int endsAt;
  final String status;
  final String? notificationId;
  final int? acknowledgedAt;
  const SessionTimersTableData({
    required this.id,
    required this.sessionId,
    this.recipeStepId,
    required this.label,
    required this.durationSeconds,
    required this.startedAt,
    required this.endsAt,
    required this.status,
    this.notificationId,
    this.acknowledgedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || recipeStepId != null) {
      map['recipe_step_id'] = Variable<String>(recipeStepId);
    }
    map['label'] = Variable<String>(label);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['started_at'] = Variable<int>(startedAt);
    map['ends_at'] = Variable<int>(endsAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notificationId != null) {
      map['notification_id'] = Variable<String>(notificationId);
    }
    if (!nullToAbsent || acknowledgedAt != null) {
      map['acknowledged_at'] = Variable<int>(acknowledgedAt);
    }
    return map;
  }

  SessionTimersTableCompanion toCompanion(bool nullToAbsent) {
    return SessionTimersTableCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      recipeStepId: recipeStepId == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeStepId),
      label: Value(label),
      durationSeconds: Value(durationSeconds),
      startedAt: Value(startedAt),
      endsAt: Value(endsAt),
      status: Value(status),
      notificationId: notificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationId),
      acknowledgedAt: acknowledgedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acknowledgedAt),
    );
  }

  factory SessionTimersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionTimersTableData(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      recipeStepId: serializer.fromJson<String?>(json['recipeStepId']),
      label: serializer.fromJson<String>(json['label']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endsAt: serializer.fromJson<int>(json['endsAt']),
      status: serializer.fromJson<String>(json['status']),
      notificationId: serializer.fromJson<String?>(json['notificationId']),
      acknowledgedAt: serializer.fromJson<int?>(json['acknowledgedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'recipeStepId': serializer.toJson<String?>(recipeStepId),
      'label': serializer.toJson<String>(label),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'startedAt': serializer.toJson<int>(startedAt),
      'endsAt': serializer.toJson<int>(endsAt),
      'status': serializer.toJson<String>(status),
      'notificationId': serializer.toJson<String?>(notificationId),
      'acknowledgedAt': serializer.toJson<int?>(acknowledgedAt),
    };
  }

  SessionTimersTableData copyWith({
    String? id,
    String? sessionId,
    Value<String?> recipeStepId = const Value.absent(),
    String? label,
    int? durationSeconds,
    int? startedAt,
    int? endsAt,
    String? status,
    Value<String?> notificationId = const Value.absent(),
    Value<int?> acknowledgedAt = const Value.absent(),
  }) => SessionTimersTableData(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    recipeStepId: recipeStepId.present ? recipeStepId.value : this.recipeStepId,
    label: label ?? this.label,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    startedAt: startedAt ?? this.startedAt,
    endsAt: endsAt ?? this.endsAt,
    status: status ?? this.status,
    notificationId: notificationId.present
        ? notificationId.value
        : this.notificationId,
    acknowledgedAt: acknowledgedAt.present
        ? acknowledgedAt.value
        : this.acknowledgedAt,
  );
  SessionTimersTableData copyWithCompanion(SessionTimersTableCompanion data) {
    return SessionTimersTableData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      recipeStepId: data.recipeStepId.present
          ? data.recipeStepId.value
          : this.recipeStepId,
      label: data.label.present ? data.label.value : this.label,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endsAt: data.endsAt.present ? data.endsAt.value : this.endsAt,
      status: data.status.present ? data.status.value : this.status,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      acknowledgedAt: data.acknowledgedAt.present
          ? data.acknowledgedAt.value
          : this.acknowledgedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionTimersTableData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('recipeStepId: $recipeStepId, ')
          ..write('label: $label, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('startedAt: $startedAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('status: $status, ')
          ..write('notificationId: $notificationId, ')
          ..write('acknowledgedAt: $acknowledgedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    recipeStepId,
    label,
    durationSeconds,
    startedAt,
    endsAt,
    status,
    notificationId,
    acknowledgedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionTimersTableData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.recipeStepId == this.recipeStepId &&
          other.label == this.label &&
          other.durationSeconds == this.durationSeconds &&
          other.startedAt == this.startedAt &&
          other.endsAt == this.endsAt &&
          other.status == this.status &&
          other.notificationId == this.notificationId &&
          other.acknowledgedAt == this.acknowledgedAt);
}

class SessionTimersTableCompanion
    extends UpdateCompanion<SessionTimersTableData> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String?> recipeStepId;
  final Value<String> label;
  final Value<int> durationSeconds;
  final Value<int> startedAt;
  final Value<int> endsAt;
  final Value<String> status;
  final Value<String?> notificationId;
  final Value<int?> acknowledgedAt;
  final Value<int> rowid;
  const SessionTimersTableCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.recipeStepId = const Value.absent(),
    this.label = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.status = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.acknowledgedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionTimersTableCompanion.insert({
    required String id,
    required String sessionId,
    this.recipeStepId = const Value.absent(),
    required String label,
    required int durationSeconds,
    required int startedAt,
    required int endsAt,
    this.status = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.acknowledgedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       label = Value(label),
       durationSeconds = Value(durationSeconds),
       startedAt = Value(startedAt),
       endsAt = Value(endsAt);
  static Insertable<SessionTimersTableData> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? recipeStepId,
    Expression<String>? label,
    Expression<int>? durationSeconds,
    Expression<int>? startedAt,
    Expression<int>? endsAt,
    Expression<String>? status,
    Expression<String>? notificationId,
    Expression<int>? acknowledgedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (recipeStepId != null) 'recipe_step_id': recipeStepId,
      if (label != null) 'label': label,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (startedAt != null) 'started_at': startedAt,
      if (endsAt != null) 'ends_at': endsAt,
      if (status != null) 'status': status,
      if (notificationId != null) 'notification_id': notificationId,
      if (acknowledgedAt != null) 'acknowledged_at': acknowledgedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionTimersTableCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String?>? recipeStepId,
    Value<String>? label,
    Value<int>? durationSeconds,
    Value<int>? startedAt,
    Value<int>? endsAt,
    Value<String>? status,
    Value<String?>? notificationId,
    Value<int?>? acknowledgedAt,
    Value<int>? rowid,
  }) {
    return SessionTimersTableCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      recipeStepId: recipeStepId ?? this.recipeStepId,
      label: label ?? this.label,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      startedAt: startedAt ?? this.startedAt,
      endsAt: endsAt ?? this.endsAt,
      status: status ?? this.status,
      notificationId: notificationId ?? this.notificationId,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (recipeStepId.present) {
      map['recipe_step_id'] = Variable<String>(recipeStepId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endsAt.present) {
      map['ends_at'] = Variable<int>(endsAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<String>(notificationId.value);
    }
    if (acknowledgedAt.present) {
      map['acknowledged_at'] = Variable<int>(acknowledgedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionTimersTableCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('recipeStepId: $recipeStepId, ')
          ..write('label: $label, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('startedAt: $startedAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('status: $status, ')
          ..write('notificationId: $notificationId, ')
          ..write('acknowledgedAt: $acknowledgedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    key,
    valueJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  final String id;
  final String profileId;
  final String key;
  final String valueJson;
  final int updatedAt;
  const AppSettingsTableData({
    required this.id,
    required this.profileId,
    required this.key,
    required this.valueJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      key: Value(key),
      valueJson: Value(valueJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AppSettingsTableData copyWith({
    String? id,
    String? profileId,
    String? key,
    String? valueJson,
    int? updatedAt,
  }) => AppSettingsTableData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    key: key ?? this.key,
    valueJson: valueJson ?? this.valueJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSettingsTableData copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, key, valueJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.key == this.key &&
          other.valueJson == this.valueJson &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> key;
  final Value<String> valueJson;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AppSettingsTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    required String id,
    required String profileId,
    required String key,
    required String valueJson,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       key = Value(key),
       valueJson = Value(valueJson),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingsTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? key,
    Value<String>? valueJson,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PermissionStatesTableTable extends PermissionStatesTable
    with TableInfo<$PermissionStatesTableTable, PermissionStatesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PermissionStatesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capabilityMeta = const VerificationMeta(
    'capability',
  );
  @override
  late final GeneratedColumn<String> capability = GeneratedColumn<String>(
    'capability',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _osStateMeta = const VerificationMeta(
    'osState',
  );
  @override
  late final GeneratedColumn<String> osState = GeneratedColumn<String>(
    'os_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptedAtMeta = const VerificationMeta(
    'promptedAt',
  );
  @override
  late final GeneratedColumn<int> promptedAt = GeneratedColumn<int>(
    'prompted_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _explanationSeenMeta = const VerificationMeta(
    'explanationSeen',
  );
  @override
  late final GeneratedColumn<bool> explanationSeen = GeneratedColumn<bool>(
    'explanation_seen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("explanation_seen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    capability,
    osState,
    promptedAt,
    updatedAt,
    explanationSeen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'permission_states_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PermissionStatesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('capability')) {
      context.handle(
        _capabilityMeta,
        capability.isAcceptableOrUnknown(data['capability']!, _capabilityMeta),
      );
    } else if (isInserting) {
      context.missing(_capabilityMeta);
    }
    if (data.containsKey('os_state')) {
      context.handle(
        _osStateMeta,
        osState.isAcceptableOrUnknown(data['os_state']!, _osStateMeta),
      );
    } else if (isInserting) {
      context.missing(_osStateMeta);
    }
    if (data.containsKey('prompted_at')) {
      context.handle(
        _promptedAtMeta,
        promptedAt.isAcceptableOrUnknown(data['prompted_at']!, _promptedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_promptedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('explanation_seen')) {
      context.handle(
        _explanationSeenMeta,
        explanationSeen.isAcceptableOrUnknown(
          data['explanation_seen']!,
          _explanationSeenMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PermissionStatesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PermissionStatesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      capability: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capability'],
      )!,
      osState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}os_state'],
      )!,
      promptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prompted_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      explanationSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}explanation_seen'],
      )!,
    );
  }

  @override
  $PermissionStatesTableTable createAlias(String alias) {
    return $PermissionStatesTableTable(attachedDatabase, alias);
  }
}

class PermissionStatesTableData extends DataClass
    implements Insertable<PermissionStatesTableData> {
  final String id;
  final String profileId;
  final String capability;
  final String osState;
  final int promptedAt;
  final int updatedAt;
  final bool explanationSeen;
  const PermissionStatesTableData({
    required this.id,
    required this.profileId,
    required this.capability,
    required this.osState,
    required this.promptedAt,
    required this.updatedAt,
    required this.explanationSeen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['capability'] = Variable<String>(capability);
    map['os_state'] = Variable<String>(osState);
    map['prompted_at'] = Variable<int>(promptedAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['explanation_seen'] = Variable<bool>(explanationSeen);
    return map;
  }

  PermissionStatesTableCompanion toCompanion(bool nullToAbsent) {
    return PermissionStatesTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      capability: Value(capability),
      osState: Value(osState),
      promptedAt: Value(promptedAt),
      updatedAt: Value(updatedAt),
      explanationSeen: Value(explanationSeen),
    );
  }

  factory PermissionStatesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PermissionStatesTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      capability: serializer.fromJson<String>(json['capability']),
      osState: serializer.fromJson<String>(json['osState']),
      promptedAt: serializer.fromJson<int>(json['promptedAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      explanationSeen: serializer.fromJson<bool>(json['explanationSeen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'capability': serializer.toJson<String>(capability),
      'osState': serializer.toJson<String>(osState),
      'promptedAt': serializer.toJson<int>(promptedAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'explanationSeen': serializer.toJson<bool>(explanationSeen),
    };
  }

  PermissionStatesTableData copyWith({
    String? id,
    String? profileId,
    String? capability,
    String? osState,
    int? promptedAt,
    int? updatedAt,
    bool? explanationSeen,
  }) => PermissionStatesTableData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    capability: capability ?? this.capability,
    osState: osState ?? this.osState,
    promptedAt: promptedAt ?? this.promptedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    explanationSeen: explanationSeen ?? this.explanationSeen,
  );
  PermissionStatesTableData copyWithCompanion(
    PermissionStatesTableCompanion data,
  ) {
    return PermissionStatesTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      capability: data.capability.present
          ? data.capability.value
          : this.capability,
      osState: data.osState.present ? data.osState.value : this.osState,
      promptedAt: data.promptedAt.present
          ? data.promptedAt.value
          : this.promptedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      explanationSeen: data.explanationSeen.present
          ? data.explanationSeen.value
          : this.explanationSeen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PermissionStatesTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('capability: $capability, ')
          ..write('osState: $osState, ')
          ..write('promptedAt: $promptedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('explanationSeen: $explanationSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    capability,
    osState,
    promptedAt,
    updatedAt,
    explanationSeen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PermissionStatesTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.capability == this.capability &&
          other.osState == this.osState &&
          other.promptedAt == this.promptedAt &&
          other.updatedAt == this.updatedAt &&
          other.explanationSeen == this.explanationSeen);
}

class PermissionStatesTableCompanion
    extends UpdateCompanion<PermissionStatesTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> capability;
  final Value<String> osState;
  final Value<int> promptedAt;
  final Value<int> updatedAt;
  final Value<bool> explanationSeen;
  final Value<int> rowid;
  const PermissionStatesTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.capability = const Value.absent(),
    this.osState = const Value.absent(),
    this.promptedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.explanationSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PermissionStatesTableCompanion.insert({
    required String id,
    required String profileId,
    required String capability,
    required String osState,
    required int promptedAt,
    required int updatedAt,
    this.explanationSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       capability = Value(capability),
       osState = Value(osState),
       promptedAt = Value(promptedAt),
       updatedAt = Value(updatedAt);
  static Insertable<PermissionStatesTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? capability,
    Expression<String>? osState,
    Expression<int>? promptedAt,
    Expression<int>? updatedAt,
    Expression<bool>? explanationSeen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (capability != null) 'capability': capability,
      if (osState != null) 'os_state': osState,
      if (promptedAt != null) 'prompted_at': promptedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (explanationSeen != null) 'explanation_seen': explanationSeen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PermissionStatesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? capability,
    Value<String>? osState,
    Value<int>? promptedAt,
    Value<int>? updatedAt,
    Value<bool>? explanationSeen,
    Value<int>? rowid,
  }) {
    return PermissionStatesTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      capability: capability ?? this.capability,
      osState: osState ?? this.osState,
      promptedAt: promptedAt ?? this.promptedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      explanationSeen: explanationSeen ?? this.explanationSeen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (capability.present) {
      map['capability'] = Variable<String>(capability.value);
    }
    if (osState.present) {
      map['os_state'] = Variable<String>(osState.value);
    }
    if (promptedAt.present) {
      map['prompted_at'] = Variable<int>(promptedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (explanationSeen.present) {
      map['explanation_seen'] = Variable<bool>(explanationSeen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PermissionStatesTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('capability: $capability, ')
          ..write('osState: $osState, ')
          ..write('promptedAt: $promptedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('explanationSeen: $explanationSeen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChangeOperationsTableTable extends ChangeOperationsTable
    with TableInfo<$ChangeOperationsTableTable, ChangeOperationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChangeOperationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
    'op_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseVersionMeta = const VerificationMeta(
    'baseVersion',
  );
  @override
  late final GeneratedColumn<int> baseVersion = GeneratedColumn<int>(
    'base_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldPathsJsonMeta = const VerificationMeta(
    'fieldPathsJson',
  );
  @override
  late final GeneratedColumn<String> fieldPathsJson = GeneratedColumn<String>(
    'field_paths_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_only'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    operationId,
    profileId,
    entityType,
    entityId,
    opType,
    baseVersion,
    payloadJson,
    fieldPathsJson,
    occurredAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'change_operations_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChangeOperationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(
        _opTypeMeta,
        opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('base_version')) {
      context.handle(
        _baseVersionMeta,
        baseVersion.isAcceptableOrUnknown(
          data['base_version']!,
          _baseVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseVersionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('field_paths_json')) {
      context.handle(
        _fieldPathsJsonMeta,
        fieldPathsJson.isAcceptableOrUnknown(
          data['field_paths_json']!,
          _fieldPathsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fieldPathsJsonMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  ChangeOperationsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChangeOperationsTableData(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      opType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_type'],
      )!,
      baseVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_version'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      fieldPathsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_paths_json'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $ChangeOperationsTableTable createAlias(String alias) {
    return $ChangeOperationsTableTable(attachedDatabase, alias);
  }
}

class ChangeOperationsTableData extends DataClass
    implements Insertable<ChangeOperationsTableData> {
  final String operationId;
  final String profileId;
  final String entityType;
  final String entityId;
  final String opType;
  final int baseVersion;
  final String payloadJson;
  final String fieldPathsJson;
  final int occurredAt;
  final String syncStatus;
  const ChangeOperationsTableData({
    required this.operationId,
    required this.profileId,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.baseVersion,
    required this.payloadJson,
    required this.fieldPathsJson,
    required this.occurredAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['profile_id'] = Variable<String>(profileId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['op_type'] = Variable<String>(opType);
    map['base_version'] = Variable<int>(baseVersion);
    map['payload_json'] = Variable<String>(payloadJson);
    map['field_paths_json'] = Variable<String>(fieldPathsJson);
    map['occurred_at'] = Variable<int>(occurredAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ChangeOperationsTableCompanion toCompanion(bool nullToAbsent) {
    return ChangeOperationsTableCompanion(
      operationId: Value(operationId),
      profileId: Value(profileId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      opType: Value(opType),
      baseVersion: Value(baseVersion),
      payloadJson: Value(payloadJson),
      fieldPathsJson: Value(fieldPathsJson),
      occurredAt: Value(occurredAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory ChangeOperationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChangeOperationsTableData(
      operationId: serializer.fromJson<String>(json['operationId']),
      profileId: serializer.fromJson<String>(json['profileId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      opType: serializer.fromJson<String>(json['opType']),
      baseVersion: serializer.fromJson<int>(json['baseVersion']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      fieldPathsJson: serializer.fromJson<String>(json['fieldPathsJson']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'profileId': serializer.toJson<String>(profileId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'opType': serializer.toJson<String>(opType),
      'baseVersion': serializer.toJson<int>(baseVersion),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'fieldPathsJson': serializer.toJson<String>(fieldPathsJson),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ChangeOperationsTableData copyWith({
    String? operationId,
    String? profileId,
    String? entityType,
    String? entityId,
    String? opType,
    int? baseVersion,
    String? payloadJson,
    String? fieldPathsJson,
    int? occurredAt,
    String? syncStatus,
  }) => ChangeOperationsTableData(
    operationId: operationId ?? this.operationId,
    profileId: profileId ?? this.profileId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    opType: opType ?? this.opType,
    baseVersion: baseVersion ?? this.baseVersion,
    payloadJson: payloadJson ?? this.payloadJson,
    fieldPathsJson: fieldPathsJson ?? this.fieldPathsJson,
    occurredAt: occurredAt ?? this.occurredAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  ChangeOperationsTableData copyWithCompanion(
    ChangeOperationsTableCompanion data,
  ) {
    return ChangeOperationsTableData(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      opType: data.opType.present ? data.opType.value : this.opType,
      baseVersion: data.baseVersion.present
          ? data.baseVersion.value
          : this.baseVersion,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      fieldPathsJson: data.fieldPathsJson.present
          ? data.fieldPathsJson.value
          : this.fieldPathsJson,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChangeOperationsTableData(')
          ..write('operationId: $operationId, ')
          ..write('profileId: $profileId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('opType: $opType, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fieldPathsJson: $fieldPathsJson, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    operationId,
    profileId,
    entityType,
    entityId,
    opType,
    baseVersion,
    payloadJson,
    fieldPathsJson,
    occurredAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChangeOperationsTableData &&
          other.operationId == this.operationId &&
          other.profileId == this.profileId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.opType == this.opType &&
          other.baseVersion == this.baseVersion &&
          other.payloadJson == this.payloadJson &&
          other.fieldPathsJson == this.fieldPathsJson &&
          other.occurredAt == this.occurredAt &&
          other.syncStatus == this.syncStatus);
}

class ChangeOperationsTableCompanion
    extends UpdateCompanion<ChangeOperationsTableData> {
  final Value<String> operationId;
  final Value<String> profileId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> opType;
  final Value<int> baseVersion;
  final Value<String> payloadJson;
  final Value<String> fieldPathsJson;
  final Value<int> occurredAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ChangeOperationsTableCompanion({
    this.operationId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.opType = const Value.absent(),
    this.baseVersion = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.fieldPathsJson = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChangeOperationsTableCompanion.insert({
    required String operationId,
    required String profileId,
    required String entityType,
    required String entityId,
    required String opType,
    required int baseVersion,
    required String payloadJson,
    required String fieldPathsJson,
    required int occurredAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       profileId = Value(profileId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       opType = Value(opType),
       baseVersion = Value(baseVersion),
       payloadJson = Value(payloadJson),
       fieldPathsJson = Value(fieldPathsJson),
       occurredAt = Value(occurredAt);
  static Insertable<ChangeOperationsTableData> custom({
    Expression<String>? operationId,
    Expression<String>? profileId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? opType,
    Expression<int>? baseVersion,
    Expression<String>? payloadJson,
    Expression<String>? fieldPathsJson,
    Expression<int>? occurredAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (profileId != null) 'profile_id': profileId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (opType != null) 'op_type': opType,
      if (baseVersion != null) 'base_version': baseVersion,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (fieldPathsJson != null) 'field_paths_json': fieldPathsJson,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChangeOperationsTableCompanion copyWith({
    Value<String>? operationId,
    Value<String>? profileId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? opType,
    Value<int>? baseVersion,
    Value<String>? payloadJson,
    Value<String>? fieldPathsJson,
    Value<int>? occurredAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return ChangeOperationsTableCompanion(
      operationId: operationId ?? this.operationId,
      profileId: profileId ?? this.profileId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      opType: opType ?? this.opType,
      baseVersion: baseVersion ?? this.baseVersion,
      payloadJson: payloadJson ?? this.payloadJson,
      fieldPathsJson: fieldPathsJson ?? this.fieldPathsJson,
      occurredAt: occurredAt ?? this.occurredAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (baseVersion.present) {
      map['base_version'] = Variable<int>(baseVersion.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (fieldPathsJson.present) {
      map['field_paths_json'] = Variable<String>(fieldPathsJson.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChangeOperationsTableCompanion(')
          ..write('operationId: $operationId, ')
          ..write('profileId: $profileId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('opType: $opType, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fieldPathsJson: $fieldPathsJson, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTableTable extends SyncCursorsTable
    with TableInfo<$SyncCursorsTableTable, SyncCursorsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSuccessAtMeta = const VerificationMeta(
    'lastSuccessAt',
  );
  @override
  late final GeneratedColumn<int> lastSuccessAt = GeneratedColumn<int>(
    'last_success_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    scope,
    cursor,
    lastSuccessAt,
    lastErrorCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursorsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    } else if (isInserting) {
      context.missing(_cursorMeta);
    }
    if (data.containsKey('last_success_at')) {
      context.handle(
        _lastSuccessAtMeta,
        lastSuccessAt.isAcceptableOrUnknown(
          data['last_success_at']!,
          _lastSuccessAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, scope};
  @override
  SyncCursorsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursorsTableData(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      )!,
      lastSuccessAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_success_at'],
      ),
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
    );
  }

  @override
  $SyncCursorsTableTable createAlias(String alias) {
    return $SyncCursorsTableTable(attachedDatabase, alias);
  }
}

class SyncCursorsTableData extends DataClass
    implements Insertable<SyncCursorsTableData> {
  final String profileId;
  final String scope;
  final String cursor;
  final int? lastSuccessAt;
  final String? lastErrorCode;
  const SyncCursorsTableData({
    required this.profileId,
    required this.scope,
    required this.cursor,
    this.lastSuccessAt,
    this.lastErrorCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['scope'] = Variable<String>(scope);
    map['cursor'] = Variable<String>(cursor);
    if (!nullToAbsent || lastSuccessAt != null) {
      map['last_success_at'] = Variable<int>(lastSuccessAt);
    }
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    return map;
  }

  SyncCursorsTableCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsTableCompanion(
      profileId: Value(profileId),
      scope: Value(scope),
      cursor: Value(cursor),
      lastSuccessAt: lastSuccessAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessAt),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
    );
  }

  factory SyncCursorsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursorsTableData(
      profileId: serializer.fromJson<String>(json['profileId']),
      scope: serializer.fromJson<String>(json['scope']),
      cursor: serializer.fromJson<String>(json['cursor']),
      lastSuccessAt: serializer.fromJson<int?>(json['lastSuccessAt']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'scope': serializer.toJson<String>(scope),
      'cursor': serializer.toJson<String>(cursor),
      'lastSuccessAt': serializer.toJson<int?>(lastSuccessAt),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
    };
  }

  SyncCursorsTableData copyWith({
    String? profileId,
    String? scope,
    String? cursor,
    Value<int?> lastSuccessAt = const Value.absent(),
    Value<String?> lastErrorCode = const Value.absent(),
  }) => SyncCursorsTableData(
    profileId: profileId ?? this.profileId,
    scope: scope ?? this.scope,
    cursor: cursor ?? this.cursor,
    lastSuccessAt: lastSuccessAt.present
        ? lastSuccessAt.value
        : this.lastSuccessAt,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
  );
  SyncCursorsTableData copyWithCompanion(SyncCursorsTableCompanion data) {
    return SyncCursorsTableData(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      scope: data.scope.present ? data.scope.value : this.scope,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      lastSuccessAt: data.lastSuccessAt.present
          ? data.lastSuccessAt.value
          : this.lastSuccessAt,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsTableData(')
          ..write('profileId: $profileId, ')
          ..write('scope: $scope, ')
          ..write('cursor: $cursor, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastErrorCode: $lastErrorCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(profileId, scope, cursor, lastSuccessAt, lastErrorCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorsTableData &&
          other.profileId == this.profileId &&
          other.scope == this.scope &&
          other.cursor == this.cursor &&
          other.lastSuccessAt == this.lastSuccessAt &&
          other.lastErrorCode == this.lastErrorCode);
}

class SyncCursorsTableCompanion extends UpdateCompanion<SyncCursorsTableData> {
  final Value<String> profileId;
  final Value<String> scope;
  final Value<String> cursor;
  final Value<int?> lastSuccessAt;
  final Value<String?> lastErrorCode;
  final Value<int> rowid;
  const SyncCursorsTableCompanion({
    this.profileId = const Value.absent(),
    this.scope = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsTableCompanion.insert({
    required String profileId,
    required String scope,
    required String cursor,
    this.lastSuccessAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       scope = Value(scope),
       cursor = Value(cursor);
  static Insertable<SyncCursorsTableData> custom({
    Expression<String>? profileId,
    Expression<String>? scope,
    Expression<String>? cursor,
    Expression<int>? lastSuccessAt,
    Expression<String>? lastErrorCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (scope != null) 'scope': scope,
      if (cursor != null) 'cursor': cursor,
      if (lastSuccessAt != null) 'last_success_at': lastSuccessAt,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsTableCompanion copyWith({
    Value<String>? profileId,
    Value<String>? scope,
    Value<String>? cursor,
    Value<int?>? lastSuccessAt,
    Value<String?>? lastErrorCode,
    Value<int>? rowid,
  }) {
    return SyncCursorsTableCompanion(
      profileId: profileId ?? this.profileId,
      scope: scope ?? this.scope,
      cursor: cursor ?? this.cursor,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (lastSuccessAt.present) {
      map['last_success_at'] = Variable<int>(lastSuccessAt.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsTableCompanion(')
          ..write('profileId: $profileId, ')
          ..write('scope: $scope, ')
          ..write('cursor: $cursor, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodLogEntriesTableTable extends FoodLogEntriesTable
    with TableInfo<$FoodLogEntriesTableTable, FoodLogEntriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodLogEntriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
  );
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealSlotMeta = const VerificationMeta(
    'mealSlot',
  );
  @override
  late final GeneratedColumn<String> mealSlot = GeneratedColumn<String>(
    'meal_slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('snack'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('scan'),
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _portionMultiplierMeta = const VerificationMeta(
    'portionMultiplier',
  );
  @override
  late final GeneratedColumn<double> portionMultiplier =
      GeneratedColumn<double>(
        'portion_multiplier',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1.0),
      );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<double> carbsG = GeneratedColumn<double>(
    'carbs_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _fiberGMeta = const VerificationMeta('fiberG');
  @override
  late final GeneratedColumn<double> fiberG = GeneratedColumn<double>(
    'fiber_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sugarGMeta = const VerificationMeta('sugarG');
  @override
  late final GeneratedColumn<double> sugarG = GeneratedColumn<double>(
    'sugar_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sodiumMgMeta = const VerificationMeta(
    'sodiumMg',
  );
  @override
  late final GeneratedColumn<double> sodiumMg = GeneratedColumn<double>(
    'sodium_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _analysisJsonMeta = const VerificationMeta(
    'analysisJson',
  );
  @override
  late final GeneratedColumn<String> analysisJson = GeneratedColumn<String>(
    'analysis_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<int> loggedAt = GeneratedColumn<int>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    dayKey,
    mealSlot,
    title,
    source,
    recipeId,
    imagePath,
    portionMultiplier,
    calories,
    proteinG,
    carbsG,
    fatG,
    fiberG,
    sugarG,
    sodiumMg,
    analysisJson,
    loggedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_log_entries_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodLogEntriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('meal_slot')) {
      context.handle(
        _mealSlotMeta,
        mealSlot.isAcceptableOrUnknown(data['meal_slot']!, _mealSlotMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('portion_multiplier')) {
      context.handle(
        _portionMultiplierMeta,
        portionMultiplier.isAcceptableOrUnknown(
          data['portion_multiplier']!,
          _portionMultiplierMeta,
        ),
      );
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    }
    if (data.containsKey('carbs_g')) {
      context.handle(
        _carbsGMeta,
        carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta),
      );
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
    }
    if (data.containsKey('fiber_g')) {
      context.handle(
        _fiberGMeta,
        fiberG.isAcceptableOrUnknown(data['fiber_g']!, _fiberGMeta),
      );
    }
    if (data.containsKey('sugar_g')) {
      context.handle(
        _sugarGMeta,
        sugarG.isAcceptableOrUnknown(data['sugar_g']!, _sugarGMeta),
      );
    }
    if (data.containsKey('sodium_mg')) {
      context.handle(
        _sodiumMgMeta,
        sodiumMg.isAcceptableOrUnknown(data['sodium_mg']!, _sodiumMgMeta),
      );
    }
    if (data.containsKey('analysis_json')) {
      context.handle(
        _analysisJsonMeta,
        analysisJson.isAcceptableOrUnknown(
          data['analysis_json']!,
          _analysisJsonMeta,
        ),
      );
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodLogEntriesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodLogEntriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      )!,
      mealSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_slot'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      portionMultiplier: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}portion_multiplier'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      )!,
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g'],
      )!,
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      )!,
      fiberG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber_g'],
      )!,
      sugarG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugar_g'],
      )!,
      sodiumMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium_mg'],
      )!,
      analysisJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_json'],
      )!,
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}logged_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FoodLogEntriesTableTable createAlias(String alias) {
    return $FoodLogEntriesTableTable(attachedDatabase, alias);
  }
}

class FoodLogEntriesTableData extends DataClass
    implements Insertable<FoodLogEntriesTableData> {
  final String id;
  final String profileId;

  /// Local calendar day the food was eaten, `YYYY-MM-DD`.
  final String dayKey;
  final String mealSlot;
  final String title;
  final String source;
  final String? recipeId;
  final String? imagePath;
  final double portionMultiplier;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final double sodiumMg;

  /// Snapshot of the analysis the entry was created from (FoodAnalysis JSON).
  final String analysisJson;
  final int loggedAt;
  final int createdAt;
  const FoodLogEntriesTableData({
    required this.id,
    required this.profileId,
    required this.dayKey,
    required this.mealSlot,
    required this.title,
    required this.source,
    this.recipeId,
    this.imagePath,
    required this.portionMultiplier,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.sugarG,
    required this.sodiumMg,
    required this.analysisJson,
    required this.loggedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['day_key'] = Variable<String>(dayKey);
    map['meal_slot'] = Variable<String>(mealSlot);
    map['title'] = Variable<String>(title);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || recipeId != null) {
      map['recipe_id'] = Variable<String>(recipeId);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['portion_multiplier'] = Variable<double>(portionMultiplier);
    map['calories'] = Variable<double>(calories);
    map['protein_g'] = Variable<double>(proteinG);
    map['carbs_g'] = Variable<double>(carbsG);
    map['fat_g'] = Variable<double>(fatG);
    map['fiber_g'] = Variable<double>(fiberG);
    map['sugar_g'] = Variable<double>(sugarG);
    map['sodium_mg'] = Variable<double>(sodiumMg);
    map['analysis_json'] = Variable<String>(analysisJson);
    map['logged_at'] = Variable<int>(loggedAt);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  FoodLogEntriesTableCompanion toCompanion(bool nullToAbsent) {
    return FoodLogEntriesTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      dayKey: Value(dayKey),
      mealSlot: Value(mealSlot),
      title: Value(title),
      source: Value(source),
      recipeId: recipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeId),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      portionMultiplier: Value(portionMultiplier),
      calories: Value(calories),
      proteinG: Value(proteinG),
      carbsG: Value(carbsG),
      fatG: Value(fatG),
      fiberG: Value(fiberG),
      sugarG: Value(sugarG),
      sodiumMg: Value(sodiumMg),
      analysisJson: Value(analysisJson),
      loggedAt: Value(loggedAt),
      createdAt: Value(createdAt),
    );
  }

  factory FoodLogEntriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodLogEntriesTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      mealSlot: serializer.fromJson<String>(json['mealSlot']),
      title: serializer.fromJson<String>(json['title']),
      source: serializer.fromJson<String>(json['source']),
      recipeId: serializer.fromJson<String?>(json['recipeId']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      portionMultiplier: serializer.fromJson<double>(json['portionMultiplier']),
      calories: serializer.fromJson<double>(json['calories']),
      proteinG: serializer.fromJson<double>(json['proteinG']),
      carbsG: serializer.fromJson<double>(json['carbsG']),
      fatG: serializer.fromJson<double>(json['fatG']),
      fiberG: serializer.fromJson<double>(json['fiberG']),
      sugarG: serializer.fromJson<double>(json['sugarG']),
      sodiumMg: serializer.fromJson<double>(json['sodiumMg']),
      analysisJson: serializer.fromJson<String>(json['analysisJson']),
      loggedAt: serializer.fromJson<int>(json['loggedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'dayKey': serializer.toJson<String>(dayKey),
      'mealSlot': serializer.toJson<String>(mealSlot),
      'title': serializer.toJson<String>(title),
      'source': serializer.toJson<String>(source),
      'recipeId': serializer.toJson<String?>(recipeId),
      'imagePath': serializer.toJson<String?>(imagePath),
      'portionMultiplier': serializer.toJson<double>(portionMultiplier),
      'calories': serializer.toJson<double>(calories),
      'proteinG': serializer.toJson<double>(proteinG),
      'carbsG': serializer.toJson<double>(carbsG),
      'fatG': serializer.toJson<double>(fatG),
      'fiberG': serializer.toJson<double>(fiberG),
      'sugarG': serializer.toJson<double>(sugarG),
      'sodiumMg': serializer.toJson<double>(sodiumMg),
      'analysisJson': serializer.toJson<String>(analysisJson),
      'loggedAt': serializer.toJson<int>(loggedAt),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  FoodLogEntriesTableData copyWith({
    String? id,
    String? profileId,
    String? dayKey,
    String? mealSlot,
    String? title,
    String? source,
    Value<String?> recipeId = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
    double? portionMultiplier,
    double? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? fiberG,
    double? sugarG,
    double? sodiumMg,
    String? analysisJson,
    int? loggedAt,
    int? createdAt,
  }) => FoodLogEntriesTableData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    dayKey: dayKey ?? this.dayKey,
    mealSlot: mealSlot ?? this.mealSlot,
    title: title ?? this.title,
    source: source ?? this.source,
    recipeId: recipeId.present ? recipeId.value : this.recipeId,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    portionMultiplier: portionMultiplier ?? this.portionMultiplier,
    calories: calories ?? this.calories,
    proteinG: proteinG ?? this.proteinG,
    carbsG: carbsG ?? this.carbsG,
    fatG: fatG ?? this.fatG,
    fiberG: fiberG ?? this.fiberG,
    sugarG: sugarG ?? this.sugarG,
    sodiumMg: sodiumMg ?? this.sodiumMg,
    analysisJson: analysisJson ?? this.analysisJson,
    loggedAt: loggedAt ?? this.loggedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  FoodLogEntriesTableData copyWithCompanion(FoodLogEntriesTableCompanion data) {
    return FoodLogEntriesTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      mealSlot: data.mealSlot.present ? data.mealSlot.value : this.mealSlot,
      title: data.title.present ? data.title.value : this.title,
      source: data.source.present ? data.source.value : this.source,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      portionMultiplier: data.portionMultiplier.present
          ? data.portionMultiplier.value
          : this.portionMultiplier,
      calories: data.calories.present ? data.calories.value : this.calories,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      fiberG: data.fiberG.present ? data.fiberG.value : this.fiberG,
      sugarG: data.sugarG.present ? data.sugarG.value : this.sugarG,
      sodiumMg: data.sodiumMg.present ? data.sodiumMg.value : this.sodiumMg,
      analysisJson: data.analysisJson.present
          ? data.analysisJson.value
          : this.analysisJson,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodLogEntriesTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('dayKey: $dayKey, ')
          ..write('mealSlot: $mealSlot, ')
          ..write('title: $title, ')
          ..write('source: $source, ')
          ..write('recipeId: $recipeId, ')
          ..write('imagePath: $imagePath, ')
          ..write('portionMultiplier: $portionMultiplier, ')
          ..write('calories: $calories, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('fiberG: $fiberG, ')
          ..write('sugarG: $sugarG, ')
          ..write('sodiumMg: $sodiumMg, ')
          ..write('analysisJson: $analysisJson, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    dayKey,
    mealSlot,
    title,
    source,
    recipeId,
    imagePath,
    portionMultiplier,
    calories,
    proteinG,
    carbsG,
    fatG,
    fiberG,
    sugarG,
    sodiumMg,
    analysisJson,
    loggedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodLogEntriesTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.dayKey == this.dayKey &&
          other.mealSlot == this.mealSlot &&
          other.title == this.title &&
          other.source == this.source &&
          other.recipeId == this.recipeId &&
          other.imagePath == this.imagePath &&
          other.portionMultiplier == this.portionMultiplier &&
          other.calories == this.calories &&
          other.proteinG == this.proteinG &&
          other.carbsG == this.carbsG &&
          other.fatG == this.fatG &&
          other.fiberG == this.fiberG &&
          other.sugarG == this.sugarG &&
          other.sodiumMg == this.sodiumMg &&
          other.analysisJson == this.analysisJson &&
          other.loggedAt == this.loggedAt &&
          other.createdAt == this.createdAt);
}

class FoodLogEntriesTableCompanion
    extends UpdateCompanion<FoodLogEntriesTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> dayKey;
  final Value<String> mealSlot;
  final Value<String> title;
  final Value<String> source;
  final Value<String?> recipeId;
  final Value<String?> imagePath;
  final Value<double> portionMultiplier;
  final Value<double> calories;
  final Value<double> proteinG;
  final Value<double> carbsG;
  final Value<double> fatG;
  final Value<double> fiberG;
  final Value<double> sugarG;
  final Value<double> sodiumMg;
  final Value<String> analysisJson;
  final Value<int> loggedAt;
  final Value<int> createdAt;
  final Value<int> rowid;
  const FoodLogEntriesTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.mealSlot = const Value.absent(),
    this.title = const Value.absent(),
    this.source = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.portionMultiplier = const Value.absent(),
    this.calories = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.fiberG = const Value.absent(),
    this.sugarG = const Value.absent(),
    this.sodiumMg = const Value.absent(),
    this.analysisJson = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodLogEntriesTableCompanion.insert({
    required String id,
    this.profileId = const Value.absent(),
    required String dayKey,
    this.mealSlot = const Value.absent(),
    required String title,
    this.source = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.portionMultiplier = const Value.absent(),
    this.calories = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.fiberG = const Value.absent(),
    this.sugarG = const Value.absent(),
    this.sodiumMg = const Value.absent(),
    this.analysisJson = const Value.absent(),
    required int loggedAt,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dayKey = Value(dayKey),
       title = Value(title),
       loggedAt = Value(loggedAt),
       createdAt = Value(createdAt);
  static Insertable<FoodLogEntriesTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? dayKey,
    Expression<String>? mealSlot,
    Expression<String>? title,
    Expression<String>? source,
    Expression<String>? recipeId,
    Expression<String>? imagePath,
    Expression<double>? portionMultiplier,
    Expression<double>? calories,
    Expression<double>? proteinG,
    Expression<double>? carbsG,
    Expression<double>? fatG,
    Expression<double>? fiberG,
    Expression<double>? sugarG,
    Expression<double>? sodiumMg,
    Expression<String>? analysisJson,
    Expression<int>? loggedAt,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (dayKey != null) 'day_key': dayKey,
      if (mealSlot != null) 'meal_slot': mealSlot,
      if (title != null) 'title': title,
      if (source != null) 'source': source,
      if (recipeId != null) 'recipe_id': recipeId,
      if (imagePath != null) 'image_path': imagePath,
      if (portionMultiplier != null) 'portion_multiplier': portionMultiplier,
      if (calories != null) 'calories': calories,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (fatG != null) 'fat_g': fatG,
      if (fiberG != null) 'fiber_g': fiberG,
      if (sugarG != null) 'sugar_g': sugarG,
      if (sodiumMg != null) 'sodium_mg': sodiumMg,
      if (analysisJson != null) 'analysis_json': analysisJson,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodLogEntriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? dayKey,
    Value<String>? mealSlot,
    Value<String>? title,
    Value<String>? source,
    Value<String?>? recipeId,
    Value<String?>? imagePath,
    Value<double>? portionMultiplier,
    Value<double>? calories,
    Value<double>? proteinG,
    Value<double>? carbsG,
    Value<double>? fatG,
    Value<double>? fiberG,
    Value<double>? sugarG,
    Value<double>? sodiumMg,
    Value<String>? analysisJson,
    Value<int>? loggedAt,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return FoodLogEntriesTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      dayKey: dayKey ?? this.dayKey,
      mealSlot: mealSlot ?? this.mealSlot,
      title: title ?? this.title,
      source: source ?? this.source,
      recipeId: recipeId ?? this.recipeId,
      imagePath: imagePath ?? this.imagePath,
      portionMultiplier: portionMultiplier ?? this.portionMultiplier,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      fiberG: fiberG ?? this.fiberG,
      sugarG: sugarG ?? this.sugarG,
      sodiumMg: sodiumMg ?? this.sodiumMg,
      analysisJson: analysisJson ?? this.analysisJson,
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (mealSlot.present) {
      map['meal_slot'] = Variable<String>(mealSlot.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (portionMultiplier.present) {
      map['portion_multiplier'] = Variable<double>(portionMultiplier.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<double>(carbsG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
    }
    if (fiberG.present) {
      map['fiber_g'] = Variable<double>(fiberG.value);
    }
    if (sugarG.present) {
      map['sugar_g'] = Variable<double>(sugarG.value);
    }
    if (sodiumMg.present) {
      map['sodium_mg'] = Variable<double>(sodiumMg.value);
    }
    if (analysisJson.present) {
      map['analysis_json'] = Variable<String>(analysisJson.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<int>(loggedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodLogEntriesTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('dayKey: $dayKey, ')
          ..write('mealSlot: $mealSlot, ')
          ..write('title: $title, ')
          ..write('source: $source, ')
          ..write('recipeId: $recipeId, ')
          ..write('imagePath: $imagePath, ')
          ..write('portionMultiplier: $portionMultiplier, ')
          ..write('calories: $calories, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('fiberG: $fiberG, ')
          ..write('sugarG: $sugarG, ')
          ..write('sodiumMg: $sodiumMg, ')
          ..write('analysisJson: $analysisJson, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTableTable profilesTable = $ProfilesTableTable(this);
  late final $RecipesTableTable recipesTable = $RecipesTableTable(this);
  late final $RecipeVersionsTableTable recipeVersionsTable =
      $RecipeVersionsTableTable(this);
  late final $RecipeNotesTableTable recipeNotesTable = $RecipeNotesTableTable(
    this,
  );
  late final $IngredientsCatalogTableTable ingredientsCatalogTable =
      $IngredientsCatalogTableTable(this);
  late final $UnitsCatalogTableTable unitsCatalogTable =
      $UnitsCatalogTableTable(this);
  late final $RecipeIngredientsTableTable recipeIngredientsTable =
      $RecipeIngredientsTableTable(this);
  late final $RecipeStepsTableTable recipeStepsTable = $RecipeStepsTableTable(
    this,
  );
  late final $StepTimersTableTable stepTimersTable = $StepTimersTableTable(
    this,
  );
  late final $ToolsCatalogTableTable toolsCatalogTable =
      $ToolsCatalogTableTable(this);
  late final $RecipeToolsTableTable recipeToolsTable = $RecipeToolsTableTable(
    this,
  );
  late final $LabelsTableTable labelsTable = $LabelsTableTable(this);
  late final $RecipeLabelsTableTable recipeLabelsTable =
      $RecipeLabelsTableTable(this);
  late final $RecipeMediaTableTable recipeMediaTable = $RecipeMediaTableTable(
    this,
  );
  late final $CollectionsTableTable collectionsTable = $CollectionsTableTable(
    this,
  );
  late final $CollectionRecipesTableTable collectionRecipesTable =
      $CollectionRecipesTableTable(this);
  late final $FavoritesTableTable favoritesTable = $FavoritesTableTable(this);
  late final $CookingSessionsTableTable cookingSessionsTable =
      $CookingSessionsTableTable(this);
  late final $SessionIngredientChecksTableTable sessionIngredientChecksTable =
      $SessionIngredientChecksTableTable(this);
  late final $SessionTimersTableTable sessionTimersTable =
      $SessionTimersTableTable(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  late final $PermissionStatesTableTable permissionStatesTable =
      $PermissionStatesTableTable(this);
  late final $ChangeOperationsTableTable changeOperationsTable =
      $ChangeOperationsTableTable(this);
  late final $SyncCursorsTableTable syncCursorsTable = $SyncCursorsTableTable(
    this,
  );
  late final $FoodLogEntriesTableTable foodLogEntriesTable =
      $FoodLogEntriesTableTable(this);
  late final Index foodLogByDay = Index(
    'food_log_by_day',
    'CREATE INDEX food_log_by_day ON food_log_entries_table (profile_id, day_key)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profilesTable,
    recipesTable,
    recipeVersionsTable,
    recipeNotesTable,
    ingredientsCatalogTable,
    unitsCatalogTable,
    recipeIngredientsTable,
    recipeStepsTable,
    stepTimersTable,
    toolsCatalogTable,
    recipeToolsTable,
    labelsTable,
    recipeLabelsTable,
    recipeMediaTable,
    collectionsTable,
    collectionRecipesTable,
    favoritesTable,
    cookingSessionsTable,
    sessionIngredientChecksTable,
    sessionTimersTable,
    appSettingsTable,
    permissionStatesTable,
    changeOperationsTable,
    syncCursorsTable,
    foodLogEntriesTable,
    foodLogByDay,
  ];
}

typedef $$ProfilesTableTableCreateCompanionBuilder =
    ProfilesTableCompanion Function({
      required String id,
      Value<String> displayName,
      Value<String> locale,
      Value<String> unitSystem,
      Value<int> settingsVersion,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$ProfilesTableTableUpdateCompanionBuilder =
    ProfilesTableCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String> locale,
      Value<String> unitSystem,
      Value<int> settingsVersion,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$ProfilesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTableTable> {
  $$ProfilesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get settingsVersion => $composableBuilder(
    column: $table.settingsVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTableTable> {
  $$ProfilesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get settingsVersion => $composableBuilder(
    column: $table.settingsVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTableTable> {
  $$ProfilesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => column,
  );

  GeneratedColumn<int> get settingsVersion => $composableBuilder(
    column: $table.settingsVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfilesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTableTable,
          ProfilesTableData,
          $$ProfilesTableTableFilterComposer,
          $$ProfilesTableTableOrderingComposer,
          $$ProfilesTableTableAnnotationComposer,
          $$ProfilesTableTableCreateCompanionBuilder,
          $$ProfilesTableTableUpdateCompanionBuilder,
          (
            ProfilesTableData,
            BaseReferences<
              _$AppDatabase,
              $ProfilesTableTable,
              ProfilesTableData
            >,
          ),
          ProfilesTableData,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableTableManager(_$AppDatabase db, $ProfilesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> unitSystem = const Value.absent(),
                Value<int> settingsVersion = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesTableCompanion(
                id: id,
                displayName: displayName,
                locale: locale,
                unitSystem: unitSystem,
                settingsVersion: settingsVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> displayName = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> unitSystem = const Value.absent(),
                Value<int> settingsVersion = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProfilesTableCompanion.insert(
                id: id,
                displayName: displayName,
                locale: locale,
                unitSystem: unitSystem,
                settingsVersion: settingsVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTableTable,
      ProfilesTableData,
      $$ProfilesTableTableFilterComposer,
      $$ProfilesTableTableOrderingComposer,
      $$ProfilesTableTableAnnotationComposer,
      $$ProfilesTableTableCreateCompanionBuilder,
      $$ProfilesTableTableUpdateCompanionBuilder,
      (
        ProfilesTableData,
        BaseReferences<_$AppDatabase, $ProfilesTableTable, ProfilesTableData>,
      ),
      ProfilesTableData,
      PrefetchHooks Function()
    >;
typedef $$RecipesTableTableCreateCompanionBuilder =
    RecipesTableCompanion Function({
      required String id,
      required String profileId,
      Value<String?> currentVersionId,
      required String title,
      Value<String?> slug,
      Value<String?> summary,
      Value<String> status,
      Value<int> baseServingsNum,
      Value<int> baseServingsDen,
      Value<String> difficulty,
      Value<int> totalMinutes,
      Value<String?> coverMediaId,
      Value<String?> visualTemplate,
      Value<String> visualStyleVersion,
      Value<bool> isCurated,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int> version,
      Value<String> origin,
      Value<String> provenanceJson,
      Value<int> rowid,
    });
typedef $$RecipesTableTableUpdateCompanionBuilder =
    RecipesTableCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String?> currentVersionId,
      Value<String> title,
      Value<String?> slug,
      Value<String?> summary,
      Value<String> status,
      Value<int> baseServingsNum,
      Value<int> baseServingsDen,
      Value<String> difficulty,
      Value<int> totalMinutes,
      Value<String?> coverMediaId,
      Value<String?> visualTemplate,
      Value<String> visualStyleVersion,
      Value<bool> isCurated,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> version,
      Value<String> origin,
      Value<String> provenanceJson,
      Value<int> rowid,
    });

class $$RecipesTableTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTableTable> {
  $$RecipesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentVersionId => $composableBuilder(
    column: $table.currentVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseServingsNum => $composableBuilder(
    column: $table.baseServingsNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseServingsDen => $composableBuilder(
    column: $table.baseServingsDen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMinutes => $composableBuilder(
    column: $table.totalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverMediaId => $composableBuilder(
    column: $table.coverMediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visualTemplate => $composableBuilder(
    column: $table.visualTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visualStyleVersion => $composableBuilder(
    column: $table.visualStyleVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCurated => $composableBuilder(
    column: $table.isCurated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provenanceJson => $composableBuilder(
    column: $table.provenanceJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTableTable> {
  $$RecipesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentVersionId => $composableBuilder(
    column: $table.currentVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseServingsNum => $composableBuilder(
    column: $table.baseServingsNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseServingsDen => $composableBuilder(
    column: $table.baseServingsDen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMinutes => $composableBuilder(
    column: $table.totalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverMediaId => $composableBuilder(
    column: $table.coverMediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visualTemplate => $composableBuilder(
    column: $table.visualTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visualStyleVersion => $composableBuilder(
    column: $table.visualStyleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCurated => $composableBuilder(
    column: $table.isCurated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provenanceJson => $composableBuilder(
    column: $table.provenanceJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTableTable> {
  $$RecipesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get currentVersionId => $composableBuilder(
    column: $table.currentVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get baseServingsNum => $composableBuilder(
    column: $table.baseServingsNum,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseServingsDen => $composableBuilder(
    column: $table.baseServingsDen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalMinutes => $composableBuilder(
    column: $table.totalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverMediaId => $composableBuilder(
    column: $table.coverMediaId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get visualTemplate => $composableBuilder(
    column: $table.visualTemplate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get visualStyleVersion => $composableBuilder(
    column: $table.visualStyleVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCurated =>
      $composableBuilder(column: $table.isCurated, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get provenanceJson => $composableBuilder(
    column: $table.provenanceJson,
    builder: (column) => column,
  );
}

class $$RecipesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTableTable,
          RecipesTableData,
          $$RecipesTableTableFilterComposer,
          $$RecipesTableTableOrderingComposer,
          $$RecipesTableTableAnnotationComposer,
          $$RecipesTableTableCreateCompanionBuilder,
          $$RecipesTableTableUpdateCompanionBuilder,
          (
            RecipesTableData,
            BaseReferences<_$AppDatabase, $RecipesTableTable, RecipesTableData>,
          ),
          RecipesTableData,
          PrefetchHooks Function()
        > {
  $$RecipesTableTableTableManager(_$AppDatabase db, $RecipesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String?> currentVersionId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> slug = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> baseServingsNum = const Value.absent(),
                Value<int> baseServingsDen = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<int> totalMinutes = const Value.absent(),
                Value<String?> coverMediaId = const Value.absent(),
                Value<String?> visualTemplate = const Value.absent(),
                Value<String> visualStyleVersion = const Value.absent(),
                Value<bool> isCurated = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> provenanceJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesTableCompanion(
                id: id,
                profileId: profileId,
                currentVersionId: currentVersionId,
                title: title,
                slug: slug,
                summary: summary,
                status: status,
                baseServingsNum: baseServingsNum,
                baseServingsDen: baseServingsDen,
                difficulty: difficulty,
                totalMinutes: totalMinutes,
                coverMediaId: coverMediaId,
                visualTemplate: visualTemplate,
                visualStyleVersion: visualStyleVersion,
                isCurated: isCurated,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                origin: origin,
                provenanceJson: provenanceJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                Value<String?> currentVersionId = const Value.absent(),
                required String title,
                Value<String?> slug = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> baseServingsNum = const Value.absent(),
                Value<int> baseServingsDen = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<int> totalMinutes = const Value.absent(),
                Value<String?> coverMediaId = const Value.absent(),
                Value<String?> visualTemplate = const Value.absent(),
                Value<String> visualStyleVersion = const Value.absent(),
                Value<bool> isCurated = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> provenanceJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesTableCompanion.insert(
                id: id,
                profileId: profileId,
                currentVersionId: currentVersionId,
                title: title,
                slug: slug,
                summary: summary,
                status: status,
                baseServingsNum: baseServingsNum,
                baseServingsDen: baseServingsDen,
                difficulty: difficulty,
                totalMinutes: totalMinutes,
                coverMediaId: coverMediaId,
                visualTemplate: visualTemplate,
                visualStyleVersion: visualStyleVersion,
                isCurated: isCurated,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                origin: origin,
                provenanceJson: provenanceJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTableTable,
      RecipesTableData,
      $$RecipesTableTableFilterComposer,
      $$RecipesTableTableOrderingComposer,
      $$RecipesTableTableAnnotationComposer,
      $$RecipesTableTableCreateCompanionBuilder,
      $$RecipesTableTableUpdateCompanionBuilder,
      (
        RecipesTableData,
        BaseReferences<_$AppDatabase, $RecipesTableTable, RecipesTableData>,
      ),
      RecipesTableData,
      PrefetchHooks Function()
    >;
typedef $$RecipeVersionsTableTableCreateCompanionBuilder =
    RecipeVersionsTableCompanion Function({
      required String id,
      required String recipeId,
      required int sequence,
      required String snapshotJson,
      Value<String?> changeSummary,
      Value<String> authorKind,
      Value<String?> parentVersionId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$RecipeVersionsTableTableUpdateCompanionBuilder =
    RecipeVersionsTableCompanion Function({
      Value<String> id,
      Value<String> recipeId,
      Value<int> sequence,
      Value<String> snapshotJson,
      Value<String?> changeSummary,
      Value<String> authorKind,
      Value<String?> parentVersionId,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$RecipeVersionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeVersionsTableTable> {
  $$RecipeVersionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changeSummary => $composableBuilder(
    column: $table.changeSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorKind => $composableBuilder(
    column: $table.authorKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentVersionId => $composableBuilder(
    column: $table.parentVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipeVersionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeVersionsTableTable> {
  $$RecipeVersionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changeSummary => $composableBuilder(
    column: $table.changeSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorKind => $composableBuilder(
    column: $table.authorKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentVersionId => $composableBuilder(
    column: $table.parentVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipeVersionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeVersionsTableTable> {
  $$RecipeVersionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get changeSummary => $composableBuilder(
    column: $table.changeSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorKind => $composableBuilder(
    column: $table.authorKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentVersionId => $composableBuilder(
    column: $table.parentVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RecipeVersionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeVersionsTableTable,
          RecipeVersionsTableData,
          $$RecipeVersionsTableTableFilterComposer,
          $$RecipeVersionsTableTableOrderingComposer,
          $$RecipeVersionsTableTableAnnotationComposer,
          $$RecipeVersionsTableTableCreateCompanionBuilder,
          $$RecipeVersionsTableTableUpdateCompanionBuilder,
          (
            RecipeVersionsTableData,
            BaseReferences<
              _$AppDatabase,
              $RecipeVersionsTableTable,
              RecipeVersionsTableData
            >,
          ),
          RecipeVersionsTableData,
          PrefetchHooks Function()
        > {
  $$RecipeVersionsTableTableTableManager(
    _$AppDatabase db,
    $RecipeVersionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeVersionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeVersionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecipeVersionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> snapshotJson = const Value.absent(),
                Value<String?> changeSummary = const Value.absent(),
                Value<String> authorKind = const Value.absent(),
                Value<String?> parentVersionId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeVersionsTableCompanion(
                id: id,
                recipeId: recipeId,
                sequence: sequence,
                snapshotJson: snapshotJson,
                changeSummary: changeSummary,
                authorKind: authorKind,
                parentVersionId: parentVersionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recipeId,
                required int sequence,
                required String snapshotJson,
                Value<String?> changeSummary = const Value.absent(),
                Value<String> authorKind = const Value.absent(),
                Value<String?> parentVersionId = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RecipeVersionsTableCompanion.insert(
                id: id,
                recipeId: recipeId,
                sequence: sequence,
                snapshotJson: snapshotJson,
                changeSummary: changeSummary,
                authorKind: authorKind,
                parentVersionId: parentVersionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipeVersionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeVersionsTableTable,
      RecipeVersionsTableData,
      $$RecipeVersionsTableTableFilterComposer,
      $$RecipeVersionsTableTableOrderingComposer,
      $$RecipeVersionsTableTableAnnotationComposer,
      $$RecipeVersionsTableTableCreateCompanionBuilder,
      $$RecipeVersionsTableTableUpdateCompanionBuilder,
      (
        RecipeVersionsTableData,
        BaseReferences<
          _$AppDatabase,
          $RecipeVersionsTableTable,
          RecipeVersionsTableData
        >,
      ),
      RecipeVersionsTableData,
      PrefetchHooks Function()
    >;
typedef $$RecipeNotesTableTableCreateCompanionBuilder =
    RecipeNotesTableCompanion Function({
      required String id,
      required String recipeId,
      required String body,
      Value<String> noteType,
      required int position,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$RecipeNotesTableTableUpdateCompanionBuilder =
    RecipeNotesTableCompanion Function({
      Value<String> id,
      Value<String> recipeId,
      Value<String> body,
      Value<String> noteType,
      Value<int> position,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$RecipeNotesTableTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeNotesTableTable> {
  $$RecipeNotesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteType => $composableBuilder(
    column: $table.noteType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipeNotesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeNotesTableTable> {
  $$RecipeNotesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteType => $composableBuilder(
    column: $table.noteType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipeNotesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeNotesTableTable> {
  $$RecipeNotesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get noteType =>
      $composableBuilder(column: $table.noteType, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RecipeNotesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeNotesTableTable,
          RecipeNotesTableData,
          $$RecipeNotesTableTableFilterComposer,
          $$RecipeNotesTableTableOrderingComposer,
          $$RecipeNotesTableTableAnnotationComposer,
          $$RecipeNotesTableTableCreateCompanionBuilder,
          $$RecipeNotesTableTableUpdateCompanionBuilder,
          (
            RecipeNotesTableData,
            BaseReferences<
              _$AppDatabase,
              $RecipeNotesTableTable,
              RecipeNotesTableData
            >,
          ),
          RecipeNotesTableData,
          PrefetchHooks Function()
        > {
  $$RecipeNotesTableTableTableManager(
    _$AppDatabase db,
    $RecipeNotesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeNotesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeNotesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeNotesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> noteType = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeNotesTableCompanion(
                id: id,
                recipeId: recipeId,
                body: body,
                noteType: noteType,
                position: position,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recipeId,
                required String body,
                Value<String> noteType = const Value.absent(),
                required int position,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RecipeNotesTableCompanion.insert(
                id: id,
                recipeId: recipeId,
                body: body,
                noteType: noteType,
                position: position,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipeNotesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeNotesTableTable,
      RecipeNotesTableData,
      $$RecipeNotesTableTableFilterComposer,
      $$RecipeNotesTableTableOrderingComposer,
      $$RecipeNotesTableTableAnnotationComposer,
      $$RecipeNotesTableTableCreateCompanionBuilder,
      $$RecipeNotesTableTableUpdateCompanionBuilder,
      (
        RecipeNotesTableData,
        BaseReferences<
          _$AppDatabase,
          $RecipeNotesTableTable,
          RecipeNotesTableData
        >,
      ),
      RecipeNotesTableData,
      PrefetchHooks Function()
    >;
typedef $$IngredientsCatalogTableTableCreateCompanionBuilder =
    IngredientsCatalogTableCompanion Function({
      required String id,
      required String canonicalName,
      Value<String?> pluralName,
      Value<String?> category,
      Value<String> synonymsJson,
      Value<String> defaultScalingPolicy,
      Value<String> allergenJson,
      Value<String?> searchTerms,
      Value<int> rowid,
    });
typedef $$IngredientsCatalogTableTableUpdateCompanionBuilder =
    IngredientsCatalogTableCompanion Function({
      Value<String> id,
      Value<String> canonicalName,
      Value<String?> pluralName,
      Value<String?> category,
      Value<String> synonymsJson,
      Value<String> defaultScalingPolicy,
      Value<String> allergenJson,
      Value<String?> searchTerms,
      Value<int> rowid,
    });

class $$IngredientsCatalogTableTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientsCatalogTableTable> {
  $$IngredientsCatalogTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pluralName => $composableBuilder(
    column: $table.pluralName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get synonymsJson => $composableBuilder(
    column: $table.synonymsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultScalingPolicy => $composableBuilder(
    column: $table.defaultScalingPolicy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allergenJson => $composableBuilder(
    column: $table.allergenJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchTerms => $composableBuilder(
    column: $table.searchTerms,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IngredientsCatalogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientsCatalogTableTable> {
  $$IngredientsCatalogTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pluralName => $composableBuilder(
    column: $table.pluralName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get synonymsJson => $composableBuilder(
    column: $table.synonymsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultScalingPolicy => $composableBuilder(
    column: $table.defaultScalingPolicy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allergenJson => $composableBuilder(
    column: $table.allergenJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchTerms => $composableBuilder(
    column: $table.searchTerms,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IngredientsCatalogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientsCatalogTableTable> {
  $$IngredientsCatalogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pluralName => $composableBuilder(
    column: $table.pluralName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get synonymsJson => $composableBuilder(
    column: $table.synonymsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultScalingPolicy => $composableBuilder(
    column: $table.defaultScalingPolicy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allergenJson => $composableBuilder(
    column: $table.allergenJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get searchTerms => $composableBuilder(
    column: $table.searchTerms,
    builder: (column) => column,
  );
}

class $$IngredientsCatalogTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientsCatalogTableTable,
          IngredientsCatalogTableData,
          $$IngredientsCatalogTableTableFilterComposer,
          $$IngredientsCatalogTableTableOrderingComposer,
          $$IngredientsCatalogTableTableAnnotationComposer,
          $$IngredientsCatalogTableTableCreateCompanionBuilder,
          $$IngredientsCatalogTableTableUpdateCompanionBuilder,
          (
            IngredientsCatalogTableData,
            BaseReferences<
              _$AppDatabase,
              $IngredientsCatalogTableTable,
              IngredientsCatalogTableData
            >,
          ),
          IngredientsCatalogTableData,
          PrefetchHooks Function()
        > {
  $$IngredientsCatalogTableTableTableManager(
    _$AppDatabase db,
    $IngredientsCatalogTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientsCatalogTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$IngredientsCatalogTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$IngredientsCatalogTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> canonicalName = const Value.absent(),
                Value<String?> pluralName = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> synonymsJson = const Value.absent(),
                Value<String> defaultScalingPolicy = const Value.absent(),
                Value<String> allergenJson = const Value.absent(),
                Value<String?> searchTerms = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientsCatalogTableCompanion(
                id: id,
                canonicalName: canonicalName,
                pluralName: pluralName,
                category: category,
                synonymsJson: synonymsJson,
                defaultScalingPolicy: defaultScalingPolicy,
                allergenJson: allergenJson,
                searchTerms: searchTerms,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String canonicalName,
                Value<String?> pluralName = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> synonymsJson = const Value.absent(),
                Value<String> defaultScalingPolicy = const Value.absent(),
                Value<String> allergenJson = const Value.absent(),
                Value<String?> searchTerms = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientsCatalogTableCompanion.insert(
                id: id,
                canonicalName: canonicalName,
                pluralName: pluralName,
                category: category,
                synonymsJson: synonymsJson,
                defaultScalingPolicy: defaultScalingPolicy,
                allergenJson: allergenJson,
                searchTerms: searchTerms,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IngredientsCatalogTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientsCatalogTableTable,
      IngredientsCatalogTableData,
      $$IngredientsCatalogTableTableFilterComposer,
      $$IngredientsCatalogTableTableOrderingComposer,
      $$IngredientsCatalogTableTableAnnotationComposer,
      $$IngredientsCatalogTableTableCreateCompanionBuilder,
      $$IngredientsCatalogTableTableUpdateCompanionBuilder,
      (
        IngredientsCatalogTableData,
        BaseReferences<
          _$AppDatabase,
          $IngredientsCatalogTableTable,
          IngredientsCatalogTableData
        >,
      ),
      IngredientsCatalogTableData,
      PrefetchHooks Function()
    >;
typedef $$UnitsCatalogTableTableCreateCompanionBuilder =
    UnitsCatalogTableCompanion Function({
      required String id,
      required String code,
      required String dimension,
      required String displayMetric,
      required String displayUs,
      Value<int> toBaseNum,
      Value<int> toBaseDen,
      Value<bool> isScalable,
      Value<int> rowid,
    });
typedef $$UnitsCatalogTableTableUpdateCompanionBuilder =
    UnitsCatalogTableCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> dimension,
      Value<String> displayMetric,
      Value<String> displayUs,
      Value<int> toBaseNum,
      Value<int> toBaseDen,
      Value<bool> isScalable,
      Value<int> rowid,
    });

class $$UnitsCatalogTableTableFilterComposer
    extends Composer<_$AppDatabase, $UnitsCatalogTableTable> {
  $$UnitsCatalogTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dimension => $composableBuilder(
    column: $table.dimension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayMetric => $composableBuilder(
    column: $table.displayMetric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayUs => $composableBuilder(
    column: $table.displayUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toBaseNum => $composableBuilder(
    column: $table.toBaseNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toBaseDen => $composableBuilder(
    column: $table.toBaseDen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isScalable => $composableBuilder(
    column: $table.isScalable,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnitsCatalogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitsCatalogTableTable> {
  $$UnitsCatalogTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dimension => $composableBuilder(
    column: $table.dimension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayMetric => $composableBuilder(
    column: $table.displayMetric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayUs => $composableBuilder(
    column: $table.displayUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toBaseNum => $composableBuilder(
    column: $table.toBaseNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toBaseDen => $composableBuilder(
    column: $table.toBaseDen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isScalable => $composableBuilder(
    column: $table.isScalable,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnitsCatalogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitsCatalogTableTable> {
  $$UnitsCatalogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get dimension =>
      $composableBuilder(column: $table.dimension, builder: (column) => column);

  GeneratedColumn<String> get displayMetric => $composableBuilder(
    column: $table.displayMetric,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayUs =>
      $composableBuilder(column: $table.displayUs, builder: (column) => column);

  GeneratedColumn<int> get toBaseNum =>
      $composableBuilder(column: $table.toBaseNum, builder: (column) => column);

  GeneratedColumn<int> get toBaseDen =>
      $composableBuilder(column: $table.toBaseDen, builder: (column) => column);

  GeneratedColumn<bool> get isScalable => $composableBuilder(
    column: $table.isScalable,
    builder: (column) => column,
  );
}

class $$UnitsCatalogTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitsCatalogTableTable,
          UnitsCatalogTableData,
          $$UnitsCatalogTableTableFilterComposer,
          $$UnitsCatalogTableTableOrderingComposer,
          $$UnitsCatalogTableTableAnnotationComposer,
          $$UnitsCatalogTableTableCreateCompanionBuilder,
          $$UnitsCatalogTableTableUpdateCompanionBuilder,
          (
            UnitsCatalogTableData,
            BaseReferences<
              _$AppDatabase,
              $UnitsCatalogTableTable,
              UnitsCatalogTableData
            >,
          ),
          UnitsCatalogTableData,
          PrefetchHooks Function()
        > {
  $$UnitsCatalogTableTableTableManager(
    _$AppDatabase db,
    $UnitsCatalogTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitsCatalogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitsCatalogTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitsCatalogTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> dimension = const Value.absent(),
                Value<String> displayMetric = const Value.absent(),
                Value<String> displayUs = const Value.absent(),
                Value<int> toBaseNum = const Value.absent(),
                Value<int> toBaseDen = const Value.absent(),
                Value<bool> isScalable = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitsCatalogTableCompanion(
                id: id,
                code: code,
                dimension: dimension,
                displayMetric: displayMetric,
                displayUs: displayUs,
                toBaseNum: toBaseNum,
                toBaseDen: toBaseDen,
                isScalable: isScalable,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String dimension,
                required String displayMetric,
                required String displayUs,
                Value<int> toBaseNum = const Value.absent(),
                Value<int> toBaseDen = const Value.absent(),
                Value<bool> isScalable = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitsCatalogTableCompanion.insert(
                id: id,
                code: code,
                dimension: dimension,
                displayMetric: displayMetric,
                displayUs: displayUs,
                toBaseNum: toBaseNum,
                toBaseDen: toBaseDen,
                isScalable: isScalable,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnitsCatalogTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitsCatalogTableTable,
      UnitsCatalogTableData,
      $$UnitsCatalogTableTableFilterComposer,
      $$UnitsCatalogTableTableOrderingComposer,
      $$UnitsCatalogTableTableAnnotationComposer,
      $$UnitsCatalogTableTableCreateCompanionBuilder,
      $$UnitsCatalogTableTableUpdateCompanionBuilder,
      (
        UnitsCatalogTableData,
        BaseReferences<
          _$AppDatabase,
          $UnitsCatalogTableTable,
          UnitsCatalogTableData
        >,
      ),
      UnitsCatalogTableData,
      PrefetchHooks Function()
    >;
typedef $$RecipeIngredientsTableTableCreateCompanionBuilder =
    RecipeIngredientsTableCompanion Function({
      required String id,
      required String recipeId,
      Value<String?> catalogIngredientId,
      required String displayName,
      Value<int?> quantityNum,
      Value<int?> quantityDen,
      Value<String?> unitCode,
      Value<String?> authoredQuantity,
      Value<String> scalingPolicy,
      Value<String?> prepText,
      Value<bool> isOptional,
      required int position,
      Value<String?> groupKey,
      Value<String?> allergenOverrideJson,
      Value<String?> illustrationKey,
      Value<int> rowid,
    });
typedef $$RecipeIngredientsTableTableUpdateCompanionBuilder =
    RecipeIngredientsTableCompanion Function({
      Value<String> id,
      Value<String> recipeId,
      Value<String?> catalogIngredientId,
      Value<String> displayName,
      Value<int?> quantityNum,
      Value<int?> quantityDen,
      Value<String?> unitCode,
      Value<String?> authoredQuantity,
      Value<String> scalingPolicy,
      Value<String?> prepText,
      Value<bool> isOptional,
      Value<int> position,
      Value<String?> groupKey,
      Value<String?> allergenOverrideJson,
      Value<String?> illustrationKey,
      Value<int> rowid,
    });

class $$RecipeIngredientsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTableTable> {
  $$RecipeIngredientsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogIngredientId => $composableBuilder(
    column: $table.catalogIngredientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityNum => $composableBuilder(
    column: $table.quantityNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityDen => $composableBuilder(
    column: $table.quantityDen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authoredQuantity => $composableBuilder(
    column: $table.authoredQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scalingPolicy => $composableBuilder(
    column: $table.scalingPolicy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prepText => $composableBuilder(
    column: $table.prepText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupKey => $composableBuilder(
    column: $table.groupKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allergenOverrideJson => $composableBuilder(
    column: $table.allergenOverrideJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get illustrationKey => $composableBuilder(
    column: $table.illustrationKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipeIngredientsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTableTable> {
  $$RecipeIngredientsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogIngredientId => $composableBuilder(
    column: $table.catalogIngredientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityNum => $composableBuilder(
    column: $table.quantityNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityDen => $composableBuilder(
    column: $table.quantityDen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authoredQuantity => $composableBuilder(
    column: $table.authoredQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scalingPolicy => $composableBuilder(
    column: $table.scalingPolicy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prepText => $composableBuilder(
    column: $table.prepText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupKey => $composableBuilder(
    column: $table.groupKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allergenOverrideJson => $composableBuilder(
    column: $table.allergenOverrideJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get illustrationKey => $composableBuilder(
    column: $table.illustrationKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipeIngredientsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTableTable> {
  $$RecipeIngredientsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get catalogIngredientId => $composableBuilder(
    column: $table.catalogIngredientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityNum => $composableBuilder(
    column: $table.quantityNum,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityDen => $composableBuilder(
    column: $table.quantityDen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitCode =>
      $composableBuilder(column: $table.unitCode, builder: (column) => column);

  GeneratedColumn<String> get authoredQuantity => $composableBuilder(
    column: $table.authoredQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scalingPolicy => $composableBuilder(
    column: $table.scalingPolicy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prepText =>
      $composableBuilder(column: $table.prepText, builder: (column) => column);

  GeneratedColumn<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get groupKey =>
      $composableBuilder(column: $table.groupKey, builder: (column) => column);

  GeneratedColumn<String> get allergenOverrideJson => $composableBuilder(
    column: $table.allergenOverrideJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get illustrationKey => $composableBuilder(
    column: $table.illustrationKey,
    builder: (column) => column,
  );
}

class $$RecipeIngredientsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeIngredientsTableTable,
          RecipeIngredientsTableData,
          $$RecipeIngredientsTableTableFilterComposer,
          $$RecipeIngredientsTableTableOrderingComposer,
          $$RecipeIngredientsTableTableAnnotationComposer,
          $$RecipeIngredientsTableTableCreateCompanionBuilder,
          $$RecipeIngredientsTableTableUpdateCompanionBuilder,
          (
            RecipeIngredientsTableData,
            BaseReferences<
              _$AppDatabase,
              $RecipeIngredientsTableTable,
              RecipeIngredientsTableData
            >,
          ),
          RecipeIngredientsTableData,
          PrefetchHooks Function()
        > {
  $$RecipeIngredientsTableTableTableManager(
    _$AppDatabase db,
    $RecipeIngredientsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeIngredientsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecipeIngredientsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecipeIngredientsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<String?> catalogIngredientId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int?> quantityNum = const Value.absent(),
                Value<int?> quantityDen = const Value.absent(),
                Value<String?> unitCode = const Value.absent(),
                Value<String?> authoredQuantity = const Value.absent(),
                Value<String> scalingPolicy = const Value.absent(),
                Value<String?> prepText = const Value.absent(),
                Value<bool> isOptional = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> groupKey = const Value.absent(),
                Value<String?> allergenOverrideJson = const Value.absent(),
                Value<String?> illustrationKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeIngredientsTableCompanion(
                id: id,
                recipeId: recipeId,
                catalogIngredientId: catalogIngredientId,
                displayName: displayName,
                quantityNum: quantityNum,
                quantityDen: quantityDen,
                unitCode: unitCode,
                authoredQuantity: authoredQuantity,
                scalingPolicy: scalingPolicy,
                prepText: prepText,
                isOptional: isOptional,
                position: position,
                groupKey: groupKey,
                allergenOverrideJson: allergenOverrideJson,
                illustrationKey: illustrationKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recipeId,
                Value<String?> catalogIngredientId = const Value.absent(),
                required String displayName,
                Value<int?> quantityNum = const Value.absent(),
                Value<int?> quantityDen = const Value.absent(),
                Value<String?> unitCode = const Value.absent(),
                Value<String?> authoredQuantity = const Value.absent(),
                Value<String> scalingPolicy = const Value.absent(),
                Value<String?> prepText = const Value.absent(),
                Value<bool> isOptional = const Value.absent(),
                required int position,
                Value<String?> groupKey = const Value.absent(),
                Value<String?> allergenOverrideJson = const Value.absent(),
                Value<String?> illustrationKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeIngredientsTableCompanion.insert(
                id: id,
                recipeId: recipeId,
                catalogIngredientId: catalogIngredientId,
                displayName: displayName,
                quantityNum: quantityNum,
                quantityDen: quantityDen,
                unitCode: unitCode,
                authoredQuantity: authoredQuantity,
                scalingPolicy: scalingPolicy,
                prepText: prepText,
                isOptional: isOptional,
                position: position,
                groupKey: groupKey,
                allergenOverrideJson: allergenOverrideJson,
                illustrationKey: illustrationKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipeIngredientsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeIngredientsTableTable,
      RecipeIngredientsTableData,
      $$RecipeIngredientsTableTableFilterComposer,
      $$RecipeIngredientsTableTableOrderingComposer,
      $$RecipeIngredientsTableTableAnnotationComposer,
      $$RecipeIngredientsTableTableCreateCompanionBuilder,
      $$RecipeIngredientsTableTableUpdateCompanionBuilder,
      (
        RecipeIngredientsTableData,
        BaseReferences<
          _$AppDatabase,
          $RecipeIngredientsTableTable,
          RecipeIngredientsTableData
        >,
      ),
      RecipeIngredientsTableData,
      PrefetchHooks Function()
    >;
typedef $$RecipeStepsTableTableCreateCompanionBuilder =
    RecipeStepsTableCompanion Function({
      required String id,
      required String recipeId,
      required int position,
      required String instructionShort,
      Value<String?> instructionDetail,
      Value<String?> spokenInstruction,
      Value<String?> actionKey,
      Value<int?> durationSeconds,
      Value<int?> temperatureC,
      Value<int?> temperatureF,
      Value<String?> layoutHint,
      Value<String?> safetyJson,
      Value<int> rowid,
    });
typedef $$RecipeStepsTableTableUpdateCompanionBuilder =
    RecipeStepsTableCompanion Function({
      Value<String> id,
      Value<String> recipeId,
      Value<int> position,
      Value<String> instructionShort,
      Value<String?> instructionDetail,
      Value<String?> spokenInstruction,
      Value<String?> actionKey,
      Value<int?> durationSeconds,
      Value<int?> temperatureC,
      Value<int?> temperatureF,
      Value<String?> layoutHint,
      Value<String?> safetyJson,
      Value<int> rowid,
    });

class $$RecipeStepsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeStepsTableTable> {
  $$RecipeStepsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructionShort => $composableBuilder(
    column: $table.instructionShort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructionDetail => $composableBuilder(
    column: $table.instructionDetail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spokenInstruction => $composableBuilder(
    column: $table.spokenInstruction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionKey => $composableBuilder(
    column: $table.actionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temperatureC => $composableBuilder(
    column: $table.temperatureC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temperatureF => $composableBuilder(
    column: $table.temperatureF,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get layoutHint => $composableBuilder(
    column: $table.layoutHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get safetyJson => $composableBuilder(
    column: $table.safetyJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipeStepsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeStepsTableTable> {
  $$RecipeStepsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructionShort => $composableBuilder(
    column: $table.instructionShort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructionDetail => $composableBuilder(
    column: $table.instructionDetail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spokenInstruction => $composableBuilder(
    column: $table.spokenInstruction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionKey => $composableBuilder(
    column: $table.actionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temperatureC => $composableBuilder(
    column: $table.temperatureC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temperatureF => $composableBuilder(
    column: $table.temperatureF,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get layoutHint => $composableBuilder(
    column: $table.layoutHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get safetyJson => $composableBuilder(
    column: $table.safetyJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipeStepsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeStepsTableTable> {
  $$RecipeStepsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get instructionShort => $composableBuilder(
    column: $table.instructionShort,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instructionDetail => $composableBuilder(
    column: $table.instructionDetail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spokenInstruction => $composableBuilder(
    column: $table.spokenInstruction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionKey =>
      $composableBuilder(column: $table.actionKey, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get temperatureC => $composableBuilder(
    column: $table.temperatureC,
    builder: (column) => column,
  );

  GeneratedColumn<int> get temperatureF => $composableBuilder(
    column: $table.temperatureF,
    builder: (column) => column,
  );

  GeneratedColumn<String> get layoutHint => $composableBuilder(
    column: $table.layoutHint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get safetyJson => $composableBuilder(
    column: $table.safetyJson,
    builder: (column) => column,
  );
}

class $$RecipeStepsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeStepsTableTable,
          RecipeStepsTableData,
          $$RecipeStepsTableTableFilterComposer,
          $$RecipeStepsTableTableOrderingComposer,
          $$RecipeStepsTableTableAnnotationComposer,
          $$RecipeStepsTableTableCreateCompanionBuilder,
          $$RecipeStepsTableTableUpdateCompanionBuilder,
          (
            RecipeStepsTableData,
            BaseReferences<
              _$AppDatabase,
              $RecipeStepsTableTable,
              RecipeStepsTableData
            >,
          ),
          RecipeStepsTableData,
          PrefetchHooks Function()
        > {
  $$RecipeStepsTableTableTableManager(
    _$AppDatabase db,
    $RecipeStepsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeStepsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeStepsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeStepsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> instructionShort = const Value.absent(),
                Value<String?> instructionDetail = const Value.absent(),
                Value<String?> spokenInstruction = const Value.absent(),
                Value<String?> actionKey = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<int?> temperatureC = const Value.absent(),
                Value<int?> temperatureF = const Value.absent(),
                Value<String?> layoutHint = const Value.absent(),
                Value<String?> safetyJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeStepsTableCompanion(
                id: id,
                recipeId: recipeId,
                position: position,
                instructionShort: instructionShort,
                instructionDetail: instructionDetail,
                spokenInstruction: spokenInstruction,
                actionKey: actionKey,
                durationSeconds: durationSeconds,
                temperatureC: temperatureC,
                temperatureF: temperatureF,
                layoutHint: layoutHint,
                safetyJson: safetyJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recipeId,
                required int position,
                required String instructionShort,
                Value<String?> instructionDetail = const Value.absent(),
                Value<String?> spokenInstruction = const Value.absent(),
                Value<String?> actionKey = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<int?> temperatureC = const Value.absent(),
                Value<int?> temperatureF = const Value.absent(),
                Value<String?> layoutHint = const Value.absent(),
                Value<String?> safetyJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeStepsTableCompanion.insert(
                id: id,
                recipeId: recipeId,
                position: position,
                instructionShort: instructionShort,
                instructionDetail: instructionDetail,
                spokenInstruction: spokenInstruction,
                actionKey: actionKey,
                durationSeconds: durationSeconds,
                temperatureC: temperatureC,
                temperatureF: temperatureF,
                layoutHint: layoutHint,
                safetyJson: safetyJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipeStepsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeStepsTableTable,
      RecipeStepsTableData,
      $$RecipeStepsTableTableFilterComposer,
      $$RecipeStepsTableTableOrderingComposer,
      $$RecipeStepsTableTableAnnotationComposer,
      $$RecipeStepsTableTableCreateCompanionBuilder,
      $$RecipeStepsTableTableUpdateCompanionBuilder,
      (
        RecipeStepsTableData,
        BaseReferences<
          _$AppDatabase,
          $RecipeStepsTableTable,
          RecipeStepsTableData
        >,
      ),
      RecipeStepsTableData,
      PrefetchHooks Function()
    >;
typedef $$StepTimersTableTableCreateCompanionBuilder =
    StepTimersTableCompanion Function({
      required String id,
      required String recipeStepId,
      required String label,
      required int durationSeconds,
      Value<bool> autoStart,
      required int position,
      Value<int> rowid,
    });
typedef $$StepTimersTableTableUpdateCompanionBuilder =
    StepTimersTableCompanion Function({
      Value<String> id,
      Value<String> recipeStepId,
      Value<String> label,
      Value<int> durationSeconds,
      Value<bool> autoStart,
      Value<int> position,
      Value<int> rowid,
    });

class $$StepTimersTableTableFilterComposer
    extends Composer<_$AppDatabase, $StepTimersTableTable> {
  $$StepTimersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeStepId => $composableBuilder(
    column: $table.recipeStepId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoStart => $composableBuilder(
    column: $table.autoStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StepTimersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StepTimersTableTable> {
  $$StepTimersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeStepId => $composableBuilder(
    column: $table.recipeStepId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoStart => $composableBuilder(
    column: $table.autoStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StepTimersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StepTimersTableTable> {
  $$StepTimersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recipeStepId => $composableBuilder(
    column: $table.recipeStepId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoStart =>
      $composableBuilder(column: $table.autoStart, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$StepTimersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StepTimersTableTable,
          StepTimersTableData,
          $$StepTimersTableTableFilterComposer,
          $$StepTimersTableTableOrderingComposer,
          $$StepTimersTableTableAnnotationComposer,
          $$StepTimersTableTableCreateCompanionBuilder,
          $$StepTimersTableTableUpdateCompanionBuilder,
          (
            StepTimersTableData,
            BaseReferences<
              _$AppDatabase,
              $StepTimersTableTable,
              StepTimersTableData
            >,
          ),
          StepTimersTableData,
          PrefetchHooks Function()
        > {
  $$StepTimersTableTableTableManager(
    _$AppDatabase db,
    $StepTimersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StepTimersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StepTimersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StepTimersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recipeStepId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<bool> autoStart = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StepTimersTableCompanion(
                id: id,
                recipeStepId: recipeStepId,
                label: label,
                durationSeconds: durationSeconds,
                autoStart: autoStart,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recipeStepId,
                required String label,
                required int durationSeconds,
                Value<bool> autoStart = const Value.absent(),
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => StepTimersTableCompanion.insert(
                id: id,
                recipeStepId: recipeStepId,
                label: label,
                durationSeconds: durationSeconds,
                autoStart: autoStart,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StepTimersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StepTimersTableTable,
      StepTimersTableData,
      $$StepTimersTableTableFilterComposer,
      $$StepTimersTableTableOrderingComposer,
      $$StepTimersTableTableAnnotationComposer,
      $$StepTimersTableTableCreateCompanionBuilder,
      $$StepTimersTableTableUpdateCompanionBuilder,
      (
        StepTimersTableData,
        BaseReferences<
          _$AppDatabase,
          $StepTimersTableTable,
          StepTimersTableData
        >,
      ),
      StepTimersTableData,
      PrefetchHooks Function()
    >;
typedef $$ToolsCatalogTableTableCreateCompanionBuilder =
    ToolsCatalogTableCompanion Function({
      required String id,
      required String canonicalName,
      Value<String?> category,
      Value<String> synonymsJson,
      Value<String?> illustrationKey,
      Value<int> rowid,
    });
typedef $$ToolsCatalogTableTableUpdateCompanionBuilder =
    ToolsCatalogTableCompanion Function({
      Value<String> id,
      Value<String> canonicalName,
      Value<String?> category,
      Value<String> synonymsJson,
      Value<String?> illustrationKey,
      Value<int> rowid,
    });

class $$ToolsCatalogTableTableFilterComposer
    extends Composer<_$AppDatabase, $ToolsCatalogTableTable> {
  $$ToolsCatalogTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get synonymsJson => $composableBuilder(
    column: $table.synonymsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get illustrationKey => $composableBuilder(
    column: $table.illustrationKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ToolsCatalogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ToolsCatalogTableTable> {
  $$ToolsCatalogTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get synonymsJson => $composableBuilder(
    column: $table.synonymsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get illustrationKey => $composableBuilder(
    column: $table.illustrationKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ToolsCatalogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ToolsCatalogTableTable> {
  $$ToolsCatalogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get synonymsJson => $composableBuilder(
    column: $table.synonymsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get illustrationKey => $composableBuilder(
    column: $table.illustrationKey,
    builder: (column) => column,
  );
}

class $$ToolsCatalogTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ToolsCatalogTableTable,
          ToolsCatalogTableData,
          $$ToolsCatalogTableTableFilterComposer,
          $$ToolsCatalogTableTableOrderingComposer,
          $$ToolsCatalogTableTableAnnotationComposer,
          $$ToolsCatalogTableTableCreateCompanionBuilder,
          $$ToolsCatalogTableTableUpdateCompanionBuilder,
          (
            ToolsCatalogTableData,
            BaseReferences<
              _$AppDatabase,
              $ToolsCatalogTableTable,
              ToolsCatalogTableData
            >,
          ),
          ToolsCatalogTableData,
          PrefetchHooks Function()
        > {
  $$ToolsCatalogTableTableTableManager(
    _$AppDatabase db,
    $ToolsCatalogTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ToolsCatalogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ToolsCatalogTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ToolsCatalogTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> canonicalName = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> synonymsJson = const Value.absent(),
                Value<String?> illustrationKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ToolsCatalogTableCompanion(
                id: id,
                canonicalName: canonicalName,
                category: category,
                synonymsJson: synonymsJson,
                illustrationKey: illustrationKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String canonicalName,
                Value<String?> category = const Value.absent(),
                Value<String> synonymsJson = const Value.absent(),
                Value<String?> illustrationKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ToolsCatalogTableCompanion.insert(
                id: id,
                canonicalName: canonicalName,
                category: category,
                synonymsJson: synonymsJson,
                illustrationKey: illustrationKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ToolsCatalogTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ToolsCatalogTableTable,
      ToolsCatalogTableData,
      $$ToolsCatalogTableTableFilterComposer,
      $$ToolsCatalogTableTableOrderingComposer,
      $$ToolsCatalogTableTableAnnotationComposer,
      $$ToolsCatalogTableTableCreateCompanionBuilder,
      $$ToolsCatalogTableTableUpdateCompanionBuilder,
      (
        ToolsCatalogTableData,
        BaseReferences<
          _$AppDatabase,
          $ToolsCatalogTableTable,
          ToolsCatalogTableData
        >,
      ),
      ToolsCatalogTableData,
      PrefetchHooks Function()
    >;
typedef $$RecipeToolsTableTableCreateCompanionBuilder =
    RecipeToolsTableCompanion Function({
      required String id,
      required String recipeId,
      Value<String?> toolId,
      required String displayName,
      Value<int> quantity,
      Value<bool> isRequired,
      required int position,
      Value<int> rowid,
    });
typedef $$RecipeToolsTableTableUpdateCompanionBuilder =
    RecipeToolsTableCompanion Function({
      Value<String> id,
      Value<String> recipeId,
      Value<String?> toolId,
      Value<String> displayName,
      Value<int> quantity,
      Value<bool> isRequired,
      Value<int> position,
      Value<int> rowid,
    });

class $$RecipeToolsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeToolsTableTable> {
  $$RecipeToolsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolId => $composableBuilder(
    column: $table.toolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipeToolsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeToolsTableTable> {
  $$RecipeToolsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolId => $composableBuilder(
    column: $table.toolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipeToolsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeToolsTableTable> {
  $$RecipeToolsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get toolId =>
      $composableBuilder(column: $table.toolId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<bool> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$RecipeToolsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeToolsTableTable,
          RecipeToolsTableData,
          $$RecipeToolsTableTableFilterComposer,
          $$RecipeToolsTableTableOrderingComposer,
          $$RecipeToolsTableTableAnnotationComposer,
          $$RecipeToolsTableTableCreateCompanionBuilder,
          $$RecipeToolsTableTableUpdateCompanionBuilder,
          (
            RecipeToolsTableData,
            BaseReferences<
              _$AppDatabase,
              $RecipeToolsTableTable,
              RecipeToolsTableData
            >,
          ),
          RecipeToolsTableData,
          PrefetchHooks Function()
        > {
  $$RecipeToolsTableTableTableManager(
    _$AppDatabase db,
    $RecipeToolsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeToolsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeToolsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeToolsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<String?> toolId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<bool> isRequired = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeToolsTableCompanion(
                id: id,
                recipeId: recipeId,
                toolId: toolId,
                displayName: displayName,
                quantity: quantity,
                isRequired: isRequired,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recipeId,
                Value<String?> toolId = const Value.absent(),
                required String displayName,
                Value<int> quantity = const Value.absent(),
                Value<bool> isRequired = const Value.absent(),
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => RecipeToolsTableCompanion.insert(
                id: id,
                recipeId: recipeId,
                toolId: toolId,
                displayName: displayName,
                quantity: quantity,
                isRequired: isRequired,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipeToolsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeToolsTableTable,
      RecipeToolsTableData,
      $$RecipeToolsTableTableFilterComposer,
      $$RecipeToolsTableTableOrderingComposer,
      $$RecipeToolsTableTableAnnotationComposer,
      $$RecipeToolsTableTableCreateCompanionBuilder,
      $$RecipeToolsTableTableUpdateCompanionBuilder,
      (
        RecipeToolsTableData,
        BaseReferences<
          _$AppDatabase,
          $RecipeToolsTableTable,
          RecipeToolsTableData
        >,
      ),
      RecipeToolsTableData,
      PrefetchHooks Function()
    >;
typedef $$LabelsTableTableCreateCompanionBuilder =
    LabelsTableCompanion Function({
      required String id,
      required String kind,
      required String canonicalKey,
      required String displayName,
      Value<String?> iconKey,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$LabelsTableTableUpdateCompanionBuilder =
    LabelsTableCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> canonicalKey,
      Value<String> displayName,
      Value<String?> iconKey,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$LabelsTableTableFilterComposer
    extends Composer<_$AppDatabase, $LabelsTableTable> {
  $$LabelsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalKey => $composableBuilder(
    column: $table.canonicalKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LabelsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LabelsTableTable> {
  $$LabelsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalKey => $composableBuilder(
    column: $table.canonicalKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LabelsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LabelsTableTable> {
  $$LabelsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get canonicalKey => $composableBuilder(
    column: $table.canonicalKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LabelsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LabelsTableTable,
          LabelsTableData,
          $$LabelsTableTableFilterComposer,
          $$LabelsTableTableOrderingComposer,
          $$LabelsTableTableAnnotationComposer,
          $$LabelsTableTableCreateCompanionBuilder,
          $$LabelsTableTableUpdateCompanionBuilder,
          (
            LabelsTableData,
            BaseReferences<_$AppDatabase, $LabelsTableTable, LabelsTableData>,
          ),
          LabelsTableData,
          PrefetchHooks Function()
        > {
  $$LabelsTableTableTableManager(_$AppDatabase db, $LabelsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LabelsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LabelsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LabelsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> canonicalKey = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> iconKey = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LabelsTableCompanion(
                id: id,
                kind: kind,
                canonicalKey: canonicalKey,
                displayName: displayName,
                iconKey: iconKey,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String canonicalKey,
                required String displayName,
                Value<String?> iconKey = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LabelsTableCompanion.insert(
                id: id,
                kind: kind,
                canonicalKey: canonicalKey,
                displayName: displayName,
                iconKey: iconKey,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LabelsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LabelsTableTable,
      LabelsTableData,
      $$LabelsTableTableFilterComposer,
      $$LabelsTableTableOrderingComposer,
      $$LabelsTableTableAnnotationComposer,
      $$LabelsTableTableCreateCompanionBuilder,
      $$LabelsTableTableUpdateCompanionBuilder,
      (
        LabelsTableData,
        BaseReferences<_$AppDatabase, $LabelsTableTable, LabelsTableData>,
      ),
      LabelsTableData,
      PrefetchHooks Function()
    >;
typedef $$RecipeLabelsTableTableCreateCompanionBuilder =
    RecipeLabelsTableCompanion Function({
      required String id,
      required String recipeId,
      required String labelId,
      Value<double> sourceConfidence,
      Value<bool> isUserConfirmed,
      Value<int> rowid,
    });
typedef $$RecipeLabelsTableTableUpdateCompanionBuilder =
    RecipeLabelsTableCompanion Function({
      Value<String> id,
      Value<String> recipeId,
      Value<String> labelId,
      Value<double> sourceConfidence,
      Value<bool> isUserConfirmed,
      Value<int> rowid,
    });

class $$RecipeLabelsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeLabelsTableTable> {
  $$RecipeLabelsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labelId => $composableBuilder(
    column: $table.labelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sourceConfidence => $composableBuilder(
    column: $table.sourceConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUserConfirmed => $composableBuilder(
    column: $table.isUserConfirmed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipeLabelsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeLabelsTableTable> {
  $$RecipeLabelsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labelId => $composableBuilder(
    column: $table.labelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sourceConfidence => $composableBuilder(
    column: $table.sourceConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUserConfirmed => $composableBuilder(
    column: $table.isUserConfirmed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipeLabelsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeLabelsTableTable> {
  $$RecipeLabelsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get labelId =>
      $composableBuilder(column: $table.labelId, builder: (column) => column);

  GeneratedColumn<double> get sourceConfidence => $composableBuilder(
    column: $table.sourceConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isUserConfirmed => $composableBuilder(
    column: $table.isUserConfirmed,
    builder: (column) => column,
  );
}

class $$RecipeLabelsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeLabelsTableTable,
          RecipeLabelsTableData,
          $$RecipeLabelsTableTableFilterComposer,
          $$RecipeLabelsTableTableOrderingComposer,
          $$RecipeLabelsTableTableAnnotationComposer,
          $$RecipeLabelsTableTableCreateCompanionBuilder,
          $$RecipeLabelsTableTableUpdateCompanionBuilder,
          (
            RecipeLabelsTableData,
            BaseReferences<
              _$AppDatabase,
              $RecipeLabelsTableTable,
              RecipeLabelsTableData
            >,
          ),
          RecipeLabelsTableData,
          PrefetchHooks Function()
        > {
  $$RecipeLabelsTableTableTableManager(
    _$AppDatabase db,
    $RecipeLabelsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeLabelsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeLabelsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeLabelsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<String> labelId = const Value.absent(),
                Value<double> sourceConfidence = const Value.absent(),
                Value<bool> isUserConfirmed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeLabelsTableCompanion(
                id: id,
                recipeId: recipeId,
                labelId: labelId,
                sourceConfidence: sourceConfidence,
                isUserConfirmed: isUserConfirmed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recipeId,
                required String labelId,
                Value<double> sourceConfidence = const Value.absent(),
                Value<bool> isUserConfirmed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeLabelsTableCompanion.insert(
                id: id,
                recipeId: recipeId,
                labelId: labelId,
                sourceConfidence: sourceConfidence,
                isUserConfirmed: isUserConfirmed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipeLabelsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeLabelsTableTable,
      RecipeLabelsTableData,
      $$RecipeLabelsTableTableFilterComposer,
      $$RecipeLabelsTableTableOrderingComposer,
      $$RecipeLabelsTableTableAnnotationComposer,
      $$RecipeLabelsTableTableCreateCompanionBuilder,
      $$RecipeLabelsTableTableUpdateCompanionBuilder,
      (
        RecipeLabelsTableData,
        BaseReferences<
          _$AppDatabase,
          $RecipeLabelsTableTable,
          RecipeLabelsTableData
        >,
      ),
      RecipeLabelsTableData,
      PrefetchHooks Function()
    >;
typedef $$RecipeMediaTableTableCreateCompanionBuilder =
    RecipeMediaTableCompanion Function({
      required String id,
      required String recipeId,
      required String kind,
      required String storageKind,
      required String relativePath,
      required String mimeType,
      Value<int?> width,
      Value<int?> height,
      Value<String?> sha256,
      Value<String?> caption,
      Value<String?> altText,
      Value<int> position,
      Value<int> rowid,
    });
typedef $$RecipeMediaTableTableUpdateCompanionBuilder =
    RecipeMediaTableCompanion Function({
      Value<String> id,
      Value<String> recipeId,
      Value<String> kind,
      Value<String> storageKind,
      Value<String> relativePath,
      Value<String> mimeType,
      Value<int?> width,
      Value<int?> height,
      Value<String?> sha256,
      Value<String?> caption,
      Value<String?> altText,
      Value<int> position,
      Value<int> rowid,
    });

class $$RecipeMediaTableTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeMediaTableTable> {
  $$RecipeMediaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageKind => $composableBuilder(
    column: $table.storageKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get altText => $composableBuilder(
    column: $table.altText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipeMediaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeMediaTableTable> {
  $$RecipeMediaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageKind => $composableBuilder(
    column: $table.storageKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get altText => $composableBuilder(
    column: $table.altText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipeMediaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeMediaTableTable> {
  $$RecipeMediaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get storageKind => $composableBuilder(
    column: $table.storageKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<String> get altText =>
      $composableBuilder(column: $table.altText, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$RecipeMediaTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeMediaTableTable,
          RecipeMediaTableData,
          $$RecipeMediaTableTableFilterComposer,
          $$RecipeMediaTableTableOrderingComposer,
          $$RecipeMediaTableTableAnnotationComposer,
          $$RecipeMediaTableTableCreateCompanionBuilder,
          $$RecipeMediaTableTableUpdateCompanionBuilder,
          (
            RecipeMediaTableData,
            BaseReferences<
              _$AppDatabase,
              $RecipeMediaTableTable,
              RecipeMediaTableData
            >,
          ),
          RecipeMediaTableData,
          PrefetchHooks Function()
        > {
  $$RecipeMediaTableTableTableManager(
    _$AppDatabase db,
    $RecipeMediaTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeMediaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeMediaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeMediaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> storageKind = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<String?> altText = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeMediaTableCompanion(
                id: id,
                recipeId: recipeId,
                kind: kind,
                storageKind: storageKind,
                relativePath: relativePath,
                mimeType: mimeType,
                width: width,
                height: height,
                sha256: sha256,
                caption: caption,
                altText: altText,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recipeId,
                required String kind,
                required String storageKind,
                required String relativePath,
                required String mimeType,
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<String?> altText = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeMediaTableCompanion.insert(
                id: id,
                recipeId: recipeId,
                kind: kind,
                storageKind: storageKind,
                relativePath: relativePath,
                mimeType: mimeType,
                width: width,
                height: height,
                sha256: sha256,
                caption: caption,
                altText: altText,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipeMediaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeMediaTableTable,
      RecipeMediaTableData,
      $$RecipeMediaTableTableFilterComposer,
      $$RecipeMediaTableTableOrderingComposer,
      $$RecipeMediaTableTableAnnotationComposer,
      $$RecipeMediaTableTableCreateCompanionBuilder,
      $$RecipeMediaTableTableUpdateCompanionBuilder,
      (
        RecipeMediaTableData,
        BaseReferences<
          _$AppDatabase,
          $RecipeMediaTableTable,
          RecipeMediaTableData
        >,
      ),
      RecipeMediaTableData,
      PrefetchHooks Function()
    >;
typedef $$CollectionsTableTableCreateCompanionBuilder =
    CollectionsTableCompanion Function({
      required String id,
      required String profileId,
      required String name,
      Value<String> colorToken,
      Value<String?> description,
      Value<int> sortOrder,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$CollectionsTableTableUpdateCompanionBuilder =
    CollectionsTableCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> name,
      Value<String> colorToken,
      Value<String?> description,
      Value<int> sortOrder,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

class $$CollectionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTableTable> {
  $$CollectionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorToken => $composableBuilder(
    column: $table.colorToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTableTable> {
  $$CollectionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorToken => $composableBuilder(
    column: $table.colorToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTableTable> {
  $$CollectionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorToken => $composableBuilder(
    column: $table.colorToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$CollectionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTableTable,
          CollectionsTableData,
          $$CollectionsTableTableFilterComposer,
          $$CollectionsTableTableOrderingComposer,
          $$CollectionsTableTableAnnotationComposer,
          $$CollectionsTableTableCreateCompanionBuilder,
          $$CollectionsTableTableUpdateCompanionBuilder,
          (
            CollectionsTableData,
            BaseReferences<
              _$AppDatabase,
              $CollectionsTableTable,
              CollectionsTableData
            >,
          ),
          CollectionsTableData,
          PrefetchHooks Function()
        > {
  $$CollectionsTableTableTableManager(
    _$AppDatabase db,
    $CollectionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> colorToken = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsTableCompanion(
                id: id,
                profileId: profileId,
                name: name,
                colorToken: colorToken,
                description: description,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String name,
                Value<String> colorToken = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsTableCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                colorToken: colorToken,
                description: description,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTableTable,
      CollectionsTableData,
      $$CollectionsTableTableFilterComposer,
      $$CollectionsTableTableOrderingComposer,
      $$CollectionsTableTableAnnotationComposer,
      $$CollectionsTableTableCreateCompanionBuilder,
      $$CollectionsTableTableUpdateCompanionBuilder,
      (
        CollectionsTableData,
        BaseReferences<
          _$AppDatabase,
          $CollectionsTableTable,
          CollectionsTableData
        >,
      ),
      CollectionsTableData,
      PrefetchHooks Function()
    >;
typedef $$CollectionRecipesTableTableCreateCompanionBuilder =
    CollectionRecipesTableCompanion Function({
      required String id,
      required String collectionId,
      required String recipeId,
      Value<int> position,
      required int addedAt,
      Value<int> rowid,
    });
typedef $$CollectionRecipesTableTableUpdateCompanionBuilder =
    CollectionRecipesTableCompanion Function({
      Value<String> id,
      Value<String> collectionId,
      Value<String> recipeId,
      Value<int> position,
      Value<int> addedAt,
      Value<int> rowid,
    });

class $$CollectionRecipesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionRecipesTableTable> {
  $$CollectionRecipesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionRecipesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionRecipesTableTable> {
  $$CollectionRecipesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionRecipesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionRecipesTableTable> {
  $$CollectionRecipesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$CollectionRecipesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionRecipesTableTable,
          CollectionRecipesTableData,
          $$CollectionRecipesTableTableFilterComposer,
          $$CollectionRecipesTableTableOrderingComposer,
          $$CollectionRecipesTableTableAnnotationComposer,
          $$CollectionRecipesTableTableCreateCompanionBuilder,
          $$CollectionRecipesTableTableUpdateCompanionBuilder,
          (
            CollectionRecipesTableData,
            BaseReferences<
              _$AppDatabase,
              $CollectionRecipesTableTable,
              CollectionRecipesTableData
            >,
          ),
          CollectionRecipesTableData,
          PrefetchHooks Function()
        > {
  $$CollectionRecipesTableTableTableManager(
    _$AppDatabase db,
    $CollectionRecipesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionRecipesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CollectionRecipesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CollectionRecipesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> collectionId = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionRecipesTableCompanion(
                id: id,
                collectionId: collectionId,
                recipeId: recipeId,
                position: position,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String collectionId,
                required String recipeId,
                Value<int> position = const Value.absent(),
                required int addedAt,
                Value<int> rowid = const Value.absent(),
              }) => CollectionRecipesTableCompanion.insert(
                id: id,
                collectionId: collectionId,
                recipeId: recipeId,
                position: position,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionRecipesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionRecipesTableTable,
      CollectionRecipesTableData,
      $$CollectionRecipesTableTableFilterComposer,
      $$CollectionRecipesTableTableOrderingComposer,
      $$CollectionRecipesTableTableAnnotationComposer,
      $$CollectionRecipesTableTableCreateCompanionBuilder,
      $$CollectionRecipesTableTableUpdateCompanionBuilder,
      (
        CollectionRecipesTableData,
        BaseReferences<
          _$AppDatabase,
          $CollectionRecipesTableTable,
          CollectionRecipesTableData
        >,
      ),
      CollectionRecipesTableData,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableTableCreateCompanionBuilder =
    FavoritesTableCompanion Function({
      required String id,
      required String profileId,
      required String recipeId,
      required int favoritedAt,
      Value<int> rowid,
    });
typedef $$FavoritesTableTableUpdateCompanionBuilder =
    FavoritesTableCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> recipeId,
      Value<int> favoritedAt,
      Value<int> rowid,
    });

class $$FavoritesTableTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTableTable> {
  $$FavoritesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get favoritedAt => $composableBuilder(
    column: $table.favoritedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTableTable> {
  $$FavoritesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get favoritedAt => $composableBuilder(
    column: $table.favoritedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTableTable> {
  $$FavoritesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<int> get favoritedAt => $composableBuilder(
    column: $table.favoritedAt,
    builder: (column) => column,
  );
}

class $$FavoritesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTableTable,
          FavoritesTableData,
          $$FavoritesTableTableFilterComposer,
          $$FavoritesTableTableOrderingComposer,
          $$FavoritesTableTableAnnotationComposer,
          $$FavoritesTableTableCreateCompanionBuilder,
          $$FavoritesTableTableUpdateCompanionBuilder,
          (
            FavoritesTableData,
            BaseReferences<
              _$AppDatabase,
              $FavoritesTableTable,
              FavoritesTableData
            >,
          ),
          FavoritesTableData,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableTableManager(
    _$AppDatabase db,
    $FavoritesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<int> favoritedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesTableCompanion(
                id: id,
                profileId: profileId,
                recipeId: recipeId,
                favoritedAt: favoritedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String recipeId,
                required int favoritedAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoritesTableCompanion.insert(
                id: id,
                profileId: profileId,
                recipeId: recipeId,
                favoritedAt: favoritedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTableTable,
      FavoritesTableData,
      $$FavoritesTableTableFilterComposer,
      $$FavoritesTableTableOrderingComposer,
      $$FavoritesTableTableAnnotationComposer,
      $$FavoritesTableTableCreateCompanionBuilder,
      $$FavoritesTableTableUpdateCompanionBuilder,
      (
        FavoritesTableData,
        BaseReferences<_$AppDatabase, $FavoritesTableTable, FavoritesTableData>,
      ),
      FavoritesTableData,
      PrefetchHooks Function()
    >;
typedef $$CookingSessionsTableTableCreateCompanionBuilder =
    CookingSessionsTableCompanion Function({
      required String id,
      required String profileId,
      required String recipeId,
      Value<String?> recipeVersionId,
      Value<String> status,
      Value<int> selectedServingsNum,
      Value<int> selectedServingsDen,
      Value<int> activeStepPosition,
      required int startedAt,
      required int lastResumedAt,
      Value<int?> completedAt,
      Value<bool> screenAwakeRequested,
      Value<bool> voiceMode,
      Value<int> rowid,
    });
typedef $$CookingSessionsTableTableUpdateCompanionBuilder =
    CookingSessionsTableCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> recipeId,
      Value<String?> recipeVersionId,
      Value<String> status,
      Value<int> selectedServingsNum,
      Value<int> selectedServingsDen,
      Value<int> activeStepPosition,
      Value<int> startedAt,
      Value<int> lastResumedAt,
      Value<int?> completedAt,
      Value<bool> screenAwakeRequested,
      Value<bool> voiceMode,
      Value<int> rowid,
    });

class $$CookingSessionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CookingSessionsTableTable> {
  $$CookingSessionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeVersionId => $composableBuilder(
    column: $table.recipeVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedServingsNum => $composableBuilder(
    column: $table.selectedServingsNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedServingsDen => $composableBuilder(
    column: $table.selectedServingsDen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeStepPosition => $composableBuilder(
    column: $table.activeStepPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastResumedAt => $composableBuilder(
    column: $table.lastResumedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get screenAwakeRequested => $composableBuilder(
    column: $table.screenAwakeRequested,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get voiceMode => $composableBuilder(
    column: $table.voiceMode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CookingSessionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CookingSessionsTableTable> {
  $$CookingSessionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeVersionId => $composableBuilder(
    column: $table.recipeVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedServingsNum => $composableBuilder(
    column: $table.selectedServingsNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedServingsDen => $composableBuilder(
    column: $table.selectedServingsDen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeStepPosition => $composableBuilder(
    column: $table.activeStepPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastResumedAt => $composableBuilder(
    column: $table.lastResumedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get screenAwakeRequested => $composableBuilder(
    column: $table.screenAwakeRequested,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get voiceMode => $composableBuilder(
    column: $table.voiceMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CookingSessionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CookingSessionsTableTable> {
  $$CookingSessionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get recipeVersionId => $composableBuilder(
    column: $table.recipeVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get selectedServingsNum => $composableBuilder(
    column: $table.selectedServingsNum,
    builder: (column) => column,
  );

  GeneratedColumn<int> get selectedServingsDen => $composableBuilder(
    column: $table.selectedServingsDen,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeStepPosition => $composableBuilder(
    column: $table.activeStepPosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get lastResumedAt => $composableBuilder(
    column: $table.lastResumedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get screenAwakeRequested => $composableBuilder(
    column: $table.screenAwakeRequested,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get voiceMode =>
      $composableBuilder(column: $table.voiceMode, builder: (column) => column);
}

class $$CookingSessionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CookingSessionsTableTable,
          CookingSessionsTableData,
          $$CookingSessionsTableTableFilterComposer,
          $$CookingSessionsTableTableOrderingComposer,
          $$CookingSessionsTableTableAnnotationComposer,
          $$CookingSessionsTableTableCreateCompanionBuilder,
          $$CookingSessionsTableTableUpdateCompanionBuilder,
          (
            CookingSessionsTableData,
            BaseReferences<
              _$AppDatabase,
              $CookingSessionsTableTable,
              CookingSessionsTableData
            >,
          ),
          CookingSessionsTableData,
          PrefetchHooks Function()
        > {
  $$CookingSessionsTableTableTableManager(
    _$AppDatabase db,
    $CookingSessionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CookingSessionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CookingSessionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CookingSessionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<String?> recipeVersionId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> selectedServingsNum = const Value.absent(),
                Value<int> selectedServingsDen = const Value.absent(),
                Value<int> activeStepPosition = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> lastResumedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<bool> screenAwakeRequested = const Value.absent(),
                Value<bool> voiceMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CookingSessionsTableCompanion(
                id: id,
                profileId: profileId,
                recipeId: recipeId,
                recipeVersionId: recipeVersionId,
                status: status,
                selectedServingsNum: selectedServingsNum,
                selectedServingsDen: selectedServingsDen,
                activeStepPosition: activeStepPosition,
                startedAt: startedAt,
                lastResumedAt: lastResumedAt,
                completedAt: completedAt,
                screenAwakeRequested: screenAwakeRequested,
                voiceMode: voiceMode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String recipeId,
                Value<String?> recipeVersionId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> selectedServingsNum = const Value.absent(),
                Value<int> selectedServingsDen = const Value.absent(),
                Value<int> activeStepPosition = const Value.absent(),
                required int startedAt,
                required int lastResumedAt,
                Value<int?> completedAt = const Value.absent(),
                Value<bool> screenAwakeRequested = const Value.absent(),
                Value<bool> voiceMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CookingSessionsTableCompanion.insert(
                id: id,
                profileId: profileId,
                recipeId: recipeId,
                recipeVersionId: recipeVersionId,
                status: status,
                selectedServingsNum: selectedServingsNum,
                selectedServingsDen: selectedServingsDen,
                activeStepPosition: activeStepPosition,
                startedAt: startedAt,
                lastResumedAt: lastResumedAt,
                completedAt: completedAt,
                screenAwakeRequested: screenAwakeRequested,
                voiceMode: voiceMode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CookingSessionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CookingSessionsTableTable,
      CookingSessionsTableData,
      $$CookingSessionsTableTableFilterComposer,
      $$CookingSessionsTableTableOrderingComposer,
      $$CookingSessionsTableTableAnnotationComposer,
      $$CookingSessionsTableTableCreateCompanionBuilder,
      $$CookingSessionsTableTableUpdateCompanionBuilder,
      (
        CookingSessionsTableData,
        BaseReferences<
          _$AppDatabase,
          $CookingSessionsTableTable,
          CookingSessionsTableData
        >,
      ),
      CookingSessionsTableData,
      PrefetchHooks Function()
    >;
typedef $$SessionIngredientChecksTableTableCreateCompanionBuilder =
    SessionIngredientChecksTableCompanion Function({
      required String id,
      required String sessionId,
      required String recipeIngredientId,
      Value<bool> isChecked,
      required int checkedAt,
      Value<int> rowid,
    });
typedef $$SessionIngredientChecksTableTableUpdateCompanionBuilder =
    SessionIngredientChecksTableCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> recipeIngredientId,
      Value<bool> isChecked,
      Value<int> checkedAt,
      Value<int> rowid,
    });

class $$SessionIngredientChecksTableTableFilterComposer
    extends Composer<_$AppDatabase, $SessionIngredientChecksTableTable> {
  $$SessionIngredientChecksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeIngredientId => $composableBuilder(
    column: $table.recipeIngredientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isChecked => $composableBuilder(
    column: $table.isChecked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionIngredientChecksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionIngredientChecksTableTable> {
  $$SessionIngredientChecksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeIngredientId => $composableBuilder(
    column: $table.recipeIngredientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isChecked => $composableBuilder(
    column: $table.isChecked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionIngredientChecksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionIngredientChecksTableTable> {
  $$SessionIngredientChecksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get recipeIngredientId => $composableBuilder(
    column: $table.recipeIngredientId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isChecked =>
      $composableBuilder(column: $table.isChecked, builder: (column) => column);

  GeneratedColumn<int> get checkedAt =>
      $composableBuilder(column: $table.checkedAt, builder: (column) => column);
}

class $$SessionIngredientChecksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionIngredientChecksTableTable,
          SessionIngredientChecksTableData,
          $$SessionIngredientChecksTableTableFilterComposer,
          $$SessionIngredientChecksTableTableOrderingComposer,
          $$SessionIngredientChecksTableTableAnnotationComposer,
          $$SessionIngredientChecksTableTableCreateCompanionBuilder,
          $$SessionIngredientChecksTableTableUpdateCompanionBuilder,
          (
            SessionIngredientChecksTableData,
            BaseReferences<
              _$AppDatabase,
              $SessionIngredientChecksTableTable,
              SessionIngredientChecksTableData
            >,
          ),
          SessionIngredientChecksTableData,
          PrefetchHooks Function()
        > {
  $$SessionIngredientChecksTableTableTableManager(
    _$AppDatabase db,
    $SessionIngredientChecksTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionIngredientChecksTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SessionIngredientChecksTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SessionIngredientChecksTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> recipeIngredientId = const Value.absent(),
                Value<bool> isChecked = const Value.absent(),
                Value<int> checkedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionIngredientChecksTableCompanion(
                id: id,
                sessionId: sessionId,
                recipeIngredientId: recipeIngredientId,
                isChecked: isChecked,
                checkedAt: checkedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String recipeIngredientId,
                Value<bool> isChecked = const Value.absent(),
                required int checkedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionIngredientChecksTableCompanion.insert(
                id: id,
                sessionId: sessionId,
                recipeIngredientId: recipeIngredientId,
                isChecked: isChecked,
                checkedAt: checkedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionIngredientChecksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionIngredientChecksTableTable,
      SessionIngredientChecksTableData,
      $$SessionIngredientChecksTableTableFilterComposer,
      $$SessionIngredientChecksTableTableOrderingComposer,
      $$SessionIngredientChecksTableTableAnnotationComposer,
      $$SessionIngredientChecksTableTableCreateCompanionBuilder,
      $$SessionIngredientChecksTableTableUpdateCompanionBuilder,
      (
        SessionIngredientChecksTableData,
        BaseReferences<
          _$AppDatabase,
          $SessionIngredientChecksTableTable,
          SessionIngredientChecksTableData
        >,
      ),
      SessionIngredientChecksTableData,
      PrefetchHooks Function()
    >;
typedef $$SessionTimersTableTableCreateCompanionBuilder =
    SessionTimersTableCompanion Function({
      required String id,
      required String sessionId,
      Value<String?> recipeStepId,
      required String label,
      required int durationSeconds,
      required int startedAt,
      required int endsAt,
      Value<String> status,
      Value<String?> notificationId,
      Value<int?> acknowledgedAt,
      Value<int> rowid,
    });
typedef $$SessionTimersTableTableUpdateCompanionBuilder =
    SessionTimersTableCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String?> recipeStepId,
      Value<String> label,
      Value<int> durationSeconds,
      Value<int> startedAt,
      Value<int> endsAt,
      Value<String> status,
      Value<String?> notificationId,
      Value<int?> acknowledgedAt,
      Value<int> rowid,
    });

class $$SessionTimersTableTableFilterComposer
    extends Composer<_$AppDatabase, $SessionTimersTableTable> {
  $$SessionTimersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeStepId => $composableBuilder(
    column: $table.recipeStepId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionTimersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionTimersTableTable> {
  $$SessionTimersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeStepId => $composableBuilder(
    column: $table.recipeStepId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionTimersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionTimersTableTable> {
  $$SessionTimersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get recipeStepId => $composableBuilder(
    column: $table.recipeStepId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endsAt =>
      $composableBuilder(column: $table.endsAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => column,
  );
}

class $$SessionTimersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionTimersTableTable,
          SessionTimersTableData,
          $$SessionTimersTableTableFilterComposer,
          $$SessionTimersTableTableOrderingComposer,
          $$SessionTimersTableTableAnnotationComposer,
          $$SessionTimersTableTableCreateCompanionBuilder,
          $$SessionTimersTableTableUpdateCompanionBuilder,
          (
            SessionTimersTableData,
            BaseReferences<
              _$AppDatabase,
              $SessionTimersTableTable,
              SessionTimersTableData
            >,
          ),
          SessionTimersTableData,
          PrefetchHooks Function()
        > {
  $$SessionTimersTableTableTableManager(
    _$AppDatabase db,
    $SessionTimersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionTimersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionTimersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionTimersTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String?> recipeStepId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> endsAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notificationId = const Value.absent(),
                Value<int?> acknowledgedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionTimersTableCompanion(
                id: id,
                sessionId: sessionId,
                recipeStepId: recipeStepId,
                label: label,
                durationSeconds: durationSeconds,
                startedAt: startedAt,
                endsAt: endsAt,
                status: status,
                notificationId: notificationId,
                acknowledgedAt: acknowledgedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                Value<String?> recipeStepId = const Value.absent(),
                required String label,
                required int durationSeconds,
                required int startedAt,
                required int endsAt,
                Value<String> status = const Value.absent(),
                Value<String?> notificationId = const Value.absent(),
                Value<int?> acknowledgedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionTimersTableCompanion.insert(
                id: id,
                sessionId: sessionId,
                recipeStepId: recipeStepId,
                label: label,
                durationSeconds: durationSeconds,
                startedAt: startedAt,
                endsAt: endsAt,
                status: status,
                notificationId: notificationId,
                acknowledgedAt: acknowledgedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionTimersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionTimersTableTable,
      SessionTimersTableData,
      $$SessionTimersTableTableFilterComposer,
      $$SessionTimersTableTableOrderingComposer,
      $$SessionTimersTableTableAnnotationComposer,
      $$SessionTimersTableTableCreateCompanionBuilder,
      $$SessionTimersTableTableUpdateCompanionBuilder,
      (
        SessionTimersTableData,
        BaseReferences<
          _$AppDatabase,
          $SessionTimersTableTable,
          SessionTimersTableData
        >,
      ),
      SessionTimersTableData,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      required String id,
      required String profileId,
      required String key,
      required String valueJson,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> key,
      Value<String> valueJson,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsTableTable,
              AppSettingsTableData
            >,
          ),
          AppSettingsTableData,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$AppDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion(
                id: id,
                profileId: profileId,
                key: key,
                valueJson: valueJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String key,
                required String valueJson,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                id: id,
                profileId: profileId,
                key: key,
                valueJson: valueJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTableTable,
      AppSettingsTableData,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData
        >,
      ),
      AppSettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$PermissionStatesTableTableCreateCompanionBuilder =
    PermissionStatesTableCompanion Function({
      required String id,
      required String profileId,
      required String capability,
      required String osState,
      required int promptedAt,
      required int updatedAt,
      Value<bool> explanationSeen,
      Value<int> rowid,
    });
typedef $$PermissionStatesTableTableUpdateCompanionBuilder =
    PermissionStatesTableCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> capability,
      Value<String> osState,
      Value<int> promptedAt,
      Value<int> updatedAt,
      Value<bool> explanationSeen,
      Value<int> rowid,
    });

class $$PermissionStatesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PermissionStatesTableTable> {
  $$PermissionStatesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capability => $composableBuilder(
    column: $table.capability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get osState => $composableBuilder(
    column: $table.osState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get promptedAt => $composableBuilder(
    column: $table.promptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get explanationSeen => $composableBuilder(
    column: $table.explanationSeen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PermissionStatesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PermissionStatesTableTable> {
  $$PermissionStatesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capability => $composableBuilder(
    column: $table.capability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get osState => $composableBuilder(
    column: $table.osState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get promptedAt => $composableBuilder(
    column: $table.promptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get explanationSeen => $composableBuilder(
    column: $table.explanationSeen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PermissionStatesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PermissionStatesTableTable> {
  $$PermissionStatesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get capability => $composableBuilder(
    column: $table.capability,
    builder: (column) => column,
  );

  GeneratedColumn<String> get osState =>
      $composableBuilder(column: $table.osState, builder: (column) => column);

  GeneratedColumn<int> get promptedAt => $composableBuilder(
    column: $table.promptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get explanationSeen => $composableBuilder(
    column: $table.explanationSeen,
    builder: (column) => column,
  );
}

class $$PermissionStatesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PermissionStatesTableTable,
          PermissionStatesTableData,
          $$PermissionStatesTableTableFilterComposer,
          $$PermissionStatesTableTableOrderingComposer,
          $$PermissionStatesTableTableAnnotationComposer,
          $$PermissionStatesTableTableCreateCompanionBuilder,
          $$PermissionStatesTableTableUpdateCompanionBuilder,
          (
            PermissionStatesTableData,
            BaseReferences<
              _$AppDatabase,
              $PermissionStatesTableTable,
              PermissionStatesTableData
            >,
          ),
          PermissionStatesTableData,
          PrefetchHooks Function()
        > {
  $$PermissionStatesTableTableTableManager(
    _$AppDatabase db,
    $PermissionStatesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PermissionStatesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PermissionStatesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PermissionStatesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> capability = const Value.absent(),
                Value<String> osState = const Value.absent(),
                Value<int> promptedAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> explanationSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PermissionStatesTableCompanion(
                id: id,
                profileId: profileId,
                capability: capability,
                osState: osState,
                promptedAt: promptedAt,
                updatedAt: updatedAt,
                explanationSeen: explanationSeen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String capability,
                required String osState,
                required int promptedAt,
                required int updatedAt,
                Value<bool> explanationSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PermissionStatesTableCompanion.insert(
                id: id,
                profileId: profileId,
                capability: capability,
                osState: osState,
                promptedAt: promptedAt,
                updatedAt: updatedAt,
                explanationSeen: explanationSeen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PermissionStatesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PermissionStatesTableTable,
      PermissionStatesTableData,
      $$PermissionStatesTableTableFilterComposer,
      $$PermissionStatesTableTableOrderingComposer,
      $$PermissionStatesTableTableAnnotationComposer,
      $$PermissionStatesTableTableCreateCompanionBuilder,
      $$PermissionStatesTableTableUpdateCompanionBuilder,
      (
        PermissionStatesTableData,
        BaseReferences<
          _$AppDatabase,
          $PermissionStatesTableTable,
          PermissionStatesTableData
        >,
      ),
      PermissionStatesTableData,
      PrefetchHooks Function()
    >;
typedef $$ChangeOperationsTableTableCreateCompanionBuilder =
    ChangeOperationsTableCompanion Function({
      required String operationId,
      required String profileId,
      required String entityType,
      required String entityId,
      required String opType,
      required int baseVersion,
      required String payloadJson,
      required String fieldPathsJson,
      required int occurredAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$ChangeOperationsTableTableUpdateCompanionBuilder =
    ChangeOperationsTableCompanion Function({
      Value<String> operationId,
      Value<String> profileId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> opType,
      Value<int> baseVersion,
      Value<String> payloadJson,
      Value<String> fieldPathsJson,
      Value<int> occurredAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$ChangeOperationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ChangeOperationsTableTable> {
  $$ChangeOperationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldPathsJson => $composableBuilder(
    column: $table.fieldPathsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChangeOperationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ChangeOperationsTableTable> {
  $$ChangeOperationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldPathsJson => $composableBuilder(
    column: $table.fieldPathsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChangeOperationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChangeOperationsTableTable> {
  $$ChangeOperationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fieldPathsJson => $composableBuilder(
    column: $table.fieldPathsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$ChangeOperationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChangeOperationsTableTable,
          ChangeOperationsTableData,
          $$ChangeOperationsTableTableFilterComposer,
          $$ChangeOperationsTableTableOrderingComposer,
          $$ChangeOperationsTableTableAnnotationComposer,
          $$ChangeOperationsTableTableCreateCompanionBuilder,
          $$ChangeOperationsTableTableUpdateCompanionBuilder,
          (
            ChangeOperationsTableData,
            BaseReferences<
              _$AppDatabase,
              $ChangeOperationsTableTable,
              ChangeOperationsTableData
            >,
          ),
          ChangeOperationsTableData,
          PrefetchHooks Function()
        > {
  $$ChangeOperationsTableTableTableManager(
    _$AppDatabase db,
    $ChangeOperationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChangeOperationsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ChangeOperationsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ChangeOperationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> operationId = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> opType = const Value.absent(),
                Value<int> baseVersion = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> fieldPathsJson = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChangeOperationsTableCompanion(
                operationId: operationId,
                profileId: profileId,
                entityType: entityType,
                entityId: entityId,
                opType: opType,
                baseVersion: baseVersion,
                payloadJson: payloadJson,
                fieldPathsJson: fieldPathsJson,
                occurredAt: occurredAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String operationId,
                required String profileId,
                required String entityType,
                required String entityId,
                required String opType,
                required int baseVersion,
                required String payloadJson,
                required String fieldPathsJson,
                required int occurredAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChangeOperationsTableCompanion.insert(
                operationId: operationId,
                profileId: profileId,
                entityType: entityType,
                entityId: entityId,
                opType: opType,
                baseVersion: baseVersion,
                payloadJson: payloadJson,
                fieldPathsJson: fieldPathsJson,
                occurredAt: occurredAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChangeOperationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChangeOperationsTableTable,
      ChangeOperationsTableData,
      $$ChangeOperationsTableTableFilterComposer,
      $$ChangeOperationsTableTableOrderingComposer,
      $$ChangeOperationsTableTableAnnotationComposer,
      $$ChangeOperationsTableTableCreateCompanionBuilder,
      $$ChangeOperationsTableTableUpdateCompanionBuilder,
      (
        ChangeOperationsTableData,
        BaseReferences<
          _$AppDatabase,
          $ChangeOperationsTableTable,
          ChangeOperationsTableData
        >,
      ),
      ChangeOperationsTableData,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableTableCreateCompanionBuilder =
    SyncCursorsTableCompanion Function({
      required String profileId,
      required String scope,
      required String cursor,
      Value<int?> lastSuccessAt,
      Value<String?> lastErrorCode,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableTableUpdateCompanionBuilder =
    SyncCursorsTableCompanion Function({
      Value<String> profileId,
      Value<String> scope,
      Value<String> cursor,
      Value<int?> lastSuccessAt,
      Value<String?> lastErrorCode,
      Value<int> rowid,
    });

class $$SyncCursorsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTableTable> {
  $$SyncCursorsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTableTable> {
  $$SyncCursorsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTableTable> {
  $$SyncCursorsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<int> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );
}

class $$SyncCursorsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTableTable,
          SyncCursorsTableData,
          $$SyncCursorsTableTableFilterComposer,
          $$SyncCursorsTableTableOrderingComposer,
          $$SyncCursorsTableTableAnnotationComposer,
          $$SyncCursorsTableTableCreateCompanionBuilder,
          $$SyncCursorsTableTableUpdateCompanionBuilder,
          (
            SyncCursorsTableData,
            BaseReferences<
              _$AppDatabase,
              $SyncCursorsTableTable,
              SyncCursorsTableData
            >,
          ),
          SyncCursorsTableData,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableTableManager(
    _$AppDatabase db,
    $SyncCursorsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<String> cursor = const Value.absent(),
                Value<int?> lastSuccessAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsTableCompanion(
                profileId: profileId,
                scope: scope,
                cursor: cursor,
                lastSuccessAt: lastSuccessAt,
                lastErrorCode: lastErrorCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String scope,
                required String cursor,
                Value<int?> lastSuccessAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsTableCompanion.insert(
                profileId: profileId,
                scope: scope,
                cursor: cursor,
                lastSuccessAt: lastSuccessAt,
                lastErrorCode: lastErrorCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTableTable,
      SyncCursorsTableData,
      $$SyncCursorsTableTableFilterComposer,
      $$SyncCursorsTableTableOrderingComposer,
      $$SyncCursorsTableTableAnnotationComposer,
      $$SyncCursorsTableTableCreateCompanionBuilder,
      $$SyncCursorsTableTableUpdateCompanionBuilder,
      (
        SyncCursorsTableData,
        BaseReferences<
          _$AppDatabase,
          $SyncCursorsTableTable,
          SyncCursorsTableData
        >,
      ),
      SyncCursorsTableData,
      PrefetchHooks Function()
    >;
typedef $$FoodLogEntriesTableTableCreateCompanionBuilder =
    FoodLogEntriesTableCompanion Function({
      required String id,
      Value<String> profileId,
      required String dayKey,
      Value<String> mealSlot,
      required String title,
      Value<String> source,
      Value<String?> recipeId,
      Value<String?> imagePath,
      Value<double> portionMultiplier,
      Value<double> calories,
      Value<double> proteinG,
      Value<double> carbsG,
      Value<double> fatG,
      Value<double> fiberG,
      Value<double> sugarG,
      Value<double> sodiumMg,
      Value<String> analysisJson,
      required int loggedAt,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$FoodLogEntriesTableTableUpdateCompanionBuilder =
    FoodLogEntriesTableCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> dayKey,
      Value<String> mealSlot,
      Value<String> title,
      Value<String> source,
      Value<String?> recipeId,
      Value<String?> imagePath,
      Value<double> portionMultiplier,
      Value<double> calories,
      Value<double> proteinG,
      Value<double> carbsG,
      Value<double> fatG,
      Value<double> fiberG,
      Value<double> sugarG,
      Value<double> sodiumMg,
      Value<String> analysisJson,
      Value<int> loggedAt,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$FoodLogEntriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $FoodLogEntriesTableTable> {
  $$FoodLogEntriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealSlot => $composableBuilder(
    column: $table.mealSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get portionMultiplier => $composableBuilder(
    column: $table.portionMultiplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberG => $composableBuilder(
    column: $table.fiberG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugarG => $composableBuilder(
    column: $table.sugarG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodiumMg => $composableBuilder(
    column: $table.sodiumMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analysisJson => $composableBuilder(
    column: $table.analysisJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodLogEntriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodLogEntriesTableTable> {
  $$FoodLogEntriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealSlot => $composableBuilder(
    column: $table.mealSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get portionMultiplier => $composableBuilder(
    column: $table.portionMultiplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberG => $composableBuilder(
    column: $table.fiberG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugarG => $composableBuilder(
    column: $table.sugarG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodiumMg => $composableBuilder(
    column: $table.sodiumMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisJson => $composableBuilder(
    column: $table.analysisJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodLogEntriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodLogEntriesTableTable> {
  $$FoodLogEntriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<String> get mealSlot =>
      $composableBuilder(column: $table.mealSlot, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<double> get portionMultiplier => $composableBuilder(
    column: $table.portionMultiplier,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  GeneratedColumn<double> get fiberG =>
      $composableBuilder(column: $table.fiberG, builder: (column) => column);

  GeneratedColumn<double> get sugarG =>
      $composableBuilder(column: $table.sugarG, builder: (column) => column);

  GeneratedColumn<double> get sodiumMg =>
      $composableBuilder(column: $table.sodiumMg, builder: (column) => column);

  GeneratedColumn<String> get analysisJson => $composableBuilder(
    column: $table.analysisJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FoodLogEntriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodLogEntriesTableTable,
          FoodLogEntriesTableData,
          $$FoodLogEntriesTableTableFilterComposer,
          $$FoodLogEntriesTableTableOrderingComposer,
          $$FoodLogEntriesTableTableAnnotationComposer,
          $$FoodLogEntriesTableTableCreateCompanionBuilder,
          $$FoodLogEntriesTableTableUpdateCompanionBuilder,
          (
            FoodLogEntriesTableData,
            BaseReferences<
              _$AppDatabase,
              $FoodLogEntriesTableTable,
              FoodLogEntriesTableData
            >,
          ),
          FoodLogEntriesTableData,
          PrefetchHooks Function()
        > {
  $$FoodLogEntriesTableTableTableManager(
    _$AppDatabase db,
    $FoodLogEntriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodLogEntriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodLogEntriesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FoodLogEntriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> dayKey = const Value.absent(),
                Value<String> mealSlot = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> recipeId = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<double> portionMultiplier = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> proteinG = const Value.absent(),
                Value<double> carbsG = const Value.absent(),
                Value<double> fatG = const Value.absent(),
                Value<double> fiberG = const Value.absent(),
                Value<double> sugarG = const Value.absent(),
                Value<double> sodiumMg = const Value.absent(),
                Value<String> analysisJson = const Value.absent(),
                Value<int> loggedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodLogEntriesTableCompanion(
                id: id,
                profileId: profileId,
                dayKey: dayKey,
                mealSlot: mealSlot,
                title: title,
                source: source,
                recipeId: recipeId,
                imagePath: imagePath,
                portionMultiplier: portionMultiplier,
                calories: calories,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                fiberG: fiberG,
                sugarG: sugarG,
                sodiumMg: sodiumMg,
                analysisJson: analysisJson,
                loggedAt: loggedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> profileId = const Value.absent(),
                required String dayKey,
                Value<String> mealSlot = const Value.absent(),
                required String title,
                Value<String> source = const Value.absent(),
                Value<String?> recipeId = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<double> portionMultiplier = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> proteinG = const Value.absent(),
                Value<double> carbsG = const Value.absent(),
                Value<double> fatG = const Value.absent(),
                Value<double> fiberG = const Value.absent(),
                Value<double> sugarG = const Value.absent(),
                Value<double> sodiumMg = const Value.absent(),
                Value<String> analysisJson = const Value.absent(),
                required int loggedAt,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FoodLogEntriesTableCompanion.insert(
                id: id,
                profileId: profileId,
                dayKey: dayKey,
                mealSlot: mealSlot,
                title: title,
                source: source,
                recipeId: recipeId,
                imagePath: imagePath,
                portionMultiplier: portionMultiplier,
                calories: calories,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                fiberG: fiberG,
                sugarG: sugarG,
                sodiumMg: sodiumMg,
                analysisJson: analysisJson,
                loggedAt: loggedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodLogEntriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodLogEntriesTableTable,
      FoodLogEntriesTableData,
      $$FoodLogEntriesTableTableFilterComposer,
      $$FoodLogEntriesTableTableOrderingComposer,
      $$FoodLogEntriesTableTableAnnotationComposer,
      $$FoodLogEntriesTableTableCreateCompanionBuilder,
      $$FoodLogEntriesTableTableUpdateCompanionBuilder,
      (
        FoodLogEntriesTableData,
        BaseReferences<
          _$AppDatabase,
          $FoodLogEntriesTableTable,
          FoodLogEntriesTableData
        >,
      ),
      FoodLogEntriesTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableTableManager get profilesTable =>
      $$ProfilesTableTableTableManager(_db, _db.profilesTable);
  $$RecipesTableTableTableManager get recipesTable =>
      $$RecipesTableTableTableManager(_db, _db.recipesTable);
  $$RecipeVersionsTableTableTableManager get recipeVersionsTable =>
      $$RecipeVersionsTableTableTableManager(_db, _db.recipeVersionsTable);
  $$RecipeNotesTableTableTableManager get recipeNotesTable =>
      $$RecipeNotesTableTableTableManager(_db, _db.recipeNotesTable);
  $$IngredientsCatalogTableTableTableManager get ingredientsCatalogTable =>
      $$IngredientsCatalogTableTableTableManager(
        _db,
        _db.ingredientsCatalogTable,
      );
  $$UnitsCatalogTableTableTableManager get unitsCatalogTable =>
      $$UnitsCatalogTableTableTableManager(_db, _db.unitsCatalogTable);
  $$RecipeIngredientsTableTableTableManager get recipeIngredientsTable =>
      $$RecipeIngredientsTableTableTableManager(
        _db,
        _db.recipeIngredientsTable,
      );
  $$RecipeStepsTableTableTableManager get recipeStepsTable =>
      $$RecipeStepsTableTableTableManager(_db, _db.recipeStepsTable);
  $$StepTimersTableTableTableManager get stepTimersTable =>
      $$StepTimersTableTableTableManager(_db, _db.stepTimersTable);
  $$ToolsCatalogTableTableTableManager get toolsCatalogTable =>
      $$ToolsCatalogTableTableTableManager(_db, _db.toolsCatalogTable);
  $$RecipeToolsTableTableTableManager get recipeToolsTable =>
      $$RecipeToolsTableTableTableManager(_db, _db.recipeToolsTable);
  $$LabelsTableTableTableManager get labelsTable =>
      $$LabelsTableTableTableManager(_db, _db.labelsTable);
  $$RecipeLabelsTableTableTableManager get recipeLabelsTable =>
      $$RecipeLabelsTableTableTableManager(_db, _db.recipeLabelsTable);
  $$RecipeMediaTableTableTableManager get recipeMediaTable =>
      $$RecipeMediaTableTableTableManager(_db, _db.recipeMediaTable);
  $$CollectionsTableTableTableManager get collectionsTable =>
      $$CollectionsTableTableTableManager(_db, _db.collectionsTable);
  $$CollectionRecipesTableTableTableManager get collectionRecipesTable =>
      $$CollectionRecipesTableTableTableManager(
        _db,
        _db.collectionRecipesTable,
      );
  $$FavoritesTableTableTableManager get favoritesTable =>
      $$FavoritesTableTableTableManager(_db, _db.favoritesTable);
  $$CookingSessionsTableTableTableManager get cookingSessionsTable =>
      $$CookingSessionsTableTableTableManager(_db, _db.cookingSessionsTable);
  $$SessionIngredientChecksTableTableTableManager
  get sessionIngredientChecksTable =>
      $$SessionIngredientChecksTableTableTableManager(
        _db,
        _db.sessionIngredientChecksTable,
      );
  $$SessionTimersTableTableTableManager get sessionTimersTable =>
      $$SessionTimersTableTableTableManager(_db, _db.sessionTimersTable);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
  $$PermissionStatesTableTableTableManager get permissionStatesTable =>
      $$PermissionStatesTableTableTableManager(_db, _db.permissionStatesTable);
  $$ChangeOperationsTableTableTableManager get changeOperationsTable =>
      $$ChangeOperationsTableTableTableManager(_db, _db.changeOperationsTable);
  $$SyncCursorsTableTableTableManager get syncCursorsTable =>
      $$SyncCursorsTableTableTableManager(_db, _db.syncCursorsTable);
  $$FoodLogEntriesTableTableTableManager get foodLogEntriesTable =>
      $$FoodLogEntriesTableTableTableManager(_db, _db.foodLogEntriesTable);
}
