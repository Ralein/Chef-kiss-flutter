import 'package:flutter/material.dart';

class ChefSpacing {
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 24.0;
  static const double space6 = 32.0;
  static const double space7 = 48.0;
  static const double space8 = 64.0;

  static const EdgeInsets p1 = EdgeInsets.all(space1);
  static const EdgeInsets p2 = EdgeInsets.all(space2);
  static const EdgeInsets p3 = EdgeInsets.all(space3);
  static const EdgeInsets p4 = EdgeInsets.all(space4);
  static const EdgeInsets p5 = EdgeInsets.all(space5);
  static const EdgeInsets p6 = EdgeInsets.all(space6);

  static const EdgeInsets h4 = EdgeInsets.symmetric(horizontal: space4);
  static const EdgeInsets v4 = EdgeInsets.symmetric(vertical: space4);
  static const EdgeInsets h5 = EdgeInsets.symmetric(horizontal: space5);
  static const EdgeInsets v5 = EdgeInsets.symmetric(vertical: space5);

  static const SizedBox gap1 = SizedBox(width: space1, height: space1);
  static const SizedBox gap2 = SizedBox(width: space2, height: space2);
  static const SizedBox gap3 = SizedBox(width: space3, height: space3);
  static const SizedBox gap4 = SizedBox(width: space4, height: space4);
  static const SizedBox gap5 = SizedBox(width: space5, height: space5);
  static const SizedBox gap6 = SizedBox(width: space6, height: space6);
}

class ChefRadius {
  static const double tile = 20.0;
  static const double card = 24.0;
  static const double sheet = 28.0;
  static const double modal = 28.0;
  static const double pill = 999.0;

  static const BorderRadius tileBorder = BorderRadius.all(Radius.circular(tile));
  static const BorderRadius cardBorder = BorderRadius.all(Radius.circular(card));
  static const BorderRadius sheetBorder = BorderRadius.only(
    topLeft: Radius.circular(sheet),
    topRight: Radius.circular(sheet),
  );
  static const BorderRadius modalBorder = BorderRadius.all(Radius.circular(modal));
  static const BorderRadius pillBorder = BorderRadius.all(Radius.circular(pill));
}

class ChefMotion {
  static const Duration quick = Duration(milliseconds: 120);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration emphasis = Duration(milliseconds: 320);

  static const Curve easeStandard = Curves.easeInOutCubic;
  static const Curve easeExit = Curves.easeOutCubic;
}
