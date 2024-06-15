import 'authenticatable.dart';

abstract class UserProvider {
  /// Retrieve a user by their unique identifier.
  ///
  /// @param  dynamic  identifier
  /// @return Authenticatable|null
  Future<Authenticatable?> retrieveById(dynamic identifier);

  /// Retrieve a user by their unique identifier and "remember me" token.
  ///
  /// @param  dynamic  identifier
  /// @param  String  token
  /// @return Authenticatable|null
  Future<Authenticatable?> retrieveByToken(dynamic identifier, String token);

  /// Update the "remember me" token for the given user in storage.
  ///
  /// @param  Authenticatable  user
  /// @param  String  token
  /// @return void
  Future<void> updateRememberToken(Authenticatable user, String token);

  /// Retrieve a user by the given credentials.
  ///
  /// @param  Map<String, dynamic>  credentials
  /// @return Authenticatable|null
  Future<Authenticatable?> retrieveByCredentials(Map<String, dynamic> credentials);

  /// Validate a user against the given credentials.
  ///
  /// @param  Authenticatable  user
  /// @param  Map<String, dynamic>  credentials
  /// @return bool
  Future<bool> validateCredentials(Authenticatable user, Map<String, dynamic> credentials);

  /// Rehash the user's password if required and supported.
  ///
  /// @param  Authenticatable  user
  /// @param  Map<String, dynamic>  credentials
  /// @param  bool  force
  /// @return void
  Future<void> rehashPasswordIfRequired(Authenticatable user, Map<String, dynamic> credentials, {bool force = false});
}
