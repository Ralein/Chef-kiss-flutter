import 'package:drift/drift.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import 'package:uuid/uuid.dart';
import '../db/app_database.dart';

class DriftCollectionRepository implements CollectionRepository {
  final AppDatabase db;
  final Uuid _uuid = const Uuid();

  DriftCollectionRepository(this.db);

  /// One join query that reads from both the collections and membership
  /// tables, so adding/removing a recipe re-emits (previously only edits to
  /// the collection row itself did).
  @override
  Stream<List<RecipeCollection>> watchCollections() {
    final query = db.select(db.collectionsTable).join([
      leftOuterJoin(db.collectionRecipesTable, db.collectionRecipesTable.collectionId.equalsExp(db.collectionsTable.id)),
    ])
      ..where(db.collectionsTable.deletedAt.isNull())
      ..orderBy([
        OrderingTerm.asc(db.collectionsTable.sortOrder),
        OrderingTerm.asc(db.collectionsTable.createdAt),
        OrderingTerm.asc(db.collectionRecipesTable.position),
      ]);

    return query.watch().map((rows) {
      final byId = <String, CollectionsTableData>{};
      final members = <String, List<String>>{};
      for (final row in rows) {
        final col = row.readTable(db.collectionsTable);
        byId.putIfAbsent(col.id, () => col);
        final link = row.readTableOrNull(db.collectionRecipesTable);
        final list = members.putIfAbsent(col.id, () => []);
        if (link != null && !list.contains(link.recipeId)) list.add(link.recipeId);
      }
      return byId.values
          .map((row) => RecipeCollection(
                id: row.id,
                profileId: row.profileId,
                name: row.name,
                colorToken: row.colorToken,
                description: row.description,
                sortOrder: row.sortOrder,
                createdAt: row.createdAt,
                updatedAt: row.updatedAt,
                recipeIds: members[row.id] ?? const [],
              ))
          .toList(growable: false);
    });
  }

  @override
  Future<Result<List<RecipeCollection>, AppFailure>> getCollections() async {
    try {
      final list = await watchCollections().first;
      return Result.ok(list);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to fetch collections: $e', cause: e));
    }
  }

  @override
  Future<Result<RecipeCollection, AppFailure>> createCollection({
    required String profileId,
    required String name,
    required String colorToken,
    String? description,
  }) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final id = _uuid.v4();

      await db.into(db.collectionsTable).insert(
            CollectionsTableCompanion(
              id: Value(id),
              profileId: Value(profileId.isEmpty ? 'default' : profileId),
              name: Value(name),
              colorToken: Value(colorToken),
              description: Value(description),
              sortOrder: const Value(0),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      return Result.ok(RecipeCollection(
        id: id,
        profileId: profileId.isEmpty ? 'default' : profileId,
        name: name,
        colorToken: colorToken,
        description: description,
        createdAt: now,
        updatedAt: now,
      ));
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to create collection: $e', cause: e));
    }
  }

  @override
  Future<Result<RecipeCollection, AppFailure>> updateCollection(RecipeCollection collection) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (db.update(db.collectionsTable)..where((c) => c.id.equals(collection.id))).write(
        CollectionsTableCompanion(
          name: Value(collection.name),
          colorToken: Value(collection.colorToken),
          description: Value(collection.description),
          sortOrder: Value(collection.sortOrder),
          updatedAt: Value(now),
        ),
      );
      return Result.ok(collection.copyWith(updatedAt: now));
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to update collection: $e', cause: e));
    }
  }

  @override
  Future<Result<void, AppFailure>> deleteCollection(String id) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (db.update(db.collectionsTable)..where((c) => c.id.equals(id))).write(
        CollectionsTableCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      return Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to delete collection: $e', cause: e));
    }
  }

  @override
  Future<Result<void, AppFailure>> addRecipeToCollection(String collectionId, String recipeId) async {
    try {
      final existing = await (db.select(db.collectionRecipesTable)
            ..where((cr) => cr.collectionId.equals(collectionId) & cr.recipeId.equals(recipeId)))
          .getSingleOrNull();

      if (existing == null) {
        await db.into(db.collectionRecipesTable).insert(
              CollectionRecipesTableCompanion(
                id: Value(_uuid.v4()),
                collectionId: Value(collectionId),
                recipeId: Value(recipeId),
                addedAt: Value(DateTime.now().toUtc().millisecondsSinceEpoch),
              ),
            );
      }
      return Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to add recipe to collection: $e', cause: e));
    }
  }

  @override
  Future<Result<void, AppFailure>> removeRecipeFromCollection(String collectionId, String recipeId) async {
    try {
      await (db.delete(db.collectionRecipesTable)
            ..where((cr) => cr.collectionId.equals(collectionId) & cr.recipeId.equals(recipeId)))
          .go();
      return Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to remove recipe from collection: $e', cause: e));
    }
  }
}
