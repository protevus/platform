/// Interface for string encryption.
abstract class StringEncrypter {
  /// Encrypt a string without serialization.
  ///
  /// @throws EncryptException
  String encryptString(String value);

  /// Decrypt the given string without unserialization.
  ///
  /// @throws DecryptException
  String decryptString(String payload);
}
