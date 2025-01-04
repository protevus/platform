import 'dart:io';

import 'package:platform_contracts/src/foundation/application.dart';
import 'package:logging/logging.dart' as logging;

import 'base_logger.dart';

/// A logger that writes to a file in emergency situations.
class EmergencyLogger extends BaseLogger {
  /// Creates a new [EmergencyLogger] instance.
  EmergencyLogger(ApplicationContract app, String path)
      : _path = path,
        super(app, {'path': path, 'level': 'debug'});

  final String _path;
  final _logger = logging.Logger('emergency');

  @override
  void log(String level, Object message,
      [Map<String, dynamic> context = const {}]) {
    final logMessage = StringBuffer()
      ..writeln(DateTime.now().toIso8601String())
      ..writeln('[$level] $message')
      ..writeln(context.isEmpty ? '' : context);

    // Ensure directory exists
    final file = File(_path);
    file.parent.createSync(recursive: true);

    // Append to file
    file.writeAsStringSync(
      '${logMessage.toString()}\n',
      mode: FileMode.append,
      flush: true,
    );

    // Also log to console in development
    if (isLocal) {
      print(logMessage);
    }
  }
}
