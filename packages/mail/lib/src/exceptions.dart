/// Base class for all mail-related exceptions.
abstract class MailException implements Exception {
  /// A message describing the error.
  final String message;

  /// The original error that caused this exception, if any.
  final Object? cause;

  /// Creates a new mail exception.
  const MailException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return '$runtimeType: $message\nCaused by: $cause';
    }
    return '$runtimeType: $message';
  }
}

/// Thrown when there is a configuration error.
class MailConfigException extends MailException {
  const MailConfigException(super.message, [super.cause]);
}

/// Thrown when there is an error with the mail driver.
class MailDriverException extends MailException {
  const MailDriverException(super.message, [super.cause]);
}

/// Thrown when there is an error sending an email.
class MailSendException extends MailException {
  /// The email address(es) that failed, if applicable.
  final List<String>? failedRecipients;

  const MailSendException(
    String message, {
    this.failedRecipients,
    Object? cause,
  }) : super(message, cause);

  @override
  String toString() {
    if (failedRecipients != null && failedRecipients!.isNotEmpty) {
      return '${super.toString()}\nFailed recipients: ${failedRecipients!.join(", ")}';
    }
    return super.toString();
  }
}

/// Thrown when there is an error with email content or formatting.
class MailFormatException extends MailException {
  const MailFormatException(super.message, [super.cause]);
}

/// Thrown when there is an error with email templates.
class MailTemplateException extends MailException {
  const MailTemplateException(super.message, [super.cause]);
}

/// Thrown when an operation times out.
class MailTimeoutException extends MailException {
  /// The duration after which the operation timed out.
  final Duration? timeout;

  const MailTimeoutException(
    String message, {
    this.timeout,
    Object? cause,
  }) : super(message, cause);

  @override
  String toString() {
    if (timeout != null) {
      return '${super.toString()}\nTimeout: ${timeout!.inSeconds} seconds';
    }
    return super.toString();
  }
}

/// Thrown when there is an authentication error.
class MailAuthException extends MailException {
  const MailAuthException(super.message, [super.cause]);
}

/// Thrown when there is a rate limit error.
class MailRateLimitException extends MailException {
  /// The time after which the operation can be retried.
  final Duration? retryAfter;

  const MailRateLimitException(
    String message, {
    this.retryAfter,
    Object? cause,
  }) : super(message, cause);

  @override
  String toString() {
    if (retryAfter != null) {
      return '${super.toString()}\nRetry after: ${retryAfter!.inSeconds} seconds';
    }
    return super.toString();
  }
}
