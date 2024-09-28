import 'package:platform_container/mirrors.dart';
import 'package:platform_core/core.dart';
import 'package:platform_core/http.dart';
import 'package:logging/logging.dart';

void main() async {
  // Logging set up/boilerplate
  Logger.root.onRecord.listen(print);

  // Create our server.
  var app = Application(
    logger: Logger('protevus'),
    reflector: MirrorsReflector(),
  );

  // Create a RESTful service that manages an in-memory collection.
  app.use('/api/todos', MapService());

  var http = PlatformHttp(app);
  await http.startServer('127.0.0.1', 0);
  print('Listening at ${http.uri}');
}
