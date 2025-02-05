import 'dart:io';

import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_foundation/router/route_data.dart';

import './http_controller_handler.dart';
import './http_error_handler.dart';
import './http_request_handler.dart';
import './http_response_handler.dart';

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
