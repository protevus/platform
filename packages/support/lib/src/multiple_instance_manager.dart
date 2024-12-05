import 'package:platform_contracts/contracts.dart';

/// A class for managing multiple instances of a type.
///
/// This class provides functionality to store, retrieve, and manage multiple
/// instances of a given type. It's particularly useful when you need to maintain
/// different instances of the same class with different configurations.
class MultipleInstanceManager<T> {
  /// The instances stored in the manager.
  final Map<String, T> _instances = {};

  /// The default instance name.
  static const String defaultName = 'default';

  /// The factory function for creating new instances.
  final T Function(Map<String, dynamic> config) _factory;

  /// The configuration for each instance.
  final Map<String, Map<String, dynamic>> _configurations = {};

  /// Create a new multiple instance manager.
  MultipleInstanceManager(this._factory);

  /// Get an instance by name.
  ///
  /// If the instance doesn't exist and a configuration is provided,
  /// it will be created using the factory function.
  T instance([String name = defaultName]) {
    if (!_instances.containsKey(name)) {
      if (!_configurations.containsKey(name)) {
        throw Exception('Instance [$name] is not configured.');
      }

      _instances[name] = _factory(_configurations[name]!);
    }

    return _instances[name]!;
  }

  /// Configure an instance with the given options.
  ///
  /// If [name] is not provided, configures the default instance.
  void configure(Map<String, dynamic> config, [String name = defaultName]) {
    _configurations[name] = config;
  }

  /// Extend the configuration for an instance.
  ///
  /// This merges the new configuration with any existing configuration.
  void extend(Map<String, dynamic> config, [String name = defaultName]) {
    if (!_configurations.containsKey(name)) {
      _configurations[name] = {};
    }

    _configurations[name]!.addAll(config);
  }

  /// Get all configured instance names.
  List<String> names() => _configurations.keys.toList();

  /// Get all instances that have been created.
  List<T> instances() => _instances.values.toList();

  /// Get all configurations.
  Map<String, Map<String, dynamic>> configurations() =>
      Map.from(_configurations);

  /// Reset an instance, removing it from the manager.
  ///
  /// The configuration is preserved unless [preserveConfig] is false.
  void reset(String name, {bool preserveConfig = true}) {
    _instances.remove(name);
    if (!preserveConfig) {
      _configurations.remove(name);
    }
  }

  /// Reset all instances, removing them from the manager.
  ///
  /// The configurations are preserved unless [preserveConfig] is false.
  void resetAll({bool preserveConfig = true}) {
    _instances.clear();
    if (!preserveConfig) {
      _configurations.clear();
    }
  }

  /// Check if an instance exists.
  bool has(String name) => _instances.containsKey(name);

  /// Check if a configuration exists.
  bool hasConfiguration(String name) => _configurations.containsKey(name);

  /// Get the configuration for an instance.
  Map<String, dynamic>? getConfiguration(String name) => _configurations[name];

  /// Set an instance directly.
  ///
  /// This can be used to manually set an instance instead of using the factory.
  void set(String name, T instance) {
    _instances[name] = instance;
  }

  /// Remove an instance and its configuration.
  void forget(String name) {
    _instances.remove(name);
    _configurations.remove(name);
  }

  /// Get the number of configured instances.
  int get count => _configurations.length;

  /// Get the number of created instances.
  int get instanceCount => _instances.length;
}
