/// Selects the appropriate translation message based on a number.
class MessageSelector {
  /// Select a proper translation string based on the given number.
  ///
  /// [line] The translation line containing plural forms
  /// [number] The number to determine plural form
  /// [locale] The locale to use for pluralization rules
  String choose(String line, num number, String locale) {
    final segments = line.split('|');

    // Try to match explicit number/range conditions first
    final value = _extract(segments, number);
    if (value != null) {
      return value;
    }

    // Fall back to positional plural forms
    final cleanSegments = _stripConditions(segments);
    final pluralIndex = _getPluralIndex(locale, number);

    if (cleanSegments.length == 1 || pluralIndex >= cleanSegments.length) {
      return _hasCondition(segments[0])
          ? cleanSegments[0]
          : cleanSegments[0].trim();
    }

    return _hasCondition(segments[pluralIndex])
        ? cleanSegments[pluralIndex]
        : cleanSegments[pluralIndex].trim();
  }

  /// Extract a translation string using inline conditions.
  String? _extract(List<String> segments, num number) {
    for (final part in segments) {
      final line = _extractFromString(part, number);
      if (line != null) {
        return line;
      }
    }
    return null;
  }

  /// Get the translation string if the condition matches.
  String? _extractFromString(String part, num number) {
    final match = RegExp(r'^[\{\[]([^\[\]\{\}]*)[\}\]](.*)').firstMatch(part);

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
      return num.parse(condition) == number ? value : null;
    } catch (_) {
      return null;
    }
  }

  /// Strip the inline conditions from each segment.
  List<String> _stripConditions(List<String> segments) {
    // If all conditions are invalid, return the last segment
    final validSegment = segments.lastWhere(
      (part) => !_hasCondition(part) || _extractFromString(part, 0) != null,
      orElse: () => segments.last,
    );

    return segments.map((part) {
      if (part == validSegment && !_hasCondition(part)) {
        return part.trim();
      }
      return part.replaceFirst(RegExp(r'^[\{\[]([^\[\]\{\}]*)[\}\]]'), '');
    }).toList();
  }

  /// Check if a segment has a condition prefix.
  bool _hasCondition(String part) {
    return RegExp(r'^[\{\[]([^\[\]\{\}]*)[\}\]]').hasMatch(part);
  }

  /// Get the index to use for pluralization.
  ///
  /// The plural rules are derived from the Unicode CLDR pluralization rules:
  /// https://unicode-org.github.io/cldr-staging/charts/latest/supplemental/language_plural_rules.html
  int _getPluralIndex(String locale, num number) {
    final String normalizedLocale = locale.replaceAll('-', '_').toLowerCase();
    final String baseLocale = normalizedLocale.split('_')[0];

    // Languages with only one form
    const oneFormLanguages = {
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

    if (oneFormLanguages.contains(baseLocale)) {
      return 0;
    }

    // Languages with two forms - singular and plural
    const twoFormLanguages = {
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

    if (twoFormLanguages.contains(baseLocale)) {
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

      case 'ru':
      case 'uk':
        if (number % 10 == 1 && number % 100 != 11) return 0;
        if (number % 10 >= 2 &&
            number % 10 <= 4 &&
            (number % 100 < 12 || number % 100 > 14)) return 1;
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
