import 'dart:io';

import 'package:illuminate_contracts/contracts.dart';

class NotFoundHttpException extends HttpExceptionInterface {
  NotFoundHttpException({
    String message = 'Not Found',
    String errorCode = 'not_found',
    int code = HttpStatus.notFound,
  }) {
    super.code = code;
    super.errorCode = errorCode;
    super.message = message;
  }
}
