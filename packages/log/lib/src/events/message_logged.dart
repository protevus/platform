/// An event that is fired when a message is logged.
class MessageLogged {
  /// Creates a new [MessageLogged] event instance.
  const MessageLogged(
    this.level,
    this.message, {
    this.context = const {},
  });

  /// The log level.
  ///
  /// This corresponds to the severity of the log message (e.g., 'debug', 'info',
  /// 'warning', 'error', etc.).
  final String level;

  /// The log message.
  ///
  /// This is the actual content that was logged.
  final String message;

  /// The log context.
  ///
  /// Additional contextual information that was provided with the log message.
  final Map<String, dynamic> context;
}
