import 'package:illuminate_container/container.dart';
import 'package:illuminate_support/src/fluent.dart';

/// Base class for managing drivers with different implementations.
///
/// This class provides a foundation for managing different implementations of a service,
/// similar to Laravel's Manager class. It handles driver creation, caching, and custom
/// driver registration.
abstract class Manager {
  /// The container instance.
  final Container container;

  /// The configuration repository instance.
  final Fluent config;

  /// The registered custom driver creators.
  final Map<String, dynamic Function(Container)> _customCreators = {};

  /// The array of created "drivers".
  final Map<String, dynamic> _drivers = {};

  /// Create a new manager instance.
  ///
  /// Parameters:
  ///   - [container]: The container instance to use for resolving dependencies
  Manager(this.container) : config = container.make<Fluent>();

  /// Get the default driver name.
  ///
  /// This method must be implemented by concrete managers to specify which
  /// driver should be used by default. Returns null if no default driver is set.
  String? getDefaultDriver();

  /// Get a driver instance.
  ///
  /// This method returns an instance of the requested driver. If the driver
  /// has already been created, it returns the cached instance. Otherwise,
  /// it creates a new instance.
  ///
  /// Parameters:
  ///   - [driver]: The name of the driver to get. If null, uses default driver.
  ///
  /// Returns:
  ///   The driver instance.
  ///
  /// Throws:
  ///   - [ArgumentError] if no driver name is provided and no default exists
  T driver<T>([String? driver]) {
    driver ??= getDefaultDriver();

    if (driver == null) {
      throw ArgumentError(
          'Unable to resolve NULL driver for [${runtimeType}].');
    }

    return _drivers.putIfAbsent(driver, () => createDriver(driver!)) as T;
  }

  /// Create a new driver instance.
  ///
  /// This method creates a new instance of the requested driver. It first checks
  /// for custom creators, then looks for a create{Driver}Driver method.
  ///
  /// Parameters:
  ///   - [driver]: The name of the driver to create
  ///
  /// Returns:
  ///   The new driver instance
  ///
  /// Throws:
  ///   - [ArgumentError] if the driver is not supported
  dynamic createDriver(String driver) {
    // Check for custom creator
    if (_customCreators.containsKey(driver)) {
      return _customCreators[driver]!(container);
    }

    // Look for create{Driver}Driver method
    var methodName =
        'create${driver[0].toUpperCase()}${driver.substring(1)}Driver';
    var result = callDriverCreator(methodName);
    if (result != null) {
      return result;
    }

    throw ArgumentError('Driver [$driver] not supported.');
  }

  /// Call a driver creator method.
  ///
  /// This method must be implemented by concrete managers to handle calling
  /// the appropriate creator method based on the method name.
  ///
  /// Parameters:
  ///   - [method]: The name of the creator method to call
  ///
  /// Returns:
  ///   The created driver instance, or null if the method doesn't exist
  dynamic callDriverCreator(String method);

  /// Register a custom driver creator.
  ///
  /// This method allows registering custom driver creators that will be used
  /// instead of the default creation logic.
  ///
  /// Parameters:
  ///   - [driver]: The name of the driver
  ///   - [creator]: The function that creates the driver
  ///
  /// Returns:
  ///   This manager instance for method chaining
  Manager extend(String driver, dynamic Function(Container) creator) {
    _customCreators[driver] = creator;
    return this;
  }

  /// Get all of the created drivers.
  ///
  /// Returns a map of all driver instances that have been created.
  Map<String, dynamic> getDrivers() => Map.unmodifiable(_drivers);

  /// Get the container instance used by the manager.
  Container getContainer() => container;

  /// Forget all of the resolved driver instances.
  ///
  /// This method clears the driver cache, forcing new instances to be created
  /// on next access.
  ///
  /// Returns:
  ///   This manager instance for method chaining
  Manager forgetDrivers() {
    _drivers.clear();
    return this;
  }
}
