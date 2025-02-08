import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_routing/routing.dart';
import 'package:sample_app/app/http/controllers/web.controller.dart';

class WebRouter extends Router {
  @override
  List<dynamic> get middleware => <dynamic>[];

  @override
  void register() {
    Route.get('/ping', webController.pong);
  }
}
