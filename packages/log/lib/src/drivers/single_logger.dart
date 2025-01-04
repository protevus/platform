import 'dart:io';

import 'package:platform_contracts/src/foundation/application.dart';
import 'package:logging/logging.dart' as logging;

import 'base_logger.dart';

/// A logger that writes to a single file.
class SingleLogger extends BaseLogger {
  /// Creates a new [SingleLogger] instance.
  SingleLogger(ApplicationContract app, Map<String, dynamic> config)
      : super(app, config) {
    _logger = logging.Logger('single')..level = _parseLevel(getLevel());
  }

  late final logging.Logger _logger;
  IOSink? _sink;

  @override
  void log(String level, Object message,
      [Map<String, dynamic> context = const {}]) {
    final logMessage = StringBuffer()
      ..writeln(DateTime.now().toIso8601String())
      ..writeln('[$level] $message')
      ..writeln(context.isEmpty ? '' : context);

    // Ensure directory exists
    final file = File(getPath());
    file.parent.createSync(recursive: true);

    // Create or get sink
    _sink ??= file.openWrite(
      mode: FileMode.append,
    );

    // Write to file
    _sink!.writeln(logMessage.toString());

    // Flush if locking is enabled
    if (getLocking()) {
      _sink!.flush();
    }

    // Also log to console in development
    if (isLocal) {
      print(logMessage);
    }
  }

  /// Parse the log level string into a [Level].
  logging.Level _parseLevel(String level) {
    return switch (level.toLowerCase()) {
      'emergency' || 'alert' || 'critical' => logging.Level.SHOUT,
      'error' => logging.Level.SEVERE,
      'warning' => logging.Level.WARNING,
      'notice' || 'info' => logging.Level.INFO,
      'debug' => logging.Level.FINE,
      _ => logging.Level.INFO,
    };
  }

  /// Close the log file.
  Future<void> close() async {
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
  }
}
