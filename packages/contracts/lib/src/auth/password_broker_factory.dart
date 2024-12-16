import 'password_broker.dart';

/// Interface for creating password broker instances.
///
/// This contract defines how password broker instances should be created
/// and managed, allowing for multiple password broker configurations.
abstract class PasswordBrokerFactory {
  /// Get a password broker instance by name.
  ///
  /// Example:
  /// ```dart
  /// // Get the default broker
  /// var broker = factory.broker();
  ///
  /// // Get a specific broker
  /// var adminBroker = factory.broker('admins');
  ///
  /// var status = await broker.sendResetLink({
  ///   'email': 'user@example.com'
  /// });
  /// ```
  PasswordBroker broker([String? name]);
}
