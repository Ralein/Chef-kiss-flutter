import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';

/// Drift-backed recipe aggregate repository.
///
/// A [Recipe] is an aggregate spread across ~8 tables (ingredients, steps,
/// timers, tools, labels, favorites, ...). This repository guarantees:
///
/// * **Atomic saves** – the whole aggregate is replaced inside one transaction.
/// * **Child-id safety** – child rows whose ids collide with rows owned by a
///   *different* recipe (or with each other) are transparently re-keyed, so a
///   save can never fail on a primary-key conflict.
/// * **Reactive reads** – watch streams re-emit when *any* table that feeds the
///   aggregate changes (not only `recipes_table`), so toggling a favorite or
///   editing a step is reflected immediately.
/// * **Batched loading** – relations for N recipes are fetched with a constant
///   number of queries instead of O(N × relations).
class DriftRecipeRepository implements RecipeRepository {
  /// Number of version snapshots kept per recipe. Older snapshots are pruned
  /// on save so frequent small edits (e.g. dragging stickers) cannot grow the
  /// database without bound.
  static const int maxStoredVersions = 25;

  /// SQLite host-parameter limits are generous on modern builds, but chunking
  /// keeps `IN (...)` queries portable across every platform's SQLite.
  static const int _inClauseChunk = 500;

  final AppDatabase db;
  final Uuid _uuid;

