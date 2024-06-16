import "job.dart";
abstract class Queue {
  /// Get the size of the queue.
  ///
  /// @param  String? queue
  /// @return int
  int size(String? queue);

  /// Push a new job onto the queue.
  ///
  /// @param  String job
  /// @param  dynamic data
  /// @param  String? queue
  /// @return dynamic
  dynamic push(dynamic job, {dynamic data = '', String? queue});

  /// Push a new job onto the queue.
  ///
  /// @param  String queue
  /// @param  String job
  /// @param  dynamic data
  /// @return dynamic
  dynamic pushOn(String queue, dynamic job, {dynamic data = ''});

  /// Push a raw payload onto the queue.
  ///
  /// @param  String payload
  /// @param  String? queue
  /// @param  Map<String, dynamic> options
  /// @return dynamic
  dynamic pushRaw(String payload, {String? queue, Map<String, dynamic> options = const {}});

  /// Push a new job onto the queue after (n) seconds.
  ///
  /// @param  dynamic delay
  /// @param  dynamic job
  /// @param  dynamic data
  /// @param  String? queue
  /// @return dynamic
  dynamic later(dynamic delay, dynamic job, {dynamic data = '', String? queue});

  /// Push a new job onto a specific queue after (n) seconds.
  ///
  /// @param  String queue
  /// @param  dynamic delay
  /// @param  dynamic job
  /// @param  dynamic data
  /// @return dynamic
  dynamic laterOn(String queue, dynamic delay, dynamic job, {dynamic data = ''});

  /// Push an array of jobs onto the queue.
  ///
  /// @param  List<dynamic> jobs
  /// @param  dynamic data
  /// @param  String? queue
  /// @return dynamic
  dynamic bulk(List<dynamic> jobs, {dynamic data = '', String? queue});

  /// Pop the next job off of the queue.
  ///
  /// @param  String? queue
  /// @return Job?
  Job? pop(String? queue);

  /// Get the connection name for the queue.
  ///
  /// @return String
  String getConnectionName();

  /// Set the connection name for the queue.
  ///
  /// @param  String name
  /// @return this
  Queue setConnectionName(String name);
}
