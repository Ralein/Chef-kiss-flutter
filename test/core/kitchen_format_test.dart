import 'package:chefs_kiss/app/widgets/kitchen_format.dart';
import 'package:chefs_kiss/features/recipe_editor/presentation/recipe_editor_screen.dart' show parseQuantity;
import 'package:recipe_domain/recipe_domain.dart';
import 'package:test/test.dart';

void main() {
  group('KitchenFormat.quantity', () {
    test('snaps spoons, cups and counts to measurable fractions', () {
      expect(KitchenFormat.quantity(0.75, 'cup'), '¾');
      expect(KitchenFormat.quantity(1 / 3, 'cup'), '⅓');
      expect(KitchenFormat.quantity(1.5, null), '1 ½');
      expect(KitchenFormat.quantity(2.25, 'tbsp'), '2 ¼');
      expect(KitchenFormat.quantity(0.125, 'tsp'), '⅛');
      expect(KitchenFormat.quantity(3, 'cloves'), '3');
    });

    test('keeps metric weights and volumes as plain numbers', () {
      expect(KitchenFormat.quantity(337.5, 'g'), '338');
      expect(KitchenFormat.quantity(7.5, 'g'), '7.5');
      expect(KitchenFormat.quantity(2.0, 'ml'), '2');
    });

    test('rejects nonsense', () {
      expect(KitchenFormat.quantity(double.nan, 'g'), '');
      expect(KitchenFormat.quantity(-1, 'g'), '');
    });
  });

  group('KitchenFormat.amount', () {
    test('pluralizes and hides count units', () {
      expect(KitchenFormat.amount(Rational(3, 2), 'cup'), '1 ½ cups');
      expect(KitchenFormat.amount(Rational(1), 'cup'), '1 cup');
      expect(KitchenFormat.amount(Rational(2), 'each'), '2');
      expect(KitchenFormat.amount(null, 'g', authored: 'a pinch'), 'a pinch');
      expect(KitchenFormat.amount(null, 'g'), isNull);
    });
  });

  test('numbers, grams and durations', () {
    expect(KitchenFormat.kcal(1284.4), '1,284');
    expect(KitchenFormat.kcal(1234567), '1,234,567');
    expect(KitchenFormat.grams(0), '0 g');
    expect(KitchenFormat.grams(2.5), '2.5 g');
    expect(KitchenFormat.grams(12.6), '13 g');
    expect(KitchenFormat.minutes(45), '45 min');
    expect(KitchenFormat.minutes(150), '2 h 30 min');
    expect(KitchenFormat.clock(3725), '1:02:05');
    expect(KitchenFormat.clock(65), '01:05');
  });

  test('editor quantity parsing understands unicode and decimal commas', () {
    expect(parseQuantity('1½'), Rational(3, 2));
    expect(parseQuantity('1 ½'), Rational(3, 2));
    expect(parseQuantity('¾'), Rational(3, 4));
    expect(parseQuantity('1 1/2'), Rational(3, 2));
    expect(parseQuantity('0,5'), Rational(1, 2));
    expect(parseQuantity(''), isNull);
    expect(parseQuantity('a pinch'), isNull);
    expect(parseQuantity('0'), isNull);
  });
}
