import 'package:flutter/material.dart';
import 'culinary_postage_stamps.dart';
import 'culinary_wax_seals.dart';
import 'culinary_food_doodles.dart';
import 'sketchbook_decorations.dart';

export 'culinary_postage_stamps.dart';
export 'culinary_wax_seals.dart';
export 'culinary_food_doodles.dart';

/// Universal master list of all SVG stamps, seals, and food doodles in the system.
final List<CulinaryStampDef> allCulinarySvgStamps = [
  ...postageStampDefs,
  ...waxSealDefs,
  ...foodDoodleDefs,
];

/// Universal resolver to render any SVG stamp, wax seal, food doodle, or custom badge by its unique ID.
Widget? renderCulinaryStampById(
  String stampId, {
  double size = 56,
  double? rotation,
  Color? color,
}) {
  final norm = stampId.toLowerCase().trim();

  // 1. Dynamic Custom Ink Badges
  if (norm.startsWith('badge-custom') || norm.startsWith('badge-dynamic')) {
    return DynamicCustomInkBadge(
      text: 'CHEF APPROVED',
      color: color ?? const Color(0xFFC85A32),
      rotation: (rotation ?? -6.0) * (3.14159 / 180),
    );
  }

  // 2. An exact id wins in any category. Without this, "food-avocado-toast"
  // fuzzy-matched the avocado *postage stamp* below before doodles were tried.
  for (final def in allCulinarySvgStamps) {
    if (def.id == norm) return def.builder(size: size, rotation: rotation ?? def.defaultRotation);
  }

  // 3. Vintage Postage Stamps (loose match for older ids)
  final stampMatch = postageStampDefs.firstWhere(
    (s) => s.id == norm || norm.contains(s.id.replaceAll('postage-', '')),
    orElse: () => CulinaryStampDef(id: '', name: '', category: '', defaultRotation: 0, builder: ({double size = 56, double rotation = 0}) => const SizedBox.shrink()),
  );
  if (stampMatch.id.isNotEmpty) {
    return stampMatch.builder(size: size, rotation: rotation ?? stampMatch.defaultRotation);
  }

  // 4. Embossed Wax Seals
  final sealMatch = waxSealDefs.firstWhere(
    (s) => s.id == norm || norm.contains(s.id.replaceAll('seal-', '')),
    orElse: () => CulinaryStampDef(id: '', name: '', category: '', defaultRotation: 0, builder: ({double size = 56, double rotation = 0}) => const SizedBox.shrink()),
  );
  if (sealMatch.id.isNotEmpty) {
    return sealMatch.builder(size: size, rotation: rotation ?? sealMatch.defaultRotation);
  }

  // 5. Food Doodles
  final doodleMatch = foodDoodleDefs.firstWhere(
    (s) => s.id == norm || norm.contains(s.id.replaceAll('food-', '').replaceAll('doodle-', '')),
    orElse: () => CulinaryStampDef(id: '', name: '', category: '', defaultRotation: 0, builder: ({double size = 56, double rotation = 0}) => const SizedBox.shrink()),
  );
  if (doodleMatch.id.isNotEmpty) {
    return doodleMatch.builder(size: size, rotation: rotation ?? doodleMatch.defaultRotation);
  }

  // 6. Fallback Doodle Painter using the ID
  return SvgFoodDoodleWidget(
    id: stampId,
    size: size,
    rotation: rotation ?? -4.0,
    color: color,
  );
}
