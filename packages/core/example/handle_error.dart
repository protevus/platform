import 'dart:async';
import 'dart:io';
import 'package:platform_container/mirrors.dart';
import 'package:platform_core/core.dart';
import 'package:platform_core/http.dart';
import 'package:logging/logging.dart';

void main() async {
  var app = Application(reflector: MirrorsReflector())
    ..logger = (Logger('protevus')
      ..onRecord.listen((rec) {
        print(rec);
        if (rec.error != null) print(rec.error);
        if (rec.stackTrace != null) print(rec.stackTrace);
      }))
    ..encoders.addAll({'gzip': gzip.encoder});

  app.fallback(
      (req, res) => Future.error('Throwing just because I feel like!'));

  var http = PlatformHttp(app);
  HttpServer? server = await http.startServer('127.0.0.1', 3000);
  var url = 'http://${server.address.address}:${server.port}';
  print('Listening at $url');
}
