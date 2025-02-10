import 'dart:io';

import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_http/http.dart';

import './request/http_request_body.dart';

/// this is a class which get matched routes and
/// pass http request to route middleware and controllers
/// and response from controllers is passed to `httpResponseHandler`
void httpRequestHandler(HttpRequest req) {
  try {
    RouteData? route = httpRouteHandler(req);
    if (route == null) return;

    httpCorsHandler(route.corsEnabled, req);

    if (WebSocketTransformer.isUpgradeRequest(req)) {
      httpWebSocketHandler(req, route);
      return;
    }

    getDoxRequest(req, route).then((Request doxReq) {
      middlewareAndControllerHandler(doxReq).then((dynamic result) {
        httpResponseHandler(result, req);
      }).onError((Object? error, StackTrace stackTrace) {
        httpErrorHandler(req, error, stackTrace);
      });
    }).onError((Object? error, StackTrace stackTrace) {
      httpErrorHandler(req, error, stackTrace);
    });

    /// form data do not support isolate or multithread
  } catch (error, stackTrace) {
    httpErrorHandler(req, error, stackTrace);
  }
}

Future<Request> getDoxRequest(HttpRequest req, RouteData route) async {
  return Request(
    route: route,
    uri: req.uri,
    body: await HttpBody.read(req),
    contentType: req.headers.contentType,
    clientIp: req.connectionInfo?.remoteAddress.address,
    httpHeaders: req.headers,
    httpRequest: req,
  );
}
