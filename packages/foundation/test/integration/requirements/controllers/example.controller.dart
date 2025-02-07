import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_http/http.dart';

class ExampleController {
  void testException(Request req) {
    throw Exception('something went wrong');
  }

  void httpException(Request req) {
    throw ValidationException();
  }
}
