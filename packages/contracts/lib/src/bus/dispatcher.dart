abstract class Dispatcher {
  /// Dispatch a command to its appropriate handler.
  ///
  /// @param  dynamic  command
  /// @return dynamic
  dynamic dispatch(dynamic command);

  /// Dispatch a command to its appropriate handler in the current process.
  ///
  /// Queueable jobs will be dispatched to the "sync" queue.
  ///
  /// @param  dynamic  command
  /// @param  dynamic  handler
  /// @return dynamic
  dynamic dispatchSync(dynamic command, [dynamic handler]);

  /// Dispatch a command to its appropriate handler in the current process.
  ///
  /// @param  dynamic  command
  /// @param  dynamic  handler
  /// @return dynamic
  dynamic dispatchNow(dynamic command, [dynamic handler]);

  /// Determine if the given command has a handler.
  ///
  /// @param  dynamic  command
  /// @return bool
  bool hasCommandHandler(dynamic command);

  /// Retrieve the handler for a command.
  ///
  /// @param  dynamic  command
  /// @return bool|dynamic
  dynamic getCommandHandler(dynamic command);

  /// Set the pipes commands should be piped through before dispatching.
  ///
  /// @param  List<dynamic>  pipes
  /// @return this
  Dispatcher pipeThrough(List<dynamic> pipes);

  /// Map a command to a handler.
  ///
  /// @param  Map<dynamic, dynamic>  map
  /// @return this
  Dispatcher map(Map<dynamic, dynamic> map);
}
