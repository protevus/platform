import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encryption;
import 'package:platform_contracts/contracts.dart';

class Encrypter implements EncrypterContract, StringEncrypter {
  final String _key;
  final String _cipher;
  final List<String> _previousKeys;

  static const Map<String, Map<String, dynamic>> supportedCiphers = {
    'aes-128-cbc': {'size': 16, 'aead': false},
    'aes-256-cbc': {'size': 32, 'aead': false},
    'aes-128-gcm': {'size': 16, 'aead': true},
    'aes-256-gcm': {'size': 32, 'aead': true},
  };

  Encrypter(this._key,
      {String cipher = 'aes-256-cbc', List<String> previousKeys = const []})
      : _cipher = cipher,
        _previousKeys = previousKeys {
    if (!isSupported(_key, _cipher)) {
      final ciphers = supportedCiphers.keys.join(', ');
      throw ArgumentError(
          'Unsupported cipher or incorrect key length. Supported ciphers are: $ciphers.');
    }
  }

  static bool isSupported(String key, String cipher) {
    final lowerCipher = cipher.toLowerCase();
    if (!supportedCiphers.containsKey(lowerCipher)) {
      return false;
    }
    return base64.decode(key).length == supportedCiphers[lowerCipher]!['size'];
  }

  static String generateKey(String cipher) {
    final size = supportedCiphers[cipher.toLowerCase()]?['size'] ?? 32;
    final random = Random.secure();
    final bytes = List<int>.generate(size, (_) => random.nextInt(256));
    return base64.encode(bytes);
  }

  @override
  String encrypt(dynamic value, [bool serialize = true]) {
    if (value == null) {
      throw EncryptException();
    }

    try {
      final iv = encryption.IV.fromSecureRandom(16);
      final encrypter = _createEncrypter(_key);

      final serializedValue = serialize ? jsonEncode(value) : value.toString();
      final encrypted = encrypter.encrypt(serializedValue, iv: iv);

      final payload = {
        'iv': base64.encode(iv.bytes),
        'value': encrypted.base64,
        'mac': _createMac(iv.bytes, encrypted.bytes, _key),
        'tag': '', // For AEAD ciphers, we'd include the tag here
      };

      return base64.encode(utf8.encode(jsonEncode(payload)));
    } catch (e) {
      throw EncryptException();
    }
  }

  @override
  String encryptString(String value) {
    return encrypt(value, false);
  }

  @override
  dynamic decrypt(String payload, [bool unserialize = true]) {
    try {
      final decodedPayload = _getJsonPayload(payload);
      final iv = encryption.IV(base64.decode(decodedPayload['iv']));

      for (final key in [_key, ..._previousKeys]) {
        if (_validMac(decodedPayload, key)) {
          final encrypter = _createEncrypter(key);
          final decrypted =
              encrypter.decrypt64(decodedPayload['value'], iv: iv);
          return unserialize ? jsonDecode(decrypted) : decrypted;
        }
      }

      throw DecryptException();
    } catch (e) {
      throw DecryptException();
    }
  }

  @override
  String decryptString(String payload) {
    return decrypt(payload, false) as String;
  }

  @override
  String getKey() => _key;

  @override
  List<String> getAllKeys() => [_key, ..._previousKeys];

  @override
  List<String> getPreviousKeys() => _previousKeys;

  encryption.Encrypter _createEncrypter(String key) {
    final keyBytes = base64.decode(key);
    final encryptionKey = encryption.Key(keyBytes);
    return encryption.Encrypter(
        encryption.AES(encryptionKey, mode: encryption.AESMode.cbc));
  }

  String _createMac(List<int> iv, List<int> value, String key) {
    final hmac = Hmac(sha256, base64.decode(key));
    final digest = hmac.convert(iv + value);
    return base64.encode(digest.bytes);
  }

  Map<String, dynamic> _getJsonPayload(String payload) {
    try {
      final decoded = jsonDecode(utf8.decode(base64.decode(payload)));
      if (!_validPayload(decoded)) {
        throw FormatException('The payload is invalid.');
      }
      return decoded;
    } catch (e) {
      throw DecryptException();
    }
  }

  bool _validPayload(dynamic payload) {
    if (payload is! Map<String, dynamic>) return false;
    for (final item in ['iv', 'value', 'mac']) {
      if (!payload.containsKey(item) || payload[item] is! String) {
        return false;
      }
    }
    return true;
  }

  bool _validMac(Map<String, dynamic> payload, String key) {
    return _createMac(
          base64.decode(payload['iv']),
          base64.decode(payload['value']),
          key,
        ) ==
        payload['mac'];
  }
}
