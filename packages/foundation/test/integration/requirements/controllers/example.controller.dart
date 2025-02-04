import 'package:illuminate_foundation/dox_core.dart';

class ExampleController {
  void testException(DoxRequest req) {
    throw Exception('something went wrong');
  }

  void httpException(DoxRequest req) {
    throw ValidationException();
  }
}
