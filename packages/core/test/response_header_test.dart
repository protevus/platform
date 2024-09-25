import 'dart:io';

import 'package:platform_container/mirrors.dart';
import 'package:platform_core/core.dart';
import 'package:platform_core/src/http/protevus_http.dart';
import 'package:test/test.dart';

void main() {
  late Protevus app;
  late ProtevusHttp http;
  late HttpClient client;

  setUp(() async {
    app = Protevus(reflector: MirrorsReflector());
    http = ProtevusHttp(app);

    await http.startServer();

    var formData = {'id': 100, 'name': 'William'};
    app.get('/api/v1/user/list', (RequestContext req, res) async {
      //await req.parseBody();
      //res.write('Hello, World!');
      res.json(formData);
    });

    client = HttpClient();
  });

  tearDown(() async {
    client.close();
    await http.close();
  });

  test('Remove Response Header', () async {
    http.removeResponseHeader({'x-frame-options': 'SAMEORIGIN'});

    var request = await client.get('localhost', 3000, '/api/v1/user/list');
    HttpClientResponse response = await request.close();
    //print(response.headers);
    expect(response.headers['x-frame-options'], isNull);
  }, skip: true);

  test('Add Response Header', () async {
    http.addResponseHeader({
      'X-XSRF_TOKEN':
          'a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e'
    });

    var request = await client.get('localhost', 3000, '/api/v1/user/list');
    HttpClientResponse response = await request.close();
    //print(response.headers);
    expect(
        response.headers['X-XSRF_TOKEN'],
        equals([
          'a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e'
        ]));
  }, skip: true);
}
