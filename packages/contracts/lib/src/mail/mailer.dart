abstract class Mailer {
  /// Begin the process of mailing a mailable class instance.
  ///
  /// [users] can be of any type.
  /// Returns a PendingMail instance.
  PendingMail to(dynamic users);

  /// Begin the process of mailing a mailable class instance.
  ///
  /// [users] can be of any type.
  /// Returns a PendingMail instance.
  PendingMail bcc(dynamic users);

  /// Send a new message with only a raw text part.
  ///
  /// [text] is the raw text message.
  /// [callback] can be of any type.
  /// Returns a SentMessage instance or null.
  SentMessage? raw(String text, dynamic callback);

  /// Send a new message using a view.
  ///
  /// [view] can be of type Mailable, String, or List.
  /// [data] is a map of data to pass to the view.
  /// [callback] is a function or null.
  /// Returns a SentMessage instance or null.
  SentMessage? send(dynamic view, {Map<String, dynamic> data = const {}, dynamic callback});

  /// Send a new message synchronously using a view.
  ///
  /// [mailable] can be of type Mailable, String, or List.
  /// [data] is a map of data to pass to the view.
  /// [callback] is a function or null.
  /// Returns a SentMessage instance or null.
  SentMessage? sendNow(dynamic mailable, {Map<String, dynamic> data = const {}, dynamic callback});
}

class PendingMail {
  // Implementation of PendingMail class
}

class SentMessage {
  // Implementation of SentMessage class
}
