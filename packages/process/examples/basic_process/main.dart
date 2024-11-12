// examples/basic_process/main.dart
import 'package:platform_core/core.dart';
import 'package:platform_core/http.dart';
import 'package:platform_process/angel3_process.dart';
import 'package:logging/logging.dart';
import 'package:platform_container/mirrors.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Create an Angel application with MirrorsReflector
  var app = Application(reflector: MirrorsReflector());
  var http = PlatformHttp(app);

  // Use dependency injection for ProcessManager
  app.container.registerSingleton(ProcessManager());

  app.get('/', (req, res) async {
    // Use the ioc function to get the ProcessManager instance
    var processManager = await req.container?.make<ProcessManager>();

    var process = await processManager?.start(
      'example_process',
      'echo',
      ['Hello, Angel3 Process!'],
    );
    var result = await process?.run();
    res.writeln('Process output: ${result?.output.trim()}');
  });

  await http.startServer('localhost', 3000);
  print('Server listening at http://localhost:3000');
}
