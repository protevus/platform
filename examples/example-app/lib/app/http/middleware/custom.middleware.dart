import 'package:illuminate_foundation/dox_core.dart';

class CustomMiddleware extends IDoxMiddleware {
  @override
  IDoxRequest handle(IDoxRequest req) {
    /// write your logic here
    return req;
  }
}
