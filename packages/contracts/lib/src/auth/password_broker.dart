/// Interface for password reset functionality.
///
/// This contract defines how password reset operations should be handled,
/// including sending reset links and performing password resets.
abstract class PasswordBroker {
  /// Constant representing a successfully sent reminder.
  static const String resetLinkSent = 'passwords.sent';

  /// Constant representing a successfully reset password.
  static const String passwordReset = 'passwords.reset';

  /// Constant representing the user not found response.
  static const String invalidUser = 'passwords.user';

  /// Constant representing an invalid token.
  static const String invalidToken = 'passwords.token';

  /// Constant representing a throttled reset attempt.
  static const String resetThrottled = 'passwords.throttled';

  /// Send a password reset link to a user.
  ///
  /// Example:
  /// ```dart
  /// var credentials = {'email': 'user@example.com'};
  /// var status = await broker.sendResetLink(
  ///   credentials,
  ///   (user) async {
  ///     // Custom notification logic
  ///   },
  /// );
  ///
  /// if (status == PasswordBroker.resetLinkSent) {
  ///   // Reset link was sent successfully
  /// }
  /// ```
  Future<String> sendResetLink(
    Map<String, dynamic> credentials, [
    void Function(dynamic user)? callback,
  ]);

  /// Reset the password for the given token.
  ///
  /// Example:
  /// ```dart
  /// var credentials = {
  ///   'email': 'user@example.com',
  ///   'password': 'newpassword',
  ///   'token': 'reset-token'
  /// };
  ///
  /// var status = await broker.reset(
  ///   credentials,
  ///   (user) async {
  ///     // Set the new password
  ///     await user.setPassword(credentials['password']);
  ///     await user.save();
  ///   },
  /// );
  ///
  /// if (status == PasswordBroker.passwordReset) {
  ///   // Password was reset successfully
  /// }
  /// ```
  Future<String> reset(
    Map<String, dynamic> credentials,
    void Function(dynamic user) callback,
  );
}
