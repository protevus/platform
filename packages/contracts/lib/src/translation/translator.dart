abstract class Translator {
  /// Get the translation for a given key.
  ///
  /// @param  String key
  /// @param  Map<String, dynamic> replace
  /// @param  String? locale
  /// @return dynamic
  dynamic get(String key, {Map<String, dynamic> replace = const {}, String? locale});

  /// Get a translation according to an integer value.
  ///
  /// @param  String key
  /// @param  dynamic number (Countable, int, double, or List)
  /// @param  Map<String, dynamic> replace
  /// @param  String? locale
  /// @return String
  String choice(String key, dynamic number, {Map<String, dynamic> replace = const {}, String? locale});

  /// Get the default locale being used.
  ///
  /// @return String
  String getLocale();

  /// Set the default locale.
  ///
  /// @param  String locale
  /// @return void
  void setLocale(String locale);
}
