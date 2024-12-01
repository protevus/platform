/// Interface for mail sending.
abstract class Mailer {
  /// Begin the process of mailing a mailable class instance.
  dynamic to(dynamic users);

  /// Begin the process of mailing a mailable class instance.
  dynamic bcc(dynamic users);

  /// Send a new message with only a raw text part.
  dynamic raw(String text, dynamic callback);

  /// Send a new message using a view.
  dynamic send(dynamic view,
      [Map<String, dynamic> data = const {}, dynamic callback]);

  /// Send a new message synchronously using a view.
  dynamic sendNow(dynamic mailable,
      [Map<String, dynamic> data = const {}, dynamic callback]);
}
