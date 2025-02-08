import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_http/http.dart';

class ResponseHandler extends ResponseHandlerInterface {
  @override
  Response handle(Response res) {
    return res;
  }
}
