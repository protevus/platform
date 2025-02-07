import 'dart:io';

import 'package:illuminate_contracts/contracts.dart';

class InternalErrorException extends HttpExceptionInterface {
  InternalErrorException({
    String message = 'Server Error',
    String errorCode = 'server_error',
    int code = HttpStatus.internalServerError,
  }) {
    super.code = code;
    super.errorCode = errorCode;
    super.message = message;
  }
}
