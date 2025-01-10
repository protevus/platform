import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:platform_foundation/core.dart';
import 'package:logging/logging.dart';
import 'src/foo.dart';

Future<Application> createServer() async {
  var app = Application()..serializer = json.encode;
  hierarchicalLoggingEnabled = true;

  // Edit this line, and then refresh the page in your browser!
  app.get('/', (req, res) => {'hello': 'hot world!'});
  app.get('/foo', (req, res) => Foo(bar: 'baz'));

  app.fallback((req, res) => throw PlatformHttpException.notFound());

  app.encoders.addAll({
    'gzip': gzip.encoder,
    'deflate': zlib.encoder,
  });

  app.logger = Logger.detached('angel')
    ..onRecord.listen((rec) {
      print(rec);
      if (rec.error != null) {
        print(rec.error);
        print(rec.stackTrace);
      }
    });

  return app;
}
