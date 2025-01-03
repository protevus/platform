import 'package:platform_contracts/contracts.dart';

import 'argon2id_hasher.dart';
import 'argon_hasher.dart';
import 'bcrypt_hasher.dart';

/// Hash manager implementation.
class HashManager implements Hasher {
  /// The configuration repository instance.
  final ConfigContract _config;

  /// The active hasher instances.
  final Map<String, Hasher> _hashers = {};

  /// Create a new hash manager instance.
  HashManager(this._config);

  /// Get a hasher instance by driver.
  Hasher driver([String? driver]) {
    driver ??= getDefaultDriver();

    return _hashers[driver] ??= _createDriver(driver);
  }

  /// Create a new hasher instance.
  Hasher _createDriver(String driver) {
    switch (driver) {
      case 'bcrypt':
        return createBcryptDriver();
      case 'argon':
        return createArgonDriver();
      case 'argon2id':
        return createArgon2idDriver();
      default:
        throw UnsupportedError('Driver [$driver] not supported.');
    }
  }

  /// Create an instance of the Bcrypt hash Driver.
  BcryptHasher createBcryptDriver() {
    return BcryptHasher(
        _config.get('hashing.bcrypt') as Map<String, dynamic>? ?? {});
  }

  /// Create an instance of the Argon2i hash Driver.
  ArgonHasher createArgonDriver() {
    return ArgonHasher(
        _config.get('hashing.argon') as Map<String, dynamic>? ?? {});
  }

  /// Create an instance of the Argon2id hash Driver.
  Argon2IdHasher createArgon2idDriver() {
    return Argon2IdHasher(
        _config.get('hashing.argon') as Map<String, dynamic>? ?? {});
  }

  /// Get information about the given hashed value.
  @override
  Map<String, dynamic> info(String hashedValue) {
    return driver().info(hashedValue);
  }

  /// Hash the given value.
  @override
  String make(String value, [Map<String, dynamic> options = const {}]) {
    return driver().make(value, options);
  }

  /// Check the given plain value against a hash.
  @override
  bool check(String value, String hashedValue,
      [Map<String, dynamic> options = const {}]) {
    return driver().check(value, hashedValue, options);
  }

  /// Check if the given hash has been hashed using the given options.
  @override
  bool needsRehash(String hashedValue,
      [Map<String, dynamic> options = const {}]) {
    return driver().needsRehash(hashedValue, options);
  }

  /// Determine if a given string is already hashed.
  bool isHashed(String value) {
    return driver().info(value)['algoNumber'] != null;
  }

  /// Get the default driver name.
  String getDefaultDriver() {
    return _config.get<String>('hashing.driver') ?? 'bcrypt';
  }
}
