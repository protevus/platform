import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';

void main() async {
  var app = Application();
  var http = PlatformHttp(app);

  app.fallback((req, res) {
    res.statusCode = 304;
  });

  await http.startServer('127.0.0.1', 3000);
  print('Listening at ${http.uri}');
}
