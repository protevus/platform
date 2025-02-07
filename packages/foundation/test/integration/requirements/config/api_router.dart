import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_http/http.dart';
import 'package:illuminate_routing/routing.dart';

import '../middleware/custom_middleware.dart';

class ApiRouter extends Router {
  @override
  String get prefix => 'api';

  @override
  void register() {
    Route.use(customMiddleware);
    Route.use(<MiddlewareInterface>[ClassBasedMiddleware()]);

    Route.get('ping', (Request req) => 'pong');
  }
}