  DriftRecipeRepository(this.db, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  Set<ResultSetImplementation<dynamic, dynamic>> get _aggregateTables => {
        db.recipesTable,
        db.recipeIngredientsTable,
        db.recipeStepsTable,
        db.stepTimersTable,
        db.recipeToolsTable,
        db.recipeLabelsTable,
        db.labelsTable,
        db.recipeNotesTable,
        db.favoritesTable,
        db.collectionRecipesTable,
      };

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  @override
  Stream<List<Recipe>> watchRecipes({RecipeFilter filter = const RecipeFilter()}) {
    return _watchAggregate(() => _queryRecipes(filter));
  }

  @override
  Future<Result<List<Recipe>, AppFailure>> getRecipes({RecipeFilter filter = const RecipeFilter()}) async {
    try {
      return Result.ok(await _queryRecipes(filter));
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to fetch recipes.', cause: e));
    }
  }

  @override
  Future<Result<Recipe, AppFailure>> getRecipeById(String id) async {
    try {
      final recipe = await _loadById(id);
      if (recipe == null) {
        return Result.err(NotFoundFailure(resourceType: 'Recipe', resourceId: id));
      }
      return Result.ok(recipe);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to load recipe.', cause: e));
    }
  }

  @override
  Stream<Recipe?> watchRecipeById(String id) => _watchAggregate(() => _loadById(id));

  @override
  Future<Result<List<Recipe>, AppFailure>> searchRecipes(String query) async {
    try {
      return Result.ok(await _queryRecipes(RecipeFilter(query: query)));
    } catch (e) {
      return Result.err(StorageFailure(message: 'Search failed.', cause: e));
    }
  }

  @override
  Stream<List<Recipe>> watchDeletedRecipes() {
    return (db.select(db.recipesTable)
          ..where((r) => r.deletedAt.isNotNull())
          ..orderBy([(r) => OrderingTerm.desc(r.deletedAt)]))
        .watch()
        .map((rows) => rows.map((r) => _mapRow(r, const _Relations.empty())).toList());
  }

  Future<Recipe?> _loadById(String id) async {
    final row = await (db.select(db.recipesTable)..where((r) => r.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final loaded = await _loadAggregates([row]);
    return loaded.single;
  }

  Future<List<Recipe>> _queryRecipes(RecipeFilter filter) async {
    final query = db.select(db.recipesTable)
      ..where((r) {
        Expression<bool> predicate = const Constant(true);
        if (!filter.includeArchived) {
          predicate = predicate & r.deletedAt.isNull();
        }
        if (filter.difficulty != null) {
          predicate = predicate & r.difficulty.equals(filter.difficulty!.name);
        }
        if (filter.maxTotalMinutes != null) {
          predicate = predicate & r.totalMinutes.isSmallerOrEqualValue(filter.maxTotalMinutes!);
        }
        return predicate;
      })
      ..orderBy([(r) => OrderingTerm.desc(r.updatedAt)]);

    var rows = await query.get();

    if (filter.collectionId != null) {
      final members = await (db.select(db.collectionRecipesTable)
            ..where((c) => c.collectionId.equals(filter.collectionId!)))
          .map((c) => c.recipeId)
          .get();
      final memberSet = members.toSet();
      rows = rows.where((r) => memberSet.contains(r.id)).toList();
    }

    var recipes = await _loadAggregates(rows);

    if (filter.onlyFavorites) {
      recipes = recipes.where((r) => r.isFavorite).toList();
    }
    if (filter.cuisine != null) {
      recipes = recipes.where((r) => _hasLabel(r, 'cuisine', filter.cuisine!)).toList();
    }
    if (filter.dietary != null) {
      recipes = recipes.where((r) => _hasLabel(r, 'dietary', filter.dietary!)).toList();
    }
    final q = filter.query?.trim().toLowerCase();
    if (q != null && q.isNotEmpty) {
      recipes = recipes.where((r) => _matchesQuery(r, q)).toList();
    }
    return recipes;
  }

  static bool _hasLabel(Recipe r, String kind, String key) {
    final k = key.toLowerCase();
    return r.labels.any((l) => l.kind == kind && (l.canonicalKey.toLowerCase() == k || l.displayName.toLowerCase() == k));
  }

  static bool _matchesQuery(Recipe r, String q) {
    return r.title.toLowerCase().contains(q) ||
        (r.summary?.toLowerCase().contains(q) ?? false) ||
        r.ingredients.any((i) => i.displayName.toLowerCase().contains(q)) ||
        r.labels.any((l) => l.displayName.toLowerCase().contains(q)) ||
        r.moodStamps.any((m) => m.toLowerCase().contains(q));
  }

  // ---------------------------------------------------------------------------
  // Commands
  // ---------------------------------------------------------------------------

  @override
  Future<Result<Recipe, AppFailure>> saveRecipe(Recipe recipe) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final recipeId = recipe.id.isEmpty ? _uuid.v4() : recipe.id;
      final profileId = recipe.profileId.isEmpty ? 'default' : recipe.profileId;

      await db.transaction(() async {
        final existing =
            await (db.select(db.recipesTable)..where((r) => r.id.equals(recipeId))).getSingleOrNull();
        // createdAt is immutable once a recipe exists.
        final createdAt = existing?.createdAt ?? (recipe.createdAt == 0 ? now : recipe.createdAt);

        await db.into(db.recipesTable).insertOnConflictUpdate(
              RecipesTableCompanion(
                id: Value(recipeId),
                profileId: Value(profileId),
                title: Value(recipe.title),
                slug: Value(recipe.slug),
                summary: Value(recipe.summary),
                status: Value(recipe.status.toDbString()),
                baseServingsNum: Value(recipe.baseServings.numerator),
                baseServingsDen: Value(recipe.baseServings.denominator),
                difficulty: Value(recipe.difficulty.name),
                totalMinutes: Value(recipe.totalMinutes),
                coverMediaId: Value(recipe.coverMediaId),
                visualTemplate: Value(recipe.visualTemplate),
                visualStyleVersion: Value(recipe.visualStyleVersion),
                isCurated: Value(recipe.isCurated),
                createdAt: Value(createdAt),
                updatedAt: Value(now),
                deletedAt: Value(recipe.deletedAt),
                version: Value(recipe.version + 1),
                origin: Value(recipe.origin.toDbString()),
                provenanceJson: Value(jsonEncode(_encodeProvenance(recipe))),
              ),
            );

        // Remove this recipe's previous children. Timers hang off steps, so
        // they must be collected *before* the steps are deleted.
        final oldStepIds = await (db.select(db.recipeStepsTable)..where((s) => s.recipeId.equals(recipeId)))
            .map((s) => s.id)
            .get();
        for (final chunk in _chunks(oldStepIds)) {
          await (db.delete(db.stepTimersTable)..where((t) => t.recipeStepId.isIn(chunk))).go();
        }
        await (db.delete(db.recipeStepsTable)..where((s) => s.recipeId.equals(recipeId))).go();
        await (db.delete(db.recipeIngredientsTable)..where((i) => i.recipeId.equals(recipeId))).go();
        await (db.delete(db.recipeToolsTable)..where((t) => t.recipeId.equals(recipeId))).go();
        await (db.delete(db.recipeLabelsTable)..where((l) => l.recipeId.equals(recipeId))).go();
        await (db.delete(db.recipeNotesTable)..where((n) => n.recipeId.equals(recipeId))).go();

        // Any incoming id still present now belongs to another recipe.
        final takenIngredientIds = await _existingIds(
          recipe.ingredients.map((i) => i.id),
          (chunk) => (db.select(db.recipeIngredientsTable)..where((i) => i.id.isIn(chunk))).map((i) => i.id).get(),
        );
        final takenStepIds = await _existingIds(
          recipe.steps.map((s) => s.id),
          (chunk) => (db.select(db.recipeStepsTable)..where((s) => s.id.isIn(chunk))).map((s) => s.id).get(),
        );
        final takenTimerIds = await _existingIds(
          recipe.steps.expand((s) => s.timers).map((t) => t.id),
          (chunk) => (db.select(db.stepTimersTable)..where((t) => t.id.isIn(chunk))).map((t) => t.id).get(),
        );
        final takenToolIds = await _existingIds(
          recipe.tools.map((t) => t.id),
          (chunk) => (db.select(db.recipeToolsTable)..where((t) => t.id.isIn(chunk))).map((t) => t.id).get(),
        );
        final takenNoteIds = await _existingIds(
          recipe.notes.map((n) => n.id),
          (chunk) => (db.select(db.recipeNotesTable)..where((n) => n.id.isIn(chunk))).map((n) => n.id).get(),
        );
        final takenLabelLinkIds = await _existingIds(
          recipe.labels.map((l) => l.id),
          (chunk) => (db.select(db.recipeLabelsTable)..where((l) => l.id.isIn(chunk))).map((l) => l.id).get(),
        );

        final ingredientKeys = _IdAllocator(takenIngredientIds, _uuid);
        for (var idx = 0; idx < recipe.ingredients.length; idx++) {
          final ing = recipe.ingredients[idx];
          await db.into(db.recipeIngredientsTable).insert(
                RecipeIngredientsTableCompanion(
                  id: Value(ingredientKeys.claim(ing.id)),
                  recipeId: Value(recipeId),
                  catalogIngredientId: Value(ing.catalogIngredientId),
                  displayName: Value(ing.displayName),
                  quantityNum: Value(ing.quantity?.numerator),
                  quantityDen: Value(ing.quantity?.denominator),
                  unitCode: Value(ing.unitCode),
                  authoredQuantity: Value(ing.authoredQuantity),
                  scalingPolicy: Value(ing.scalingPolicy.toDbString()),
                  prepText: Value(ing.prepText),
                  isOptional: Value(ing.isOptional),
                  position: Value(idx + 1),
                  groupKey: Value(ing.groupKey),
                  allergenOverrideJson: Value(jsonEncode({
                    'icon': ing.icon,
                    'iconColor': ing.iconColor,
                    'x': ing.x,
                    'y': ing.y,
                  })),
                  illustrationKey: Value(ing.illustrationKey),
                ),
              );
        }

        final stepKeys = _IdAllocator(takenStepIds, _uuid);
        final timerKeys = _IdAllocator(takenTimerIds, _uuid);
        for (var sIdx = 0; sIdx < recipe.steps.length; sIdx++) {
          final step = recipe.steps[sIdx];
          final stepId = stepKeys.claim(step.id);
          await db.into(db.recipeStepsTable).insert(
                RecipeStepsTableCompanion(
                  id: Value(stepId),
                  recipeId: Value(recipeId),
                  position: Value(sIdx + 1),
                  instructionShort: Value(step.instructionShort),
                  instructionDetail: Value(step.instructionDetail),
                  spokenInstruction: Value(step.spokenInstruction),
                  actionKey: Value(step.actionKey),
                  durationSeconds: Value(step.durationSeconds),
                  temperatureC: Value(step.temperatureC),
                  temperatureF: Value(step.temperatureF),
                  layoutHint: Value(step.layoutHint),
                  safetyJson: Value(jsonEncode({
                    'iconKey': step.iconKey,
                    'iconColor': step.iconColor,
                    'cookwareKey': step.cookwareKey,
                    'x': step.x,
                    'y': step.y,
                  })),
                ),
              );

          for (var tIdx = 0; tIdx < step.timers.length; tIdx++) {
            final timer = step.timers[tIdx];
            await db.into(db.stepTimersTable).insert(
                  StepTimersTableCompanion(
                    id: Value(timerKeys.claim(timer.id)),
                    recipeStepId: Value(stepId),
                    label: Value(timer.label),
                    durationSeconds: Value(timer.durationSeconds),
                    autoStart: Value(timer.autoStart),
                    position: Value(tIdx + 1),
                  ),
                );
          }
        }

        final toolKeys = _IdAllocator(takenToolIds, _uuid);
        for (var idx = 0; idx < recipe.tools.length; idx++) {
          final tool = recipe.tools[idx];
          await db.into(db.recipeToolsTable).insert(
                RecipeToolsTableCompanion(
                  id: Value(toolKeys.claim(tool.id)),
                  recipeId: Value(recipeId),
                  toolId: Value(tool.toolId),
                  displayName: Value(tool.displayName),
                  quantity: Value(tool.quantity),
                  isRequired: Value(tool.isRequired),
                  position: Value(idx + 1),
                ),
              );
        }

        final labelKeys = _IdAllocator(takenLabelLinkIds, _uuid);
        for (final label in recipe.labels) {
          await db.into(db.labelsTable).insertOnConflictUpdate(
                LabelsTableCompanion(
                  id: Value(label.labelId),
                  kind: Value(label.kind),
                  canonicalKey: Value(label.canonicalKey),
                  displayName: Value(label.displayName),
                ),
              );
          await db.into(db.recipeLabelsTable).insert(
                RecipeLabelsTableCompanion(
                  id: Value(labelKeys.claim(label.id)),
                  recipeId: Value(recipeId),
                  labelId: Value(label.labelId),
                  sourceConfidence: Value(label.sourceConfidence),
                  isUserConfirmed: Value(label.isUserConfirmed),
                ),
              );
        }

        final noteKeys = _IdAllocator(takenNoteIds, _uuid);
        for (var idx = 0; idx < recipe.notes.length; idx++) {
          final note = recipe.notes[idx];
          await db.into(db.recipeNotesTable).insert(
                RecipeNotesTableCompanion(
                  id: Value(noteKeys.claim(note.id)),
                  recipeId: Value(recipeId),
                  body: Value(note.body),
                  noteType: Value(note.noteType),
                  position: Value(idx + 1),
                  createdAt: Value(now),
                ),
              );
        }

        await _syncFavorite(recipeId, profileId, recipe.isFavorite, now);

        await db.into(db.recipeVersionsTable).insert(
              RecipeVersionsTableCompanion(
                id: Value(_uuid.v4()),
                recipeId: Value(recipeId),
                sequence: Value(recipe.version + 1),
                snapshotJson: Value(jsonEncode(_serializeRecipeSnapshot(recipe))),
                changeSummary: const Value('Saved recipe draft/update'),
                authorKind: Value(recipe.origin.toDbString()),
                createdAt: Value(now),
              ),
            );
        await _pruneVersions(recipeId);

        await db.into(db.changeOperationsTable).insert(
              ChangeOperationsTableCompanion(
                operationId: Value(_uuid.v4()),
                profileId: Value(profileId),
                entityType: const Value('recipe'),
                entityId: Value(recipeId),
                opType: const Value('upsert'),
                baseVersion: Value(recipe.version),
                payloadJson: Value(jsonEncode({'title': recipe.title, 'status': recipe.status.name})),
                fieldPathsJson: const Value('["/"]'),
                occurredAt: Value(now),
              ),
            );
      });

      return await getRecipeById(recipeId);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to save recipe.', cause: e));
    }
  }

  @override
  Future<Result<bool, AppFailure>> toggleFavorite(String recipeId) async {
    try {
      final existing = await (db.select(db.favoritesTable)..where((f) => f.recipeId.equals(recipeId))).get();
      if (existing.isNotEmpty) {
        await (db.delete(db.favoritesTable)..where((f) => f.recipeId.equals(recipeId))).go();
        return Result.ok(false);
      }
      await db.into(db.favoritesTable).insert(
            FavoritesTableCompanion(
              id: Value(_uuid.v4()),
              profileId: const Value('default'),
              recipeId: Value(recipeId),
              favoritedAt: Value(DateTime.now().toUtc().millisecondsSinceEpoch),
            ),
          );
      return Result.ok(true);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to update favorite.', cause: e));
    }
  }

  @override
  Future<Result<void, AppFailure>> deleteRecipe(String recipeId) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (db.update(db.recipesTable)..where((r) => r.id.equals(recipeId))).write(
        RecipesTableCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      return Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to delete recipe.', cause: e));
    }
  }

