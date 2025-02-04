import 'dart:io';

import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_foundation/http/http_response_handler.dart';

void httpErrorHandler(HttpRequest req, Object? error, StackTrace stackTrace) {
  if (error is Exception || error is Error) {
    Dox().config.errorHandler(error, stackTrace);
  }
  httpResponseHandler(error, req);
}
