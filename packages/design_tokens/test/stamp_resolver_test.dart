import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exact ids resolve to their own artwork before fuzzy matches', () {
    final doodle = renderCulinaryStampById('food-avocado-toast');
    expect(doodle, isA<SvgFoodDoodleWidget>());
    expect((doodle! as SvgFoodDoodleWidget).id, 'food-avocado-toast');

    final stamp = renderCulinaryStampById('postage-avocado');
    expect(stamp, isA<SvgPostageStampWidget>());

    final seal = renderCulinaryStampById('seal-michelin');
    expect(seal, isA<SvgWaxSealWidget>());
    expect(renderCulinaryStampById('nonsense-id'), isA<Widget>());
  });
}
