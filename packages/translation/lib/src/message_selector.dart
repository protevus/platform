/// Selects the appropriate translation message based on a number.
class MessageSelector {
  // Languages with only one form
  static const _oneFormLanguages = {
    'az',
    'bm',
    'fa',
    'ig',
    'hu',
    'ja',
    'ko',
    'my',
    'root',
    'sah',
    'ses',
    'sg',
    'th',
    'vi',
    'wo',
    'yo',
    'zh'
  };

  // Languages with two forms - singular and plural (English-like)
  static const _twoFormLanguages = {
    'af',
    'an',
    'ast',
    'bg',
    'bn',
    'ca',
    'da',
    'de',
    'el',
    'en',
    'eo',
    'es',
    'et',
    'eu',
    'fi',
    'fo',
    'fur',
    'fy',
    'gl',
    'gu',
    'ha',
    'he',
    'hi',
    'hu',
    'is',
    'it',
    'ku',
    'lb',
    'ml',
    'mn',
    'mr',
    'nah',
    'nb',
    'ne',
    'nl',
    'nn',
    'no',
    'om',
    'or',
    'pa',
    'pap',
    'ps',
    'pt',
    'so',
    'sq',
    'sv',
    'sw',
    'ta',
    'te',
    'tk',
    'ur',
    'zu'
  };

  /// Select a proper translation string based on the given number.
  ///
  /// [line] The translation line containing plural forms
  /// [number] The number to determine plural form
  /// [locale] The locale to use for pluralization rules
  String choose(String line, num number, String locale) {
    final segments = line.split('|');

    // Get locale info and normalize
    final String normalizedLocale = locale.replaceAll('-', '_').toLowerCase();
    final String baseLocale = normalizedLocale.split('_')[0];

    // Handle single form
    if (segments.length == 1) {
      return segments[0].trim();
    }

    // Try to match explicit number/range conditions first
    String? lastNoCondition;
    String? firstMatch;
    String? firstExactValue;
    bool hasInvalidCondition = false;

    for (final part in segments) {
      if (!_hasCondition(part)) {
        lastNoCondition = part;
      } else {
        final match = _extractFromString(part, number);
        if (match != null) {
          if (!part.contains(',')) {
            // Exact number match
            return match;
          } else if (firstMatch == null) {
            // Range match
            firstMatch = match;
          }
        } else if (!part.contains(',')) {
          // Store first exact match value for fallback
          if (firstExactValue == null) {
            final value = _extractFromString(part, 1);
            if (value != null) {
              firstExactValue = value;
            }
          }
          hasInvalidCondition = true;
        }
      }
    }

    // For invalid conditions, return last segment without conditions
    if (hasInvalidCondition && lastNoCondition != null) {
      return lastNoCondition.trim();
    }

    // Return range match if found
    if (firstMatch != null) {
      return firstMatch;
    }

    // For explicit conditions with no match, return first exact match value
    if (firstExactValue != null) {
      return firstExactValue;
    }

    // Handle basic two-form pluralization for English-like languages
    if (segments.length == 2 && _twoFormLanguages.contains(baseLocale)) {
      if (!_hasCondition(segments[0]) && !_hasCondition(segments[1])) {
        return segments[number == 1 ? 0 : 1].trim();
      }
    }

    // Handle special cases for Russian and Arabic
    if (baseLocale == 'ru' || baseLocale == 'uk') {
      final mod10 = number % 10;
      final mod100 = number % 100;
      if (mod10 == 1 && mod100 != 11) {
        return _stripConditions([segments[0]])[0].trim();
      } else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
        return segments.length > 1
            ? _stripConditions([segments[1]])[0].trim()
            : _stripConditions([segments[0]])[0].trim();
      } else {
        return segments.length > 2
            ? _stripConditions([segments[2]])[0].trim()
            : _stripConditions([segments[0]])[0].trim();
      }
    } else if (baseLocale == 'ar') {
      if (segments.length >= 6) {
        if (number == 0) return _stripConditions([segments[0]])[0].trim();
        if (number == 1) return _stripConditions([segments[1]])[0].trim();
        if (number == 2) return _stripConditions([segments[2]])[0].trim();
        if (number % 100 >= 3 && number % 100 <= 10)
          return _stripConditions([segments[3]])[0].trim();
        if (number % 100 >= 11 && number % 100 <= 99)
          return _stripConditions([segments[4]])[0].trim();
        return _stripConditions([segments[5]])[0].trim();
      }
    }

