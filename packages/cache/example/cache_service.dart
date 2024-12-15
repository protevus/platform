import 'package:platform_cache/platform_cache.dart';
import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';

void main() async {
  var app = Application();

  app.use(
    '/api/todos',
    CacheService(
        cache: MapService(),
        database: AnonymousService(index: ([params]) {
          print(
              'Fetched directly from the underlying service at ${DateTime.now()}!');
          return ['foo', 'bar', 'baz'];
        }, read: (dynamic id, [params]) {
          return {id: '$id at ${DateTime.now()}'};
        })),
  );

  var http = PlatformHttp(app);
  var server = await http.startServer('127.0.0.1', 3000);
  print('Listening at http://${server.address.address}:${server.port}');
}
