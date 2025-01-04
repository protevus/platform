import 'dart:convert';
import 'dart:typed_data';

import 'package:platform_contracts/contracts.dart';
import 'package:pointycastle/export.dart';

/// Abstract base class for hashers.
abstract class AbstractHasher implements Hasher {
  @override
  Map<String, dynamic> info(String hashedValue) {
    final parts = hashedValue.split(r'$');
    if (parts.length < 3) {
      return {
        'algoName': null,
        'algoNumber': null,
        'options': {},
      };
    }

    final algorithm = parts[1];
    final options = _parseOptions(parts[2]);

    return {
      'algoName': algorithm,
      'algoNumber': _getAlgoNumber(algorithm),
      'options': options,
    };
  }

  @override
  bool check(String value, String hashedValue,
      [Map<String, dynamic> options = const {}]) {
    if (hashedValue.isEmpty) {
      return false;
    }

    try {
      final parts = hashedValue.split(r'$');
      if (parts.length < 4) return false;

      final salt = base64Decode(parts[2]);
      final hash = base64Decode(parts[3]);

      final computedHash = _hashPassword(value, salt,
          algorithm: parts[1], options: _parseOptions(parts[2]));

      return _constantTimeEquals(hash, computedHash);
    } catch (e) {
      return false;
    }
  }

  /// Parse options from the hash string.
  Map<String, dynamic> _parseOptions(String optionsStr) {
    // Default implementation for bcrypt style options
    // Override in specific implementations if needed
    try {
      final rounds = int.parse(optionsStr);
      return {'rounds': rounds};
    } catch (e) {
      return {};
    }
  }

  /// Get the algorithm number based on name.
  int? _getAlgoNumber(String algorithm) {
    switch (algorithm.toLowerCase()) {
      case 'bcrypt':
      case '2a':
      case '2b':
      case '2y':
        return 2;
      case 'argon2i':
        return 96;
      case 'argon2id':
        return 97;
      default:
        return null;
    }
  }

  /// Hash a password with the given salt and options.
  Uint8List _hashPassword(
    String password,
    Uint8List salt, {
    required String algorithm,
    required Map<String, dynamic> options,
  });

  /// Constant time comparison of two byte arrays.
  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;

    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// Generate a secure random salt.
  Uint8List generateSalt([int length = 16]) {
    final secureRandom = SecureRandom('Fortuna');
    final seed = secureRandom.nextBytes(32);
    final random = FortunaRandom();
    random.seed(KeyParameter(seed));
    return random.nextBytes(length);
  }
}
