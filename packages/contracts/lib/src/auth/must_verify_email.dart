abstract class MustVerifyEmail {
  /// Determine if the user has verified their email address.
  ///
  /// @return bool
  bool hasVerifiedEmail();

  /// Mark the given user's email as verified.
  ///
  /// @return bool
  bool markEmailAsVerified();

  /// Send the email verification notification.
  ///
  /// @return void
  void sendEmailVerificationNotification();

  /// Get the email address that should be used for verification.
  ///
  /// @return string
  String getEmailForVerification();
}
