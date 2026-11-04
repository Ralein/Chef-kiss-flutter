import 'food_catalog.dart';

/// Resolves free-text ingredient names ("finely chopped yellow onions",
/// "Grated Parmigiano-Reggiano") to [FoodEntry] records.
///
/// Matching is phrase based. Every keyword phrase found in the normalized name
/// is scored by *(position of its last word, number of words)* and the highest
/// score wins. Preferring the right-most phrase follows English noun-phrase
/// structure, where the head noun comes last: "whole milk ricotta" resolves to
/// ricotta, "peanut butter" to peanut butter and "rice vinegar" to vinegar.
class FoodMatcher {
  final List<FoodEntry> catalog;
  late final List<_IndexedKeyword> _index = _buildIndex();

  FoodMatcher([List<FoodEntry>? catalog]) : catalog = catalog ?? foodCatalog;

  static final FoodMatcher standard = FoodMatcher();

  FoodEntry? match(String rawName) {
    final words = normalizeWords(rawName);
    if (words.isEmpty) return null;

    _IndexedKeyword? best;
    var bestEnd = -1;
    for (final kw in _index) {
      final end = _lastOccurrenceEnd(words, kw.words);
      if (end < 0) continue;
      if (best == null ||
          end > bestEnd ||
          (end == bestEnd && kw.words.length > best.words.length) ||
          (end == bestEnd && kw.words.length == best.words.length && kw.priority < best.priority)) {
        best = kw;
        bestEnd = end;
      }
    }
    return best?.entry;
  }

  List<_IndexedKeyword> _buildIndex() {
    final out = <_IndexedKeyword>[];
    for (var i = 0; i < catalog.length; i++) {
      final entry = catalog[i];
      for (final keyword in entry.keywords) {
        final words = normalizeWords(keyword);
        if (words.isNotEmpty) out.add(_IndexedKeyword(entry, words, i));
      }
    }
    return out;
  }

  /// Index of the last word of the right-most occurrence of [needle] in
  /// [haystack], or -1 when it does not occur as a contiguous phrase.
  static int _lastOccurrenceEnd(List<String> haystack, List<String> needle) {
    if (needle.length > haystack.length) return -1;
    for (var start = haystack.length - needle.length; start >= 0; start--) {
      var ok = true;
      for (var j = 0; j < needle.length; j++) {
        if (haystack[start + j] != needle[j]) {
          ok = false;
          break;
        }
      }
      if (ok) return start + needle.length - 1;
    }
    return -1;
  }

  static const Set<String> _noiseWords = {
    'of', 'a', 'an', 'the', 'to', 'taste', 'for', 'serving', 'garnish', 'optional', 'divided', 'plus', 'more',
    'about', 'approximately', 'approx', 'some', 'and', 'or', 'with', 'into', 'in',
  };

  static const Map<String, String> _diacritics = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ñ': 'n', 'ç': 'c', 'ý': 'y', 'ÿ': 'y', 'œ': 'oe', 'æ': 'ae', 'ß': 'ss',
  };

  /// Lower-cases, strips accents/punctuation/parentheticals, drops noise words
  /// and singularizes, producing the token list used for matching.
  static List<String> normalizeWords(String raw) {
    var s = raw.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in s.runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(_diacritics[ch] ?? ch);
    }
    s = buffer.toString()
        .replaceAll(RegExp(r'\([^)]*\)'), ' ')
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
    return s
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !_noiseWords.contains(w))
        .map(singularize)
        .toList(growable: false);
  }

  static const Set<String> _invariant = {
    'molasses', 'hummus', 'couscous', 'asparagus', 'swiss', 'brussels', 'grits', 'mascarpone', 'series',
    'species', 'glass', 'grass', 'bass', 'cress', 'watercress', 'citrus', 'haricots',
  };

  static const Map<String, String> _irregular = {
    'leaves': 'leaf',
    'halves': 'half',
    'loaves': 'loaf',
    'knives': 'knife',
    'cookies': 'cookie',
    'pies': 'pie',
    'chilies': 'chili',
    'chillies': 'chili',
    'chilli': 'chili',
    'chillis': 'chili',
    'greens': 'green',
  };

  static String singularize(String w) {
    final irregular = _irregular[w];
    if (irregular != null) return irregular;
    if (w.length <= 3 || _invariant.contains(w)) return w;
    if (w.endsWith('ies')) return '${w.substring(0, w.length - 3)}y';
    if (w.endsWith('oes')) return w.substring(0, w.length - 2);
    if (w.endsWith('ches') || w.endsWith('shes') || w.endsWith('sses') || w.endsWith('xes')) {
      return w.substring(0, w.length - 2);
    }
    if (w.endsWith('s') && !w.endsWith('ss') && !w.endsWith('us') && !w.endsWith('is')) {
      return w.substring(0, w.length - 1);
    }
    return w;
  }
}

class _IndexedKeyword {
  final FoodEntry entry;
  final List<String> words;
  final int priority;

  const _IndexedKeyword(this.entry, this.words, this.priority);
}
