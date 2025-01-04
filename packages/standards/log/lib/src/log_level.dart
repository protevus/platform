/// Standard logging levels.
///
/// These log levels are derived from the BSD syslog protocol levels, which are
/// described in RFC 5424.
class LogLevel {
  /// System is unusable.
  static const String emergency = 'emergency';

  /// Action must be taken immediately.
  ///
  /// Example: Entire website down, database unavailable, etc.
  static const String alert = 'alert';

  /// Critical conditions.
  ///
  /// Example: Application component unavailable, unexpected exception.
  static const String critical = 'critical';

  /// Runtime errors that do not require immediate action but should be logged
  /// and monitored.
  static const String error = 'error';

  /// Exceptional occurrences that are not errors.
  ///
  /// Example: Use of deprecated APIs, poor use of an API, undesirable things
  /// that are not necessarily wrong.
  static const String warning = 'warning';

  /// Normal but significant events.
  static const String notice = 'notice';

  /// Interesting events.
  ///
  /// Example: User logs in, SQL logs.
  static const String info = 'info';

  /// Detailed debug information.
  static const String debug = 'debug';

  /// List of all valid log levels.
  static const List<String> validLevels = [
    emergency,
    alert,
    critical,
    error,
    warning,
    notice,
    info,
    debug,
  ];
}
