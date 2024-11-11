import 'dart:async';
import 'dart:io';
import 'package:platform_container/mirrors.dart';
import 'package:platform_core/core.dart';
import 'package:platform_core/http.dart';
import 'package:platform_testing/http.dart';
import 'package:test/test.dart';

final Uri endpoint = Uri.parse('http://example.com/accept');

void main() {
  test('no content type', () async {
    var req = await acceptContentTypes();
    expect(req.acceptsAll, isFalse);
    //expect(req.accepts(ContentType.JSON), isFalse);
    expect(req.accepts('application/json'), isFalse);
    //expect(req.accepts(ContentType.HTML), isFalse);
    expect(req.accepts('text/html'), isFalse);
  });

  test('wildcard', () async {
    var req = await acceptContentTypes(['*/*']);
    expect(req.acceptsAll, isTrue);
    //expect(req.accepts(ContentType.JSON), isTrue);
    expect(req.accepts('application/json'), isTrue);
    //expect(req.accepts(ContentType.HTML), isTrue);
    expect(req.accepts('text/html'), isTrue);
  });

  test('specific type', () async {
    var req = await acceptContentTypes(['text/html']);
    expect(req.acceptsAll, isFalse);
    //expect(req.accepts(ContentType.JSON), isFalse);
    expect(req.accepts('application/json'), isFalse);
    //expect(req.accepts(ContentType.HTML), isTrue);
    expect(req.accepts('text/html'), isTrue);
  });

  test('strict', () async {
    var req = await acceptContentTypes(['text/html', '*/*']);
    expect(req.accepts('text/html'), isTrue);
    //expect(req.accepts(ContentType.HTML), isTrue);
    //expect(req.accepts(ContentType.JSON, strict: true), isFalse);
    expect(req.accepts('application/json', strict: true), isFalse);
  });

  group('disallow null', () {
    late RequestContext req;

    setUp(() async {
      req = await acceptContentTypes();
    });

    test('throws error', () {
      expect(() => req.accepts(null), throwsArgumentError);
    });
  });
}

Future<RequestContext> acceptContentTypes(
    [Iterable<String> contentTypes = const []]) {
  var headerString =
      contentTypes.isEmpty ? ContentType.text : contentTypes.join(',');
  var rq = MockHttpRequest('GET', endpoint, persistentConnection: false);
  rq.headers.set('accept', headerString);
  rq.close();
  var app = Application(reflector: MirrorsReflector());
  var http = PlatformHttp(app);
  return http.createRequestContext(rq, rq.response);
}
