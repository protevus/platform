import 'package:illuminate_http/http.dart';
import 'package:illuminate_support/support.dart';

class ExampleController {
  void testException(Request req) {
    throw Exception('something went wrong');
  }

  void httpException(Request req) {
    throw ValidationException();
  }
}
