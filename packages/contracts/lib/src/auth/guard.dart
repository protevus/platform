import 'authenticatable.dart';

/// Interface for authentication guards.
///
/// This contract defines the methods that an authentication guard must implement
/// to provide user authentication functionality.
abstract class Guard {
  /// Determine if the current user is authenticated.
  ///
  /// Example:
  /// ```dart
  /// if (guard.check()) {
  ///   print('User is authenticated');
  /// }
  /// ```
  bool check();

  /// Determine if the current user is a guest.
  ///
  /// Example:
  /// ```dart
  /// if (guard.guest()) {
  ///   print('User is not authenticated');
  /// }
  /// ```
  bool guest();

  /// Get the currently authenticated user.
  ///
  /// Example:
  /// ```dart
  /// var user = guard.user();
  /// if (user != null) {
  ///   print('Hello ${user.name}');
  /// }
  /// ```
  Authenticatable? user();

  /// Get the ID for the currently authenticated user.
  ///
  /// Example:
  /// ```dart
  /// var userId = guard.id();
  /// if (userId != null) {
  ///   print('User ID: $userId');
  /// }
  /// ```
  dynamic id();

  /// Validate a user's credentials.
  ///
  /// Example:
  /// ```dart
  /// var credentials = {
  ///   'email': 'user@example.com',
  ///   'password': 'password123'
  /// };
  /// if (guard.validate(credentials)) {
  ///   print('Credentials are valid');
  /// }
  /// ```
  bool validate([Map<String, dynamic> credentials = const {}]);

  /// Determine if the guard has a user instance.
  ///
  /// Example:
  /// ```dart
  /// if (guard.hasUser()) {
  ///   print('Guard has a user instance');
  /// }
  /// ```
  bool hasUser();

  /// Set the current user.
  ///
  /// Example:
  /// ```dart
  /// guard.setUser(user);
  /// ```
  Guard setUser(Authenticatable user);
}
