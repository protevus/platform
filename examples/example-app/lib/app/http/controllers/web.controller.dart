import 'package:example_app/config/redis.dart';
import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_http/http.dart';

class WebController {
  String pong(Request req) {
    return 'pong';
  }

  dynamic testRedis(Request req) async {
    await redis.set('dox', 'awesome');
    return await redis.get('dox');
  }
}
