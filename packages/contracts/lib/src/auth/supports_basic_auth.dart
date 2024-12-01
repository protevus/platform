import '../http/response.dart';

/// Interface for HTTP Basic Authentication support.
///
/// This contract defines how HTTP Basic Authentication should be handled,
/// providing methods for both stateful and stateless authentication attempts.
abstract class SupportsBasicAuth {
  /// Attempt to authenticate using HTTP Basic Auth.
  ///
  /// Example:
  /// ```dart
  /// class ApiGuard implements SupportsBasicAuth {
  ///   @override
  ///   Future<Response?> basic([
  ///     String field = 'email',
  ///     Map<String, dynamic> extraConditions = const {},
  ///   ]) async {
  ///     var credentials = getBasicAuthCredentials();
  ///     if (await validateCredentials(credentials)) {
  ///       return null; // Authentication successful
  ///     }
  ///     return Response(
  ///       content: 'Unauthorized',
  ///       status: 401,
  ///       headers: {
  ///         'WWW-Authenticate': 'Basic realm="API Access"'
  ///       },
  ///     );
  ///   }
  /// }
  /// ```
  Future<Response?> basic([
    String field = 'email',
    Map<String, dynamic> extraConditions = const {},
  ]);

  /// Perform a stateless HTTP Basic login attempt.
  ///
  /// Example:
  /// ```dart
  /// class ApiGuard implements SupportsBasicAuth {
  ///   @override
  ///   Future<Response?> onceBasic([
  ///     String field = 'email',
  ///     Map<String, dynamic> extraConditions = const {},
  ///   ]) async {
  ///     var credentials = getBasicAuthCredentials();
  ///     if (await validateCredentials(credentials)) {
  ///       return null; // Authentication successful
  ///     }
  ///     return Response(
  ///       content: 'Unauthorized',
  ///       status: 401,
  ///       headers: {
  ///         'WWW-Authenticate': 'Basic realm="API Access"'
  ///       },
  ///     );
  ///   }
  /// }
  /// ```
  Future<Response?> onceBasic([
    String field = 'email',
    Map<String, dynamic> extraConditions = const {},
  ]);
}
