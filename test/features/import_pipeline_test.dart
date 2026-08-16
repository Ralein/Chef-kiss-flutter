import 'package:test/test.dart';
import 'package:drift/native.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/data/repositories/drift_recipe_repository.dart';
import 'package:chefs_kiss/features/imports/services/heuristic_recipe_extractor.dart';
import 'package:chefs_kiss/features/imports/data/local_import_repository.dart';
import 'package:chefs_kiss/features/illustrations/data/illustration_matcher.dart';

void main() {
  late AppDatabase db;
  late DriftRecipeRepository recipeRepo;
  late HeuristicRecipeExtractor extractor;
  late LocalImportRepository importRepo;
  late IllustrationMatcher illustrationMatcher;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    recipeRepo = DriftRecipeRepository(db);
    extractor = HeuristicRecipeExtractor();
    importRepo = LocalImportRepository(
      recipeRepo: recipeRepo,
      extractor: extractor,
    );
    illustrationMatcher = IllustrationMatcher();
  });

  tearDown(() async {
    await db.close();
  });

  group('Smart Import Pipeline & Heuristic Extraction', () {
    test('extracts Schema.org JSON-LD recipe with exact fractions and units', () async {
      const jsonLd = '''{
        "@context": "https://schema.org",
        "@type": "Recipe",
        "name": "Classic Lemon Ricotta Pasta",
        "description": "Bright, fresh weeknight pasta dish.",
        "recipeYield": "4 servings",
        "recipeIngredient": [
          "1 lb rigatoni pasta",
          "1 cup whole milk ricotta cheese",
          "1/2 cup grated parmesan cheese",
          "2 lemons, zested and juiced"
        ],
        "recipeInstructions": [
          "Boil pasta in salted water for 10 minutes.",
          "Whisk ricotta, parmesan, and lemon juice together.",
          "Toss hot pasta with sauce and serve."
        ]
      }''';

      final source = ImportSource(
        id: 'src_jsonld_1',
        kind: ImportSourceKind.text,
        rawText: jsonLd,
        sha256Checksum: '12345',
        byteSize: jsonLd.length,
        createdAt: 1000,
      );

      final extractRes = await extractor.extractRecipe(
        source: source,
        profileId: 'default',
      );

      expect(extractRes.isSuccess, isTrue);
      final recipe = extractRes.orNull!;

      expect(recipe.title, equals('Classic Lemon Ricotta Pasta'));
      expect(recipe.baseServings, equals(Rational(4)));
      expect(recipe.ingredients.length, equals(4));
      expect(recipe.ingredients[0].displayName, equals('rigatoni pasta'));
      expect(recipe.ingredients[0].quantity, equals(Rational(1)));
      expect(recipe.ingredients[0].unitCode, equals('lb'));
      expect(recipe.ingredients[2].quantity, equals(Rational(1, 2)));
      expect(recipe.steps.length, equals(3));
      expect(recipe.steps[0].durationSeconds, equals(600));
    });

    test('extracts freeform text recipe and parses sections', () async {
      const freeform = '''# Grandma’s Apple Crumble
Warm spiced apples with a golden oat topping.
Servings: 6

Ingredients:
- 5 large honeycrisp apples, peeled and sliced
- 1 cup rolled oats
- 1/2 cup all-purpose flour
- 1/2 cup unsalted butter, melted
- 1 tsp ground cinnamon

Instructions:
1. Preheat oven to 350°F.
2. Toss sliced apples with cinnamon and place in baking dish.
3. Mix oats, flour, and melted butter to form crumble topping.
4. Bake for 35 minutes until golden and bubbling.''';

      final source = ImportSource(
        id: 'src_freeform_1',
        kind: ImportSourceKind.text,
        rawText: freeform,
        sha256Checksum: '67890',
        byteSize: freeform.length,
        createdAt: 1000,
      );

      final extractRes = await extractor.extractRecipe(
        source: source,
        profileId: 'default',
      );

      expect(extractRes.isSuccess, isTrue);
      final recipe = extractRes.orNull!;

      expect(recipe.title, equals('Grandma’s Apple Crumble'));
      expect(recipe.baseServings, equals(Rational(6)));
      expect(recipe.ingredients.length, equals(5));
      expect(recipe.steps.length, equals(4));
      expect(recipe.steps[0].temperatureF, equals(350));
      expect(recipe.steps[3].durationSeconds, equals(2100)); // 35 mins
    });

    test('full import repository lifecycle: queue -> extract -> safety analysis -> accept review', () async {
      const freeform = '''# Crispy Garlic Butter Chicken
Servings: 2

Ingredients:
- 2 chicken breasts
- 3 tbsp unsalted butter
- 4 cloves garlic, minced

Instructions:
1. Sauté garlic in butter for 2 minutes.
2. Sear chicken in skillet for 12 minutes until cooked through.''';

      final source = ImportSource(
        id: 'src_chicken_1',
        kind: ImportSourceKind.text,
        rawText: freeform,
        sha256Checksum: 'abcde',
        byteSize: freeform.length,
        createdAt: 1000,
      );

      final jobRes = await importRepo.createJob(
        profileId: 'default',
        source: source,
      );

      expect(jobRes.isSuccess, isTrue);
      final initialJob = jobRes.orNull!;

      // Wait a tick for async extraction pipeline
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final updatedJob = (await importRepo.getJobById(initialJob.id)).orNull!;
      expect(updatedJob.status, equals(ImportStatus.reviewRequired));
      expect(updatedJob.extractedDraft, isNotNull);
      expect(updatedJob.overallConfidence, greaterThanOrEqualTo(0.9));

      // Verify safety warning for poultry internal temperature
      expect(updatedJob.warnings.any((w) => w.contains('74°C (165°F)')), isTrue);

      // Accept review and commit to database
      final acceptRes = await importRepo.acceptImportReview(
        jobId: updatedJob.id,
        recipe: updatedJob.extractedDraft!,
      );

      expect(acceptRes.isSuccess, isTrue);
      final savedRecipe = acceptRes.orNull!;

      // Verify recipe is now persisted in RecipeRepository
      final fetchedFromDb = (await recipeRepo.getRecipeById(savedRecipe.id)).orNull!;
      expect(fetchedFromDb.title, equals('Crispy Garlic Butter Chicken'));
      expect(fetchedFromDb.origin, equals(Origin.imported));
    });

    test('IllustrationMatcher matches recipe categories accurately', () {
      final pastaRecipe = Recipe(
        id: 'r_pasta',
        profileId: 'default',
        title: 'Rigatoni Carbonara with Guanciale',
        status: RecipeStatus.ready,
        baseServings: Rational(2),
        difficulty: RecipeDifficulty.medium,
        totalMinutes: 20,
        createdAt: 1000,
        updatedAt: 1000,
        ingredients: const [],
        steps: const [],
      );

      final match = illustrationMatcher.matchRecipe(pastaRecipe);
      expect(match.canonicalKey, equals('pasta'));
      expect(match.category, equals('pasta'));
    });
  });
}
