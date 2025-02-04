import 'package:dox_app/app/models/user/user.model.dart';
import 'package:illuminate_auth/dox_auth.dart';
import 'package:illuminate_foundation/dox_core.dart';

class AuthService implements DoxService {
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
