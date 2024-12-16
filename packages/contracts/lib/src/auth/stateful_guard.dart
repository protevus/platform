import 'authenticatable.dart';
import 'guard.dart';

/// Interface for stateful authentication guards.
///
/// This contract extends the base Guard interface to add methods for
/// maintaining authentication state, such as login/logout functionality
/// and "remember me" capabilities.
abstract class StatefulGuard implements Guard {
  /// Attempt to authenticate a user using the given credentials.
  ///
  /// Example:
  /// ```dart
  /// var credentials = {
  ///   'email': 'user@example.com',
  ///   'password': 'password123'
  /// };
  /// if (await guard.attempt(credentials, remember: true)) {
  ///   // User is authenticated and will be remembered
  /// }
  /// ```
  Future<bool> attempt([
    Map<String, dynamic> credentials = const {},
    bool remember = false,
  ]);

  /// Log a user into the application without sessions or cookies.
  ///
  /// Example:
  /// ```dart
  /// var credentials = {
  ///   'email': 'user@example.com',
  ///   'password': 'password123'
  /// };
  /// if (await guard.once(credentials)) {
  ///   // User is authenticated for this request only
  /// }
  /// ```
  Future<bool> once([Map<String, dynamic> credentials = const {}]);

  /// Log a user into the application.
  ///
  /// Example:
  /// ```dart
  /// await guard.login(user, remember: true);
  /// ```
  Future<void> login(Authenticatable user, [bool remember = false]);

  /// Log the given user ID into the application.
  ///
  /// Example:
  /// ```dart
  /// var user = await guard.loginUsingId(1, remember: true);
  /// if (user != null) {
  ///   // User was logged in successfully
  /// }
  /// ```
  Future<Authenticatable?> loginUsingId(dynamic id, [bool remember = false]);

  /// Log the given user ID into the application without sessions or cookies.
  ///
  /// Example:
  /// ```dart
  /// var user = await guard.onceUsingId(1);
  /// if (user != null) {
  ///   // User was logged in for this request only
  /// }
  /// ```
  Future<Authenticatable?> onceUsingId(dynamic id);

  /// Determine if the user was authenticated via "remember me" cookie.
  ///
  /// Example:
  /// ```dart
  /// if (guard.viaRemember()) {
  ///   // User was authenticated using remember me cookie
  /// }
  /// ```
  bool viaRemember();

  /// Log the user out of the application.
  ///
  /// Example:
  /// ```dart
  /// await guard.logout();
  /// ```
  Future<void> logout();
}
