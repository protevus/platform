import 'package:platform_container/mirrors.dart';
import 'package:platform_core/core.dart';
import 'package:platform_core/http.dart';

void main() async {
  var app = Protevus(reflector: MirrorsReflector());

  app.viewGenerator = (name, [data]) async =>
      'View generator invoked with name $name and data: $data';

  // Index route. Returns JSON.
  app.get('/', (req, res) => res.render('index', {'foo': 'bar'}));

  var http = ProtevusHttp(app);
  var server = await http.startServer('127.0.0.1', 3000);
  var url = 'http://${server.address.address}:${server.port}';
  print('Listening at $url');
}