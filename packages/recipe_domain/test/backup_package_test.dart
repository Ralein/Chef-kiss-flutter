import 'dart:convert';
import 'package:test/test.dart';
import 'package:recipe_domain/recipe_domain.dart';

void main() {
  group('ChefBackupPackage', () {
    test('round-trip serializes and parses backup package JSON', () {
      final recipe = Recipe(
        id: 'rec_pasta_1',
        profileId: 'default',
        title: 'Rigatoni Carbonara',
        summary: 'Classic Roman pasta dish.',
        status: RecipeStatus.ready,
        baseServings: Rational(4),
        difficulty: RecipeDifficulty.medium,
        totalMinutes: 25,
        createdAt: 1000,
        updatedAt: 1000,
        ingredients: [
          RecipeIngredient(
            id: 'ing_1',
            recipeId: 'rec_pasta_1',
            displayName: 'Rigatoni',
            quantity: Rational(500),
            unitCode: 'g',
            position: 1,
          ),
        ],
        steps: const [
          RecipeStep(
            id: 'step_1',
            recipeId: 'rec_pasta_1',
            position: 1,
            instructionShort: 'Boil pasta.',
            durationSeconds: 600,
          ),
        ],
      );

      final collection = RecipeCollection(
        id: 'col_pasta',
        profileId: 'default',
        name: 'Italian Classics',
        colorToken: 'accent.tomato',
        createdAt: 1000,
        updatedAt: 1000,
        recipeIds: const ['rec_pasta_1'],
      );

      const profile = UserProfile(
        id: 'default',
        displayName: 'Chef Mario',
        unitSystem: UnitSystem.metric,
        createdAt: 1000,
        updatedAt: 1000,
      );

      const manifest = BackupManifest(
        exportedAt: 1000,
        profileId: 'default',
        recipeCount: 1,
        collectionCount: 1,
        sha256Checksum: 'dummy_hash',
      );

      final pkg = ChefBackupPackage(
        manifest: manifest,
        profile: profile,
        recipes: [recipe],
        collections: [collection],
      );

      final jsonStr = jsonEncode(pkg.toJson());
      final decodedPkg = ChefBackupPackage.fromJsonString(jsonStr);

      expect(decodedPkg.recipes.length, equals(1));
      expect(decodedPkg.recipes.first.title, equals('Rigatoni Carbonara'));
      expect(decodedPkg.recipes.first.baseServings, equals(Rational(4)));
      expect(decodedPkg.recipes.first.ingredients.first.displayName, equals('Rigatoni'));
      expect(decodedPkg.collections.length, equals(1));
      expect(decodedPkg.collections.first.name, equals('Italian Classics'));
      expect(decodedPkg.profile.displayName, equals('Chef Mario'));
    });
  });
}
