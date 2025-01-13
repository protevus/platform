import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
import 'package:platform_static/angel3_static.dart';
import 'package:file/local.dart';

void main() async {
  Application app;
  PlatformHttp http;
  var testDir = const LocalFileSystem().directory('test');
  app = Application();
  http = PlatformHttp(app);

  app.fallback(
    CachingVirtualDirectory(app, const LocalFileSystem(),
        source: testDir,
        maxAge: 350,
        onlyInProduction: false,
        indexFileNames: ['index.txt']).handleRequest,
  );

  app.get('*', (req, res) => 'Fallback');

  app.dumpTree(showMatchers: true);

  var server = await http.startServer();
  print('Open at http://${server.address.host}:${server.port}');
}
