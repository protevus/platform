import 'dart:io';

import 'package:illuminate_foundation/dox_core.dart';

class QueryException extends IHttpException {
  QueryException({
    String message = 'Error in sql query',
    String errorCode = 'sql_query_error',
    int code = HttpStatus.internalServerError,
  }) {
    super.code = code;
    super.errorCode = errorCode;
    super.message = message;
  }
}
