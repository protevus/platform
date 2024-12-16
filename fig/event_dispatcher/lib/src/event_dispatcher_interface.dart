/// Interface for event dispatchers.
abstract class EventDispatcherInterface {
  /// Provides all relevant listeners with an event to process.
  ///
  /// [event] The object to process.
  ///
  /// Returns the Event that was passed, now modified by listeners.
  ///
  /// The dispatcher should invoke each listener with the supplied event.
  /// If a listener returns an Event object, that object should replace the one
  /// passed to other listeners.
  ///
  /// The function MUST return an event object, which MAY be the same as the
  /// event passed or MAY be a new Event object.
  Object dispatch(Object event);
}
