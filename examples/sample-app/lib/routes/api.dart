import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_routing/routing.dart';
import 'package:sample_app/app/http/controllers/api.controller.dart';

class ApiRouter extends Router {
  @override
  String get prefix => 'api';

  @override
  List<dynamic> get middleware => <dynamic>[];

  @override
  void register() {
    Route.get('/ping', apiController.pong);
  }
}
