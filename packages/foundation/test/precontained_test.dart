import 'dart:convert';

import 'package:platform_container/mirrors.dart';
import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
import 'package:platform_testing/http.dart';

import 'package:test/test.dart';

void main() {
  test('preinjects functions', () async {
    var app = Application(reflector: MirrorsReflector())
      ..configuration['foo'] = 'bar'
      ..get('/foo', ioc(echoAppFoo));
    app.optimizeForProduction(force: true);
    print(app.preContained);
    expect(app.preContained.keys, contains(echoAppFoo));

    var rq = MockHttpRequest('GET', Uri(path: '/foo'));
    await rq.close();
    await PlatformHttp(app).handleRequest(rq);
    var rs = rq.response;
    var body = await rs.transform(utf8.decoder).join();
    expect(body, json.encode('bar'));
  }, skip: 'Protevus no longer has to preinject functions');
}

String echoAppFoo(String foo) => foo;
