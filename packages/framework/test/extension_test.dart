import 'dart:async';
import 'package:platform_container/mirrors.dart';
import 'package:platform_framework/platform_framework.dart';
import 'package:platform_framework/http.dart';
import 'package:platform_mock_request/platform_mock_request.dart';
import 'package:test/test.dart';

final Uri endpoint = Uri.parse('http://example.com');

void main() {
  test('single extension', () async {
    var req = await makeRequest('foo.js');
    expect(req.extension, '.js');
  });

  test('multiple extensions', () async {
    var req = await makeRequest('foo.min.js');
    expect(req.extension, '.js');
  });

  test('no extension', () async {
    var req = await makeRequest('foo');
    expect(req.extension, '');
  });
}

Future<RequestContext> makeRequest(String path) {
  var rq = MockHttpRequest('GET', endpoint.replace(path: path))..close();
  var app = Angel(reflector: MirrorsReflector());
  var http = AngelHttp(app);
  return http.createRequestContext(rq, rq.response);
}