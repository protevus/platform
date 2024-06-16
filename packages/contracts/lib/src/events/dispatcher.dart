abstract class Dispatcher {
  /// Register an event listener with the dispatcher.
  ///
  /// @param  Closure|string|array  events
  /// @param  Closure|string|array|null  listener
  /// @return void
  void listen(dynamic events, [dynamic listener]);

  /// Determine if a given event has listeners.
  ///
  /// @param  string  eventName
  /// @return bool
  bool hasListeners(String eventName);

  /// Register an event subscriber with the dispatcher.
  ///
  /// @param  object|string  subscriber
  /// @return void
  void subscribe(dynamic subscriber);

  /// Dispatch an event until the first non-null response is returned.
  ///
  /// @param  string|object  event
  /// @param  mixed  payload
  /// @return mixed
  dynamic until(dynamic event, [dynamic payload]);

  /// Dispatch an event and call the listeners.
  ///
  /// @param  string|object  event
  /// @param  mixed  payload
  /// @param  bool  halt
  /// @return List<dynamic>|null
  List<dynamic>? dispatch(dynamic event, [dynamic payload, bool halt = false]);

  /// Register an event and payload to be fired later.
  ///
  /// @param  string  event
  /// @param  array  payload
  /// @return void
  void push(String event, [List<dynamic>? payload]);

  /// Flush a set of pushed events.
  ///
  /// @param  string  event
  /// @return void
  void flush(String event);

  /// Remove a set of listeners from the dispatcher.
  ///
  /// @param  string  event
  /// @return void
  void forget(String event);

  /// Forget all of the queued listeners.
  ///
  /// @return void
  void forgetPushed();
}
