import 'package:illuminate_foundation/dox_core.dart';

abstract class ResponseHandlerInterface {
  const ResponseHandlerInterface();

  DoxResponse handle(DoxResponse res);
}
