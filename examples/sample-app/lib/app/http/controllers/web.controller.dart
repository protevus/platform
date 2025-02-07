import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_http/http.dart';

class WebController {
  String pong(Request req) {
    return 'pong';
  }
}

WebController webController = WebController();
