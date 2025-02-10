import 'dart:io' as io;

/// A class for interacting with environment variables.
class Env {
  /// The environment variables cache.
  static final Map<String, String?> _cache = {};

  /// Get the value of an environment variable.
  static String? get(String key, [String? defaultValue]) {
    if (_cache.containsKey(key)) {
      return _cache[key] ?? defaultValue;
    }

    String? value = io.Platform.environment[key];
    _cache[key] = value;

    return value ?? defaultValue;
  }

  /// Get the value of an environment variable as a bool.
  static bool getBool(String key, [bool defaultValue = false]) {
    final value = get(key);
    if (value == null) {
      return defaultValue;
    }

    return _isTruthy(value);
  }

  /// Get the value of an environment variable as an int.
  static int getInt(String key, [int defaultValue = 0]) {
    final value = get(key);
    if (value == null) {
      return defaultValue;
    }

    return int.tryParse(value) ?? defaultValue;
  }

  /// Get the value of an environment variable as a double.
  static double getDouble(String key, [double defaultValue = 0.0]) {
    final value = get(key);
    if (value == null) {
      return defaultValue;
    }

    return double.tryParse(value) ?? defaultValue;
  }

  /// Check if an environment variable exists.
  static bool has(String key) {
    return get(key) != null;
  }

  /// Set an environment variable.
  static void put(String key, String value) {
    _cache[key] = value;
  }

  /// Forget a cached environment variable.
  static void forget(String key) {
    _cache.remove(key);
  }

  /// Clear the environment variables cache.
  static void clear() {
    _cache.clear();
  }

  /// Determine if a value is "truthy".
  static bool _isTruthy(String value) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1' || lower == 'yes' || lower == 'on';
  }
}
