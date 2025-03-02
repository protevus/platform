import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:illuminate_console/console.dart';
import 'package:path/path.dart' as path;
import 'package:watcher/watcher.dart';

/// Command to serve the application with hot reload.
class ServeCommand extends Command {
  @override
  String get name => 'serve';

  @override
  String get description => 'Serve the application with hot reload';

  @override
  String get signature => 'serve';

  Future<Process> _startServer([String? message]) async {
    if (message != null) {
      output.info('$message..');
    }
    Process process = await Process.start('dart', ['run', 'bin/server.dart']);

    process.stdout.transform(utf8.decoder).listen((data) {
      final lines = data.split('\n');
      for (final line in lines) {
        if (line.isNotEmpty) {
          output.writeln(line);
        }
      }
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      final lines = data.split('\n');
      for (final line in lines) {
        if (line.isNotEmpty) {
          output.error(line);
        }
      }
    });

    return process;
  }

  @override
  Future<void> handle() async {
    final watcher = DirectoryWatcher(Directory.current.path);
    Timer? timer;
    Process? process;

    process = await _startServer();

    watcher.events.listen((event) async {
      if (path.extension(event.path) != '.dart') {
        return;
      }
      output.info('File changed: ${path.basename(event.path)}');

      timer?.cancel();
      timer = Timer(Duration(milliseconds: 500), () async {
        process?.kill();
        final exitCode = await process?.exitCode;
        if (exitCode.toString().isNotEmpty) {
          process = await _startServer('Restarting server');
        }
      });
    });

    // Keep the command running
    await Completer<void>().future;
  }
}
