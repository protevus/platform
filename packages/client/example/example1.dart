import 'package:platform_foundation/core.dart';
import 'package:platform_auth/auth.dart';

import 'package:platform_foundation/http.dart';
import 'package:logging/logging.dart';

void main() async {
  const Map<String, String> user = {'username': 'foo', 'password': 'bar'};
  var localOpts =
      AngelAuthOptions<Map<String, String>>(canRespondWithJson: true);

  Application app = Application();
  PlatformHttp http = PlatformHttp(app, useZone: false);
  var auth = PlatformAuth(
      serializer: (_) async => 'baz', deserializer: (_) async => user);

  auth.strategies['local'] = LocalAuthStrategy((username, password) async {
    if (username == 'foo' && password == 'bar') {
      return user;
    }

    return {};
  }, allowBasic: false);

  app.post('/auth/local', auth.authenticate('local', localOpts));

  await app.configure(auth.configureServer);

  app.logger = Logger('auth_test')
    ..onRecord.listen((rec) {
      print(
          '${rec.time}: ${rec.level.name}: ${rec.loggerName}: ${rec.message}');
    });

  await http.startServer('127.0.0.1', 3000);
}
