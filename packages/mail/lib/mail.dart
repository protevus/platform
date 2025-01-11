/// The Mail Package for the Protevus Platform.
///
/// This package provides a robust email sending solution with support for multiple
/// drivers (SMTP, Mailgun, etc.), templating, and queued email delivery.
library mail;

export 'src/mail_manager.dart';
export 'src/mailable.dart';
export 'src/mail_driver.dart';
export 'src/drivers/smtp_driver.dart';
export 'src/drivers/mailgun_driver.dart';
export 'src/drivers/log_driver.dart';
export 'src/exceptions.dart';
export 'src/attachment.dart';
export 'src/address.dart';
