/// Interface for queue management.
abstract class Queue {
  /// Get the size of the queue.
  int size([String? queue]);

  /// Push a new job onto the queue.
  dynamic push(dynamic job, [dynamic data = '', String? queue]);

  /// Push a new job onto the queue.
  dynamic pushOn(String queue, dynamic job, [dynamic data = '']);

  /// Push a raw payload onto the queue.
  dynamic pushRaw(String payload,
      [String? queue, Map<String, dynamic> options = const {}]);

  /// Push a new job onto the queue after (n) seconds.
  dynamic later(dynamic delay, dynamic job, [dynamic data = '', String? queue]);

  /// Push a new job onto a specific queue after (n) seconds.
  dynamic laterOn(String queue, dynamic delay, dynamic job,
      [dynamic data = '']);

  /// Push an array of jobs onto the queue.
  dynamic bulk(List<dynamic> jobs, [dynamic data = '', String? queue]);

  /// Pop the next job off of the queue.
  dynamic pop([String? queue]);

  /// Get the connection name for the queue.
  String getConnectionName();

  /// Set the connection name for the queue.
  Queue setConnectionName(String name);
}
