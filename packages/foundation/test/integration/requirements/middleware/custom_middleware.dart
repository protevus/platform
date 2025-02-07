import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_http/http.dart';

Request customMiddleware(Request req) {
  return req;
}

class ClassBasedMiddleware implements MiddlewareInterface {
  @override
  RequestInterface handle(RequestInterface req) {
    return req;
  }
}
