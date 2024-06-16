import 'dart:async';

abstract class Encrypter {
  /// Encrypt the given value.
  ///
  /// [value]: The value to be encrypted.
  /// [serialize]: Whether to serialize the value before encryption.
  /// Returns a string representing the encrypted value.
  /// Throws an EncryptException if encryption fails.
  Future<String> encrypt(dynamic value, {bool serialize = true});

  /// Decrypt the given value.
  ///
  /// [payload]: The encrypted payload to be decrypted.
  /// [unserialize]: Whether to unserialize the value after decryption.
  /// Returns the decrypted value.
  /// Throws a DecryptException if decryption fails.
  Future<dynamic> decrypt(String payload, {bool unserialize = true});

  /// Get the encryption key that the encrypter is currently using.
  ///
  /// Returns the current encryption key as a string.
  String getKey();

  /// Get the current encryption key and all previous encryption keys.
  ///
  /// Returns a list of all encryption keys.
  List<String> getAllKeys();

  /// Get the previous encryption keys.
  ///
  /// Returns a list of previous encryption keys.
  List<String> getPreviousKeys();
}
