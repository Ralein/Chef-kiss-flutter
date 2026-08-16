import '../models/rational.dart';
import '../models/recipe.dart';
import '../models/scaling_policy.dart';

class RecipeNormalizer {
  final String Function()? _idGenerator;

  const RecipeNormalizer({String Function()? idGenerator}) : _idGenerator = idGenerator;

  String _nextId() => _idGenerator?.call() ?? DateTime.now().microsecondsSinceEpoch.toString();

  /// Known unit dictionary mapping variations to standard unit codes
  static const Map<String, String> _unitMap = {
    'cup': 'cup',
    'cups': 'cup',
    'c': 'cup',
    'tbsp': 'tbsp',
    'tablespoon': 'tbsp',
    'tablespoons': 'tbsp',
    'tbs': 'tbsp',
    'tb': 'tbsp',
    'tsp': 'tsp',
    'teaspoon': 'tsp',
    'teaspoons': 'tsp',
    'g': 'g',
    'gram': 'g',
    'grams': 'g',
    'kg': 'kg',
    'kilogram': 'kg',
    'kilograms': 'kg',
    'ml': 'ml',
    'milliliter': 'ml',
    'milliliters': 'ml',
    'l': 'l',
    'liter': 'l',
    'liters': 'l',
    'oz': 'oz',
    'ounce': 'oz',
    'ounces': 'oz',
    'fl oz': 'fl oz',
    'fluid ounce': 'fl oz',
    'fluid ounces': 'fl oz',
    'lb': 'lb',
    'lbs': 'lb',
    'pound': 'lb',
    'pounds': 'lb',
    'pinch': 'pinch',
    'pinches': 'pinch',
    'dash': 'dash',
    'dashes': 'dash',
    'clove': 'cloves',
    'cloves': 'cloves',
    'slice': 'slices',
    'slices': 'slices',
    'can': 'can',
    'cans': 'can',
    'stalk': 'stalk',
    'stalks': 'stalk',
    'handful': 'handful',
    'handfuls': 'handful',
    'bunch': 'bunch',
    'bunches': 'bunch',
    'package': 'pkg',
    'pkg': 'pkg',
  };

  /// Common action verbs in kitchen instructions
  static const List<String> _actionKeywords = [
    'sauté', 'saute', 'chop', 'bake', 'boil', 'mix', 'simmer', 'whisk',
    'roast', 'fry', 'knead', 'slice', 'sear', 'preheat', 'cool', 'fold',
    'drain', 'garnish', 'blend', 'season', 'stir', 'grill', 'poach', 'serve'
  ];

  /// Parses a raw ingredient line into a structured RecipeIngredient
  RecipeIngredient normalizeIngredient(String rawLine, {required String recipeId, int position = 1}) {
    final cleaned = rawLine.trim().replaceAll(RegExp(r'^[•\-\*]\s*'), '').trim();
    if (cleaned.isEmpty) {
      return RecipeIngredient(
        id: _nextId(),
        recipeId: recipeId,
        displayName: 'Ingredient',
        position: position,
      );
    }

    // Check "to taste" policy
    final isToTaste = RegExp(r'\bto taste\b', caseSensitive: false).hasMatch(cleaned);

    // Split comma-separated prep phrases: "2 cups flour, sifted" -> ("2 cups flour", "sifted")
    String mainPart = cleaned;
    String? prepText;
    final commaIdx = cleaned.indexOf(',');
    if (commaIdx != -1) {
      mainPart = cleaned.substring(0, commaIdx).trim();
      prepText = cleaned.substring(commaIdx + 1).trim();
    }

    // Extract quantity from the start:
    // Support: "2 1/2", "3/4", "3", "1.5", "1-2"
    Rational? quantity;
    String? authoredQty;
    String remainder = mainPart;

    final mixedPattern = RegExp(r'^(\d+)\s+([1-9]\d*)/([1-9]\d*)');
    final fracPattern = RegExp(r'^([1-9]\d*)/([1-9]\d*)');
    final numPattern = RegExp(r'^(\d+(?:\.\d+)?)');

    final mixedMatch = mixedPattern.firstMatch(mainPart);
    if (mixedMatch != null) {
      final whole = int.parse(mixedMatch.group(1)!);
      final num = int.parse(mixedMatch.group(2)!);
      final den = int.parse(mixedMatch.group(3)!);
      quantity = Rational(whole * den + num, den);
      authoredQty = mixedMatch.group(0);
      remainder = mainPart.substring(mixedMatch.end).trim();
    } else {
      final fracMatch = fracPattern.firstMatch(mainPart);
      if (fracMatch != null) {
        final num = int.parse(fracMatch.group(1)!);
        final den = int.parse(fracMatch.group(2)!);
        quantity = Rational(num, den);
        authoredQty = fracMatch.group(0);
        remainder = mainPart.substring(fracMatch.end).trim();
      } else {
        final numMatch = numPattern.firstMatch(mainPart);
        if (numMatch != null) {
          quantity = Rational.tryParse(numMatch.group(1)!);
          authoredQty = numMatch.group(0);
          remainder = mainPart.substring(numMatch.end).trim();
        }
      }
    }

    // Strip any range suffix if present (e.g. "- 3")
    remainder = remainder.replaceFirst(RegExp(r'^\s*-\s*\d+(?:\.\d+)?\s*'), '').trim();

    String? unitCode;
    String displayName = remainder;

    if (quantity != null && remainder.isNotEmpty) {
      final words = remainder.split(RegExp(r'\s+'));
      if (words.isNotEmpty) {
        final firstWord = words.first.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
        if (_unitMap.containsKey(firstWord)) {
          unitCode = _unitMap[firstWord];
          displayName = words.sublist(1).join(' ').trim();
        } else if (words.length > 1) {
          final twoWords = '${words[0].toLowerCase()} ${words[1].toLowerCase()}'.replaceAll(RegExp(r'[^\w\s]'), '');
          if (_unitMap.containsKey(twoWords)) {
            unitCode = _unitMap[twoWords];
            displayName = words.sublist(2).join(' ').trim();
          }
        }
      }
    }

    unitCode ??= (quantity != null ? 'each' : null);

    return RecipeIngredient(
      id: _nextId(),
      recipeId: recipeId,
      displayName: displayName.isNotEmpty ? displayName : cleaned,
      quantity: isToTaste ? null : quantity,
      unitCode: unitCode,
      authoredQuantity: authoredQty,
      scalingPolicy: isToTaste ? ScalingPolicy.toTaste : ScalingPolicy.scale,
      prepText: prepText,
      position: position,
    );
  }

