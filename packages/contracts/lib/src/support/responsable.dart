import 'package:symfony_http_foundation/response.dart';
import 'request.dart';

// TODO: Fix Imports.
abstract class Responsable {
  /// Create an HTTP response that represents the object.
  ///
  /// @param  Request  request
  /// @return Response
  Response toResponse(Request request);
}
