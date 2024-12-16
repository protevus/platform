/// Interface for password reset functionality.
///
/// This contract defines how password reset functionality should be handled
/// for users that can reset their passwords. It provides methods for getting
/// the email address for password resets and sending reset notifications.
abstract class CanResetPassword {
  /// Get the e-mail address where password reset links are sent.
  ///
  /// Example:
  /// ```dart
  /// class User implements CanResetPassword {
  ///   @override
  ///   String getEmailForPasswordReset() => email;
  /// }
  /// ```
  String getEmailForPasswordReset();

  /// Send the password reset notification.
  ///
  /// Example:
  /// ```dart
  /// class User implements CanResetPassword {
  ///   @override
  ///   Future<void> sendPasswordResetNotification(String token) async {
  ///     await notificationService.send(
  ///       PasswordResetNotification(
  ///         user: this,
  ///         token: token,
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  Future<void> sendPasswordResetNotification(String token);
}
