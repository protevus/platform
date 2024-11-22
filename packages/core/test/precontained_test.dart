import 'dart:convert';

import 'package:platform_container/mirrors.dart';
import 'package:platform_core/core.dart';
import 'package:platform_core/http.dart';
import 'package:platform_testing/http.dart';

import 'package:test/test.dart';

void main() {
  test('preinjects functions when executed', () async {
    // Create app with mirrors reflector
    var app = Application(reflector: MirrorsReflector())
      ..configuration['foo'] = 'bar'
      ..get('/foo', ioc(echoAppFoo));

    // Create request and response contexts
    var rq = MockHttpRequest('GET', Uri(path: '/foo'));
    var reqContext = await HttpRequestContext.from(rq, app, '/foo');
    var resContext = HttpResponseContext(rq.response, app, reqContext);

    // Force pre-injection by running the handler
    await app.runReflected(echoAppFoo, reqContext, resContext);

    // Verify preContained has the function
    expect(app.preContained.keys, contains(echoAppFoo));

    // Clean up
    await reqContext.close();
  });
}

String echoAppFoo(String foo) => foo;
