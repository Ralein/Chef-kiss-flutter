import 'package:test/test.dart';
import 'package:drift/native.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:chefs_kiss/data/db/app_database.dart';
import 'package:chefs_kiss/data/repositories/drift_cooking_session_repository.dart';

void main() {
  late AppDatabase db;
  late DriftCookingSessionRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftCookingSessionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DriftCookingSessionRepository', () {
    test('starts session and advances step progression', () async {
      final sessionRes = await repo.startSession(
        profileId: 'default',
        recipeId: 'rec_1',
        selectedServings: Rational(4),
      );

      expect(sessionRes.isSuccess, isTrue);
      final session = sessionRes.orNull!;
      expect(session.recipeId, equals('rec_1'));
      expect(session.selectedServings, equals(Rational(4)));
      expect(session.activeStepPosition, equals(1));
      expect(session.status, equals(CookingSessionStatus.active));

      // Advance to Step 2
      final updated = await repo.updateActiveStep(
        sessionId: session.id,
        stepPosition: 2,
      );
      expect(updated.orNull!.activeStepPosition, equals(2));
    });

    test('sets ingredient check states', () async {
      final sessionRes = await repo.startSession(
        profileId: 'default',
        recipeId: 'rec_1',
        selectedServings: Rational(2),
      );
      final session = sessionRes.orNull!;

      final checkRes = await repo.setIngredientCheck(
        sessionId: session.id,
        recipeIngredientId: 'ing_tomato',
        isChecked: true,
      );
      expect(checkRes.isSuccess, isTrue);
      expect(checkRes.orNull!.isChecked, isTrue);

      final fetched = (await repo.getSessionByRecipeId('rec_1')).orNull!;
      expect(fetched.isIngredientChecked('ing_tomato'), isTrue);
    });

    test('creates multi-timers with absolute UTC end times', () async {
      final sessionRes = await repo.startSession(
        profileId: 'default',
        recipeId: 'rec_1',
        selectedServings: Rational(2),
      );
      final session = sessionRes.orNull!;

      final timerRes = await repo.createTimer(
        sessionId: session.id,
        label: 'Sauté Onions',
        durationSeconds: 180,
      );

      expect(timerRes.isSuccess, isTrue);
      final timer = timerRes.orNull!;
      expect(timer.durationSeconds, equals(180));
      expect(timer.endsAt, greaterThan(timer.startedAt));
      expect(timer.remainingSeconds(), lessThanOrEqualTo(180));
    });

    test('pauses and completes session', () async {
      final sessionRes = await repo.startSession(
        profileId: 'default',
        recipeId: 'rec_1',
        selectedServings: Rational(2),
      );
      final session = sessionRes.orNull!;

      await repo.pauseSession(session.id);
      var fetched = (await repo.getSessionByRecipeId('rec_1')).orNull!;
      expect(fetched.status, equals(CookingSessionStatus.paused));

      await repo.completeSession(session.id);
      final completed = (await repo.getSessionByRecipeId('rec_1')).orNull;
      // Once completed, getSessionByRecipeId returns null for active search
      expect(completed, isNull);
    });
  });
}
