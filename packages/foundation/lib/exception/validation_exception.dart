import 'dart:io';

import 'package:illuminate_contracts/contracts.dart';

class ValidationException extends HttpExceptionInterface {
  ValidationException({
    dynamic message = const <String, dynamic>{},
    String errorCode = 'validation_failed',
    int code = HttpStatus.unprocessableEntity,
  }) {
    super.code = code;
    super.errorCode = errorCode;
    super.message = message;
  }
}
