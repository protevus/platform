import 'factory.dart';

abstract class QueueingFactory extends Factory {
  /// Queue a cookie to send with the next response.
  void queue(List<dynamic> parameters);

  /// Remove a cookie from the queue.
  void unqueue(String name, [String? path]);

  /// Get the cookies which have been queued for the next request.
  List<Map<String, dynamic>> getQueuedCookies();
}
