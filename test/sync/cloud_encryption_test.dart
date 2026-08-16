import 'package:test/test.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:chefs_kiss/features/sync/services/cloud_encryption_service.dart';

void main() {
  late CloudEncryptionService cryptoService;

  setUp(() {
    cryptoService = CloudEncryptionService();
  });

  group('CloudEncryptionService', () {
    final sampleRecipe = Recipe(
      id: 'rec_enc_1',
      profileId: 'prof_1',
      title: 'Secret Family Recipe',
      summary: 'Grandmother secret stew.',
      status: RecipeStatus.ready,
      baseServings: Rational(4),
      difficulty: RecipeDifficulty.medium,
      totalMinutes: 60,
      createdAt: 1000,
      updatedAt: 1000,
      ingredients: [
        RecipeIngredient(
          id: 'ing_1',
          recipeId: 'rec_enc_1',
          displayName: 'Special Herbs',
          quantity: Rational(2),
          unitCode: 'tbsp',
          position: 1,
        ),
      ],
      steps: const [
        RecipeStep(
          id: 'step_1',
          recipeId: 'rec_enc_1',
          position: 1,
          instructionShort: 'Simmer on low for 45 minutes.',
          durationSeconds: 2700,
        ),
      ],
    );

    final samplePackage = ChefBackupPackage(
      manifest: const BackupManifest(
        exportedAt: 1700000000000,
        appVersion: '1.0.0+1',
        schemaVersion: 1,
        profileId: 'prof_1',
        recipeCount: 1,
        collectionCount: 0,
        sha256Checksum: 'dummy',
      ),
      profile: const UserProfile(
        id: 'prof_1',
        displayName: 'Test Chef',
        createdAt: 1000,
        updatedAt: 1000,
      ),
      recipes: [sampleRecipe],
      collections: [],
    );

    test('encrypts and decrypts backup package with correct passphrase', () async {
      const passphrase = 'SuperSecretPassphrase123!';

      final encResult = await cryptoService.encryptBackupPackage(
        package: samplePackage,
        passphrase: passphrase,
        userId: 'user_42',
      );

      expect(encResult.isSuccess, isTrue);
      final envelope = encResult.orNull!;
      expect(envelope.userId, equals('user_42'));
      expect(envelope.itemCount, equals(1));
      expect(envelope.ciphertext.isNotEmpty, isTrue);

      // Decrypt
      final decResult = await cryptoService.decryptBackupPackage(
        envelope: envelope,
        passphrase: passphrase,
      );

      expect(decResult.isSuccess, isTrue);
      final decryptedPackage = decResult.orNull!;
      expect(decryptedPackage.recipes.length, equals(1));
      expect(decryptedPackage.recipes.first.title, equals('Secret Family Recipe'));
      expect(decryptedPackage.recipes.first.ingredients.first.displayName, equals('Special Herbs'));
    });

    test('rejects decryption with incorrect passphrase', () async {
      final encResult = await cryptoService.encryptBackupPackage(
        package: samplePackage,
        passphrase: 'CorrectPassword!',
      );

      final envelope = encResult.orNull!;

      final decResult = await cryptoService.decryptBackupPackage(
        envelope: envelope,
        passphrase: 'WrongPassword!',
      );

      expect(decResult.isFailure, isTrue);
    });

    test('rejects empty passphrase', () async {
      final encResult = await cryptoService.encryptBackupPackage(
        package: samplePackage,
        passphrase: '  ',
      );

      expect(encResult.isFailure, isTrue);
    });
  });
}
