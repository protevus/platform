import 'package:platform_framework/platform_framework.dart';
import 'package:platform_framework/http.dart';

void main() async {
  var app = Angel();
  var http = AngelHttp(app);

  app.fallback((req, res) {
    res.statusCode = 304;
  });

  await http.startServer('127.0.0.1', 3000);
  print('Listening at ${http.uri}');
}
