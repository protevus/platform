import 'package:illuminate_contracts/contracts.dart';

abstract class MiddlewareInterface {
  dynamic handle(RequestInterface req);
}
