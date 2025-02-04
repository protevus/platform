import 'dart:io';

import 'package:illuminate_annotation/src/core_annotation.dart';

abstract class IDoxWebsocket {
  dynamic create();
}

abstract class WebsocketEvent {
  void on(String event, Function controller);
  Future<WebSocket?> handle(IDoxRequest req);
}
