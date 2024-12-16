import '../http/request.dart';
import '../http/response.dart';

/// Interface for objects that can be converted to HTTP responses.
///
/// This contract defines a standard way for objects to be converted
/// into HTTP responses. This is particularly useful for API resources,
/// view models, and other objects that need to be sent as HTTP responses.
///
/// Example:
/// ```dart
/// class UserResource implements Responsable {
///   final User user;
///
///   UserResource(this.user);
///
///   @override
///   Response toResponse(Request request) {
///     return JsonResponse({
///       'id': user.id,
///       'name': user.name,
///       'email': user.email,
///       '_links': {
///         'self': '/api/users/${user.id}',
///       },
///     });
///   }
/// }
/// ```
abstract class Responsable {
  /// Create an HTTP response that represents the object.
  ///
  /// This method allows objects to define their own custom response
  /// transformation logic. The [request] parameter provides context
  /// about the current HTTP request, which can be used to customize
  /// the response format (e.g., JSON vs HTML based on Accept header).
  Response toResponse(Request request);
}
