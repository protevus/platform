/// Interface for event listener providers.
abstract class ListenerProviderInterface {
  /// Gets the listeners for a specific event.
  ///
  /// [event] An event for which to return the relevant listeners.
  /// Returns an iterable of callables that can handle the event.
  ///
  /// Each callable MUST be type-compatible with the event.
  /// Each callable MUST accept a single parameter: the event.
  /// Each callable SHOULD have a void return type.
  /// Each callable MAY be an instance of a class that implements __invoke().
  Iterable<Function> getListenersForEvent(Object event);
}
