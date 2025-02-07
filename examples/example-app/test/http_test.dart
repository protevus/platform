import 'package:example_app/config/app.dart';
import 'package:illuminate_foundation/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

String baseUrl = 'http://localhost:${appConfig.serverPort}';

void main() {
  setUpAll(() async {
    Application().initialize(appConfig);
    await Application().startServer();
    await Future<dynamic>.delayed(Duration(milliseconds: 500));
  });

  test('ping route', () async {
    Uri url = Uri.parse('$baseUrl/api/ping');
    http.Response response = await http.get(url);
    expect(response.statusCode, 200);
    expect(response.body, 'pong');
  });
}
