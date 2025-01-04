import 'package:dsr_log/log.dart';
import 'package:platform_contracts/contracts.dart';
import 'package:platform_support/platform_support.dart';

import 'events/message_logged.dart';

/// A logger implementation that wraps a PSR-3 style logger.
class Logger implements LoggerInterface {
  /// Creates a new [Logger] instance.
  Logger(this._logger, this._dispatcher);

  final LoggerInterface _logger;
  final EventDispatcherContract? _dispatcher;
  final Map<String, dynamic> _context = {};

  /// Add context to all future logs.
  Logger withContext(Map<String, dynamic> context) {
    _context.addAll(context);
    return this;
  }

  /// Flush the existing context array.
  Logger withoutContext() {
    _context.clear();
    return this;
  }

  /// Register a new callback handler for when a log event is triggered.
  void listen(void Function(MessageLogged event) callback) {
    if (_dispatcher == null) {
      throw StateError('Events dispatcher has not been set.');
    }

    _dispatcher!.listen(MessageLogged, callback);
  }

  /// Get the underlying logger implementation.
  LoggerInterface getLogger() => _logger;

  /// Get the event dispatcher instance.
  EventDispatcherContract? getEventDispatcher() => _dispatcher;

  @override
  void emergency(Object message, [Map<String, dynamic> context = const {}]) {
    _writeLog('emergency', message, context);
  }

  @override
  void alert(Object message, [Map<String, dynamic> context = const {}]) {
    _writeLog('alert', message, context);
  }

  @override
  void critical(Object message, [Map<String, dynamic> context = const {}]) {
    _writeLog('critical', message, context);
  }

  @override
  void error(Object message, [Map<String, dynamic> context = const {}]) {
    _writeLog('error', message, context);
  }

  @override
  void warning(Object message, [Map<String, dynamic> context = const {}]) {
    _writeLog('warning', message, context);
  }

  @override
  void notice(Object message, [Map<String, dynamic> context = const {}]) {
    _writeLog('notice', message, context);
  }

  @override
  void info(Object message, [Map<String, dynamic> context = const {}]) {
    _writeLog('info', message, context);
  }

  @override
  void debug(Object message, [Map<String, dynamic> context = const {}]) {
    _writeLog('debug', message, context);
  }

  @override
  void log(String level, Object message,
      [Map<String, dynamic> context = const {}]) {
    _writeLog(level, message, context);
  }

  /// Write a message to the log.
  void _writeLog(String level, Object message, Map<String, dynamic> context) {
    final formattedMessage = _formatMessage(message);
    final mergedContext = {..._context, ...context};

    _logger.log(level, formattedMessage, mergedContext);
    _fireLogEvent(level, formattedMessage, mergedContext);
  }

  /// Format the message for logging.
  String _formatMessage(Object message) {
    if (message is Map) {
      return message.toString();
    } else if (message is Jsonable) {
      return message.toJson();
    } else if (message is Arrayable) {
      return message.toArray().toString();
    }

    return message.toString();
  }

  /// Fire a log event.
  void _fireLogEvent(
      String level, String message, Map<String, dynamic> context) {
    _dispatcher?.dispatch(MessageLogged(level, message, context: context));
  }
}
