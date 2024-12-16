/// Interface for queue monitoring.
abstract class Monitor {
  /// Register a callback to be executed on every iteration through the queue loop.
  void looping(dynamic callback);

  /// Register a callback to be executed when a job fails after the maximum number of retries.
  void failing(dynamic callback);

  /// Register a callback to be executed when a daemon queue is stopping.
  void stopping(dynamic callback);
}
