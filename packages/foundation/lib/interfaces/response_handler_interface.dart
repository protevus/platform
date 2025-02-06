import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_http/http.dart';

abstract class ResponseHandlerInterface {
  const ResponseHandlerInterface();

  DoxResponse handle(DoxResponse res);
}
