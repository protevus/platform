// examples/process_pool/main.dart
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

  // Register ProcessManager as a singleton in the container
  app.container.registerSingleton(ProcessManager());

  app.get('/', (req, res) async {
    // Use dependency injection to get the ProcessManager instance
    var processManager = await req.container?.make<ProcessManager>();

    var processes =
        List.generate(5, (index) => angel3Process('echo', ['Process $index']));
    var results = await processManager?.pool(processes, concurrency: 3);
    var output = results
        ?.map((result) =>
            '${result.process.command} output: ${result.output.trim()}')
        .join('\n');
    res.write(output);
  });

  await http.startServer('localhost', 3000);
  print('Server listening at http://localhost:3000');
}
