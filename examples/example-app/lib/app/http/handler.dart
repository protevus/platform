import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_http/http.dart';

class ResponseHandler extends ResponseHandlerInterface {
  @override
  DoxResponse handle(DoxResponse res) {
    return res;
  }
}
