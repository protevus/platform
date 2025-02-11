import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/argon2.dart';

import 'argon_hasher.dart';

/// Argon2id hasher implementation.
class Argon2IdHasher extends ArgonHasher {
  /// Create a new hasher instance.
  Argon2IdHasher([super.options]);

  @override
  String make(String value, [Map<String, dynamic> options = const {}]) {
    try {
      final salt = generateSalt();
      final hash = _hashPassword(value, salt, algorithm: 'argon2id', options: {
        'memory_cost': memory(options),
        'time_cost': time(options),
        'threads': threads(options),
      });

      final memStr = memory(options).toString();
      final timeStr = time(options).toString();
      final threadStr = threads(options).toString();

      return '\$argon2id\$v=19\$m=$memStr,t=$timeStr,p=$threadStr\$' +
          base64Encode(salt) +
          r'$' +
          base64Encode(hash);
    } catch (e) {
      throw StateError('Argon2id hashing not supported: $e');
    }
  }

  @override
  bool check(String value, String hashedValue,
      [Map<String, dynamic> options = const {}]) {
    if (verifyAlgorithm && !isUsingCorrectAlgorithm(hashedValue)) {
      throw StateError('This password does not use the Argon2id algorithm.');
    }

    return super.check(value, hashedValue, options);
  }

  @override
  bool isUsingCorrectAlgorithm(String hashedValue) {
    return info(hashedValue)['algoName'] == 'argon2id';
  }

  @override
  Uint8List _hashPassword(
    String password,
    Uint8List salt, {
    required String algorithm,
    required Map<String, dynamic> options,
  }) {
    final memoryCost = options['memory_cost'] as int? ?? memory({});
    final timeCost = options['time_cost'] as int? ?? time({});
    final parallelism = options['threads'] as int? ?? threads({});

    final argon2 = Argon2BytesGenerator();
    final params = Argon2Parameters(
      Argon2Parameters.ARGON2_id,
      salt,
      desiredKeyLength: 32,
      iterations: timeCost,
      memory: memoryCost,
      lanes: parallelism,
      version: Argon2Parameters.ARGON2_VERSION_13,
    );
    argon2.init(params);

    final output = Uint8List(32);
    final passwordBytes = utf8.encode(password) as Uint8List;
    argon2.deriveKey(passwordBytes, 0, output, 0);
    return output;
  }
}
