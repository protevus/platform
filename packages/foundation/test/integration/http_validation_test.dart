import 'dart:convert';

import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_http/http.dart';
import 'package:illuminate_routing/routing.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../utils/start_http_server.dart';
import 'requirements/config/app.dart';

String baseUrl = 'http://localhost:${config.serverPort}';

void main() {
  group('Http |', () {
    setUpAll(() async {
      await startHttpServer(config);
    });

    tearDownAll(() async {
      await Application().server.close();
    });

    test('validation failed', () async {
      Route.post('/validation', (Request req) {
        req.validate(<String, String>{
          'name': 'required',
          'email': 'required|email',
        });
        return 'pong';
      });

      Uri url = Uri.parse('$baseUrl/validation');
      http.Response res = await http.post(url);

      expect(res.statusCode, 422);
      expect(res.body.contains('email is required'), true);
      expect(res.body.contains('name is required'), true);
    });

    test('validation passed', () async {
      Route.post('/validation_passed', (Request req) {
        req.validate(<String, String>{
          'name': 'required',
          'email': 'required|email',
        });
        return 'pong';
      });

      Uri url = Uri.parse('$baseUrl/validation_passed');
      http.Response res = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'name': 'dox',
          'email': 'support@dartondox.dev',
        }),
      );

      expect(res.statusCode, 200);
      expect(res.body, 'pong');
    });
  });
}
