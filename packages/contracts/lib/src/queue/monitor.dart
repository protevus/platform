abstract class Monitor {
  /// Register a callback to be executed on every iteration through the queue loop.
  ///
  /// @param  Function callback
  /// @return void
  void looping(Function callback);

  /// Register a callback to be executed when a job fails after the maximum number of retries.
  ///
  /// @param  Function callback
  /// @return void
  void failing(Function callback);

  /// Register a callback to be executed when a daemon queue is stopping.
  ///
  /// @param  Function callback
  /// @return void
  void stopping(Function callback);
}
