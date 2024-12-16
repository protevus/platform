/// Interface for email verification functionality.
///
/// This contract defines how email verification should be handled for users
/// that require email verification. It provides methods for checking and
/// updating verification status, as well as sending verification notifications.
abstract class MustVerifyEmail {
  /// Determine if the user has verified their email address.
  ///
  /// Example:
  /// ```dart
  /// class User implements MustVerifyEmail {
  ///   @override
  ///   bool hasVerifiedEmail() {
  ///     return emailVerifiedAt != null;
  ///   }
  /// }
  /// ```
  bool hasVerifiedEmail();

  /// Mark the given user's email as verified.
  ///
  /// Example:
  /// ```dart
  /// class User implements MustVerifyEmail {
  ///   @override
  ///   Future<bool> markEmailAsVerified() async {
  ///     emailVerifiedAt = DateTime.now();
  ///     await save();
  ///     return true;
  ///   }
  /// }
  /// ```
  Future<bool> markEmailAsVerified();

  /// Send the email verification notification.
  ///
  /// Example:
  /// ```dart
  /// class User implements MustVerifyEmail {
  ///   @override
  ///   Future<void> sendEmailVerificationNotification() async {
  ///     await notificationService.send(
  ///       EmailVerificationNotification(user: this),
  ///     );
  ///   }
  /// }
  /// ```
  Future<void> sendEmailVerificationNotification();

  /// Get the email address that should be used for verification.
  ///
  /// Example:
  /// ```dart
  /// class User implements MustVerifyEmail {
  ///   @override
  ///   String getEmailForVerification() => email;
  /// }
  /// ```
  String getEmailForVerification();
}
