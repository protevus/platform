import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_http/http.dart';

class WebController {
  String pong(DoxRequest req) {
    return 'pong';
  }
}

WebController webController = WebController();
