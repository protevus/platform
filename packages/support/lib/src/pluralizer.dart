/// A class that provides word pluralization functionality.
///
/// This class handles pluralization of English words, including regular rules,
/// irregular cases, and uncountable words.
class Pluralizer {
  /// Regular expression for matching word inflection.
  static final RegExp _regex = RegExp(r'^(.*?)(s|ss|sh|ch|x|z|o|is|us|um|a)$');

  /// Regular expression for matching sibilant sounds.
  static final RegExp _sibilantRegex = RegExp(r'(s|ss|sh|ch|x|z)$');

  /// Regular expression for matching words ending in 'y'.
  static final RegExp _yRegex = RegExp(r'^(.*?)([^aeiou])y$');

  /// Words that are uncountable and don't have plural forms.
  static final Set<String> _uncountable = {
    'equipment',
    'information',
    'rice',
    'money',
    'species',
    'series',
    'fish',
    'sheep',
    'deer',
    'aircraft',
    'offspring',
    'news',
  };

  /// Irregular word forms that don't follow standard rules.
  static final Map<String, String> _irregular = {
    'person': 'people',
    'man': 'men',
    'child': 'children',
    'sex': 'sexes',
    'move': 'moves',
    'foot': 'feet',
    'tooth': 'teeth',
    'goose': 'geese',
    'criterion': 'criteria',
    'radius': 'radii',
    'phenomenon': 'phenomena',
    'index': 'indices',
    'vertex': 'vertices',
    'matrix': 'matrices',
    'quiz': 'quizzes',
    'analysis': 'analyses',
    'thesis': 'theses',
    'datum': 'data',
    'bacterium': 'bacteria',
    'syllabus': 'syllabi',
    'focus': 'foci',
    'fungus': 'fungi',
    'cactus': 'cacti',
    'hypothesis': 'hypotheses',
    'crisis': 'crises',
    'basis': 'bases',
    'diagnosis': 'diagnoses',
    'ellipsis': 'ellipses',
    'oasis': 'oases',
    'parenthesis': 'parentheses',
    'synopsis': 'synopses',
    'thesis': 'theses',
  };

  /// Custom pluralization rules.
  static final Map<String, String> _rules = {};

  /// Add a custom pluralization rule.
  static void addRule(String singular, String plural) {
    _rules[singular.toLowerCase()] = plural.toLowerCase();
  }

  /// Add an irregular word form.
  static void addIrregular(String singular, String plural) {
    _irregular[singular.toLowerCase()] = plural.toLowerCase();
  }

  /// Add an uncountable word.
  static void addUncountable(String word) {
    _uncountable.add(word.toLowerCase());
  }

  /// Get the plural form of a word.
  static String plural(String word, [int count = 2]) {
    if (count == 1) {
      return word;
    }

    final lower = word.toLowerCase();

    // Check uncountable
    if (_uncountable.contains(lower)) {
      return word;
    }

    // Check custom rules
    if (_rules.containsKey(lower)) {
      return _matchCase(_rules[lower]!, word);
    }

    // Check irregular forms
    if (_irregular.containsKey(lower)) {
      return _matchCase(_irregular[lower]!, word);
    }

    // Check for words ending in 'y'
    final yMatch = _yRegex.firstMatch(lower);
    if (yMatch != null) {
      return _matchCase('${yMatch.group(1)}${yMatch.group(2)}ies', word);
    }

    // Apply regular rules
    final match = _regex.firstMatch(lower);
    if (match != null) {
      final base = match.group(1)!;
      final suffix = match.group(2)!;

      String plural;
      switch (suffix) {
        case 'is':
          plural = '${base}es';
          break;
        case 'us':
          if (lower.endsWith('bus')) {
            plural = '${base}${suffix}es';
          } else {
            plural = '${base}i';
          }
          break;
        case 'um':
        case 'a':
          plural = '${base}a';
          break;
        case 'o':
          plural = '${base}oes';
          break;
        case 'ss':
        case 'sh':
        case 'ch':
        case 'x':
        case 'z':
          plural = '${word}es';
          break;
        case 's':
          plural = '${base}ses';
          break;
        default:
          plural = '${word}s';
      }
      return _matchCase(plural, word);
    }

    // Default to adding 's'
    return _matchCase('${word}s', word);
  }

