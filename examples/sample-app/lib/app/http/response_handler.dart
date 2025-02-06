import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_http/http.dart';

class ResponseHandler extends ResponseHandlerInterface {
  /// Modify the response here.
  /// Example
  /// ```
  /// return res.content(<String, String>{'foo' : 'bar'}).statusCode(200);
  /// ```
  @override
  DoxResponse handle(DoxResponse res) {
    return res;
  }
}
