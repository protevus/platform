import 'dart:io';

import 'package:illuminate_contracts/contracts.dart';

class QueryException extends HttpExceptionInterface {
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
