abstract class Authenticatable {
  /// Get the name of the unique identifier for the user.
  ///
  /// @return string
  String getAuthIdentifierName();

  /// Get the unique identifier for the user.
  ///
  /// @return dynamic
  dynamic getAuthIdentifier();

  /// Get the name of the password attribute for the user.
  ///
  /// @return string
  String getAuthPasswordName();

  /// Get the password for the user.
  ///
  /// @return string
  String getAuthPassword();

  /// Get the token value for the "remember me" session.
  ///
  /// @return string
  String getRememberToken();

  /// Set the token value for the "remember me" session.
  ///
  /// @param  string  value
  /// @return void
  void setRememberToken(String value);

  /// Get the column name for the "remember me" token.
  ///
  /// @return string
  String getRememberTokenName();
}
