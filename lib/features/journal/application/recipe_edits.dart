import 'dart:async';

import 'package:app_contracts/app_contracts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/providers.dart';

/// Applies small edits (move a sticker, change an icon) one after another.
///
/// Each edit is a function of the newest version of the recipe — including
/// edits still being saved — so dragging two stickers in quick succession
/// can't save a stale copy that puts the first one back.
class RecipeEditQueue {
  RecipeEditQueue(this._repo);

  final RecipeRepository _repo;
  final Map<String, Recipe> _inFlight = {};
  final Map<String, Recipe> _lastSaved = {};
  final Map<String, Future<Result<Recipe, AppFailure>>> _tail = {};

  /// The newest known version of [current]: queued edits first, then what we
  /// last saved (screens may still hold an older copy from before the save
  /// came back through the database stream).
  Recipe latest(Recipe current) {
    final queued = _inFlight[current.id];
    if (queued != null) return queued;
    final saved = _lastSaved[current.id];
    if (saved != null && saved.version > current.version) return saved;
    return current;
  }

  Future<Result<Recipe, AppFailure>> apply(Recipe current, Recipe Function(Recipe latest) change) {
    final id = current.id;
    final next = change(latest(current));
    _inFlight[id] = next;
    final previous = _tail[id] ?? Future.value(Result<Recipe, AppFailure>.ok(current));
    final saved = previous.then((_) => _repo.saveRecipe(next)).then((res) {
      final stored = res.orNull;
      if (stored != null) _lastSaved[id] = stored;
      if (identical(_inFlight[id], next)) {
        _inFlight.remove(id);
        _tail.remove(id);
      }
      return res;
    });
    _tail[id] = saved;
    return saved;
  }
}

final recipeEditQueueProvider = Provider<RecipeEditQueue>(
  (ref) => RecipeEditQueue(ref.watch(recipeRepositoryProvider)),
);

/// Servings chosen on a journal page, shared with the toolbar's Cook and
/// Listen buttons. Null means the recipe's own yield.
final journalServingsProvider = StateProvider.family<int?, String>((ref, recipeId) => null);
