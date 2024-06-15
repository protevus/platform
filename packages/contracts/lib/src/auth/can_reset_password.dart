abstract class CanResetPassword {
  /// Get the e-mail address where password reset links are sent.
  ///
  /// @return string
  String getEmailForPasswordReset();

  /// Send the password reset notification.
  ///
  /// @param  string  token
  /// @return void
  void sendPasswordResetNotification(String token);
}
