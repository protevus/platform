import 'dart:convert';
import 'dart:typed_data';

import 'package:platform_contracts/contracts.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

import 'abstract_hasher.dart';

/// BCrypt hasher implementation.
class BcryptHasher extends AbstractHasher implements Hasher {
  /// The default cost factor.
  int _rounds = 12;

  /// Indicates whether to perform an algorithm check.
  bool _verifyAlgorithm = false;

  /// Create a new hasher instance.
  BcryptHasher([Map<String, dynamic> options = const {}]) {
    _rounds = options['rounds'] as int? ?? _rounds;
    _verifyAlgorithm = options['verify'] as bool? ?? _verifyAlgorithm;
  }

  @override
  String make(String value, [Map<String, dynamic> options = const {}]) {
    try {
      final salt = generateSalt();
      final hash = _hashPassword(value, salt,
          algorithm: 'bcrypt', options: {'rounds': cost(options)});

      return r'$2y$' +
          cost(options).toString().padLeft(2, '0') +
          r'$' +
          base64Encode(salt) +
          r'$' +
          base64Encode(hash);
    } catch (e) {
      throw StateError('Bcrypt hashing not supported: $e');
    }
  }

  @override
  bool check(String value, String hashedValue,
      [Map<String, dynamic> options = const {}]) {
    if (_verifyAlgorithm && !isUsingCorrectAlgorithm(hashedValue)) {
      throw StateError('This password does not use the Bcrypt algorithm.');
    }

    return super.check(value, hashedValue, options);
  }

  @override
  bool needsRehash(String hashedValue,
      [Map<String, dynamic> options = const {}]) {
    final hashInfo = info(hashedValue);
    final currentRounds = (hashInfo['options'] as Map)['rounds'] as int?;

    return hashInfo['algoName'] != 'bcrypt' ||
        currentRounds == null ||
        currentRounds != cost(options);
  }

  /// Verifies that the configuration is less than or equal to what is configured.
  bool verifyConfiguration(String value) {
    return isUsingCorrectAlgorithm(value) && isUsingValidOptions(value);
  }

  /// Verify the hashed value's algorithm.
  bool isUsingCorrectAlgorithm(String hashedValue) {
    return info(hashedValue)['algoName'] == 'bcrypt';
  }

  /// Verify the hashed value's options.
  bool isUsingValidOptions(String hashedValue) {
    final options = info(hashedValue)['options'] as Map;
    final cost = options['rounds'] as int?;

    if (cost == null) {
      return false;
    }

    if (cost > _rounds) {
      return false;
    }

    return true;
  }

  /// Set the default password work factor.
  void setRounds(int rounds) {
    _rounds = rounds;
  }

  /// Extract the cost value from the options array.
  int cost(Map<String, dynamic> options) {
    return options['rounds'] as int? ?? _rounds;
  }

  @override
  Uint8List _hashPassword(
    String password,
    Uint8List salt, {
    required String algorithm,
    required Map<String, dynamic> options,
  }) {
    final rounds = options['rounds'] as int? ?? _rounds;

    // Use PBKDF2 with SHA-512 as a substitute for BCrypt
    // since PointyCastle doesn't have direct BCrypt support
    final digest = SHA512Digest();
    final hmac = HMac.withDigest(digest);
    final passwordBytes = utf8.encode(password) as Uint8List;
    hmac.init(KeyParameter(passwordBytes));

    final pbkdf2 = PBKDF2KeyDerivator(hmac);
    final pbkdf2Params =
        Pbkdf2Parameters(salt, 1 << rounds, 32); // 32 bytes output
    pbkdf2.init(pbkdf2Params);

    final output = Uint8List(32);
    pbkdf2.deriveKey(salt, 0, output, 0);
    return output;
  }
}
