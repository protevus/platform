/// Base interface representing a generic exception in a container.
abstract class ContainerExceptionInterface implements Exception {
  /// The error message.
  String get message;
}

/// Interface representing an exception when a requested entry is not found.
abstract class NotFoundExceptionInterface
    implements ContainerExceptionInterface {
  /// The ID that was not found.
  String get id;
}

/// A concrete implementation of ContainerExceptionInterface.
class ContainerException implements ContainerExceptionInterface {
  @override
  final String message;

  /// Creates a new container exception.
  const ContainerException([this.message = '']);

  @override
  String toString() =>
      message.isEmpty ? 'ContainerException' : 'ContainerException: $message';
}

/// A concrete implementation of NotFoundExceptionInterface.
class NotFoundException implements NotFoundExceptionInterface {
  @override
  final String message;

  @override
  final String id;

  /// Creates a new not found exception.
  const NotFoundException(this.id, [this.message = '']);

  @override
  String toString() {
    if (message.isEmpty) {
      return 'NotFoundException: No entry was found for "$id" identifier';
    }
    return 'NotFoundException: $message';
  }
}
