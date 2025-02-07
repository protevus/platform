import 'dart:io';

import 'package:illuminate_foundation/foundation.dart';

import './http_response_handler.dart';

void httpErrorHandler(HttpRequest req, Object? error, StackTrace stackTrace) {
  if (error is Exception || error is Error) {
    Application().config.errorHandler(error, stackTrace);
  }
  httpResponseHandler(error, req);
}
