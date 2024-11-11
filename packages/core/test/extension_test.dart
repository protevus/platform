import 'dart:async';
import 'package:platform_container/mirrors.dart';
import 'package:platform_core/core.dart';
import 'package:platform_core/http.dart';
import 'package:platform_testing/http.dart';
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
  var app = Application(reflector: MirrorsReflector());
  var http = PlatformHttp(app);
  return http.createRequestContext(rq, rq.response);
}
