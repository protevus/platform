/// Interface for encryption.
abstract class EncrypterContract {
  /// Encrypt the given value.
  ///
  /// @throws EncryptException
  String encrypt(dynamic value, [bool serialize = true]);

  /// Decrypt the given value.
  ///
  /// @throws DecryptException
  dynamic decrypt(String payload, [bool unserialize = true]);

  /// Get the encryption key that the encrypter is currently using.
  String getKey();

  /// Get the current encryption key and all previous encryption keys.
  List<String> getAllKeys();

  /// Get the previous encryption keys.
  List<String> getPreviousKeys();
}
