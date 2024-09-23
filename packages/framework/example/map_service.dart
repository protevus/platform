import 'package:platform_container/mirrors.dart';
import 'package:platform_framework/platform_framework.dart';
import 'package:platform_framework/http.dart';
import 'package:logging/logging.dart';

void main() async {
  // Logging set up/boilerplate
  Logger.root.onRecord.listen(print);

  // Create our server.
  var app = Protevus(
    logger: Logger('protevus'),
    reflector: MirrorsReflector(),
  );

  // Create a RESTful service that manages an in-memory collection.
  app.use('/api/todos', MapService());

  var http = ProtevusHttp(app);
  await http.startServer('127.0.0.1', 0);
  print('Listening at ${http.uri}');
}
