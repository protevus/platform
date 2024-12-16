import 'log_level.dart';

/// Exception thrown if an invalid level is passed to a logger method.
class InvalidArgumentException implements Exception {
  final String message;

  InvalidArgumentException(this.message);

  @override
  String toString() => 'InvalidArgumentException: $message';
}

/// Describes a logger instance.
///
/// The message MUST be a string or object implementing toString().
///
/// The context array can contain any extraneous information that does not fit well
/// in a string. The context array can contain anything, but implementors MUST
/// ensure they treat context data with as much lenience as possible.
abstract class LoggerInterface {
  /// System is unusable.
  void emergency(Object message, [Map<String, dynamic> context = const {}]);

  /// Action must be taken immediately.
  ///
  /// Example: Entire website down, database unavailable, etc.
  void alert(Object message, [Map<String, dynamic> context = const {}]);

  /// Critical conditions.
  ///
  /// Example: Application component unavailable, unexpected exception.
  void critical(Object message, [Map<String, dynamic> context = const {}]);

  /// Runtime errors that do not require immediate action but should be logged
  /// and monitored.
  void error(Object message, [Map<String, dynamic> context = const {}]);

  /// Exceptional occurrences that are not errors.
  ///
  /// Example: Use of deprecated APIs, poor use of an API, undesirable things
  /// that are not necessarily wrong.
  void warning(Object message, [Map<String, dynamic> context = const {}]);

  /// Normal but significant events.
  void notice(Object message, [Map<String, dynamic> context = const {}]);

  /// Interesting events.
  ///
  /// Example: User logs in, SQL logs.
  void info(Object message, [Map<String, dynamic> context = const {}]);

  /// Detailed debug information.
  void debug(Object message, [Map<String, dynamic> context = const {}]);

  /// Logs with an arbitrary level.
  ///
  /// [level] The log level. Must be one of the LogLevel constants.
  /// [message] The log message.
  /// [context] Additional context data.
  ///
  /// Throws [InvalidArgumentException] if level is not valid.
  void log(String level, Object message,
      [Map<String, dynamic> context = const {}]) {
    if (!LogLevel.validLevels.contains(level)) {
      throw InvalidArgumentException(
          'Level "$level" is not valid. Valid levels are: ${LogLevel.validLevels.join(', ')}');
    }
  }
}
