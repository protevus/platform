/// Interface for translation services.
abstract class Translator {
  /// Get the translation for a given key.
  dynamic get(String key,
      [Map<String, dynamic> replace = const {}, String? locale]);

  /// Get a translation according to an integer value.
  String choice(String key, dynamic number,
      [Map<String, dynamic> replace = const {}, String? locale]);

  /// Get the default locale being used.
  String getLocale();

  /// Set the default locale.
  void setLocale(String locale);
}
