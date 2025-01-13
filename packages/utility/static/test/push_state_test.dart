import 'package:platform_foundation/core.dart';
import 'package:platform_static/angel3_static.dart';
import 'package:platform_testing/testing.dart';
import 'package:file/memory.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  Application app;
  MemoryFileSystem fileSystem;
  late TestClient client;

  setUp(() async {
    // For teting on Linux/MacOS
    fileSystem = MemoryFileSystem();

    // For testing on Windows
    //fileSystem = MemoryFileSystem(style: FileSystemStyle.windows);

    var webDir = fileSystem.directory('web');
    await webDir.create(recursive: true);

    var indexFile = webDir.childFile('index.html');
    await indexFile.writeAsString('index');

    app = Application();

    var vDir = VirtualDirectory(
      app,
      fileSystem,
      source: webDir,
    );

    app
      ..fallback(vDir.handleRequest)
      ..fallback(vDir.pushState('index.html'))
      ..fallback((req, res) => 'Fallback');

    app.logger = Logger('push_state')
      ..onRecord.listen(
        (rec) {
          print(rec);
          if (rec.error != null) print(rec.error);
          if (rec.stackTrace != null) print(rec.stackTrace);
        },
      );

    client = await connectTo(app);
  });

  tearDown(() => client.close());

  test('serves as fallback', () async {
    var response = await client.get(Uri.parse('/nope'));
    print(response);
    expect(response.body, 'index');
  });
}
