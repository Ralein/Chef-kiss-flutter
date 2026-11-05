import 'package:recipe_domain/recipe_domain.dart';

/// Human-friendly formatting for scaled recipe quantities and nutrition.
class KitchenFormat {
  KitchenFormat._();

  static const _metric = {'g', 'kg', 'mg', 'ml', 'l', 'cl', 'dl'};
  static const _pluralizable = {
    'cup': 'cups', 'can': 'cans', 'slice': 'slices', 'clove': 'cloves', 'bunch': 'bunches', 'handful': 'handfuls',
    'pinch': 'pinches', 'stalk': 'stalks', 'sprig': 'sprigs', 'sheet': 'sheets', 'piece': 'pieces', 'head': 'heads',
    'stick': 'sticks', 'dash': 'dashes', 'jar': 'jars', 'packet': 'packets', 'tin': 'tins',
  };
  static const _hiddenUnits = {'each', 'ea', 'whole', 'unit', 'units', 'piece'};

  /// "1 ½", "⅓", "250", "2.5" — snapped to fractions a cook can measure for
  /// spoons/cups/counts, plain numbers for metric weights and volumes.
  static String quantity(double value, String? unit) {
    if (!value.isFinite || value <= 0) return '';
    final u = (unit ?? '').trim().toLowerCase();
    if (_metric.contains(u)) {
      if (value >= 10) return value.round().toString();
      final s = value.toStringAsFixed(1);
      return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
    }
    if (value >= 20) return value.round().toString();
    return _snapFraction(value).toDisplayString();
  }

  static String unit(String? unit, double value) {
    final u = (unit ?? '').trim();
    if (u.isEmpty || _hiddenUnits.contains(u.toLowerCase())) return '';
    if (value > 1 && _pluralizable.containsKey(u.toLowerCase())) return _pluralizable[u.toLowerCase()]!;
    return u;
  }

  /// "1 ½ cups" / "200 g" / "3" for an ingredient amount, or null if none.
  static String? amount(Rational? qty, String? unitCode, {String? authored}) {
    if (qty == null) {
      return (authored != null && authored.trim().isNotEmpty) ? authored.trim() : null;
    }
    final v = qty.toDouble();
    final q = quantity(v, unitCode);
    if (q.isEmpty) return null;
    final u = unit(unitCode, v);
    return u.isEmpty ? q : '$q $u';
  }

  /// Nearest measurable fraction (halves, thirds, quarters, eighths). A finer
  /// denominator only wins if it is clearly closer, so 0.5 stays ½ rather
  /// than 4/8, while 0.75 still becomes ¾.
  static Rational _snapFraction(double v) {
    Rational? best;
    var bestError = double.infinity;
    for (final d in const [1, 2, 3, 4, 8]) {
      final n = (v * d).round();
      if (n == 0) continue;
      final err = (v - n / d).abs();
      if (best == null || err < bestError - 0.01) {
        best = Rational(n, d);
        bestError = err;
      }
    }
    return best ?? Rational(1, 8);
  }

  static String kcal(double value) => _thousands(value.round());

  static String grams(double value) {
    if (value >= 10 || value == 0) return '${value.round()} g';
    final s = value.toStringAsFixed(1);
    return '${s.endsWith('.0') ? s.substring(0, s.length - 2) : s} g';
  }

  static String milligrams(double value) => '${_thousands(value.round())} mg';

  static String _thousands(int v) {
    final s = v.abs().toString();
    final buf = StringBuffer(v < 0 ? '-' : '');
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static String minutes(int total) {
    if (total <= 0) return '—';
    if (total < 60) return '$total min';
    final h = total ~/ 60;
    final m = total % 60;
    return m == 0 ? '$h h' : '$h h $m min';
  }

  static String clock(int seconds) {
    final s = seconds < 0 ? 0 : seconds;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return h > 0 ? '$h:${two(m)}:${two(sec)}' : '${two(m)}:${two(sec)}';
  }
}
