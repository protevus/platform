import 'package:platform_contracts/src/foundation/application.dart';
import 'package:logging/logging.dart' as logging;

import '../logger.dart';
import 'base_logger.dart';

/// A logger that combines multiple loggers into one.
class StackLogger extends BaseLogger {
  /// Creates a new [StackLogger] instance.
  StackLogger(
    ApplicationContract app,
    Map<String, dynamic> config,
    List<Logger> handlers,
  )   : _handlers = handlers,
        super(app, config) {
    _logger = logging.Logger('stack')..level = _parseLevel(getLevel());
  }

  final List<Logger> _handlers;
  late final logging.Logger _logger;

  @override
  void log(String level, Object message,
      [Map<String, dynamic> context = const {}]) {
    // Forward to all handlers
    for (final handler in _handlers) {
      handler.log(level, message, context);
    }

    // Also log to console in development
    if (isLocal) {
      print('[$level] $message ${context.isEmpty ? '' : context}');
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
}
