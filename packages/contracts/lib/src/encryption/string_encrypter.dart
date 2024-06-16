
abstract class StringEncrypter {
  /// Encrypt a string without serialization.
  ///
  /// @param  String  value
  /// @return String
  ///
  /// @throws EncryptException
  String encryptString(String value);

  /// Decrypt the given string without unserialization.
  ///
  /// @param  String  payload
  /// @return String
  ///
  /// @throws DecryptException
  String decryptString(String payload);
}
