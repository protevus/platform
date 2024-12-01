/// Interface for queued mail sending.
abstract class MailQueue {
  /// Queue a new e-mail message for sending.
  dynamic queue(dynamic view, [String? queue]);

  /// Queue a new e-mail message for sending after (n) seconds.
  dynamic later(dynamic delay, dynamic view, [String? queue]);
}
