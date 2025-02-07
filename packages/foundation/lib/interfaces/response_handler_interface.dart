import 'package:illuminate_http/http.dart';

abstract class ResponseHandlerInterface {
  const ResponseHandlerInterface();

  Response handle(Response res);
}
