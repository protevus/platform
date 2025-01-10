import 'dart:async';
import 'dart:io';

import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
import 'package:logging/logging.dart';

Future<HttpServer> startTestServer() {
  final app = Application();

  app.get('/hello', (req, res) => res.write('world'));
  app.get('/foo/bar', (req, res) => res.write('baz'));
  app.post('/body', (RequestContext req, res) async {
    var body = await req.parseBody().then((_) => req.bodyAsMap);
    app.logger.info('Body: $body');
    return body;
  });

  app.logger = Logger('testApp');
  var server = PlatformHttp(app);
  app.dumpTree();

  return server.startServer();
}
