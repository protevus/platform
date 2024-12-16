import 'mailer.dart';

/// Interface for mail factory.
abstract class MailFactory {
  /// Get a mailer instance by name.
  Mailer mailer([String? name]);
}
