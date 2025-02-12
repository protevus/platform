import 'dart:convert';

/// Manages translations for notification content.
class TranslationManager {
  /// The loaded translations.
  final Map<String, Map<String, String>> _translations = {};

  /// The fallback locale to use when a translation is missing.
  final String _fallbackLocale;

  /// Creates a new translation manager.
  ///
  /// [fallbackLocale] The locale to use when a translation is missing
  TranslationManager({String fallbackLocale = 'en'})
      : _fallbackLocale = fallbackLocale;

  /// Load translations from a JSON string.
  ///
  /// The JSON should be structured as:
  /// {
  ///   "en": {
  ///     "welcome": "Welcome, {{name}}!",
  ///     "goodbye": "Goodbye!"
  ///   },
  ///   "es": {
  ///     "welcome": "¡Bienvenido, {{name}}!",
  ///     "goodbye": "¡Adiós!"
  ///   }
  /// }
  void loadFromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    for (final entry in data.entries) {
      if (entry.value is Map) {
        _translations[entry.key] = Map<String, String>.from(entry.value as Map);
      }
    }
  }

  /// Get a translation for a key in the specified locale.
  ///
  /// If the translation is not found in the specified locale,
  /// falls back to the fallback locale.
  ///
  /// [key] The translation key
  /// [locale] The locale to get the translation for
  /// [fallback] Optional fallback string if no translation is found
  String get(String key, String locale, [String? fallback]) {
    // Try requested locale
    if (_translations.containsKey(locale)) {
      final localeTranslations = _translations[locale]!;
      if (localeTranslations.containsKey(key)) {
        return localeTranslations[key]!;
      }
    }

    // Try fallback locale
    if (_translations.containsKey(_fallbackLocale)) {
      final fallbackTranslations = _translations[_fallbackLocale]!;
      if (fallbackTranslations.containsKey(key)) {
        return fallbackTranslations[key]!;
      }
    }

    // Return fallback string or key
    return fallback ?? key;
  }

  /// Add translations for a locale.
  ///
  /// [locale] The locale code (e.g., 'en', 'es')
  /// [translations] Map of translation keys to translated strings
  void add(String locale, Map<String, String> translations) {
    _translations[locale] = translations;
  }

  /// Remove translations for a locale.
  ///
  /// [locale] The locale code to remove
  void remove(String locale) {
    _translations.remove(locale);
  }

  /// Clear all translations.
  void clear() {
    _translations.clear();
  }

  /// Get all available locales.
  Set<String> get locales => _translations.keys.toSet();

  /// Check if translations exist for a locale.
  ///
  /// [locale] The locale code to check
  bool hasLocale(String locale) => _translations.containsKey(locale);
}
