abstract class Dispatcher {
  /// Send the given notification to the given notifiable entities.
  ///
  /// @param  List<dynamic>|dynamic  notifiables
  /// @param  dynamic  notification
  /// @return void
  void send(dynamic notifiables, dynamic notification);

  /// Send the given notification immediately.
  ///
  /// @param  List<dynamic>|dynamic  notifiables
  /// @param  dynamic  notification
  /// @param  List<String>?  channels
  /// @return void
  void sendNow(dynamic notifiables, dynamic notification, List<String>? channels);
}
