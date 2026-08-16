import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import 'package:uuid/uuid.dart';
import '../db/app_database.dart';

class DriftRecipeRepository implements RecipeRepository {
  final AppDatabase db;
  final Uuid _uuid = const Uuid();

  DriftRecipeRepository(this.db);

  @override
  Stream<List<Recipe>> watchRecipes({RecipeFilter filter = const RecipeFilter()}) {
    final query = db.select(db.recipesTable)
      ..where((r) {
        Expression<bool> predicate = const Constant(true);

        if (!filter.includeArchived) {
          predicate = predicate & r.deletedAt.isNull();
        }

        if (filter.cuisine != null) {
          // Join or check labels if needed
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

    return query.watch().asyncMap((rows) async {
      final recipes = <Recipe>[];
      for (final row in rows) {
        // Check favorite
        final fav = await (db.select(db.favoritesTable)
              ..where((f) => f.recipeId.equals(row.id)))
            .getSingleOrNull();

        if (filter.onlyFavorites && fav == null) {
          continue;
        }

        // Apply text query filter if given
        if (filter.query != null && filter.query!.trim().isNotEmpty) {
          final q = filter.query!.trim().toLowerCase();
          final matchesTitle = row.title.toLowerCase().contains(q);
          final matchesSummary = row.summary?.toLowerCase().contains(q) ?? false;
          if (!matchesTitle && !matchesSummary) {
            // Check ingredients
            final matchingIng = await (db.select(db.recipeIngredientsTable)
                  ..where((i) => i.recipeId.equals(row.id) & i.displayName.lower().like('%$q%')))
                .get();
            if (matchingIng.isEmpty) {
              continue;
            }
          }
        }

        // Check collection filter
        if (filter.collectionId != null) {
          final inCollection = await (db.select(db.collectionRecipesTable)
                ..where((c) => c.collectionId.equals(filter.collectionId!) & c.recipeId.equals(row.id)))
              .getSingleOrNull();
          if (inCollection == null) {
            continue;
          }
        }

        recipes.add(await _loadFullRecipe(row));
      }
      return recipes;
    });
  }

  @override
  Future<Result<List<Recipe>, AppFailure>> getRecipes({RecipeFilter filter = const RecipeFilter()}) async {
    try {
      final list = await watchRecipes(filter: filter).first;
      return Result.ok(list);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to fetch recipes: $e', cause: e));
    }
  }

  @override
  Future<Result<Recipe, AppFailure>> getRecipeById(String id) async {
    try {
      final row = await (db.select(db.recipesTable)..where((r) => r.id.equals(id))).getSingleOrNull();
      if (row == null) {
        return Result.err(NotFoundFailure(resourceType: 'Recipe', resourceId: id));
      }

      final recipe = await _loadFullRecipe(row);
      return Result.ok(recipe);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to load recipe: $e', cause: e));
    }
  }

  @override
  Stream<Recipe?> watchRecipeById(String id) {
    return (db.select(db.recipesTable)..where((r) => r.id.equals(id)))
        .watchSingleOrNull()
        .asyncMap((row) async {
      if (row == null) return null;
      return await _loadFullRecipe(row);
    });
  }

  @override
  Future<Result<Recipe, AppFailure>> saveRecipe(Recipe recipe) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final recipeId = recipe.id.isEmpty ? _uuid.v4() : recipe.id;

      await db.transaction(() async {
        // 1. Upsert recipes table
        final provenanceMap = {
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
        };

        await db.into(db.recipesTable).insertOnConflictUpdate(
              RecipesTableCompanion(
                id: Value(recipeId),
                profileId: Value(recipe.profileId.isEmpty ? 'default' : recipe.profileId),
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
                createdAt: Value(recipe.createdAt == 0 ? now : recipe.createdAt),
                updatedAt: Value(now),
                deletedAt: Value(recipe.deletedAt),
                version: Value(recipe.version + 1),
                origin: Value(recipe.origin.toDbString()),
                provenanceJson: Value(jsonEncode(provenanceMap)),
              ),
            );

        // 2. Replace Ingredients
        await (db.delete(db.recipeIngredientsTable)..where((i) => i.recipeId.equals(recipeId))).go();
        for (var idx = 0; idx < recipe.ingredients.length; idx++) {
          final ing = recipe.ingredients[idx];
          final ingMeta = {
            'icon': ing.icon,
            'iconColor': ing.iconColor,
            'x': ing.x,
            'y': ing.y,
          };
          await db.into(db.recipeIngredientsTable).insert(
                RecipeIngredientsTableCompanion(
                  id: Value(ing.id.isEmpty ? _uuid.v4() : ing.id),
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
                  allergenOverrideJson: Value(jsonEncode(ingMeta)),
                  illustrationKey: Value(ing.illustrationKey),
                ),
              );
        }

        // 3. Replace Steps & Timers
        await (db.delete(db.recipeStepsTable)..where((s) => s.recipeId.equals(recipeId))).go();
        for (var sIdx = 0; sIdx < recipe.steps.length; sIdx++) {
          final step = recipe.steps[sIdx];
          final stepId = step.id.isEmpty ? _uuid.v4() : step.id;
          final stepMeta = {
            'iconKey': step.iconKey,
            'iconColor': step.iconColor,
            'cookwareKey': step.cookwareKey,
            'x': step.x,
            'y': step.y,
          };
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
                  safetyJson: Value(jsonEncode(stepMeta)),
                ),
              );

          // Insert Step Timers
          for (var tIdx = 0; tIdx < step.timers.length; tIdx++) {
            final timer = step.timers[tIdx];
            await db.into(db.stepTimersTable).insert(
                  StepTimersTableCompanion(
                    id: Value(timer.id.isEmpty ? _uuid.v4() : timer.id),
                    recipeStepId: Value(stepId),
                    label: Value(timer.label),
                    durationSeconds: Value(timer.durationSeconds),
                    autoStart: Value(timer.autoStart),
                    position: Value(tIdx + 1),
                  ),
                );
          }
        }

        // 4. Replace Tools
        await (db.delete(db.recipeToolsTable)..where((t) => t.recipeId.equals(recipeId))).go();
        for (var idx = 0; idx < recipe.tools.length; idx++) {
          final tool = recipe.tools[idx];
          await db.into(db.recipeToolsTable).insert(
                RecipeToolsTableCompanion(
                  id: Value(tool.id.isEmpty ? _uuid.v4() : tool.id),
                  recipeId: Value(recipeId),
                  toolId: Value(tool.toolId),
                  displayName: Value(tool.displayName),
                  quantity: Value(tool.quantity),
                  isRequired: Value(tool.isRequired),
                  position: Value(idx + 1),
                ),
              );
        }

        // 5. Replace Labels
        await (db.delete(db.recipeLabelsTable)..where((l) => l.recipeId.equals(recipeId))).go();
        for (final label in recipe.labels) {
          // Ensure label exists in labelsTable
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
                  id: Value(label.id.isEmpty ? _uuid.v4() : label.id),
                  recipeId: Value(recipeId),
                  labelId: Value(label.labelId),
                  sourceConfidence: Value(label.sourceConfidence),
                  isUserConfirmed: Value(label.isUserConfirmed),
                ),
              );
        }

        // 6. Record Version Snapshot
        await db.into(db.recipeVersionsTable).insert(
              RecipeVersionsTableCompanion(
                id: Value(_uuid.v4()),
                recipeId: Value(recipeId),
                sequence: Value(recipe.version + 1),
                snapshotJson: Value(jsonEncode(_serializeRecipeSnapshot(recipe))),
                changeSummary: Value('Saved recipe draft/update'),
                authorKind: Value(recipe.origin.toDbString()),
                createdAt: Value(now),
              ),
            );

        // 7. Append Change Operation
        await db.into(db.changeOperationsTable).insert(
              ChangeOperationsTableCompanion(
                operationId: Value(_uuid.v4()),
                profileId: Value(recipe.profileId.isEmpty ? 'default' : recipe.profileId),
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

      final saved = await getRecipeById(recipeId);
      return saved;
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to save recipe: $e', cause: e));
    }
  }

  @override
  Future<Result<bool, AppFailure>> toggleFavorite(String recipeId) async {
    try {
      final existing = await (db.select(db.favoritesTable)
            ..where((f) => f.recipeId.equals(recipeId)))
          .getSingleOrNull();

      if (existing != null) {
        await (db.delete(db.favoritesTable)..where((f) => f.recipeId.equals(recipeId))).go();
        return Result.ok(false);
      } else {
        await db.into(db.favoritesTable).insert(
              FavoritesTableCompanion(
                id: Value(_uuid.v4()),
                profileId: const Value('default'),
                recipeId: Value(recipeId),
                favoritedAt: Value(DateTime.now().toUtc().millisecondsSinceEpoch),
              ),
            );
        return Result.ok(true);
      }
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to toggle favorite: $e', cause: e));
    }
  }

  @override
  Future<Result<void, AppFailure>> deleteRecipe(String recipeId) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (db.update(db.recipesTable)..where((r) => r.id.equals(recipeId))).write(
        RecipesTableCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      return Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to delete recipe: $e', cause: e));
    }
  }

