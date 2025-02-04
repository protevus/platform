import 'dart:io';

import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_foundation/http/http_controller_handler.dart';
import 'package:illuminate_foundation/http/http_error_handler.dart';
import 'package:illuminate_foundation/http/http_request_handler.dart';
import 'package:illuminate_foundation/http/http_response_handler.dart';
import 'package:illuminate_foundation/router/route_data.dart';

void httpWebSocketHandler(HttpRequest req, RouteData route) {
  getDoxRequest(req, route).then((DoxRequest doxReq) {
    middlewareAndControllerHandler(doxReq).then((dynamic result) {
      httpResponseHandler(result, req);
    }).onError((Object? error, StackTrace stackTrace) {
      /// coverage:ignore-start
      httpErrorHandler(req, error, stackTrace);

      /// coverage:ignore-end
    });
  }).onError((Object? error, StackTrace stackTrace) {
    /// coverage:ignore-start
    httpErrorHandler(req, error, stackTrace);

    /// coverage:ignore-end
  });
}
