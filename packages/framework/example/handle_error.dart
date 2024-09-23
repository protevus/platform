import 'dart:async';
import 'dart:io';
import 'package:platform_container/mirrors.dart';
import 'package:platform_framework/platform_framework.dart';
import 'package:platform_framework/http.dart';
import 'package:logging/logging.dart';

void main() async {
  var app = Protevus(reflector: MirrorsReflector())
    ..logger = (Logger('angel')
      ..onRecord.listen((rec) {
        print(rec);
        if (rec.error != null) print(rec.error);
        if (rec.stackTrace != null) print(rec.stackTrace);
      }))
    ..encoders.addAll({'gzip': gzip.encoder});

  app.fallback(
      (req, res) => Future.error('Throwing just because I feel like!'));

  var http = ProtevusHttp(app);
  HttpServer? server = await http.startServer('127.0.0.1', 3000);
  var url = 'http://${server.address.address}:${server.port}';
  print('Listening at $url');
}
