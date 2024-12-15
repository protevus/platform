import 'package:platform_auth/auth.dart';
import 'package:platform_client/io.dart' as c;
import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
import 'package:platform_websocket/io.dart' as c;
import 'package:platform_websocket/server.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

const Map<String, String> user = {'username': 'foo', 'password': 'bar'};

void main() {
  Application app;
  late PlatformHttp http;
  late c.Angel client;
  late c.WebSockets ws;

  setUp(() async {
    app = Application();
    http = PlatformHttp(app, useZone: false);
    var auth = PlatformAuth(
        serializer: (_) async => 'baz', deserializer: (_) async => user);

    auth.strategies['local'] = LocalAuthStrategy(
      (username, password) async {
        if (username == 'foo' && password == 'bar') {
          return user;
        }

        return {};
      },
    );

    app.post('/auth/local', auth.authenticate('local'));

    await app.configure(auth.configureServer);
    var sock = AngelWebSocket(app);

    await app.configure(sock.configureServer);

    app.all('/ws', sock.handleRequest);
    app.logger = Logger('angel_auth')..onRecord.listen(print);

    var server = await http.startServer();

    client = c.Rest('http://${server.address.address}:${server.port}');

    ws = c.WebSockets('ws://${server.address.address}:${server.port}/ws');
    await ws.connect();
  });

  tearDown(() {
    http.close();
    client.close();
    ws.close();
  });

  test('auth event fires', () async {
    var localAuth = await client.authenticate(type: 'local', credentials: user);
    print('JWT: ${localAuth.token}');

    ws.authenticateViaJwt(localAuth.token);
    var auth = await ws.onAuthenticated.first;
    expect(auth.token, localAuth.token);
  });
}
