import 'package:drift/drift.dart';
import 'tables/tables.dart';
import 'connection/connection.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  ProfilesTable,
  RecipesTable,
  RecipeVersionsTable,
  RecipeNotesTable,
  IngredientsCatalogTable,
  UnitsCatalogTable,
  RecipeIngredientsTable,
  RecipeStepsTable,
  StepTimersTable,
  ToolsCatalogTable,
  RecipeToolsTable,
  LabelsTable,
  RecipeLabelsTable,
  RecipeMediaTable,
  CollectionsTable,
  CollectionRecipesTable,
  FavoritesTable,
  CookingSessionsTable,
  SessionIngredientChecksTable,
  SessionTimersTable,
  AppSettingsTable,
  PermissionStatesTable,
  ChangeOperationsTable,
  SyncCursorsTable,
  FoodLogEntriesTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.defaults() {
    return AppDatabase(openDefaultConnection());
  }

  /// A throw-away database that lives only in memory. Used by tests and
  /// previews; it never touches the user's real database file.
  factory AppDatabase.inMemory([QueryExecutor? executor]) {
    return AppDatabase(executor ?? openInMemoryConnection());
  }

  /// v1: initial schema.
  /// v2: food log (`food_log_entries_table`) for scanned / logged meals.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _createSearchIndex();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(foodLogEntriesTable);
          await m.createIndex(foodLogByDay);
        }
      },
    );
  }

  Future<void> _createSearchIndex() async {
    try {
      await customStatement('''
        CREATE VIRTUAL TABLE IF NOT EXISTS recipe_search_fts USING fts5(
          recipe_id UNINDEXED,
          title,
          summary,
          ingredients_text,
          tags_text
        );
      ''');
    } catch (_) {
      // Some SQLite builds (e.g. certain web/wasm bundles) lack FTS5.
    }
  }
}
