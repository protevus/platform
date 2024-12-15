import 'dart:async';
import 'package:platform_auth/auth.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
import 'package:logging/logging.dart';

final Map<String, String> sampleUser = {'hello': 'world'};

final PlatformAuth<Map<String, String>> auth =
    PlatformAuth<Map<String, String>>(
        serializer: (user) async => '1337',
        deserializer: (id) async => sampleUser);
//var headers = <String, String>{'accept': 'application/json'};
var localOpts = AngelAuthOptions<Map<String, String>>(
    failureRedirect: '/failure', successRedirect: '/success');
var localOpts2 =
    AngelAuthOptions<Map<String, String>>(canRespondWithJson: false);

Future<Map<String, String>> verifier(String? username, String? password) async {
  if (username == 'username' && password == 'password') {
    return sampleUser;
  } else {
    return {};
  }
}

Future wireAuth(Application app) async {
  //auth.strategies['local'] = LocalAuthStrategy(verifier);
  auth.strategies['local'] =
      LocalAuthStrategy(verifier, forceBasic: true, realm: 'test');
  await app.configure(auth.configureServer);
}

/*
 * Backend for local test cases
 */
void main() async {
  Application app = Application(reflector: MirrorsReflector());
  PlatformHttp angelHttp = PlatformHttp(app, useZone: false);
  await app.configure(wireAuth);

  app.get('/hello', (req, res) {
    // => 'Woo auth'
    return 'Woo auth';
  }, middleware: [auth.authenticate('local', localOpts2)]);

  app.post('/login', (req, res) => 'This should not be shown',
      middleware: [auth.authenticate('local', localOpts)]);

  app.get('/success', (req, res) => 'yep', middleware: [
    requireAuthentication<Map<String, String>>(),
  ]);

  app.get('/failure', (req, res) => 'nope');

  app.logger = Logger('local_test')
    ..onRecord.listen((rec) {
      print(
          '${rec.time}: ${rec.level.name}: ${rec.loggerName}: ${rec.message}');

      if (rec.error != null) {
        print(rec.error);
        print(rec.stackTrace);
      }
    });

  await angelHttp.startServer('127.0.0.1', 3000);
}
