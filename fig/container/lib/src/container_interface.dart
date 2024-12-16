import 'exceptions.dart';

/// Describes the interface of a container that exposes methods to read its entries.
abstract class ContainerInterface {
  /// Finds an entry of the container by its identifier and returns it.
  ///
  /// [id] Identifier of the entry to look for.
  ///
  /// Returns the entry.
  ///
  /// Throws [NotFoundExceptionInterface] if no entry was found for **this** identifier.
  /// Throws [ContainerExceptionInterface] if an error occurred while retrieving the entry.
  dynamic get(String id);

  /// Returns true if the container can return an entry for the given identifier.
  /// Returns false otherwise.
  ///
  /// [id] Identifier of the entry to look for.
  ///
  /// Returns true if the container can return an entry for the given identifier.
  /// Returns false otherwise.
  ///
  /// Throws [ContainerExceptionInterface] if an error occurred while retrieving the entry.
  bool has(String id);
}
