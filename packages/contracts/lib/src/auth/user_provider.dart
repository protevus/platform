import 'authenticatable.dart';

/// Interface for retrieving and validating users.
///
/// This contract defines how users should be retrieved from storage
/// and how their credentials should be validated.
abstract class UserProvider {
  /// Retrieve a user by their unique identifier.
  ///
  /// Example:
  /// ```dart
  /// var user = await provider.retrieveById(1);
  /// if (user != null) {
  ///   print('Found user: ${user.getAuthIdentifier()}');
  /// }
  /// ```
  Future<Authenticatable?> retrieveById(dynamic identifier);

  /// Retrieve a user by their unique identifier and "remember me" token.
  ///
  /// Example:
  /// ```dart
  /// var user = await provider.retrieveByToken(1, 'remember-token');
  /// if (user != null) {
  ///   print('Found user by remember token');
  /// }
  /// ```
  Future<Authenticatable?> retrieveByToken(dynamic identifier, String token);

  /// Update the "remember me" token for the given user in storage.
  ///
  /// Example:
  /// ```dart
  /// await provider.updateRememberToken(user, 'new-remember-token');
  /// ```
  Future<void> updateRememberToken(Authenticatable user, String token);

  /// Retrieve a user by the given credentials.
  ///
  /// Example:
  /// ```dart
  /// var credentials = {
  ///   'email': 'user@example.com',
  ///   'password': 'password123'
  /// };
  /// var user = await provider.retrieveByCredentials(credentials);
  /// if (user != null) {
  ///   print('Found user by credentials');
  /// }
  /// ```
  Future<Authenticatable?> retrieveByCredentials(
      Map<String, dynamic> credentials);

  /// Validate a user against the given credentials.
  ///
  /// Example:
  /// ```dart
  /// var credentials = {
  ///   'email': 'user@example.com',
  ///   'password': 'password123'
  /// };
  /// if (await provider.validateCredentials(user, credentials)) {
  ///   print('Credentials are valid');
  /// }
  /// ```
  Future<bool> validateCredentials(
    Authenticatable user,
    Map<String, dynamic> credentials,
  );

  /// Rehash the user's password if required and supported.
  ///
  /// Example:
  /// ```dart
  /// await provider.rehashPasswordIfRequired(
  ///   user,
  ///   credentials,
  ///   force: true,
  /// );
  /// ```
  Future<void> rehashPasswordIfRequired(
    Authenticatable user,
    Map<String, dynamic> credentials, [
    bool force = false,
  ]);
}
