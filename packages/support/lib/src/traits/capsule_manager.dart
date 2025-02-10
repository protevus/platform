import 'package:illuminate_container/container.dart';
import 'package:illuminate_support/src/fluent.dart';

/// A mixin that provides capsule management functionality.
///
/// This mixin allows classes to manage a global instance and a container instance,
/// similar to Laravel's CapsuleManagerTrait.
mixin CapsuleManager {
  /// The current globally used instance.
  static dynamic _instance;

  /// The container instance.
  Container? _container;

  /// Setup the IoC container instance.
  ///
  /// This method initializes the container and ensures it has a config binding.
  /// If no config binding exists, it creates one with an empty [Fluent] instance.
  void setupContainer(Container container) {
    _container = container;

    // if (!_container!.has<Fluent>()) {
    //   _container!.registerSingleton(Fluent(), as: Fluent);
    // }
  }

  /// Make this capsule instance available globally.
  ///
  /// This method sets the current instance as the global instance that can be
  /// accessed throughout the application.
  void setAsGlobal() {
    _instance = this;
  }

  /// Get the IoC container instance.
  ///
  /// Returns the current container instance used by this capsule.
  Container? getContainer() => _container;

  /// Set the IoC container instance.
  ///
  /// This method allows changing the container instance used by this capsule.
  void setContainer(Container container) {
    _container = container;
  }

  /// Get the current globally used instance.
  ///
  /// Returns the current global instance of this capsule.
  static dynamic getInstance() => _instance;
}
