import 'dart:async';
import 'package:platform_auth/auth.dart';
import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';

void main() async {
  var app = Application();
  var auth = PlatformAuth<User>(
      serializer: (user) => user.id ?? '',
      deserializer: (id) => fetchAUserByIdSomehow(id));

  // Middleware to decode JWT's and inject a user object...
  await app.configure(auth.configureServer);

  auth.strategies['local'] = LocalAuthStrategy((username, password) {
    // Retrieve a user somehow...
    // If authentication succeeds, return a User object.
    //
    // Otherwise, return `null`.
    return null;
  });

  app.post('/auth/local', auth.authenticate('local'));

  var http = PlatformHttp(app);
  await http.startServer('127.0.0.1', 3000);

  print('Listening at http://127.0.0.1:3000');
}

class User {
  String? id, username, password;
}

Future<User> fetchAUserByIdSomehow(String id) async {
  // Fetch a user somehow...
  throw UnimplementedError();
}
