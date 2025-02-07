import 'dart:io';
import 'package:illuminate_contracts/contracts.dart';

abstract class WebsocketEvent {
  void on(String event, Function controller);
  Future<WebSocket?> handle(RequestInterface req);
}
