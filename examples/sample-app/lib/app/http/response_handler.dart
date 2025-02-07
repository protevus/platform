import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_http/http.dart';

class ResponseHandler extends ResponseHandlerInterface {
  /// Modify the response here.
  /// Example
  /// ```
  /// return res.content(<String, String>{'foo' : 'bar'}).statusCode(200);
  /// ```
  @override
  Response handle(Response res) {
    return res;
  }
}
