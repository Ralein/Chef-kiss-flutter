import 'package:meta/meta.dart';

/// Represents an exact rational fraction (numerator / denominator)
/// with integer arithmetic and friendly fraction rendering.
@immutable
class Rational implements Comparable<Rational> {
  final int numerator;
  final int denominator;

  const Rational.constant(this.numerator, [this.denominator = 1]);

  const Rational._(this.numerator, this.denominator);

  factory Rational(int numerator, [int denominator = 1]) {
    if (denominator == 0) {
      throw ArgumentError.value(denominator, 'denominator', 'Cannot be zero');
    }
    if (denominator < 0) {
      numerator = -numerator;
      denominator = -denominator;
    }
    if (numerator == 0) {
      return const Rational._(0, 1);
    }
    final g = _gcd(numerator.abs(), denominator);
    return Rational._(numerator ~/ g, denominator ~/ g);
  }

  static const Rational zero = Rational._(0, 1);
  static const Rational one = Rational._(1, 1);
  static const Rational half = Rational._(1, 2);

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  static Rational? tryParse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // Mixed fraction: "1 1/2" or "1-1/2"
    final mixedMatch = RegExp(r'^(\d+)\s+([1-9]\d*)/([1-9]\d*)$').firstMatch(trimmed);
    if (mixedMatch != null) {
      final whole = int.tryParse(mixedMatch.group(1)!);
      final num = int.tryParse(mixedMatch.group(2)!);
      final den = int.tryParse(mixedMatch.group(3)!);
      if (whole != null && num != null && den != null && den > 0) {
        return Rational(whole * den + num, den);
      }
    }

    // Simple fraction: "3/4"
    final fracMatch = RegExp(r'^(-?\d+)/([1-9]\d*)$').firstMatch(trimmed);
    if (fracMatch != null) {
      final num = int.tryParse(fracMatch.group(1)!);
      final den = int.tryParse(fracMatch.group(2)!);
      if (num != null && den != null && den > 0) {
        return Rational(num, den);
      }
    }

    // Decimal or integer: "1.5" or "2"
    final d = double.tryParse(trimmed);
    if (d != null) {
      return fromDouble(d);
    }

    return null;
  }

  static Rational fromDouble(double value, [double tolerance = 1e-4]) {
    if (value.isNaN || value.isInfinite) {
      throw ArgumentError('Cannot convert NaN or infinite double to Rational');
    }
    if (value == 0.0) return Rational.zero;

    final isNeg = value < 0;
    var v = value.abs();

    var h1 = 1, h2 = 0;
    var k1 = 0, k2 = 1;
    var b = v;

    do {
      final a = b.floor();
      var aux = h1;
      h1 = a * h1 + h2;
      h2 = aux;
      aux = k1;
      k1 = a * k1 + k2;
      k2 = aux;
      b = 1 / (b - a);
    } while ((v - h1 / k1).abs() > v * tolerance && k1 < 10000);

    final num = isNeg ? -h1 : h1;
    return Rational(num, k1);
  }

  double toDouble() => numerator / denominator;

  bool get isZero => numerator == 0;
  bool get isPositive => numerator > 0;
  bool get isNegative => numerator < 0;
  bool get isWhole => denominator == 1;

  Rational operator +(Rational other) {
    return Rational(
      numerator * other.denominator + other.numerator * denominator,
      denominator * other.denominator,
    );
  }

  Rational operator -(Rational other) {
    return Rational(
      numerator * other.denominator - other.numerator * denominator,
      denominator * other.denominator,
    );
  }

  Rational operator *(Rational other) {
    return Rational(
      numerator * other.numerator,
      denominator * other.denominator,
    );
  }

  Rational operator /(Rational other) {
    if (other.isZero) {
      throw ArgumentError('Cannot divide by zero');
    }
    return Rational(
      numerator * other.denominator,
      denominator * other.numerator,
    );
  }

  bool operator <(Rational other) => compareTo(other) < 0;
  bool operator <=(Rational other) => compareTo(other) <= 0;
  bool operator >(Rational other) => compareTo(other) > 0;
  bool operator >=(Rational other) => compareTo(other) >= 0;

  Rational scale(Rational factor) => this * factor;

  @override
  int compareTo(Rational other) {
    return (numerator * other.denominator).compareTo(other.numerator * denominator);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rational &&
          runtimeType == other.runtimeType &&
          numerator == other.numerator &&
          denominator == other.denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);

  /// Renders friendly cooking fractions with Unicode glyphs (e.g., "1 ½", "¾", "2")
  String toDisplayString() {
    if (isZero) return '0';
    final isNeg = isNegative;
    final absNum = numerator.abs();
    final whole = absNum ~/ denominator;
    final rem = absNum % denominator;

    final prefix = isNeg ? '-' : '';

    if (rem == 0) {
      return '$prefix$whole';
    }

    final fracGlyph = _fractionGlyph(rem, denominator);
    if (fracGlyph != null) {
      if (whole == 0) {
        return '$prefix$fracGlyph';
      } else {
        return '$prefix$whole $fracGlyph';
      }
    }

    if (whole == 0) {
      return '$prefix$rem/$denominator';
    } else {
      return '$prefix$whole $rem/$denominator';
    }
  }

  /// Spoken text for screen readers & voice mode (e.g., "one and a half", "three quarters")
  String toSpokenString() {
    if (isZero) return 'zero';
    final isNeg = isNegative;
    final absNum = numerator.abs();
    final whole = absNum ~/ denominator;
    final rem = absNum % denominator;
    final prefix = isNeg ? 'negative ' : '';

    if (rem == 0) {
      return '$prefix$whole';
    }

    final fracWords = _fractionWords(rem, denominator);
    if (whole == 0) {
      return '$prefix$fracWords';
    } else {
      return '$prefix$whole and $fracWords';
    }
  }

  static String? _fractionGlyph(int num, int den) {
    if (num == 1 && den == 2) return '½';
    if (num == 1 && den == 3) return '⅓';
    if (num == 2 && den == 3) return '⅔';
    if (num == 1 && den == 4) return '¼';
    if (num == 3 && den == 4) return '¾';
    if (num == 1 && den == 5) return '⅕';
    if (num == 2 && den == 5) return '⅖';
    if (num == 3 && den == 5) return '⅗';
    if (num == 4 && den == 5) return '⅘';
    if (num == 1 && den == 6) return '⅙';
    if (num == 5 && den == 6) return '⅚';
    if (num == 1 && den == 8) return '⅛';
    if (num == 3 && den == 8) return '⅜';
    if (num == 5 && den == 8) return '⅝';
    if (num == 7 && den == 8) return '⅞';
    return null;
  }

  static String _fractionWords(int num, int den) {
    if (num == 1 && den == 2) return 'one half';
    if (num == 1 && den == 3) return 'one third';
    if (num == 2 && den == 3) return 'two thirds';
    if (num == 1 && den == 4) return 'one quarter';
    if (num == 3 && den == 4) return 'three quarters';
    if (num == 1 && den == 8) return 'one eighth';
    if (num == 3 && den == 8) return 'three eighths';
    if (num == 5 && den == 8) return 'five eighths';
    if (num == 7 && den == 8) return 'seven eighths';
    return '$num over $den';
  }

  @override
  String toString() => toDisplayString();
}
