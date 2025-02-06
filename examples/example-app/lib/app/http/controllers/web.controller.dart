import 'package:example_app/config/redis.dart';
import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_http/http.dart';

class WebController {
  String pong(DoxRequest req) {
    return 'pong';
  }

  dynamic testRedis(DoxRequest req) async {
    await redis.set('dox', 'awesome');
    return await redis.get('dox');
  }
}
