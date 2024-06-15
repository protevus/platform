abstract class ShouldBroadcast {
  /// Get the channels the event should broadcast on.
  ///
  /// Returns either a single channel or a list of channels.
  dynamic broadcastOn();
}
