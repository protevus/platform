import 'dart:convert';

import 'package:platform_container/mirrors.dart';
import 'package:platform_framework/platform_framework.dart';
import 'package:platform_framework/http.dart';
import 'package:platform_mocking/platform_mocking.dart';

import 'package:test/test.dart';

void main() {
  test('preinjects functions', () async {
    var app = Protevus(reflector: MirrorsReflector())
      ..configuration['foo'] = 'bar'
      ..get('/foo', ioc(echoAppFoo));
    app.optimizeForProduction(force: true);
    print(app.preContained);
    expect(app.preContained.keys, contains(echoAppFoo));

    var rq = MockHttpRequest('GET', Uri(path: '/foo'));
    await rq.close();
    await ProtevusHttp(app).handleRequest(rq);
    var rs = rq.response;
    var body = await rs.transform(utf8.decoder).join();
    expect(body, json.encode('bar'));
  }, skip: 'Protevus no longer has to preinject functions');
}

String echoAppFoo(String foo) => foo;
