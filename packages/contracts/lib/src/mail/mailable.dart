/// Interface for mail messages.
abstract class Mailable {
  /// Send the message using the given mailer.
  dynamic send(dynamic mailer);

  /// Queue the given message.
  dynamic queue(dynamic queue);

  /// Deliver the queued message after (n) seconds.
  dynamic later(dynamic delay, dynamic queue);

  /// Set the CC recipients of the message.
  Mailable cc(dynamic address, [String? name]);

  /// Set the BCC recipients of the message.
  Mailable bcc(dynamic address, [String? name]);

  /// Set the recipients of the message.
  Mailable to(dynamic address, [String? name]);

  /// Set the locale of the message.
  Mailable locale(String locale);

  /// Set the name of the mailer that should be used to send the message.
  Mailable mailer(String mailer);
}
