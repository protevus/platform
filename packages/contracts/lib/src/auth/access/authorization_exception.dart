/// Exception thrown when authorization fails.
///
/// This exception is thrown when an authorization check fails, typically
/// when a user attempts to perform an action they are not authorized to do.
class AuthorizationException implements Exception {
  /// The message describing why authorization failed.
  final String message;

  /// The code associated with the authorization failure.
  final String? code;

  /// Create a new authorization exception.
  ///
  /// Example:
  /// ```dart
  /// throw AuthorizationException(
  ///   'User is not authorized to edit posts',
  ///   code: 'posts.edit.unauthorized',
  /// );
  /// ```
  const AuthorizationException(this.message, {this.code});

  @override
  String toString() =>
      'AuthorizationException: $message${code != null ? ' (code: $code)' : ''}';
}
