import 'package:example_app/config/redis.dart';
import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_websocket/websocket.dart';
import 'package:ioredis/ioredis.dart';

class WebsocketService implements Service {
  @override
  void setup() {
    Redis sub = redis.duplicate();
    Redis pub = sub.duplicate();

    WebsocketServer io = WebsocketServer(Application());
    io.adapter(WebsocketRedisAdapter(
      subscriber: sub,
      publisher: pub,
    ));
  }
}
