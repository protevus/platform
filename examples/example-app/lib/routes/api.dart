import 'package:example_app/app/http/controllers/api.controller.dart';
import 'package:example_app/app/http/controllers/auth.controller.dart';
import 'package:example_app/app/http/controllers/blog.controller.dart';
import 'package:illuminate_auth/dox_auth.dart';
import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_routing/routing.dart';

class ApiRouter extends Router {
  @override
  String get prefix => 'api';

  @override
  List<dynamic> get middleware => <dynamic>[];

  @override
  void register() {
    ApiController api = ApiController();
    BlogController blogController = BlogController();
    AuthController authController = AuthController();

    Route.get('ping', <dynamic>[api.pong]);

    Route.resource('blogs', blogController);

    Route.post('/auth/login', authController.login);
    Route.post('/auth/register', authController.register);
    Route.get('/auth/user', <dynamic>[
      AuthMiddleware(),
      authController.user,
    ]);
  }
}
