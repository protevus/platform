import 'dart:io';
import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
import 'package:platform_foundation/http2.dart';
import 'package:platform_websocket/server.dart';
import 'package:file/local.dart';
import 'package:logging/logging.dart';

void main(List<String> args) async {
  var app = Application();
  var http = PlatformHttp(app);
  var ws = AngelWebSocket(app, sendErrors: !app.environment.isProduction);
  var fs = const LocalFileSystem();
  app.logger = Logger('platform_websocket');

  // This is a plug-in. It hooks all your services,
  // to automatically broadcast events.
  await app.configure(ws.configureServer);

  app.get('/', (req, res) => res.streamFile(fs.file('example/index.html')));

  // Listen for requests at `/ws`.
  app.get('/ws', ws.handleRequest);

  app.fallback((req, res) => throw PlatformHttpException.notFound());

  ws.onConnection.listen((socket) {
    var h = socket.request.headers;
    print('WebSocket onConnection  $h');

    socket.onData.listen((x) {
      socket.send('pong', x);
    });
  });

  if (args.contains('http2')) {
    var ctx = SecurityContext()
      ..useCertificateChain('dev.pem')
      ..usePrivateKey('dev.key', password: 'dartdart');

    try {
      ctx.setAlpnProtocols(['h2'], true);
    } catch (e, st) {
      app.logger.severe(
        'Cannot set ALPN protocol on server to `h2`. The server will only serve HTTP/1.x.',
        e,
        st,
      );
    }

    var http2 = PlatformHttp2(app, ctx);
    http2.onHttp1.listen(http.handleRequest);
    await http2.startServer('127.0.0.1', 3000);
    print('Listening at ${http2.uri}');
  } else {
    await http.startServer('127.0.0.1', 3000);
    print('Listening at ${http.uri}');
  }
}
