import 'package:illuminate_foundation/dox_core.dart';
import 'package:sample_app/app/http/controllers/web.controller.dart';

class WebRouter extends Router {
  @override
  List<dynamic> get middleware => <dynamic>[];

  @override
  void register() {
    Route.get('/ping', webController.pong);
  }
}
