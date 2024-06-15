import 'dart:async';

typedef Closure = FutureOr<dynamic> Function();

abstract class PasswordBroker {
  /// Constant representing a successfully sent reminder.
  static const String RESET_LINK_SENT = 'passwords.sent';

  /// Constant representing a successfully reset password.
  static const String PASSWORD_RESET = 'passwords.reset';

  /// Constant representing the user not found response.
  static const String INVALID_USER = 'passwords.user';

  /// Constant representing an invalid token.
  static const String INVALID_TOKEN = 'passwords.token';

  /// Constant representing a throttled reset attempt.
  static const String RESET_THROTTLED = 'passwords.throttled';

  /// Send a password reset link to a user.
  ///
  /// @param  Map<String, dynamic>  credentials
  /// @param  Closure?  callback
  /// @return Future<String>
  Future<String> sendResetLink(Map<String, dynamic> credentials, [Closure? callback]);

  /// Reset the password for the given token.
  ///
  /// @param  Map<String, dynamic>  credentials
  /// @param  Closure  callback
  /// @return Future<dynamic>
  Future<dynamic> reset(Map<String, dynamic> credentials, Closure callback);
}
