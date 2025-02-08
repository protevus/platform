import 'package:illuminate_contracts/contracts.dart';

class CustomMiddleware extends MiddlewareInterface {
  @override
  RequestInterface handle(RequestInterface req) {
    /// write your logic here
    return req;
  }
}
