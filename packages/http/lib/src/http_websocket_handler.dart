import 'dart:io';

import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_http/http.dart';

void httpWebSocketHandler(HttpRequest req, RouteData route) {
  getDoxRequest(req, route).then((Request doxReq) {
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
