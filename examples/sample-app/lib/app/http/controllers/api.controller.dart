import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_http/http.dart';

class ApiController {
  String pong(Request req) {
    return 'pong';
  }
}

ApiController apiController = ApiController();
