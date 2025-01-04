import 'dart:io';

import 'package:platform_contracts/src/foundation/application.dart';
import 'package:logging/logging.dart' as logging;
import 'package:path/path.dart' as path;

import 'base_logger.dart';

/// A logger that creates a new log file each day.
class DailyLogger extends BaseLogger {
  /// Creates a new [DailyLogger] instance.
  DailyLogger(ApplicationContract app, Map<String, dynamic> config)
      : super(app, config) {
    _logger = logging.Logger('daily')..level = _parseLevel(getLevel());
  }

  late final logging.Logger _logger;
  IOSink? _sink;
  DateTime? _currentDate;

  @override
  void log(String level, Object message,
      [Map<String, dynamic> context = const {}]) {
    final now = DateTime.now();
    final logMessage = StringBuffer()
      ..writeln(now.toIso8601String())
      ..writeln('[$level] $message')
      ..writeln(context.isEmpty ? '' : context);

    // Check if we need to rotate the log file
    if (_currentDate?.day != now.day) {
      _rotateLogFile(now);
    }

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

  /// Rotate the log file based on the current date.
  void _rotateLogFile(DateTime date) {
    // Close existing sink if any
    if (_sink != null) {
      _sink!.flush();
      _sink!.close();
      _sink = null;
    }

    // Create new log file for current date
    final basePath = getPath();
    final dir = path.dirname(basePath);
    final ext = path.extension(basePath);
    final basename = path.basenameWithoutExtension(basePath);
    final dateSuffix = date.toIso8601String().split('T')[0];
    final logPath = path.join(dir, '$basename-$dateSuffix$ext');

    // Ensure directory exists
    final file = File(logPath);
    file.parent.createSync(recursive: true);

    // Open new sink
    _sink = file.openWrite(mode: FileMode.append);
    _currentDate = date;

    // Clean old logs if max days is set
    final days = config['days'] as int? ?? 7;
    if (days > 0) {
      _cleanOldLogs(date, days);
    }
  }

  /// Clean old log files beyond the retention period.
  void _cleanOldLogs(DateTime currentDate, int days) {
    final dir = Directory(path.dirname(getPath()));
    if (!dir.existsSync()) return;

    final baseName = path.basenameWithoutExtension(getPath());
    final ext = path.extension(getPath());
    final cutoffDate = currentDate.subtract(Duration(days: days));

    for (final file in dir.listSync()) {
      if (file is! File) continue;

      final fileName = path.basename(file.path);
      if (!fileName.startsWith(baseName) || !fileName.endsWith(ext)) continue;

      // Extract date from filename
      final match = RegExp(r'\d{4}-\d{2}-\d{2}').firstMatch(fileName);
      if (match == null) continue;

      final dateStr = match.group(0)!;
      final fileDate = DateTime.parse(dateStr);

      if (fileDate.isBefore(cutoffDate)) {
        file.deleteSync();
      }
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
