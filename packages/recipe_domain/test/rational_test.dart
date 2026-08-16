import 'package:recipe_domain/recipe_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Rational', () {
    test('creates simplified rational', () {
      final r = Rational(4, 8);
      expect(r.numerator, equals(1));
      expect(r.denominator, equals(2));
      expect(r.toDisplayString(), equals('½'));
      expect(r.toDouble(), equals(0.5));
    });

    test('handles mixed numbers in toDisplayString', () {
      final r1 = Rational(3, 2);
      expect(r1.toDisplayString(), equals('1 ½'));
      expect(r1.toSpokenString(), equals('1 and one half'));

      final r2 = Rational(7, 4);
      expect(r2.toDisplayString(), equals('1 ¾'));
      expect(r2.toSpokenString(), equals('1 and three quarters'));

      final r3 = Rational(6, 3);
      expect(r3.toDisplayString(), equals('2'));
      expect(r3.toSpokenString(), equals('2'));
    });

    test('parses various string formats', () {
      expect(Rational.tryParse('1 1/2'), equals(Rational(3, 2)));
      expect(Rational.tryParse('3/4'), equals(Rational(3, 4)));
      expect(Rational.tryParse('2'), equals(Rational(2, 1)));
      expect(Rational.tryParse('0.5'), equals(Rational(1, 2)));
      expect(Rational.tryParse('0.25'), equals(Rational(1, 4)));
      expect(Rational.tryParse('invalid'), isNull);
    });

    test('supports rational arithmetic', () {
      final a = Rational(1, 2);
      final b = Rational(1, 3);

      expect(a + b, equals(Rational(5, 6)));
      expect(a - b, equals(Rational(1, 6)));
      expect(a * b, equals(Rational(1, 6)));
      expect(a / b, equals(Rational(3, 2)));
    });

    test('handles zero denominator rejection', () {
      expect(() => Rational(1, 0), throwsArgumentError);
    });
  });
}
