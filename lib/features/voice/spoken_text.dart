import 'package:recipe_domain/recipe_domain.dart';

/// Turns kitchen shorthand into text that reads naturally aloud:
/// "1 ½ tbsp" → "1 and a half tablespoons", "180°C" → "180 degrees Celsius",
/// "10–12 min" → "10 to 12 minutes".
///
/// Pure string rewriting, so it is deterministic and unit-tested; speech
/// engines differ a lot in how they pronounce symbols and abbreviations.
class SpokenText {
  SpokenText._();

  static const _fractionWords = {
    '½': 'a half',
    '⅓': 'a third',
    '⅔': 'two thirds',
    '¼': 'a quarter',
    '¾': 'three quarters',
    '⅛': 'an eighth',
    '⅜': 'three eighths',
    '⅝': 'five eighths',
    '⅞': 'seven eighths',
    '⅕': 'a fifth',
    '⅙': 'a sixth',
  };

  static const _asciiFractions = {
    '1/2': '½',
    '1/3': '⅓',
    '2/3': '⅔',
    '1/4': '¼',
    '3/4': '¾',
    '1/8': '⅛',
    '3/8': '⅜',
    '5/8': '⅝',
    '7/8': '⅞',
  };

  /// Unit spellings, singular then plural.
  static const _units = <String, (String, String)>{
    'tsp': ('teaspoon', 'teaspoons'),
    'tsps': ('teaspoon', 'teaspoons'),
    'teaspoon': ('teaspoon', 'teaspoons'),
    'teaspoons': ('teaspoon', 'teaspoons'),
    'tbsp': ('tablespoon', 'tablespoons'),
    'tbsps': ('tablespoon', 'tablespoons'),
    'tbs': ('tablespoon', 'tablespoons'),
    'tablespoon': ('tablespoon', 'tablespoons'),
    'tablespoons': ('tablespoon', 'tablespoons'),
    'g': ('gram', 'grams'),
    'gr': ('gram', 'grams'),
    'grams': ('gram', 'grams'),
    'kg': ('kilogram', 'kilograms'),
    'mg': ('milligram', 'milligrams'),
    'ml': ('milliliter', 'milliliters'),
    'cl': ('centiliter', 'centiliters'),
    'dl': ('deciliter', 'deciliters'),
    'l': ('liter', 'liters'),
    'oz': ('ounce', 'ounces'),
    'fl oz': ('fluid ounce', 'fluid ounces'),
    'lb': ('pound', 'pounds'),
    'lbs': ('pound', 'pounds'),
    'qt': ('quart', 'quarts'),
    'pt': ('pint', 'pints'),
    'gal': ('gallon', 'gallons'),
    'cm': ('centimeter', 'centimeters'),
    'mm': ('millimeter', 'millimeters'),
    'min': ('minute', 'minutes'),
    'mins': ('minute', 'minutes'),
    'hr': ('hour', 'hours'),
    'hrs': ('hour', 'hours'),
    'h': ('hour', 'hours'),
    'sec': ('second', 'seconds'),
    'secs': ('second', 'seconds'),
    'cup': ('cup', 'cups'),
    'cups': ('cup', 'cups'),
    'clove': ('clove', 'cloves'),
    'cloves': ('clove', 'cloves'),
    'can': ('can', 'cans'),
    'cans': ('can', 'cans'),
    'pinch': ('pinch', 'pinches'),
    'pinches': ('pinch', 'pinches'),
    'slice': ('slice', 'slices'),
    'slices': ('slice', 'slices'),
  };

  static final _emoji = RegExp(r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{200D}]', unicode: true);

