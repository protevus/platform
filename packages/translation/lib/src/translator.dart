import 'package:meta/meta.dart';
import 'contracts/loader.dart';
import 'message_selector.dart';

/// Main translator class that handles retrieving translations.
class Translator {
  /// The loader implementation.
  final Loader _loader;

  /// The default locale being used.
  String _locale;

  /// The fallback locale used when translations are missing.
  String? _fallback;

  /// The loaded translation groups.
  final Map<String, Map<String, Map<String, dynamic>>> _loaded = {};

  /// The message selector instance.
  MessageSelector? _selector;

  /// Create a new translator instance.
  ///
  /// [loader] The loader to use for loading translations
  /// [locale] The default locale to use
  Translator(this._loader, String locale) : _locale = locale;

  /// Get the translation for the given key.
  ///
  /// [key] The translation key to look up
  /// [replace] Parameters to replace in the translation string
  /// [locale] Optional locale to use instead of the default
  /// [fallback] Whether to attempt fallback locales if translation is missing
  String translate(
    String key, {
    Map<String, dynamic> replace = const {},
    String? locale,
    bool fallback = true,
  }) {
    locale ??= _locale;

    final locales = fallback ? _getLocaleArray(locale) : [locale];
    String? line;

    // Try each locale until we find a translation
    for (final currentLocale in locales) {
      // Try JSON translations first
      _load('*', '*', currentLocale);
      line = _loaded['*']?['*']?[currentLocale]?[key] as String?;

      // If not found in JSON, try file-based translations
      if (line == null) {
        final parts = _parseKey(key);
        final namespace = parts[0];
        final group = parts[1];
        final item = parts[2];

        _load(namespace, group, currentLocale);
        final translation = _loaded[namespace]?[group]?[currentLocale]?[item];
        if (translation != null) {
          line = translation is String
              ? translation
              : translation is Map
                  ? translation.toString()
                  : null;
        }
      }

      if (line != null) break;
    }

    // If no translation found, return the key itself
    return _makeReplacements(line ?? key, replace);
  }

  /// Get a translation according to an integer value.
  ///
  /// [key] The translation key containing plural forms
  /// [number] The number to determine which plural form to use
  /// [replace] Parameters to replace in the translation string
  /// [locale] Optional locale to use instead of the default
  String choice(
    String key,
    num number, {
    Map<String, dynamic> replace = const {},
    String? locale,
  }) {
    locale ??= _locale;

    final line = translate(key, replace: const {}, locale: locale);

    replace = Map<String, dynamic>.from(replace)..['count'] = number;

    return _makeReplacements(
      _getSelector().choose(line, number, locale),
      replace,
    );
  }

  /// Load the specified language group.
  @protected
  void _load(String namespace, String group, String locale) {
    if (_isLoaded(namespace, group, locale)) return;

    // Initialize the structure if needed
    _loaded[namespace] ??= {};
    _loaded[namespace]![group] ??= {};

    // Load and store the translations
    _loaded[namespace]![group]![locale] =
        _loader.load(locale, group, namespace);
  }

  /// Check if a group has been loaded.
  bool _isLoaded(String namespace, String group, String locale) {
    return _loaded[namespace]?[group]?[locale] != null;
  }

  /// Make the place-holder replacements on a line.
  String _makeReplacements(String line, Map<String, dynamic> replace) {
    if (replace.isEmpty) return line;

    final replacements = <String, String>{};

    replace.forEach((key, value) {
      final stringValue = value?.toString() ?? '';
      // Support Laravel-style :key replacements
      replacements[':$key'] = stringValue;
      // Also support capitalized versions
      replacements[':${key[0].toUpperCase()}${key.substring(1)}'] =
          stringValue[0].toUpperCase() + stringValue.substring(1);
      replacements[':${key.toUpperCase()}'] = stringValue.toUpperCase();
    });

    return line.replaceAllMapped(
      RegExp(replacements.keys.map((key) => RegExp.escape(key)).join('|')),
      (match) => replacements[match[0]]!,
    );
  }

  /// Parse a key into namespace, group, and item.
  List<String> _parseKey(String key) {
    List<String> parts = key.contains('::') ? key.split('::') : ['*', key];

    parts = parts.length > 1
        ? [parts[0], ...parts[1].split('.')]
        : ['*', ...parts[0].split('.')];

    if (parts.length == 2) parts.add('');

    return parts;
  }

  /// Get the array of locales to try.
  List<String> _getLocaleArray(String locale) {
    final locales = [locale];
    if (_fallback != null && _fallback != locale) {
      locales.add(_fallback!);
    }
    return locales;
  }

  /// Get the message selector instance.
  MessageSelector _getSelector() {
    return _selector ??= MessageSelector();
  }

  /// Set the message selector instance.
  set selector(MessageSelector selector) {
    _selector = selector;
  }

  /// Get the default locale being used.
  String get locale => _locale;

  /// Set the default locale.
  set locale(String locale) {
    if (locale.contains(RegExp(r'[/\\]'))) {
      throw ArgumentError('Invalid characters present in locale.');
    }
    _locale = locale;
  }

  /// Get the fallback locale being used.
  String? get fallback => _fallback;

  /// Set the fallback locale.
  set fallback(String? fallback) {
    _fallback = fallback;
  }

  /// Add translation lines to the given locale.
  void addLines(Map<String, String> lines, String locale,
      [String namespace = '*']) {
    for (final entry in lines.entries) {
      final parts = entry.key.split('.');
      final group = parts[0];
      final item = parts.sublist(1).join('.');

      // Initialize structure if needed
      _loaded[namespace] ??= {};
      _loaded[namespace]![group] ??= {};
      _loaded[namespace]![group]![locale] ??= {};

      _loaded[namespace]![group]![locale]![item] = entry.value;
    }
  }

  /// Add a new namespace to the loader.
  void addNamespace(String namespace, String hint) {
    _loader.addNamespace(namespace, hint);
  }

  /// Add a new JSON path to the loader.
  void addJsonPath(String path) {
    _loader.addJsonPath(path);
  }
}
