import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_routing/routing.dart';
import 'package:illuminate_websocket/websocket.dart';

class WebsocketRouter extends Router {
  @override
  List<dynamic> get middleware => <dynamic>[];

  @override
  void register() {
    Route.websocket('ws', (WebsocketEvent event) {
      event.on('intro', (WebsocketEmitter emitter, dynamic message) {
        emitter.emit('intro', message);
      });

      event.on('json', (WebsocketEmitter emitter, dynamic message) {
        emitter.emit('json_response', message);
      });
    });

    Route.websocket('chat', (WebsocketEvent event) {
      event.on('intro', (WebsocketEmitter emitter, dynamic message) {
        emitter.emit('intro', message);
      });

      event.on('json', (WebsocketEmitter emitter, dynamic message) {
        emitter.emit('json_response', message);
      });
    });
  }
}
