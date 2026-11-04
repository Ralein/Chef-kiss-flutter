import 'package:drift/drift.dart';

// --- Identity & Recipe Core ---

class ProfilesTable extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text().withDefault(const Constant('Local Cook'))();
  TextColumn get locale => text().withDefault(const Constant('en'))();
  TextColumn get unitSystem => text().withDefault(const Constant('metric'))();
  IntColumn get settingsVersion => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipesTable extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text()();
  TextColumn get currentVersionId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get slug => text().nullable()();
  TextColumn get summary => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('draft'))(); // draft, ready, archived
  IntColumn get baseServingsNum => integer().withDefault(const Constant(2))();
  IntColumn get baseServingsDen => integer().withDefault(const Constant(1))();
  TextColumn get difficulty => text().withDefault(const Constant('medium'))();
  IntColumn get totalMinutes => integer().withDefault(const Constant(0))();
  TextColumn get coverMediaId => text().nullable()();
  TextColumn get visualTemplate => text().nullable()();
  TextColumn get visualStyleVersion => text().withDefault(const Constant('v1'))();
  BoolColumn get isCurated => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get origin => text().withDefault(const Constant('manual'))();
  TextColumn get provenanceJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipeVersionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()();
  IntColumn get sequence => integer()();
  TextColumn get snapshotJson => text()();
  TextColumn get changeSummary => text().nullable()();
  TextColumn get authorKind => text().withDefault(const Constant('manual'))();
  TextColumn get parentVersionId => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipeNotesTable extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()();
  TextColumn get body => text()();
  TextColumn get noteType => text().withDefault(const Constant('user'))();
  IntColumn get position => integer()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class IngredientsCatalogTable extends Table {
  TextColumn get id => text()();
  TextColumn get canonicalName => text()();
  TextColumn get pluralName => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get synonymsJson => text().withDefault(const Constant('[]'))();
  TextColumn get defaultScalingPolicy => text().withDefault(const Constant('scale'))();
  TextColumn get allergenJson => text().withDefault(const Constant('[]'))();
  TextColumn get searchTerms => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UnitsCatalogTable extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get dimension => text()(); // mass, volume, count, authored
  TextColumn get displayMetric => text()();
  TextColumn get displayUs => text()();
  IntColumn get toBaseNum => integer().withDefault(const Constant(1))();
  IntColumn get toBaseDen => integer().withDefault(const Constant(1))();
  BoolColumn get isScalable => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipeIngredientsTable extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()();
  TextColumn get catalogIngredientId => text().nullable()();
  TextColumn get displayName => text()();
  IntColumn get quantityNum => integer().nullable()();
  IntColumn get quantityDen => integer().nullable()();
  TextColumn get unitCode => text().nullable()();
  TextColumn get authoredQuantity => text().nullable()();
  TextColumn get scalingPolicy => text().withDefault(const Constant('scale'))();
  TextColumn get prepText => text().nullable()();
  BoolColumn get isOptional => boolean().withDefault(const Constant(false))();
  IntColumn get position => integer()();
  TextColumn get groupKey => text().nullable()();
  TextColumn get allergenOverrideJson => text().nullable()();
  TextColumn get illustrationKey => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipeStepsTable extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()();
  IntColumn get position => integer()();
  TextColumn get instructionShort => text()();
  TextColumn get instructionDetail => text().nullable()();
  TextColumn get spokenInstruction => text().nullable()();
  TextColumn get actionKey => text().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  IntColumn get temperatureC => integer().nullable()();
  IntColumn get temperatureF => integer().nullable()();
  TextColumn get layoutHint => text().nullable()();
  TextColumn get safetyJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class StepTimersTable extends Table {
  TextColumn get id => text()();
  TextColumn get recipeStepId => text()();
  TextColumn get label => text()();
  IntColumn get durationSeconds => integer()();
  BoolColumn get autoStart => boolean().withDefault(const Constant(false))();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class ToolsCatalogTable extends Table {
  TextColumn get id => text()();
  TextColumn get canonicalName => text()();
  TextColumn get category => text().nullable()();
  TextColumn get synonymsJson => text().withDefault(const Constant('[]'))();
  TextColumn get illustrationKey => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipeToolsTable extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()();
  TextColumn get toolId => text().nullable()();
  TextColumn get displayName => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  BoolColumn get isRequired => boolean().withDefault(const Constant(true))();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class LabelsTable extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()(); // tag, cuisine, dietary, allergen, difficulty
  TextColumn get canonicalKey => text()();
  TextColumn get displayName => text()();
  TextColumn get iconKey => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipeLabelsTable extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()();
  TextColumn get labelId => text()();
  RealColumn get sourceConfidence => real().withDefault(const Constant(1.0))();
  BoolColumn get isUserConfirmed => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipeMediaTable extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()();
  TextColumn get kind => text()();
  TextColumn get storageKind => text()(); // bundled, local, cache
  TextColumn get relativePath => text()();
  TextColumn get mimeType => text()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  TextColumn get sha256 => text().nullable()();
  TextColumn get caption => text().nullable()();
  TextColumn get altText => text().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class CollectionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text()();
  TextColumn get name => text()();
  TextColumn get colorToken => text().withDefault(const Constant('accent.herb'))();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CollectionRecipesTable extends Table {
  TextColumn get id => text()();
  TextColumn get collectionId => text()();
  TextColumn get recipeId => text()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  IntColumn get addedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class FavoritesTable extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text()();
  TextColumn get recipeId => text()();
  IntColumn get favoritedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class CookingSessionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text()();
  TextColumn get recipeId => text()();
  TextColumn get recipeVersionId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get selectedServingsNum => integer().withDefault(const Constant(2))();
  IntColumn get selectedServingsDen => integer().withDefault(const Constant(1))();
  IntColumn get activeStepPosition => integer().withDefault(const Constant(1))();
  IntColumn get startedAt => integer()();
  IntColumn get lastResumedAt => integer()();
  IntColumn get completedAt => integer().nullable()();
  BoolColumn get screenAwakeRequested => boolean().withDefault(const Constant(true))();
  BoolColumn get voiceMode => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class SessionIngredientChecksTable extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get recipeIngredientId => text()();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  IntColumn get checkedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class SessionTimersTable extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get recipeStepId => text().nullable()();
  TextColumn get label => text()();
  IntColumn get durationSeconds => integer()();
  IntColumn get startedAt => integer()();
  IntColumn get endsAt => integer()(); // UTC epoch ms
  TextColumn get status => text().withDefault(const Constant('running'))();
  TextColumn get notificationId => text().nullable()();
  IntColumn get acknowledgedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettingsTable extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text()();
  TextColumn get key => text()();
  TextColumn get valueJson => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class PermissionStatesTable extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text()();
  TextColumn get capability => text()();
  TextColumn get osState => text()();
  IntColumn get promptedAt => integer()();
  IntColumn get updatedAt => integer()();
  BoolColumn get explanationSeen => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ChangeOperationsTable extends Table {
  TextColumn get operationId => text()();
  TextColumn get profileId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get opType => text()();
  IntColumn get baseVersion => integer()();
  TextColumn get payloadJson => text()();
  TextColumn get fieldPathsJson => text()();
  IntColumn get occurredAt => integer()();
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();

  @override
  Set<Column> get primaryKey => {operationId};
}

class SyncCursorsTable extends Table {
  TextColumn get profileId => text()();
  TextColumn get scope => text()();
  TextColumn get cursor => text()();
  IntColumn get lastSuccessAt => integer().nullable()();
  TextColumn get lastErrorCode => text().nullable()();

  @override
  Set<Column> get primaryKey => {profileId, scope};
}


// --- Nutrition / Food Log (schema v2) ---

/// One eaten meal or snack. Nutrient columns hold what was actually eaten
/// (base estimate × [portionMultiplier]) so daily totals are a plain SUM.
@TableIndex(name: 'food_log_by_day', columns: {#profileId, #dayKey})
class FoodLogEntriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text().withDefault(const Constant('default'))();

  /// Local calendar day the food was eaten, `YYYY-MM-DD`.
  TextColumn get dayKey => text()();
  TextColumn get mealSlot => text().withDefault(const Constant('snack'))(); // breakfast|lunch|dinner|snack
  TextColumn get title => text()();
  TextColumn get source => text().withDefault(const Constant('scan'))(); // scan|recipe|manual
  TextColumn get recipeId => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  RealColumn get portionMultiplier => real().withDefault(const Constant(1.0))();
  RealColumn get calories => real().withDefault(const Constant(0.0))();
  RealColumn get proteinG => real().withDefault(const Constant(0.0))();
  RealColumn get carbsG => real().withDefault(const Constant(0.0))();
  RealColumn get fatG => real().withDefault(const Constant(0.0))();
  RealColumn get fiberG => real().withDefault(const Constant(0.0))();
  RealColumn get sugarG => real().withDefault(const Constant(0.0))();
  RealColumn get sodiumMg => real().withDefault(const Constant(0.0))();

  /// Snapshot of the analysis the entry was created from (FoodAnalysis JSON).
  TextColumn get analysisJson => text().withDefault(const Constant('{}'))();
  IntColumn get loggedAt => integer()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
