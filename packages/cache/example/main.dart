import 'package:platform_cache/platform_cache.dart';
import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';

void main() async {
  var app = Application();

  // Cache a glob
  var cache = ResponseCache()
    ..patterns.addAll([
      RegExp('^/?\\w+\\.txt'),
    ]);

  // Handle `if-modified-since` header, and also send cached content
  app.fallback(cache.handleRequest);

  // A simple handler that returns a different result every time.
  app.get(
      '/date.txt', (req, res) => res.write(DateTime.now().toIso8601String()));

  // Support purging the cache.
  app.addRoute('PURGE', '*', (req, res) {
    if (req.ip != '127.0.0.1') {
      throw PlatformHttpException.forbidden();
    }

    cache.purge(req.uri!.path);
    print('Purged ${req.uri!.path}');
  });

  // The response finalizer that actually saves the content
  app.responseFinalizers.add(cache.responseFinalizer);

  var http = PlatformHttp(app);
  var server = await http.startServer('127.0.0.1', 3000);
  print('Listening at http://${server.address.address}:${server.port}');
}