  /// Rewrites [input] for a speech engine. Returns an empty string for blank
  /// input; otherwise the result ends with sentence punctuation.
  static String normalize(String input) {
    var s = input.replaceAll(_emoji, '').trim();
    if (s.isEmpty) return '';
    s = s.replaceAll(RegExp(r'\s*\n+\s*'), '. ');

    // Approximate amounts.
    s = s.replaceAllMapped(RegExp(r'(^|\s)~\s*(?=\d|[½⅓⅔¼¾⅛⅜⅝⅞])'), (m) => '${m[1]}about ');
    s = s.replaceAll(RegExp(r'\bapprox\.?(?=\s)', caseSensitive: false), 'about');

    // Ranges: "10–12", "10 - 12" → "10 to 12" (digits only, so words keep their hyphens).
    s = s.replaceAllMapped(RegExp(r'(\d)\s*[–—-]\s*(\d)'), (m) => '${m[1]} to ${m[2]}');

    // ASCII fractions → glyphs so a single rule handles both.
    s = s.replaceAllMapped(RegExp(r'(?<![\d/])(\d)/(\d)(?![\d/])'), (m) {
      return _asciiFractions['${m[1]}/${m[2]}'] ?? '${m[1]} over ${m[2]}';
    });

    // Temperatures.
    s = s.replaceAllMapped(RegExp(r'(\d)\s*°\s*C\b'), (m) => '${m[1]} degrees Celsius');
    s = s.replaceAllMapped(RegExp(r'(\d)\s*°\s*F\b'), (m) => '${m[1]} degrees Fahrenheit');
    s = s.replaceAll('°', ' degrees');

    // Number + unit, including glyph fractions ("1 ½ cups", "½ tsp", "200g").
    final unitAlternation = (_units.keys.toList()..sort((a, b) => b.length.compareTo(a.length)))
        .map(RegExp.escape)
        .join('|');
    final amountUnit = RegExp(
      r'(\d+(?:\.\d+)?)?\s*([½⅓⅔¼¾⅛⅜⅝⅞⅕⅙])?\s*(' + unitAlternation + r')(?![A-Za-z])',
      caseSensitive: false,
    );
    s = s.replaceAllMapped(amountUnit, (m) {
      final whole = m[1];
      final glyph = m[2];
      final unitKey = m[3]!.toLowerCase();
      if (whole == null && glyph == null) return m[0]!; // a bare word like "can"
      final forms = _units[unitKey]!;
      final value = (double.tryParse(whole ?? '0') ?? 0) + (glyph == null ? 0 : 0.5);
      if (whole == null) {
        // Fraction only: "half a cup", "a quarter teaspoon".
        if (glyph == '½') return 'half a ${forms.$1}';
        return '${_fractionWords[glyph]} ${forms.$1}';
      }
      final number = glyph == null ? whole : '$whole and ${_fractionWords[glyph]}';
      final plural = glyph != null || value != 1;
      return '$number ${plural ? forms.$2 : forms.$1}';
    });

    // "2 teaspoons. salt" → the dot was an abbreviation, not a sentence end.
    final spelled = {for (final f in _units.values) ...[f.$1, f.$2]}.map(RegExp.escape).join('|');
    s = s.replaceAllMapped(RegExp('\\b($spelled)\\.(?=\\s+[a-z])'), (m) => m[1]!);

    // Remaining glyph fractions without a unit.
    s = s.replaceAllMapped(RegExp(r'(\d+)\s*([½⅓⅔¼¾⅛⅜⅝⅞⅕⅙])'), (m) => '${m[1]} and ${_fractionWords[m[2]]}');
    s = s.replaceAllMapped(RegExp(r'[½⅓⅔¼¾⅛⅜⅝⅞⅕⅙]'), (m) => m[0] == '½' ? 'half' : _fractionWords[m[0]]!);

    // Common shorthand.
    s = s.replaceAll(RegExp(r'\be\.g\.', caseSensitive: false), 'for example');
    s = s.replaceAll(RegExp(r'\bi\.e\.', caseSensitive: false), 'that is');
    s = s.replaceAll(RegExp(r'\s*&\s*'), ' and ');
    s = s.replaceAll(RegExp(r'\s*[•·|]\s*'), ', ');
    s = s.replaceAllMapped(RegExp(r'(\d)\s*x\b'), (m) => '${m[1]} times');

    s = s.replaceAll(RegExp(r'\s+'), ' ').replaceAllMapped(RegExp(r'\s+([,.;:!?])'), (m) => m[1]!).trim();
    s = s.replaceAll(RegExp(r'\.{2,}'), '.').replaceAll(RegExp(r'[,;:]\.'), '.');
    if (!RegExp(r'[A-Za-z0-9]').hasMatch(s)) return '';
    if (!RegExp(r'[.!?]$').hasMatch(s)) s = '$s.';
    return s;
  }
}

/// One piece of a read-aloud session; [id] lets the UI highlight what is
/// currently being read (for example the step on screen).
class SpokenSegment {
  final String id;
  final String text;
  const SpokenSegment(this.id, this.text);

