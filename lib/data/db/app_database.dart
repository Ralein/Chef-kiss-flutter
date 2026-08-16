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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.defaults() {
    return AppDatabase(openDefaultConnection());
  }

  factory AppDatabase.inMemory([QueryExecutor? executor]) {
    return AppDatabase(executor ?? openDefaultConnection());
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        // Create FTS5 table if supported
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
          // In-memory or web mock might not have fts5 compiled, graceful fallback
        }
      },
    );
  }
}
