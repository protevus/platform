import 'dart:io';

import 'package:illuminate_foundation/dox_core.dart';

class ValidationException extends IHttpException {
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
