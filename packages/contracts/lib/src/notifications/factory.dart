// Define the namespace (this would be part of the file structure in Dart)
//library illuminate.contracts.notifications;

// TODO: Check imports - Check for way to do namespaces

// Import necessary Dart packages
import 'package:collection/collection.dart';

// Define the Factory interface
abstract class Factory {
  /// Get a channel instance by name.
  ///
  /// @param  String?  name
  /// @return dynamic
  dynamic channel(String? name);

  /// Send the given notification to the given notifiable entities.
  ///
  /// @param  dynamic notifiables
  /// @param  dynamic notification
  /// @return void
  void send(dynamic notifiables, dynamic notification);

  /// Send the given notification immediately.
  ///
  /// @param  dynamic notifiables
  /// @param  dynamic notification
  /// @return void
  void sendNow(dynamic notifiables, dynamic notification);
}
