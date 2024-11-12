// examples/web_server_with_processes/main.dart
import 'package:platform_core/core.dart';
import 'package:platform_core/http.dart';
import 'package:platform_process/angel3_process.dart';
import 'package:file/local.dart';
import 'package:logging/logging.dart';
import 'package:angel3_mustache/angel3_mustache.dart';
import 'package:platform_container/mirrors.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Create an Angel application with MirrorsReflector
  var app = Application(reflector: MirrorsReflector());
  var http = PlatformHttp(app);

  // Register dependencies in the container
  app.container.registerSingleton(const LocalFileSystem());
  app.container.registerSingleton(ProcessManager());

  // Set up the view renderer
  var fs = await app.container.make<LocalFileSystem>();
  var viewsDirectory = fs.directory('views');
  //await app.configure(mustache(viewsDirectory));

  app.get('/', (req, res) async {
    await res.render('index');
  });

  app.post('/run-process', (req, res) async {
    var body = await req.bodyAsMap;
    var command = body['command'] as String?;
    var args = (body['args'] as String?)?.split(' ') ?? [];

    if (command == null || command.isEmpty) {
      throw PlatformHttpException.badRequest(message: 'Command is required');
    }

    // Use dependency injection to get the ProcessManager instance
    var processManager = await req.container?.make<ProcessManager>();

    var process = await processManager?.start(
      'user_process',
      command,
      args,
    );
    var result = await process?.run();

    await res.json({
      'output': result?.output.trim(),
      'exitCode': result?.exitCode,
    });
  });

  app.fallback((req, res) => throw PlatformHttpException.notFound());

  app.errorHandler = (e, req, res) {
    res.writeln('Error: ${e.message}');
    return false;
  };

  await http.startServer('localhost', 3000);
  print('Server listening at http://localhost:3000');
}
