import 'dart:async';
import 'package:platform_core/core.dart';
import 'package:platform_core/http.dart';
import 'package:http/io_client.dart' as http;
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'pretty_log.dart';

void main() {
  late http.IOClient client;
  late PlatformHttp driver;
  late Logger logger;
  late StringBuffer buf;

  setUp(() async {
    buf = StringBuffer();
    client = http.IOClient();
    hierarchicalLoggingEnabled = true;

    logger = Logger.detached('req_shutdown')
      ..level = Level.ALL
      ..onRecord.listen(prettyLog);

    var app = Application(logger: logger);

    app.fallback((req, res) {
      req.shutdownHooks.add(() => buf.write('Hello, '));
      req.shutdownHooks.add(() => buf.write('world!'));
    });

    driver = PlatformHttp(app);
    await driver.startServer();
  });

  tearDown(() {
    logger.clearListeners();
    client.close();
    scheduleMicrotask(driver.close);
  });

  test('does not continue processing after streaming', () async {
    await client.get(driver.uri);
    await Future.delayed(Duration(milliseconds: 100));
    expect(buf.toString(), 'Hello, world!');
  });
}
