import 'package:example_app/app/models/user/user.model.dart';
import 'package:illuminate_auth/auth.dart';
import 'package:illuminate_config/config.dart';
import 'package:illuminate_foundation/foundation.dart';

class AuthService implements Service {
  @override
  void setup() {
    Auth.initialize(AuthConfig(
      /// default auth guard
      defaultGuard: 'web',

      /// list of auth guards
      guards: <String, AuthGuard>{
        'web': AuthGuard(
          driver: JwtAuthDriver(secret: SecretKey(Env.get('APP_KEY'))),
          provider: AuthProvider(
            model: () => User(),
          ),
        ),
      },
    ));
  }
}
