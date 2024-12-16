/// Interface for events that can be stopped from further propagation.
abstract class StoppableEventInterface {
  /// Whether no further event listeners should be triggered.
  ///
  /// Returns true if the event is complete and no further listeners should be called.
  /// Returns false to continue calling listeners.
  bool isPropagationStopped();
}
