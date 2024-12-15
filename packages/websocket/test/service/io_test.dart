import 'dart:io';
import 'package:platform_container/mirrors.dart';
import 'package:platform_foundation/core.dart' as srv;
import 'package:platform_foundation/http.dart' as srv;
import 'package:platform_websocket/io.dart' as ws;
import 'package:platform_websocket/server.dart' as srv;
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'common.dart';

void main() {
  srv.Application app;
  late srv.PlatformHttp http;
  ws.WebSockets? client;
  srv.AngelWebSocket websockets;
  HttpServer? server;
  String? url;

  setUp(() async {
    app = srv.Application(reflector: MirrorsReflector())
      ..use('/api/todos', TodoService());
    http = srv.PlatformHttp(app, useZone: false);

    websockets = srv.AngelWebSocket(app)
      ..onData.listen((data) {
        print('Received by server: $data');
      });

    await app.configure(websockets.configureServer);
    app.all('/ws', websockets.handleRequest);
    app.logger = Logger('angel_auth')..onRecord.listen(print);
    server = await http.startServer();
    url = 'ws://${server!.address.address}:${server!.port}/ws';

    client = ws.WebSockets(url);
    await client!.connect();

    client
      ?..onData.listen((data) {
        print('Received by client: $data');
      })
      ..onError.listen((error) {
        // Auto-fail tests on errors ;)
        stderr.writeln(error);
        error.errors.forEach(stderr.writeln);
        throw error;
      });
  });

  tearDown(() async {
    await client!.close();
    await http.server!.close(force: true);

    //app = null;
    client = null;
    server = null;
    url = null;
    //exit(0);
  });

  group('service.io', () {
    test('index', () => testIndex(client!));
  });
}