  @override
  String toString() => 'SpokenSegment($id, $text)';
}

/// Builds the read-aloud script for recipes and cooking steps.
class SpokenRecipe {
  SpokenRecipe._();

  /// Units after which "of" reads naturally: "2 cups of flour", but "3 eggs".
  static final _measureWords = <String>{
    ...SpokenText._units.keys,
    'bunch',
    'bunches',
    'handful',
    'handfuls',
    'sprig',
    'sprigs',
    'stick',
    'sticks',
    'sheet',
    'sheets',
    'head',
    'heads',
    'jar',
    'jars',
    'packet',
    'packets',
    'tin',
    'tins',
    'dash',
    'dashes',
    'stalk',
    'stalks',
    'piece',
    'pieces',
    'knob',
    'drizzle',
    'splash',
  };

  static String stepId(RecipeStep step) => 'step:${step.id}';
  static const ingredientsId = 'ingredients';
  static const introId = 'intro';

  /// "Step 2 of 6. Whisk the eggs…" — prefers the author's spoken wording.
  static String step(RecipeStep step, {required int number, required int total}) {
    final authored = step.spokenInstruction?.trim();
    final body = (authored != null && authored.isNotEmpty)
        ? authored
        : [
            step.instructionShort.trim(),
            if (step.instructionDetail != null && step.instructionDetail!.trim().isNotEmpty)
              step.instructionDetail!.trim(),
          ].map(_sentence).join(' ');
    final timers = step.timers
        .where((t) => t.durationSeconds > 0)
        .map(
          (t) =>
              'Timer for ${t.label.trim().isEmpty ? 'this step' : t.label.trim()}: ${_duration(t.durationSeconds)}.',
        )
        .join(' ');
    return SpokenText.normalize('Step $number of $total. $body $timers');
  }

  /// "You'll need: 2 tablespoons of olive oil; …" for already-formatted
  /// amounts (so speech matches what is on screen, including scaling).
  static String ingredients(List<({String amount, String name, String? prep})> lines, {String? servings}) {
    if (lines.isEmpty) return 'There are no ingredients listed for this recipe.';
    final head = servings == null ? 'You will need' : 'For $servings, you will need';
    final items = lines
        .map((l) {
          final amount = l.amount.trim();
          final prep = (l.prep?.trim().isNotEmpty ?? false) ? ', ${l.prep!.trim()}' : '';
          if (amount.isEmpty || amount.toLowerCase() == 'to taste') {
            return '${l.name.trim()}${amount.isEmpty ? '' : ' to taste'}$prep';
          }
          final lastWord = amount.split(RegExp(r'\s+')).last.toLowerCase().replaceAll('.', '');
          final of = _measureWords.contains(lastWord) ? ' of' : '';
          return '$amount$of ${l.name.trim()}$prep';
        })
        .join('; ');
    return SpokenText.normalize('$head: $items.');
  }

  static String intro(Recipe r) {
    final parts = <String>[r.title.trim()];
    if (r.summary != null && r.summary!.trim().isNotEmpty) parts.add(r.summary!.trim());
    if (r.totalMinutes > 0) parts.add('It takes about ${_duration(r.totalMinutes * 60)}');
    return SpokenText.normalize(parts.map(_sentence).join(' '));
  }

  static String tip(Recipe r) {
    final tip = r.chefTip?.trim();
    if (tip == null || tip.isEmpty) return '';
    return SpokenText.normalize('Chef’s tip: ${_sentence(tip)}');
  }

  static String timerDone(String label, {String? recipeTitle}) {
    final name = label.trim().isEmpty ? 'Your' : 'Your ${label.trim()}';
    final suffix = (recipeTitle != null && recipeTitle.trim().isNotEmpty) ? ' for ${recipeTitle.trim()}' : '';
    return SpokenText.normalize('$name timer$suffix is done');
  }

  static String _sentence(String s) {
    final t = s.trim();
    if (t.isEmpty) return t;
    return RegExp(r'[.!?]$').hasMatch(t) ? t : '$t.';
  }

  static String _duration(int seconds) {
    if (seconds < 60) return '$seconds second${seconds == 1 ? '' : 's'}';
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes minute${minutes == 1 ? '' : 's'}';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final hours = '$h hour${h == 1 ? '' : 's'}';
    return m == 0 ? hours : '$hours and $m minute${m == 1 ? '' : 's'}';
  }
}
