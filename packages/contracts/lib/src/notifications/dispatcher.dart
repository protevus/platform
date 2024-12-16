/// Interface for notification dispatching.
abstract class Dispatcher {
  /// Send the given notification to the given notifiable entities.
  void send(dynamic notifiables, dynamic notification);

  /// Send the given notification immediately.
  void sendNow(dynamic notifiables, dynamic notification,
      [List<String>? channels]);
}
