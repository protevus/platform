import 'dart:io';

import 'package:illuminate_contracts/contracts.dart';

class UnAuthorizedException extends HttpExceptionInterface {
  UnAuthorizedException({
    String message = 'Authentication failed',
    String errorCode = 'unauthorized',
    int code = HttpStatus.unauthorized,
  }) {
    super.code = code;
    super.errorCode = errorCode;
    super.message = message;
  }
}
