/// Interface for configuration repository.
///
/// This contract defines the standard way to interact with configuration values
/// in the application. It provides methods to get, set, and manipulate
/// configuration values in a consistent manner.
abstract class Repository {
  /// Determine if the given configuration value exists.
  ///
  /// Example:
  /// ```dart
  /// if (config.has('database.default')) {
  ///   // Use the database configuration
  /// }
  /// ```
  bool has(String key);

  /// Get the specified configuration value.
  ///
  /// Returns [defaultValue] if the key doesn't exist.
  ///
  /// Example:
  /// ```dart
  /// var dbHost = config.get('database.connections.mysql.host', 'localhost');
  /// ```
  T? get<T>(String key, [T? defaultValue]);

  /// Get all of the configuration items.
  ///
  /// Example:
  /// ```dart
  /// var allConfig = config.all();
  /// print('Database host: ${allConfig['database']['connections']['mysql']['host']}');
  /// ```
  Map<String, dynamic> all();

  /// Set a given configuration value.
  ///
  /// Example:
  /// ```dart
  /// config.set('app.timezone', 'UTC');
  /// config.set('services.aws', {
  ///   'key': 'your-key',
  ///   'secret': 'your-secret',
  ///   'region': 'us-east-1',
  /// });
  /// ```
  void set(String key, dynamic value);

  /// Prepend a value onto an array configuration value.
  ///
  /// Example:
  /// ```dart
  /// config.prepend('app.providers', MyServiceProvider);
  /// ```
  void prepend(String key, dynamic value);

  /// Push a value onto an array configuration value.
  ///
  /// Example:
  /// ```dart
  /// config.push('app.providers', MyServiceProvider);
  /// ```
  void push(String key, dynamic value);
}