  @override
  Future<Result<void, AppFailure>> restoreRecipe(String recipeId) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (db.update(db.recipesTable)..where((r) => r.id.equals(recipeId))).write(
        RecipesTableCompanion(deletedAt: const Value(null), updatedAt: Value(now)),
      );
      return Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to restore recipe.', cause: e));
    }
  }

  @override
  Future<Result<void, AppFailure>> purgeRecipe(String id) async {
    try {
      await db.transaction(() async {
        final stepIds = await (db.select(db.recipeStepsTable)..where((s) => s.recipeId.equals(id)))
            .map((s) => s.id)
            .get();
        for (final chunk in _chunks(stepIds)) {
          await (db.delete(db.stepTimersTable)..where((t) => t.recipeStepId.isIn(chunk))).go();
        }
        final sessionIds = await (db.select(db.cookingSessionsTable)..where((s) => s.recipeId.equals(id)))
            .map((s) => s.id)
            .get();
        for (final chunk in _chunks(sessionIds)) {
          await (db.delete(db.sessionIngredientChecksTable)..where((c) => c.sessionId.isIn(chunk))).go();
          await (db.delete(db.sessionTimersTable)..where((t) => t.sessionId.isIn(chunk))).go();
        }
        await (db.delete(db.cookingSessionsTable)..where((s) => s.recipeId.equals(id))).go();
        await (db.delete(db.recipeStepsTable)..where((s) => s.recipeId.equals(id))).go();
        await (db.delete(db.recipeIngredientsTable)..where((i) => i.recipeId.equals(id))).go();
        await (db.delete(db.recipeToolsTable)..where((t) => t.recipeId.equals(id))).go();
        await (db.delete(db.recipeLabelsTable)..where((l) => l.recipeId.equals(id))).go();
        await (db.delete(db.recipeNotesTable)..where((n) => n.recipeId.equals(id))).go();
        await (db.delete(db.recipeMediaTable)..where((m) => m.recipeId.equals(id))).go();
        await (db.delete(db.recipeVersionsTable)..where((v) => v.recipeId.equals(id))).go();
        await (db.delete(db.collectionRecipesTable)..where((c) => c.recipeId.equals(id))).go();
        await (db.delete(db.favoritesTable)..where((f) => f.recipeId.equals(id))).go();
        await (db.delete(db.recipesTable)..where((r) => r.id.equals(id))).go();
      });
      return const Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to permanently delete recipe.', cause: e));
    }
  }

  @override
  Future<Result<int, AppFailure>> seedStarterRecipes(List<Recipe> starterRecipes) async {
    try {
      var count = 0;
      for (final starter in starterRecipes) {
        final existing =
            await (db.select(db.recipesTable)..where((r) => r.id.equals(starter.id))).getSingleOrNull();
        if (existing != null) continue;
        final saved = await saveRecipe(starter);
        if (saved.isSuccess) count++;
      }
      return Result.ok(count);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Seeding starter recipes failed.', cause: e));
    }
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// Emits [load]'s result immediately and again whenever an aggregate table
  /// changes. Bursts of updates that arrive while a load is in flight are
  /// coalesced into a single follow-up load.
  Stream<T> _watchAggregate<T>(Future<T> Function() load) {
    late final StreamController<T> controller;
    StreamSubscription<Set<TableUpdate>>? trigger;
    var running = false;
    var dirty = false;

    Future<void> run() async {
      if (running) {
        dirty = true;
        return;
      }
      running = true;
      try {
        do {
          dirty = false;
          final value = await load();
          if (controller.isClosed) return;
          controller.add(value);
        } while (dirty);
      } catch (e, st) {
        if (!controller.isClosed) controller.addError(e, st);
      } finally {
        running = false;
      }
    }

    controller = StreamController<T>(
      onListen: () {
        trigger = db.tableUpdates(TableUpdateQuery.onAllTables(_aggregateTables)).listen((_) => run());
        run();
      },
      onCancel: () => trigger?.cancel(),
    );
    return controller.stream;
  }

  Future<void> _syncFavorite(String recipeId, String profileId, bool isFavorite, int now) async {
    final rows = await (db.select(db.favoritesTable)..where((f) => f.recipeId.equals(recipeId))).get();
    if (isFavorite && rows.isEmpty) {
      await db.into(db.favoritesTable).insert(
            FavoritesTableCompanion(
              id: Value(_uuid.v4()),
              profileId: Value(profileId),
              recipeId: Value(recipeId),
              favoritedAt: Value(now),
            ),
          );
    } else if (!isFavorite && rows.isNotEmpty) {
      await (db.delete(db.favoritesTable)..where((f) => f.recipeId.equals(recipeId))).go();
    }
  }

  Future<void> _pruneVersions(String recipeId) async {
    final keep = await (db.select(db.recipeVersionsTable)
          ..where((v) => v.recipeId.equals(recipeId))
          ..orderBy([(v) => OrderingTerm.desc(v.createdAt), (v) => OrderingTerm.desc(v.sequence)])
          ..limit(maxStoredVersions))
        .map((v) => v.id)
        .get();
    await (db.delete(db.recipeVersionsTable)..where((v) => v.recipeId.equals(recipeId) & v.id.isNotIn(keep))).go();
  }

  Future<Set<String>> _existingIds(
    Iterable<String> candidates,
    Future<List<String>> Function(List<String> chunk) lookup,
  ) async {
    final ids = candidates.where((id) => id.isNotEmpty).toSet().toList();
    final taken = <String>{};
    for (final chunk in _chunks(ids)) {
      taken.addAll(await lookup(chunk));
    }
    return taken;
  }

  Iterable<List<String>> _chunks(List<String> ids) sync* {
    for (var i = 0; i < ids.length; i += _inClauseChunk) {
      yield ids.sublist(i, i + _inClauseChunk > ids.length ? ids.length : i + _inClauseChunk);
    }
  }

  Future<List<Recipe>> _loadAggregates(List<RecipesTableData> rows) async {
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.id).toList();

    final ingredients = <RecipeIngredientsTableData>[];
    final steps = <RecipeStepsTableData>[];
    final tools = <RecipeToolsTableData>[];
    final labelLinks = <TypedResult>[];
    final notes = <RecipeNotesTableData>[];
    final favorites = <String>{};

    for (final chunk in _chunks(ids)) {
      ingredients.addAll(await (db.select(db.recipeIngredientsTable)
            ..where((i) => i.recipeId.isIn(chunk))
            ..orderBy([(i) => OrderingTerm.asc(i.position)]))
          .get());
      steps.addAll(await (db.select(db.recipeStepsTable)
            ..where((s) => s.recipeId.isIn(chunk))
            ..orderBy([(s) => OrderingTerm.asc(s.position)]))
          .get());
      tools.addAll(await (db.select(db.recipeToolsTable)
            ..where((t) => t.recipeId.isIn(chunk))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get());
      labelLinks.addAll(await (db.select(db.recipeLabelsTable).join([
        innerJoin(db.labelsTable, db.labelsTable.id.equalsExp(db.recipeLabelsTable.labelId)),
      ])
            ..where(db.recipeLabelsTable.recipeId.isIn(chunk)))
          .get());
      notes.addAll(await (db.select(db.recipeNotesTable)
            ..where((n) => n.recipeId.isIn(chunk))
            ..orderBy([(n) => OrderingTerm.asc(n.position)]))
          .get());
      favorites.addAll(
        await (db.select(db.favoritesTable)..where((f) => f.recipeId.isIn(chunk))).map((f) => f.recipeId).get(),
      );
    }

    final timers = <StepTimersTableData>[];
    for (final chunk in _chunks(steps.map((s) => s.id).toList())) {
      timers.addAll(await (db.select(db.stepTimersTable)
            ..where((t) => t.recipeStepId.isIn(chunk))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get());
    }

    final timersByStep = <String, List<StepTimer>>{};
    for (final t in timers) {
      timersByStep.putIfAbsent(t.recipeStepId, () => []).add(StepTimer(
            id: t.id,
            recipeStepId: t.recipeStepId,
            label: t.label,
            durationSeconds: t.durationSeconds,
            autoStart: t.autoStart,
            position: t.position,
          ));
    }

    final ingredientsByRecipe = <String, List<RecipeIngredient>>{};
    for (final i in ingredients) {
      final meta = _decodeObject(i.allergenOverrideJson);
      ingredientsByRecipe.putIfAbsent(i.recipeId, () => []).add(RecipeIngredient(
            id: i.id,
            recipeId: i.recipeId,
            catalogIngredientId: i.catalogIngredientId,
            displayName: i.displayName,
            quantity: i.quantityNum != null && (i.quantityDen ?? 1) != 0
                ? Rational(i.quantityNum!, i.quantityDen ?? 1)
                : null,
            unitCode: i.unitCode,
            authoredQuantity: i.authoredQuantity,
            scalingPolicy: ScalingPolicy.fromString(i.scalingPolicy),
            prepText: i.prepText,
            isOptional: i.isOptional,
            position: i.position,
            groupKey: i.groupKey,
            allergenOverrideJson: i.allergenOverrideJson,
            illustrationKey: i.illustrationKey,
            icon: meta['icon'] as String?,
            iconColor: meta['iconColor'] as String?,
            x: (meta['x'] as num?)?.toDouble(),
            y: (meta['y'] as num?)?.toDouble(),
          ));
    }

    final stepsByRecipe = <String, List<RecipeStep>>{};
    for (final s in steps) {
      final meta = _decodeObject(s.safetyJson);
      stepsByRecipe.putIfAbsent(s.recipeId, () => []).add(RecipeStep(
            id: s.id,
            recipeId: s.recipeId,
            position: s.position,
            instructionShort: s.instructionShort,
            instructionDetail: s.instructionDetail,
            spokenInstruction: s.spokenInstruction,
            actionKey: s.actionKey,
            iconKey: meta['iconKey'] as String?,
            iconColor: meta['iconColor'] as String?,
            cookwareKey: meta['cookwareKey'] as String?,
            durationSeconds: s.durationSeconds,
            temperatureC: s.temperatureC,
            temperatureF: s.temperatureF,
            layoutHint: s.layoutHint,
            safetyJson: s.safetyJson,
            x: (meta['x'] as num?)?.toDouble(),
            y: (meta['y'] as num?)?.toDouble(),
            timers: timersByStep[s.id] ?? const [],
          ));
    }

    final toolsByRecipe = <String, List<RecipeTool>>{};
    for (final t in tools) {
      toolsByRecipe.putIfAbsent(t.recipeId, () => []).add(RecipeTool(
            id: t.id,
            recipeId: t.recipeId,
            toolId: t.toolId,
            displayName: t.displayName,
            quantity: t.quantity,
            isRequired: t.isRequired,
            position: t.position,
          ));
    }

    final labelsByRecipe = <String, List<RecipeLabel>>{};
    for (final row in labelLinks) {
      final link = row.readTable(db.recipeLabelsTable);
      final label = row.readTable(db.labelsTable);
      labelsByRecipe.putIfAbsent(link.recipeId, () => []).add(RecipeLabel(
            id: link.id,
            recipeId: link.recipeId,
            labelId: link.labelId,
            kind: label.kind,
            canonicalKey: label.canonicalKey,
            displayName: label.displayName,
            sourceConfidence: link.sourceConfidence,
            isUserConfirmed: link.isUserConfirmed,
          ));
    }

    final notesByRecipe = <String, List<RecipeNote>>{};
    for (final n in notes) {
      notesByRecipe.putIfAbsent(n.recipeId, () => []).add(RecipeNote(
            id: n.id,
            recipeId: n.recipeId,
            body: n.body,
            noteType: n.noteType,
            position: n.position,
          ));
    }

    return rows
        .map((row) => _mapRow(
              row,
              _Relations(
                ingredients: ingredientsByRecipe[row.id] ?? const [],
                steps: stepsByRecipe[row.id] ?? const [],
                tools: toolsByRecipe[row.id] ?? const [],
                labels: labelsByRecipe[row.id] ?? const [],
                notes: notesByRecipe[row.id] ?? const [],
                isFavorite: favorites.contains(row.id),
              ),
            ))
        .toList(growable: false);
  }

  Recipe _mapRow(RecipesTableData row, _Relations rel) {
    final provenance = _decodeObject(row.provenanceJson);
    return Recipe(
      id: row.id,
      profileId: row.profileId,
      title: row.title,
      slug: row.slug,
      summary: row.summary,
      status: RecipeStatus.fromString(row.status),
      baseServings: row.baseServingsDen == 0 ? Rational(2) : Rational(row.baseServingsNum, row.baseServingsDen),
      difficulty: RecipeDifficulty.fromString(row.difficulty),
      totalMinutes: row.totalMinutes,
      coverMediaId: row.coverMediaId,
      coverImage: provenance['coverImage'] as String?,
      polaroidCaption: provenance['polaroidCaption'] as String?,
      polaroidRotation: (provenance['polaroidRotation'] as num?)?.toDouble(),
      polaroidX: (provenance['polaroidX'] as num?)?.toDouble(),
      polaroidY: (provenance['polaroidY'] as num?)?.toDouble(),
      chefTip: provenance['chefTip'] as String?,
      chefTipIcon: provenance['chefTipIcon'] as String?,
      chefTipIconColor: provenance['chefTipIconColor'] as String?,
      theme: ScrapbookTheme.fromKey(provenance['theme'] as String?),
      moodStamps: (provenance['moodStamps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      stickers: _decodeList(provenance['stickers'], ScrapbookSticker.fromJson),
      washiTapes: _decodeList(provenance['washiTapes'], WashiTapeDecoration.fromJson),
      nutritionOverrides: NutritionFacts.decodeOverrides(provenance['nutritionOverrides']),
      visualTemplate: row.visualTemplate,
      visualStyleVersion: row.visualStyleVersion,
      isCurated: row.isCurated,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      version: row.version,
      origin: Origin.fromString(row.origin),
      currentVersionId: row.currentVersionId,
      ingredients: rel.ingredients,
      steps: rel.steps,
      tools: rel.tools,
      labels: rel.labels,
      notes: rel.notes,
      isFavorite: rel.isFavorite,
    );
  }

  Map<String, Object?> _encodeProvenance(Recipe recipe) => {
        'theme': recipe.theme.toKey(),
        'moodStamps': recipe.moodStamps,
        'stickers': recipe.stickers.map((s) => s.toJson()).toList(),
        'washiTapes': recipe.washiTapes.map((w) => w.toJson()).toList(),
        'coverImage': recipe.coverImage,
        'polaroidCaption': recipe.polaroidCaption,
        'polaroidRotation': recipe.polaroidRotation,
        'polaroidX': recipe.polaroidX,
        'polaroidY': recipe.polaroidY,
        'chefTip': recipe.chefTip,
        'chefTipIcon': recipe.chefTipIcon,
        'chefTipIconColor': recipe.chefTipIconColor,
        if (recipe.nutritionOverrides.isNotEmpty)
          'nutritionOverrides': NutritionFacts.encodeOverrides(recipe.nutritionOverrides),
      };

  static Map<String, dynamic> _decodeObject(String? json) {
    if (json == null || json.isEmpty) return const {};
    try {
      final decoded = jsonDecode(json);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }

  static List<T> _decodeList<T>(Object? raw, T Function(Map<String, dynamic>) fromJson) {
    if (raw is! List) return const [];
    final out = <T>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        try {
          out.add(fromJson(item));
        } catch (_) {
          // Skip a single corrupt decoration rather than failing the recipe.
        }
      }
    }
    return out;
  }

  Map<String, dynamic> _serializeRecipeSnapshot(Recipe recipe) {
    return {
      'id': recipe.id,
      'title': recipe.title,
      'summary': recipe.summary,
      'servings': recipe.baseServings.toDisplayString(),
      'difficulty': recipe.difficulty.name,
      'minutes': recipe.totalMinutes,
      'ingredients': recipe.ingredients
          .map((i) => {
                'name': i.displayName,
                'qty': i.quantity?.toDisplayString(),
                'unit': i.unitCode,
                'prep': i.prepText,
              })
          .toList(),
      'steps': recipe.steps
          .map((s) => {
                'instruction': s.instructionShort,
                'action': s.actionKey,
                'duration': s.durationSeconds,
              })
          .toList(),
    };
  }
}

class _Relations {
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final List<RecipeTool> tools;
  final List<RecipeLabel> labels;
  final List<RecipeNote> notes;
  final bool isFavorite;

  const _Relations({
    required this.ingredients,
    required this.steps,
    required this.tools,
    required this.labels,
    required this.notes,
    required this.isFavorite,
  });

  const _Relations.empty()
      : ingredients = const [],
        steps = const [],
        tools = const [],
        labels = const [],
        notes = const [],
        isFavorite = false;
}

/// Hands out child-row primary keys, replacing ids that are empty, already
/// owned by another recipe, or duplicated within the same save.
class _IdAllocator {
  final Set<String> _taken;
  final Uuid _uuid;

  _IdAllocator(Set<String> takenByOthers, this._uuid) : _taken = {...takenByOthers};

  String claim(String requested) {
    final id = (requested.isEmpty || _taken.contains(requested)) ? _uuid.v4() : requested;
    _taken.add(id);
    return id;
  }
}
