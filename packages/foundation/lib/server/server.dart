import 'dart:io';

import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_http/http.dart';

class Server {
  /// register singleton
  static final Server _singleton = Server._internal();
  factory Server() => _singleton;
  Server._internal();

  /// httpServer dart:io
  late HttpServer httpServer;

  /// set responseHandler
  ResponseHandlerInterface? responseHandler;

  /// listen the request
  /// ```
  /// DoxServer().listen(3000);
  /// ```
  Future<HttpServer> listen(int port,
      {Function? onError, int? isolateId}) async {
    HttpServer server = await HttpServer.bind(
      InternetAddress.anyIPv6,
      port,
      shared: true,
    );
    server.listen(
      (HttpRequest req) {
        httpRequestHandler(req);
      },
      onError: onError ?? (dynamic error) => print(error),
    );
    httpServer = server;
    return server;
  }

  /// close http server
  /// ```
  /// server.close();
  /// ```
  Future<void> close({bool force = false}) async {
    await httpServer.close(force: force);
  }

  /// set response handler
  /// ```
  /// server.setResponseHandler(Handler());
  /// ```
  void setResponseHandler(ResponseHandlerInterface? handler) {
    responseHandler = handler;
  }
}
