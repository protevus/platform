/// Interface for notification factory.
abstract class Factory {
  /// Get a channel instance by name.
  dynamic channel([String? name]);

  /// Send the given notification to the given notifiable entities.
  void send(dynamic notifiables, dynamic notification);

  /// Send the given notification immediately.
  void sendNow(dynamic notifiables, dynamic notification);
}
