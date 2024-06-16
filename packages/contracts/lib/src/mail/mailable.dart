import 'package:some_package/queue.dart'; // Replace with actual queue package
import 'package:some_package/mail.dart'; // Replace with actual mail package

// TODO: Check Imports.

abstract class Mailable {
  /// Send the message using the given mailer.
  ///
  /// @param  Factory|Mailer  $mailer
  /// @return SentMessage|null
  Future<SentMessage?> send(Mailer mailer);

  /// Queue the given message.
  ///
  /// @param  Queue  $queue
  /// @return dynamic
  Future<dynamic> queue(Queue queue);

  /// Deliver the queued message after (n) seconds.
  ///
  /// @param  DateTimeInterface|Duration|int  $delay
  /// @param  Queue  $queue
  /// @return dynamic
  Future<dynamic> later(dynamic delay, Queue queue);

  /// Set the recipients of the message.
  ///
  /// @param  dynamic  $address
  /// @param  String?  $name
  /// @return self
  Mailable cc(dynamic address, [String? name]);

  /// Set the recipients of the message.
  ///
  /// @param  dynamic  $address
  /// @param  String?  $name
  /// @return $this
  Mailable bcc(dynamic address, [String? name]);

  /// Set the recipients of the message.
  ///
  /// @param  dynamic  $address
  /// @param  String?  $name
  /// @return $this
  Mailable to(dynamic address, [String? name]);

  /// Set the locale of the message.
  ///
  /// @param  String  $locale
  /// @return $this
  Mailable locale(String locale);

  /// Set the name of the mailer that should be used to send the message.
  ///
  /// @param  String  $mailer
  /// @return $this
  Mailable mailer(String mailer);
}
