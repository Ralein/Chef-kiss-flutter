import 'package:drift/native.dart';
import 'package:test/test.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/data/repositories/drift_collection_repository.dart';

void main() {
  test('watchCollections re-emits when recipes are added or removed', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftCollectionRepository(db);
    final col = (await repo.createCollection(profileId: 'default', name: 'Weeknight', colorToken: 'accent.herb')).orNull!;

    final seen = <int>[];
    final sub = repo.watchCollections().listen((list) => seen.add(list.single.recipeIds.length));
    await Future<void>.delayed(const Duration(milliseconds: 30));

    await repo.addRecipeToCollection(col.id, 'r1');
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await repo.addRecipeToCollection(col.id, 'r2');
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await repo.removeRecipeFromCollection(col.id, 'r1');
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await sub.cancel();

    expect(seen.first, 0);
    expect(seen, containsAllInOrder([1, 2, 1]));
  });

  test('empty collections are still listed', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftCollectionRepository(db);
    await repo.createCollection(profileId: 'default', name: 'A', colorToken: 'accent.herb');
    await repo.createCollection(profileId: 'default', name: 'B', colorToken: 'accent.herb');
    final list = await repo.watchCollections().first;
    expect(list.map((c) => c.name), unorderedEquals(['A', 'B']));
  });
}
