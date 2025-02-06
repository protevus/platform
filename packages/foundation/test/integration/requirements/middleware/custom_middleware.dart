import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_http/http.dart';

DoxRequest customMiddleware(DoxRequest req) {
  return req;
}

class ClassBasedMiddleware implements IDoxMiddleware {
  @override
  IDoxRequest handle(IDoxRequest req) {
    return req;
  }
}
