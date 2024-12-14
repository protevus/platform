import 'dart:convert';
import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
import 'package:platform_testing/http.dart';
import 'package:test/test.dart';

void main() {
  late PlatformHttp http;

  setUp(() async {
    var app = Application();
    http = PlatformHttp(app);

    app.get('/detach', (req, res) async {
      if (res is HttpResponseContext) {
        var io = res.detach();
        io.write('Hey!');
        await io.close();
      } else {
        throw StateError('This endpoint only supports HTTP/1.1.');
      }
    });
  });

  tearDown(() => http.close());

  test('detach response', () async {
    var rq = MockHttpRequest('GET', Uri.parse('/detach'));
    await rq.close();
    var rs = rq.response;
    await http.handleRequest(rq);
    var body = await rs.transform(utf8.decoder).join();
    expect(body, 'Hey!');
  });
}
