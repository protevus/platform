import 'package:example_app/app/http/serializers/user.serializer.dart';
import 'package:example_app/app/models/user/user.model.dart';
import 'package:illuminate_auth/dox_auth.dart';
import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_http/http.dart';
import 'package:illuminate_log/log.dart';
import 'package:illuminate_support/support.dart';

class AuthController {
  Future<dynamic> login(DoxRequest req) async {
    Map<String, dynamic> credentials = req.only(<String>['email', 'password']);

    Auth auth = Auth();
    String? token = await auth.attempt(credentials);
    User? user = auth.user<User>();

    if (token != null) {
      return response(<String, dynamic>{
        'success': true,
        'token': token,
        'user': user,
      }).header('Authorization', token);
    }

    return <String, dynamic>{
      'success': false,
    };
  }

  Future<dynamic> register(DoxRequest req) async {
    User user = User();
    user.name = 'AJ';
    user.email = 'aj@mail.com';
    user.password = Hash.make('password');
    await user.save();
    return user;
  }

  Future<dynamic> user(DoxRequest req) async {
    IAuth? auth = req.auth;
    if (auth?.isLoggedIn() == true) {
      Logger.info('${auth?.user<User>()?.name} is logged in');
      return UserSerializer(auth?.user());
    }
    return UnAuthorizedException();
  }
}
