/// Interface for objects that can be authenticated.
///
/// This contract defines the methods that an authenticatable entity
/// (like a User model) must implement to work with the authentication system.
abstract class Authenticatable {
  /// Get the name of the unique identifier for the user.
  ///
  /// Example:
  /// ```dart
  /// class User implements Authenticatable {
  ///   @override
  ///   String getAuthIdentifierName() => 'id';
  /// }
  /// ```
  String getAuthIdentifierName();

  /// Get the unique identifier for the user.
  ///
  /// Example:
  /// ```dart
  /// class User implements Authenticatable {
  ///   @override
  ///   dynamic getAuthIdentifier() => id;
  /// }
  /// ```
  dynamic getAuthIdentifier();

  /// Get the name of the password attribute for the user.
  ///
  /// Example:
  /// ```dart
  /// class User implements Authenticatable {
  ///   @override
  ///   String getAuthPasswordName() => 'password';
  /// }
  /// ```
  String getAuthPasswordName();

  /// Get the password for the user.
  ///
  /// Example:
  /// ```dart
  /// class User implements Authenticatable {
  ///   @override
  ///   String? getAuthPassword() => password;
  /// }
  /// ```
  String? getAuthPassword();

  /// Get the "remember me" token value.
  ///
  /// Example:
  /// ```dart
  /// class User implements Authenticatable {
  ///   @override
  ///   String? getRememberToken() => rememberToken;
  /// }
  /// ```
  String? getRememberToken();

  /// Set the "remember me" token value.
  ///
  /// Example:
  /// ```dart
  /// class User implements Authenticatable {
  ///   @override
  ///   void setRememberToken(String? value) {
  ///     rememberToken = value;
  ///   }
  /// }
  /// ```
  void setRememberToken(String? value);

  /// Get the column name for the "remember me" token.
  ///
  /// Example:
  /// ```dart
  /// class User implements Authenticatable {
  ///   @override
  ///   String getRememberTokenName() => 'remember_token';
  /// }
  /// ```
  String getRememberTokenName();
}