  @override
  Future<Result<void, AppFailure>> restoreRecipe(String recipeId) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (db.update(db.recipesTable)..where((r) => r.id.equals(recipeId))).write(
        RecipesTableCompanion(
          deletedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );
      return Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to restore recipe: $e', cause: e));
    }
  }

  @override
  Future<Result<void, AppFailure>> purgeRecipe(String id) async {
    try {
      await db.transaction(() async {
        await (db.delete(db.recipeIngredientsTable)..where((i) => i.recipeId.equals(id))).go();
        await (db.delete(db.recipeStepsTable)..where((s) => s.recipeId.equals(id))).go();
        await (db.delete(db.collectionRecipesTable)..where((c) => c.recipeId.equals(id))).go();
        await (db.delete(db.favoritesTable)..where((f) => f.recipeId.equals(id))).go();
        await (db.delete(db.recipesTable)..where((r) => r.id.equals(id))).go();
      });
      return const Result.ok(null);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to purge recipe: $e', cause: e));
    }
  }

  @override
  Stream<List<Recipe>> watchDeletedRecipes() {
    return (db.select(db.recipesTable)
          ..where((r) => r.deletedAt.isNotNull())
          ..orderBy([(r) => OrderingTerm.desc(r.deletedAt)]))
        .watch()
        .map((rows) => rows.map((r) => _mapRowToRecipe(r, isFavorite: false)).toList());
  }

  @override
  Future<Result<List<Recipe>, AppFailure>> searchRecipes(String query) async {
    try {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) {
        final all = await (db.select(db.recipesTable)
              ..where((r) => r.deletedAt.isNull())
              ..orderBy([(r) => OrderingTerm.desc(r.updatedAt)]))
            .get();
        final mapped = all.map((r) => _mapRowToRecipe(r)).toList();
        return Result.ok(mapped);
      }

      final rows = await (db.select(db.recipesTable)
            ..where((r) =>
                r.deletedAt.isNull() &
                (r.title.lower().like('%$q%') | r.summary.lower().like('%$q%'))))
          .get();

      final list = <Recipe>[];
      for (final r in rows) {
        final full = await _loadFullRecipe(r);
        list.add(full);
      }
      return Result.ok(list);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Search failed: $e', cause: e));
    }
  }

  @override
  Future<Result<int, AppFailure>> seedStarterRecipes(List<Recipe> starterRecipes) async {
    try {
      var count = 0;
      for (final starter in starterRecipes) {
        final existing = await (db.select(db.recipesTable)..where((r) => r.id.equals(starter.id))).getSingleOrNull();
        if (existing == null) {
          await saveRecipe(starter);
          count++;
        }
      }
      return Result.ok(count);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Seeding starter recipes failed: $e', cause: e));
    }
  }

  Future<Recipe> _loadFullRecipe(RecipesTableData row) async {
    // Parse scrapbook provenance metadata
    Map<String, dynamic> provenance = {};
    try {
      if (row.provenanceJson.isNotEmpty) {
        provenance = jsonDecode(row.provenanceJson) as Map<String, dynamic>;
      }
    } catch (_) {}

    final theme = ScrapbookTheme.fromKey(provenance['theme'] as String?);
    final moodStamps = (provenance['moodStamps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final stickers = (provenance['stickers'] as List<dynamic>?)
            ?.map((e) => ScrapbookSticker.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final washiTapes = (provenance['washiTapes'] as List<dynamic>?)
            ?.map((e) => WashiTapeDecoration.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final coverImage = provenance['coverImage'] as String?;
    final polaroidCaption = provenance['polaroidCaption'] as String?;
    final polaroidRotation = (provenance['polaroidRotation'] as num?)?.toDouble();
    final polaroidX = (provenance['polaroidX'] as num?)?.toDouble();
    final polaroidY = (provenance['polaroidY'] as num?)?.toDouble();
    final chefTip = provenance['chefTip'] as String?;
    final chefTipIcon = provenance['chefTipIcon'] as String?;
    final chefTipIconColor = provenance['chefTipIconColor'] as String?;

    // Ingredients
    final ingRows = await (db.select(db.recipeIngredientsTable)
          ..where((i) => i.recipeId.equals(row.id))
          ..orderBy([(i) => OrderingTerm.asc(i.position)]))
        .get();
    final ingredients = ingRows.map((i) {
      Map<String, dynamic> ingMeta = {};
      try {
        if (i.allergenOverrideJson != null && i.allergenOverrideJson!.isNotEmpty) {
          ingMeta = jsonDecode(i.allergenOverrideJson!) as Map<String, dynamic>;
        }
      } catch (_) {}

      return RecipeIngredient(
        id: i.id,
        recipeId: i.recipeId,
        catalogIngredientId: i.catalogIngredientId,
        displayName: i.displayName,
        quantity: i.quantityNum != null
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
        icon: ingMeta['icon'] as String?,
        iconColor: ingMeta['iconColor'] as String?,
        x: (ingMeta['x'] as num?)?.toDouble(),
        y: (ingMeta['y'] as num?)?.toDouble(),
      );
    }).toList();

    // Steps & Timers
    final stepRows = await (db.select(db.recipeStepsTable)
          ..where((s) => s.recipeId.equals(row.id))
          ..orderBy([(s) => OrderingTerm.asc(s.position)]))
        .get();
    final steps = <RecipeStep>[];
    for (final s in stepRows) {
      final timerRows = await (db.select(db.stepTimersTable)
            ..where((t) => t.recipeStepId.equals(s.id))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();
      final timers = timerRows
          .map((t) => StepTimer(
                id: t.id,
                recipeStepId: t.recipeStepId,
                label: t.label,
                durationSeconds: t.durationSeconds,
                autoStart: t.autoStart,
                position: t.position,
              ))
          .toList();

      Map<String, dynamic> stepMeta = {};
      try {
        if (s.safetyJson != null && s.safetyJson!.isNotEmpty) {
          stepMeta = jsonDecode(s.safetyJson!) as Map<String, dynamic>;
        }
      } catch (_) {}

      steps.add(RecipeStep(
        id: s.id,
        recipeId: s.recipeId,
        position: s.position,
        instructionShort: s.instructionShort,
        instructionDetail: s.instructionDetail,
        spokenInstruction: s.spokenInstruction,
        actionKey: s.actionKey,
        iconKey: stepMeta['iconKey'] as String?,
        iconColor: stepMeta['iconColor'] as String?,
        cookwareKey: stepMeta['cookwareKey'] as String?,
        durationSeconds: s.durationSeconds,
        temperatureC: s.temperatureC,
        temperatureF: s.temperatureF,
        layoutHint: s.layoutHint,
        safetyJson: s.safetyJson,
        x: (stepMeta['x'] as num?)?.toDouble(),
        y: (stepMeta['y'] as num?)?.toDouble(),
        timers: timers,
      ));
    }

    // Tools
    final toolRows = await (db.select(db.recipeToolsTable)
          ..where((t) => t.recipeId.equals(row.id))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    final tools = toolRows
        .map((t) => RecipeTool(
              id: t.id,
              recipeId: t.recipeId,
              toolId: t.toolId,
              displayName: t.displayName,
              quantity: t.quantity,
              isRequired: t.isRequired,
              position: t.position,
            ))
        .toList();

    // Labels
    final labelRows = await (db.select(db.recipeLabelsTable)..where((l) => l.recipeId.equals(row.id))).get();
    final labels = <RecipeLabel>[];
    for (final rl in labelRows) {
      final lData = await (db.select(db.labelsTable)..where((l) => l.id.equals(rl.labelId))).getSingleOrNull();
      if (lData != null) {
        labels.add(RecipeLabel(
          id: rl.id,
          recipeId: rl.recipeId,
          labelId: rl.labelId,
          kind: lData.kind,
          canonicalKey: lData.canonicalKey,
          displayName: lData.displayName,
          sourceConfidence: rl.sourceConfidence,
          isUserConfirmed: rl.isUserConfirmed,
        ));
      }
    }

    // Favorite status
    final fav = await (db.select(db.favoritesTable)..where((f) => f.recipeId.equals(row.id))).getSingleOrNull();

    return Recipe(
      id: row.id,
      profileId: row.profileId,
      title: row.title,
      slug: row.slug,
      summary: row.summary,
      status: RecipeStatus.fromString(row.status),
      baseServings: Rational(row.baseServingsNum, row.baseServingsDen),
      difficulty: RecipeDifficulty.fromString(row.difficulty),
      totalMinutes: row.totalMinutes,
      coverMediaId: row.coverMediaId,
      coverImage: coverImage,
      polaroidCaption: polaroidCaption,
      polaroidRotation: polaroidRotation,
      polaroidX: polaroidX,
      polaroidY: polaroidY,
      chefTip: chefTip,
      chefTipIcon: chefTipIcon,
      chefTipIconColor: chefTipIconColor,
      theme: theme,
      moodStamps: moodStamps,
      stickers: stickers,
      washiTapes: washiTapes,
      visualTemplate: row.visualTemplate,
      visualStyleVersion: row.visualStyleVersion,
      isCurated: row.isCurated,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      version: row.version,
      origin: Origin.fromString(row.origin),
      currentVersionId: row.currentVersionId,
      ingredients: ingredients,
      steps: steps,
      tools: tools,
      labels: labels,
      isFavorite: fav != null,
    );
  }

  Recipe _mapRowToRecipe(RecipesTableData r, {bool isFavorite = false}) {
    Map<String, dynamic> provenance = {};
    try {
      if (r.provenanceJson.isNotEmpty) {
        provenance = jsonDecode(r.provenanceJson) as Map<String, dynamic>;
      }
    } catch (_) {}

    return Recipe(
      id: r.id,
      profileId: r.profileId,
      title: r.title,
      slug: r.slug,
      summary: r.summary,
      status: RecipeStatus.fromString(r.status),
      baseServings: Rational(r.baseServingsNum, r.baseServingsDen),
      difficulty: RecipeDifficulty.fromString(r.difficulty),
      totalMinutes: r.totalMinutes,
      coverMediaId: r.coverMediaId,
      coverImage: provenance['coverImage'] as String?,
      polaroidCaption: provenance['polaroidCaption'] as String?,
      polaroidRotation: (provenance['polaroidRotation'] as num?)?.toDouble(),
      polaroidX: (provenance['polaroidX'] as num?)?.toDouble(),
      polaroidY: (provenance['polaroidY'] as num?)?.toDouble(),
      chefTip: provenance['chefTip'] as String?,
      chefTipIcon: provenance['chefTipIcon'] as String?,
      chefTipIconColor: provenance['chefTipIconColor'] as String?,
      theme: ScrapbookTheme.fromKey(provenance['theme'] as String?),
      moodStamps: (provenance['moodStamps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      stickers: (provenance['stickers'] as List<dynamic>?)
              ?.map((e) => ScrapbookSticker.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      washiTapes: (provenance['washiTapes'] as List<dynamic>?)
              ?.map((e) => WashiTapeDecoration.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      visualTemplate: r.visualTemplate,
      visualStyleVersion: r.visualStyleVersion,
      isCurated: r.isCurated,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: r.deletedAt,
      version: r.version,
      origin: Origin.fromString(r.origin),
      currentVersionId: r.currentVersionId,
      isFavorite: isFavorite,
    );
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
