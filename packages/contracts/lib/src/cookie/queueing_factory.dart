import 'cookie_factory.dart';

/// Interface for queueing cookie factory.
abstract class QueueingFactory extends CookieFactory {
  /// Queue a cookie to send with the next response.
  void queue(String name, String value,
      [Map<String, dynamic> options = const {}]);

  /// Remove a cookie from the queue.
  void unqueue(String name);

  /// Get the queued cookies.
  Map<String, dynamic> getQueuedCookies();
}