  /// Parses a raw instruction step string into a structured RecipeStep
  RecipeStep normalizeStep(String rawStep, {required String recipeId, int position = 1}) {
    final cleaned = rawStep.trim().replaceAll(RegExp(r'^(?:[•\-\*]|\d+[\.\)])\s*'), '').trim();
    final lower = cleaned.toLowerCase();

    // 1. Detect Action Key without relying on ASCII-only \b for accented characters
    String? actionKey;
    for (final act in _actionKeywords) {
      final actLower = act.toLowerCase();
      final idx = lower.indexOf(actLower);
      if (idx != -1) {
        final before = idx > 0 ? lower[idx - 1] : ' ';
        final after = (idx + actLower.length < lower.length) ? lower[idx + actLower.length] : ' ';
        if (RegExp(r'[\s,\.;:!\-]').hasMatch(before) && RegExp(r'[\s,\.;:!\-]').hasMatch(after)) {
          actionKey = act;
          break;
        }
      }
    }

    // 2. Extract Duration (e.g. "for 15 minutes", "bake 25 mins", "simmer 1 hour")
    int? durationSeconds;
    final minMatch = RegExp(r'(\d+)(?:\s*-\s*\d+)?\s*(?:minutes|minute|mins|min)\b', caseSensitive: false).firstMatch(cleaned);
    if (minMatch != null) {
      final mins = int.tryParse(minMatch.group(1)!);
      if (mins != null) durationSeconds = mins * 60;
    } else {
      final hrMatch = RegExp(r'(\d+)\s*(?:hours|hour|hrs|hr)\b', caseSensitive: false).firstMatch(cleaned);
      if (hrMatch != null) {
        final hrs = int.tryParse(hrMatch.group(1)!);
        if (hrs != null) durationSeconds = hrs * 3600;
      } else {
        final secMatch = RegExp(r'(\d+)\s*(?:seconds|second|secs|sec)\b', caseSensitive: false).firstMatch(cleaned);
        if (secMatch != null) {
          durationSeconds = int.tryParse(secMatch.group(1)!);
        }
      }
    }

    // 3. Extract Temperature (e.g. "375°F", "400 degrees F", "200°C")
    int? tempF;
    int? tempC;
    final fMatch = RegExp(r'(\d{2,3})\s*(?:°\s*F|degrees\s*F|F\b)', caseSensitive: false).firstMatch(cleaned);
    if (fMatch != null) {
      tempF = int.tryParse(fMatch.group(1)!);
      if (tempF != null) tempC = ((tempF - 32) * 5 / 9).round();
    }
    final cMatch = RegExp(r'(\d{2,3})\s*(?:°\s*C|degrees\s*C|C\b)', caseSensitive: false).firstMatch(cleaned);
    if (cMatch != null) {
      tempC = int.tryParse(cMatch.group(1)!);
      if (tempC != null) tempF = (tempC * 9 / 5 + 32).round();
    }

    final stepId = _nextId();
    final timers = <StepTimer>[];
    if (durationSeconds != null && durationSeconds > 0) {
      timers.add(StepTimer(
        id: _nextId(),
        recipeStepId: stepId,
        label: actionKey != null ? '${actionKey.toUpperCase()} Step $position' : 'Step $position',
        durationSeconds: durationSeconds,
        position: 1,
      ));
    }

    return RecipeStep(
      id: stepId,
      recipeId: recipeId,
      position: position,
      instructionShort: cleaned,
      actionKey: actionKey,
      durationSeconds: durationSeconds,
      temperatureC: tempC,
      temperatureF: tempF,
      timers: timers,
    );
  }
}
