import 'dart:io';

import 'package:illuminate_http/http.dart';
import 'package:illuminate_routing/routing.dart';

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
