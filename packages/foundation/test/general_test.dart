import 'dart:io';
import 'package:platform_container/mirrors.dart';
import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  late Application app;
  late http.Client client;
  late HttpServer server;
  late String url;

  setUp(() async {
    app = Application(reflector: MirrorsReflector())
      ..post('/foo', (req, res) => res.serialize({'hello': 'world'}))
      ..all('*', (req, res) => throw PlatformHttpException.notFound());
    client = http.Client();

    server = await PlatformHttp(app).startServer();
    url = 'http://${server.address.host}:${server.port}';
  });

  tearDown(() async {
    client.close();
    await server.close(force: true);
  });

  test('allow override of method', () async {
    var response = await client.get(Uri.parse('$url/foo'),
        headers: {'X-HTTP-Method-Override': 'POST'});
    print('Response: ${response.body}');
    expect(json.decode(response.body), equals({'hello': 'world'}));
  });
}
