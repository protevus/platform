import 'password_broker.dart';

abstract class PasswordBrokerFactory {
  /// Get a password broker instance by name.
  ///
  /// @param String? name
  /// @return PasswordBroker
  PasswordBroker broker([String? name]);
}
