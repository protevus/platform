import 'logger_interface.dart';

/// Describes a logger-aware instance.
abstract class LoggerAwareInterface {
  /// Sets a logger instance on the object.
  ///
  /// [logger] The logger to set.
  void setLogger(LoggerInterface logger);
}
