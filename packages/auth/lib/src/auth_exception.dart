import 'dart:io';

import 'package:illuminate_annotation/dox_annotation.dart';

class UnAuthorizedException extends IHttpException {
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
