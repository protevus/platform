/// Base interface for HTTP client exceptions.
abstract class ClientExceptionInterface implements Exception {
  /// The error message.
  String get message;
}

/// Exception for when a request cannot be sent.
abstract class RequestExceptionInterface implements ClientExceptionInterface {
  /// The request that caused the exception.
  dynamic get request;
}

/// Exception for network-related errors.
abstract class NetworkExceptionInterface implements ClientExceptionInterface {
  /// The request that caused the exception.
  dynamic get request;
}

/// A concrete implementation of ClientExceptionInterface.
class ClientException implements ClientExceptionInterface {
  @override
  final String message;

  /// Creates a new client exception.
  const ClientException([this.message = '']);

  @override
  String toString() =>
      message.isEmpty ? 'ClientException' : 'ClientException: $message';
}

/// A concrete implementation of RequestExceptionInterface.
class RequestException implements RequestExceptionInterface {
  @override
  final String message;

  @override
  final dynamic request;

  /// Creates a new request exception.
  const RequestException(this.request, [this.message = '']);

  @override
  String toString() =>
      message.isEmpty ? 'RequestException' : 'RequestException: $message';
}

/// A concrete implementation of NetworkExceptionInterface.
class NetworkException implements NetworkExceptionInterface {
  @override
  final String message;

  @override
  final dynamic request;

  /// Creates a new network exception.
  const NetworkException(this.request, [this.message = '']);

  @override
  String toString() =>
      message.isEmpty ? 'NetworkException' : 'NetworkException: $message';
}
