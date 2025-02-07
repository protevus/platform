import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_routing/routing.dart';
import 'package:illuminate_websocket/websocket.dart';

class WsController {
  intro(WebsocketEmitter emitter, dynamic message) {
    emitter.emit('intro', message);
  }

  json(WebsocketEmitter emitter, dynamic message) {
    emitter.emit('json', message);
  }
}

class WebsocketRouter implements Router {
  @override
  List get middleware => [];

  @override
  String get prefix => '';

  @override
  void register() {
    WsController wsController = WsController();

    Route.websocket('ws', (WebsocketEvent event) {
      event.on('intro', wsController.intro);
      event.on('json', wsController.json);
    });
  }
}
