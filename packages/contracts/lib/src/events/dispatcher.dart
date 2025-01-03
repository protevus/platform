/// Interface for event dispatching.
abstract class EventDispatcherContract {
  /// Register an event listener with the dispatcher.
  void listen(dynamic events, [dynamic listener]);

  /// Determine if a given event has listeners.
  bool hasListeners(String eventName);

  /// Register an event subscriber with the dispatcher.
  void subscribe(dynamic subscriber);

  /// Dispatch an event until the first non-null response is returned.
  dynamic until(dynamic event, [dynamic payload = const []]);

  /// Dispatch an event and call the listeners.
  List<dynamic>? dispatch(dynamic event,
      [dynamic payload = const [], bool halt = false]);

  /// Register an event and payload to be fired later.
  void push(String event, [List<dynamic> payload = const []]);

  /// Flush a set of pushed events.
  void flush(String event);

  /// Remove a set of listeners from the dispatcher.
  void forget(String event);

  /// Forget all of the queued listeners.
  void forgetPushed();
}
