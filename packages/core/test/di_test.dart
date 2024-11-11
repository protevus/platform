import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:platform_container/container.dart';
import 'package:platform_core/http.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_core/core.dart';
import 'package:http/http.dart' as http;
import 'package:platform_testing/http.dart';
import 'package:test/test.dart';

import 'common.dart';

final String sampleText = 'make your bed';
final String sampleOver = 'never';

void main() {
  late Application app;
  late http.Client client;
  late HttpServer server;
  String? url;

  setUp(() async {
    app = Application(reflector: MirrorsReflector());
    client = http.Client();

    // Inject some todos
    app.container.registerSingleton(Todo(text: sampleText, over: sampleOver));
    app.container.registerFactory<Future<Foo>>((container) async {
      var req = container.make<RequestContext>();
      var text = await utf8.decoder.bind(req.body!).join();
      return Foo(text);
    });

    app.get('/errands', ioc((Todo singleton) => singleton));
    app.get(
        '/errands3',
        ioc(({required Errand singleton, Todo? foo, RequestContext? req}) =>
            singleton.text));
    app.post('/async', ioc((Foo foo) => {'baz': foo.bar}));
    await app.configure(SingletonController().configureServer);
    await app.configure(ErrandController().configureServer);

    server = await PlatformHttp(app).startServer();
    url = 'http://${server.address.host}:${server.port}';
  });

  tearDown(() async {
    url = null;
    client.close();
    await server.close(force: true);
  });

  test('runContained with custom container', () async {
    var app = Application();
    var c = Container(const MirrorsReflector());
    c.registerSingleton(Todo(text: 'Hey!'));

    app.get('/', (req, res) async {
      return app.runContained((Todo t) => t.text, req, res, c);
    });

    var rq = MockHttpRequest('GET', Uri(path: '/'));
    await rq.close();
    var rs = rq.response;
    await PlatformHttp(app).handleRequest(rq);
    var text = await rs.transform(utf8.decoder).join();
    expect(text, json.encode('Hey!'));
  });

  test('singleton in route', () async {
    validateTodoSingleton(await client.get(Uri.parse('$url/errands')));
  });

  test('singleton in controller', () async {
    validateTodoSingleton(await client.get(Uri.parse('$url/errands2')));
  });

  test('make in route', () async {
    var response = await client.get(Uri.parse('$url/errands3'));
    var text = await json.decode(response.body) as String?;
    expect(text, equals(sampleText));
  });

  test('make in controller', () async {
    var response = await client.get(Uri.parse('$url/errands4'));
    var text = await json.decode(response.body) as String?;
    expect(text, equals(sampleText));
  });

  test('resolve from future in controller', () async {
    var response =
        await client.post(Uri.parse('$url/errands4/async'), body: 'hey');
    expect(response.body, json.encode({'bar': 'hey'}));
  });

  test('resolve from future in route', () async {
    var response = await client.post(Uri.parse('$url/async'), body: 'yes');
    expect(response.body, json.encode({'baz': 'yes'}));
  });
}

void validateTodoSingleton(response) {
  var todo = json.decode(response.body.toString()) as Map;
  expect(todo['id'], equals(null));
  expect(todo['text'], equals(sampleText));
  expect(todo['over'], equals(sampleOver));
}

@Expose('/errands2')
class SingletonController extends Controller {
  @Expose('/')
  Todo todo(Todo singleton) => singleton;
}

@Expose('/errands4')
class ErrandController extends Controller {
  @Expose('/')
  String? errand(Errand errand) {
    return errand.text;
  }

  @Expose('/async', method: 'POST')
  Map<String, String> asyncResolve(Foo foo) {
    return {'bar': foo.bar};
  }
}

class Foo {
  final String bar;

  Foo(this.bar);
}

class Errand {
  Todo todo;

  String? get text => todo.text;

  Errand(this.todo);
}
