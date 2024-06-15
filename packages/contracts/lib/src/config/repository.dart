abstract class Repository {
  /// Determine if the given configuration value exists.
  ///
  /// @param  String key
  /// @return bool
  bool has(String key);

  /// Get the specified configuration value.
  ///
  /// @param  String key
  /// @param  dynamic defaultValue
  /// @return dynamic
  dynamic get(String key, [dynamic defaultValue]);

  /// Get all of the configuration items for the application.
  ///
  /// @return Map<String, dynamic>
  Map<String, dynamic> all();

  /// Set a given configuration value.
  ///
  /// @param  String key
  /// @param  dynamic value
  /// @return void
  void set(String key, [dynamic value]);

  /// Prepend a value onto an array configuration value.
  ///
  /// @param  String key
  /// @param  dynamic value
  /// @return void
  void prepend(String key, dynamic value);

  /// Push a value onto an array configuration value.
  ///
  /// @param  String key
  /// @param  dynamic value
  /// @return void
  void push(String key, dynamic value);
}