    // Handle locale-specific pluralization
    final pluralIndex = _getPluralIndex(baseLocale, number);
    if (pluralIndex < segments.length) {
      return _stripConditions([segments[pluralIndex]])[0].trim();
    }

    // For invalid conditions, return last segment without conditions
    if (lastNoCondition != null) {
      return lastNoCondition.trim();
    }

    // Fallback to first form
    return _stripConditions([segments[0]])[0].trim();
  }

  /// Get the translation string if the condition matches.
  String? _extractFromString(String part, num number) {
    final match =
        RegExp(r'^\s*[\{\[]([^\[\]\{\}]*)[\}\]](.*)').firstMatch(part);

    if (match == null || match.groupCount != 2) {
      return null;
    }

    final condition = match.group(1)!.trim();
    final value = match.group(2)!;

    if (condition.contains(',')) {
      final parts = condition.split(',').map((p) => p.trim()).toList();
      final from = parts[0];
      final to = parts[1];

      try {
        if (to == '*' && number >= num.parse(from)) {
          return value;
        } else if (from == '*' && number <= num.parse(to)) {
          return value;
        } else if (number >= num.parse(from) && number <= num.parse(to)) {
          return value;
        }
      } catch (_) {
        return null;
      }
    }

    try {
      if (num.parse(condition) == number) {
        return value;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Strip the inline conditions from each segment.
  List<String> _stripConditions(List<String> segments) {
    return segments.map((part) {
      if (!_hasCondition(part)) {
        return part;
      }
      return part.replaceFirst(RegExp(r'^\s*[\{\[]([^\[\]\{\}]*)[\}\]]'), '');
    }).toList();
  }

  /// Check if a segment has a condition prefix.
  bool _hasCondition(String part) {
    return RegExp(r'^\s*[\{\[]([^\[\]\{\}]*)[\}\]]').hasMatch(part);
  }

  /// Get the index to use for pluralization.
  ///
  /// The plural rules are derived from the Unicode CLDR pluralization rules:
  /// https://unicode-org.github.io/cldr-staging/charts/latest/supplemental/language_plural_rules.html
  int _getPluralIndex(String baseLocale, num number) {
    if (_oneFormLanguages.contains(baseLocale)) {
      return 0;
    }

    if (_twoFormLanguages.contains(baseLocale)) {
      return number == 1 ? 0 : 1;
    }

    // Special cases for different plural rules
    switch (baseLocale) {
      case 'ar':
        if (number == 0) return 0;
        if (number == 1) return 1;
        if (number == 2) return 2;
        if (number % 100 >= 3 && number % 100 <= 10) return 3;
        if (number % 100 >= 11 && number % 100 <= 99) return 4;
        return 5;

      case 'ru':
      case 'uk':
        final mod10 = number % 10;
        final mod100 = number % 100;
        if (mod10 == 1 && mod100 != 11) return 0;
        if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 1;
        return 2;

      case 'cs':
      case 'sk':
        if (number == 1) return 0;
        if (number >= 2 && number <= 4) return 1;
        return 2;

      case 'pl':
        if (number == 1) return 0;
        if (number % 10 >= 2 &&
            number % 10 <= 4 &&
            (number % 100 < 12 || number % 100 > 14)) return 1;
        return 2;

      case 'lt':
        if (number % 10 == 1 && number % 100 != 11) return 0;
        if (number % 10 >= 2 && (number % 100 < 10 || number % 100 >= 20))
          return 1;
        return 2;

      case 'sl':
        if (number % 100 == 1) return 0;
        if (number % 100 == 2) return 1;
        if (number % 100 == 3 || number % 100 == 4) return 2;
        return 3;

      default:
        return 0;
    }
  }
}
