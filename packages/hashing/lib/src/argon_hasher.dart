import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:platform_contracts/contracts.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/argon2.dart';

import 'abstract_hasher.dart';

/// Argon2i hasher implementation.
class ArgonHasher extends AbstractHasher implements Hasher {
  /// The default memory cost factor.
  @protected
  int _memory = 1024;

  /// The default time cost factor.
  @protected
  int _time = 2;

  /// The default threads factor.
  @protected
  int _threads = 2;

  /// Indicates whether to perform an algorithm check.
  @protected
  bool verifyAlgorithm = false;

  /// Create a new hasher instance.
  ArgonHasher([Map<String, dynamic> options = const {}]) {
    _time = options['time'] as int? ?? _time;
    _memory = options['memory'] as int? ?? _memory;
    _threads = threads(options);
    verifyAlgorithm = options['verify'] as bool? ?? verifyAlgorithm;
  }

  @override
  String make(String value, [Map<String, dynamic> options = const {}]) {
    try {
      final salt = generateSalt();
      final hash = _hashPassword(value, salt, algorithm: 'argon2i', options: {
        'memory_cost': memory(options),
        'time_cost': time(options),
        'threads': threads(options),
      });

      final memStr = memory(options).toString();
      final timeStr = time(options).toString();
      final threadStr = threads(options).toString();

      return '\$argon2i\$v=19\$m=$memStr,t=$timeStr,p=$threadStr\$' +
          base64Encode(salt) +
          r'$' +
          base64Encode(hash);
    } catch (e) {
      throw StateError('Argon2i hashing not supported: $e');
    }
  }

  @override
  bool check(String value, String hashedValue,
      [Map<String, dynamic> options = const {}]) {
    if (verifyAlgorithm && !isUsingCorrectAlgorithm(hashedValue)) {
      throw StateError('This password does not use the Argon2i algorithm.');
    }

    return super.check(value, hashedValue, options);
  }

  @override
  bool needsRehash(String hashedValue,
      [Map<String, dynamic> options = const {}]) {
    final hashInfo = info(hashedValue);
    final currentOptions = hashInfo['options'] as Map;

    return hashInfo['algoName'] != 'argon2i' ||
        currentOptions['memory_cost'] != memory(options) ||
        currentOptions['time_cost'] != time(options) ||
        currentOptions['threads'] != threads(options);
  }

  /// Verifies that the configuration is less than or equal to what is configured.
  bool verifyConfiguration(String value) {
    return isUsingCorrectAlgorithm(value) && isUsingValidOptions(value);
  }

  /// Verify the hashed value's algorithm.
  bool isUsingCorrectAlgorithm(String hashedValue) {
    return info(hashedValue)['algoName'] == 'argon2i';
  }

  /// Verify the hashed value's options.
  bool isUsingValidOptions(String hashedValue) {
    final options = info(hashedValue)['options'] as Map;

    if (!options.containsKey('memory_cost') ||
        !options.containsKey('time_cost') ||
        !options.containsKey('threads')) {
      return false;
    }

    if (options['memory_cost'] > _memory ||
        options['time_cost'] > _time ||
        options['threads'] > _threads) {
      return false;
    }

    return true;
  }

  @override
  Map<String, dynamic> _parseOptions(String optionsStr) {
    final parts = optionsStr.split(',');
    final options = <String, dynamic>{};

    for (final part in parts) {
      final keyValue = part.split('=');
      if (keyValue.length == 2) {
        final key = keyValue[0].trim();
        final value = int.tryParse(keyValue[1].trim());
        if (value != null) {
          switch (key) {
            case 'm':
              options['memory_cost'] = value;
              break;
            case 't':
              options['time_cost'] = value;
              break;
            case 'p':
              options['threads'] = value;
              break;
          }
        }
      }
    }

    return options;
  }

  /// Set the default password memory factor.
  void setMemory(int memory) {
    _memory = memory;
  }

  /// Set the default password timing factor.
  void setTime(int time) {
    _time = time;
  }

  /// Set the default password threads factor.
  void setThreads(int threads) {
    _threads = threads;
  }

  /// Extract the memory cost value from the options array.
  int memory(Map<String, dynamic> options) {
    return options['memory'] as int? ?? _memory;
  }

  /// Extract the time cost value from the options array.
  int time(Map<String, dynamic> options) {
    return options['time'] as int? ?? _time;
  }

  /// Extract the threads value from the options array.
  int threads(Map<String, dynamic> options) {
    return options['threads'] as int? ?? _threads;
  }

  @override
  Uint8List _hashPassword(
    String password,
    Uint8List salt, {
    required String algorithm,
    required Map<String, dynamic> options,
  }) {
    final memoryCost = options['memory_cost'] as int? ?? _memory;
    final timeCost = options['time_cost'] as int? ?? _time;
    final parallelism = options['threads'] as int? ?? _threads;

    final argon2 = Argon2BytesGenerator();
    final params = Argon2Parameters(
      Argon2Parameters.ARGON2_i,
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
