import 'dart:convert';
import 'dart:io';
import 'package:illuminate_console/console.dart';

/// Command to update the Illuminate CLI tool.
class UpdateCommand extends Command {
  @override
  String get name => 'update';

  @override
  String get description => 'Update the Illuminate CLI tool';

  @override
  String get signature => 'update';

  @override
  Future<void> handle() async {
    final process = await Process.start(
        'dart', ['pub', 'global', 'activate', 'illuminate']);

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

    await process.exitCode;
  }
}
