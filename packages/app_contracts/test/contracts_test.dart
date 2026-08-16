import 'package:app_contracts/app_contracts.dart';
import 'package:test/test.dart';

void main() {
  group('Result & Failures', () {
    test('Result.ok returns value in when and getOrElse', () {
      final res = Result<int, AppFailure>.ok(42);
      expect(res.isSuccess, isTrue);
      expect(res.orNull, equals(42));
      expect(res.getOrElse((_) => 0), equals(42));
    });

    test('Result.err triggers error branch', () {
      final failure = const ValidationFailure(message: 'Invalid');
      final res = Result<int, AppFailure>.err(failure);
      expect(res.isFailure, isTrue);
      expect(res.orNull, isNull);
      expect(res.getOrElse((_) => 99), equals(99));
    });
  });

  group('Redactor', () {
    test('redacts forbidden keys from log metadata map', () {
      final input = {
        'title': 'Secret Family Lasagna',
        'recipe_title': 'Spaghetti',
        'notes': 'Add extra garlic',
        'duration_seconds': 180,
        'step_count': 4,
      };

      final sanitized = Redactor.sanitizeMap(input);
      expect(sanitized['title'], equals('[REDACTED]'));
      expect(sanitized['recipe_title'], equals('[REDACTED]'));
      expect(sanitized['notes'], equals('[REDACTED]'));
      expect(sanitized['duration_seconds'], equals(180));
      expect(sanitized['step_count'], equals(4));
    });
  });
}
