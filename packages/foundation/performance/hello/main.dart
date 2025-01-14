/// A basic server that prints "Hello, world!"
library performance.hello;

import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';

void main() async {
  var app = Application();
  var http = PlatformHttp.custom(app, startShared, useZone: false);

  app.get('/', (req, res) => res.write('Hello, world!'));
  app.optimizeForProduction(force: true);

  var oldHandler = app.errorHandler;
  app.errorHandler = (e, req, res) {
    print('Oops: ${e.error ?? e}');
    print(e.stackTrace);
    return oldHandler(e, req, res);
  };

  await http.startServer('127.0.0.1', 3000);
  print('Listening at ${http.uri}');
}
