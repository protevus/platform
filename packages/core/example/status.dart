import 'package:platform_core/core.dart';
import 'package:platform_core/http.dart';

void main() async {
  var app = Protevus();
  var http = ProtevusHttp(app);

  app.fallback((req, res) {
    res.statusCode = 304;
  });

  await http.startServer('127.0.0.1', 3000);
  print('Listening at ${http.uri}');
}