  /// Get the singular form of a word.
  static String singular(String word) {
    final lower = word.toLowerCase();

    // Check uncountable
    if (_uncountable.contains(lower)) {
      return word;
    }

    // Check custom rules
    for (final entry in _rules.entries) {
      if (entry.value == lower) {
        return _matchCase(entry.key, word);
      }
    }

    // Check irregular forms
    for (final entry in _irregular.entries) {
      if (entry.value == lower) {
        return _matchCase(entry.key, word);
      }
    }

    // Apply regular rules
    if (lower.endsWith('ies') && !lower.endsWith('series')) {
      return _matchCase('${word.substring(0, word.length - 3)}y', word);
    }

    if (lower.endsWith('es')) {
      if (lower.endsWith('ses') && !lower.endsWith('bases')) {
        return _matchCase(word.substring(0, word.length - 2), word);
      }
      if (lower.endsWith('oes')) {
        return _matchCase(word.substring(0, word.length - 2), word);
      }
      if (lower.endsWith('uses')) {
        return _matchCase(word.substring(0, word.length - 2), word);
      }
      if (_sibilantRegex.hasMatch(lower.substring(0, lower.length - 2))) {
        return _matchCase(word.substring(0, word.length - 2), word);
      }
      return _matchCase(word.substring(0, word.length - 2), word);
    }

    if (lower.endsWith('a')) {
      if (lower.endsWith('phenomena')) {
        return _matchCase('phenomenon', word);
      }
      if (lower.endsWith('criteria')) {
        return _matchCase('criterion', word);
      }
      if (lower.endsWith('bacteria')) {
        return _matchCase('bacterium', word);
      }
      return _matchCase('${word.substring(0, word.length - 1)}um', word);
    }

    if (lower.endsWith('i')) {
      if (lower.endsWith('radii')) {
        return _matchCase('radius', word);
      }
      if (lower.endsWith('fungi')) {
        return _matchCase('fungus', word);
      }
      if (lower.endsWith('cacti')) {
        return _matchCase('cactus', word);
      }
      if (lower.endsWith('syllabi')) {
        return _matchCase('syllabus', word);
      }
      return _matchCase('${word.substring(0, word.length - 1)}us', word);
    }

    if (lower.endsWith('s')) {
      return _matchCase(word.substring(0, word.length - 1), word);
    }

    return word;
  }

  /// Check if a word is plural.
  static bool isPlural(String word) {
    final lower = word.toLowerCase();
    if (_uncountable.contains(lower)) return false;

    // Check irregular plurals
    for (final entry in _irregular.entries) {
      if (entry.value == lower) return true;
    }

    // Check custom rules
    for (final entry in _rules.entries) {
      if (entry.value == lower) return true;
    }

    // Check common plural endings
    if (lower.endsWith('s') && !lower.endsWith('ss')) return true;
    if (lower.endsWith('es')) return true;
    if (lower.endsWith('ies')) return true;
    if (lower.endsWith('i')) return true;
    if (lower.endsWith('a') && !lower.endsWith('ia')) return true;

    return false;
  }

  /// Check if a word is singular.
  static bool isSingular(String word) {
    final lower = word.toLowerCase();
    if (_uncountable.contains(lower)) return true;

    // Check irregular singulars
    if (_irregular.containsKey(lower)) return true;

    // Check custom rules
    if (_rules.containsKey(lower)) return true;

    // If it's plural, it's not singular
    if (isPlural(word)) return false;

    return true;
  }

  /// Match the case of the target word.
  static String _matchCase(String word, String target) {
    if (target.toUpperCase() == target) {
      return word.toUpperCase();
    }
    if (target[0].toUpperCase() == target[0]) {
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }
    return word.toLowerCase();
  }
}
