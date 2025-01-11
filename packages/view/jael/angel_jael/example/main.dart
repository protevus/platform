import 'dart:convert';
import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
import 'package:platform_jael/angel3_jael.dart';
import 'package:file/local.dart';
import 'package:logging/logging.dart';

main() async {
  var app = Application();
  var http = PlatformHttp(app);
  var fileSystem = const LocalFileSystem();

  await app.configure(
    jael(fileSystem.directory('views')),
  );

  app.get(
      '/',
      (req, res) =>
          res.render('index', {'title': 'Sample App', 'message': null}));

  app.post('/', (req, res) async {
    var body = await req.parseBody().then((_) => req.bodyAsMap);
    print('Body: $body');
    var msg = body['message'] ?? '<unknown>';
    return await res.render('index', {
      'title': 'Form Submission',
      'message': msg,
      'json_message': json.encode(msg),
    });
  });

  app.fallback((req, res) => throw PlatformHttpException.notFound());

  app.logger = Logger('angel')
    ..onRecord.listen((rec) {
      print(rec);
      if (rec.error != null) print(rec.error);
      if (rec.stackTrace != null) print(rec.stackTrace);
    });

  var server = await http.startServer('127.0.0.1', 3000);
  print('Listening at http://${server.address.address}:${server.port}');
}
