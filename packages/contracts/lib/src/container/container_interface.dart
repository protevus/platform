/// Interface for service containers.
///
/// This contract defines the basic interface that any service container
/// must implement. It follows the PSR-11 ContainerInterface specification
/// from PHP-FIG, adapted for Dart.
abstract class ContainerInterface {
  /// Finds an entry of the container by its identifier and returns it.
  ///
  /// Example:
  /// ```dart
  /// var logger = container.get('logger');
  /// ```
  ///
  /// Throws [BindingResolutionException] if the identifier is not found.
  dynamic get(String id);

  /// Returns true if the container can return an entry for the given identifier.
  /// Returns false otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (container.has('logger')) {
  ///   // Use the logger service
  /// }
  /// ```
  bool has(String id);
}
