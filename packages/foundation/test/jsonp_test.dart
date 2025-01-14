import 'dart:async';
import 'dart:convert';
import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:platform_testing/http.dart';
import 'package:test/test.dart';

void main() {
  var app = Application();
  var http = PlatformHttp(app);

  app.get('/default', (req, res) => res.jsonp({'foo': 'bar'}));

  app.get('/callback',
      (req, res) => res.jsonp({'foo': 'bar'}, callbackName: 'doIt'));

  app.get(
      '/contentType',
      (req, res) =>
          res.jsonp({'foo': 'bar'}, contentType: MediaType('foo', 'bar')));

  Future<MediaType> getContentType(String path) async {
    var rq = MockHttpRequest('GET', Uri(path: '/$path'));
    await rq.close();
    await http.handleRequest(rq);
    return MediaType.parse(rq.response.headers.contentType.toString());
  }

  Future<String> getText(String path) async {
    var rq = MockHttpRequest('GET', Uri(path: '/$path'));
    await rq.close();
    await http.handleRequest(rq);
    return await rq.response.transform(utf8.decoder).join();
  }

  test('default', () async {
    var response = await getText('default');
    var contentType = await getContentType('default');
    expect(response, r'callback({"foo":"bar"})');
    expect(contentType.mimeType, 'application/javascript');
  });

  test('callback', () async {
    var response = await getText('callback');
    var contentType = await getContentType('callback');
    expect(response, r'doIt({"foo":"bar"})');
    expect(contentType.mimeType, 'application/javascript');
  });

  test('content type', () async {
    var response = await getText('contentType');
    var contentType = await getContentType('contentType');
    expect(response, r'callback({"foo":"bar"})');
    expect(contentType.mimeType, 'foo/bar');
  });
}
