import 'dart:convert';
import 'package:test/test.dart';
import 'package:illuminate_encryption/encryption.dart';
import 'package:illuminate_contracts/contracts.dart';

void main() {
  late Encrypter encrypter;
  late String testKey;

  setUp(() {
    // Generate a 256-bit (32-byte) key for AES-256-CBC
    final keyBytes = List<int>.generate(32, (i) => i);
    testKey = base64.encode(keyBytes);
    encrypter = Encrypter(testKey, cipher: 'aes-256-cbc');
  });

  test('Encrypter implements EncrypterContract and StringEncrypter', () {
    expect(encrypter, isA<EncrypterContract>());
    expect(encrypter, isA<StringEncrypter>());
  });

  test('Encrypt and decrypt a string', () {
    const originalString = 'Hello, World!';
    final encrypted = encrypter.encrypt(originalString);
    final decrypted = encrypter.decrypt(encrypted);
    expect(decrypted, equals(originalString));
  });

  test('Encrypt and decrypt an object', () {
    final originalObject = {'key': 'value', 'number': 42};
    final encrypted = encrypter.encrypt(originalObject);
    final decrypted = encrypter.decrypt(encrypted);
    expect(decrypted, equals(originalObject));
  });

  test('EncryptString and decryptString', () {
    const originalString = 'Hello, World!';
    final encrypted = encrypter.encryptString(originalString);
    final decrypted = encrypter.decryptString(encrypted);
    expect(decrypted, equals(originalString));
  });

  test('GetKey returns the correct key', () {
    expect(encrypter.getKey(), equals(testKey));
  });

  test('GetAllKeys returns all keys', () {
    final previousKeyBytes = List<int>.generate(32, (i) => i + 100);
    final previousKey = base64.encode(previousKeyBytes);
    final encrypterWithPreviousKey =
        Encrypter(testKey, cipher: 'aes-256-cbc', previousKeys: [previousKey]);
    expect(
        encrypterWithPreviousKey.getAllKeys(), equals([testKey, previousKey]));
  });

  test('GetPreviousKeys returns previous keys', () {
    final previousKeyBytes = List<int>.generate(32, (i) => i + 100);
    final previousKey = base64.encode(previousKeyBytes);
    final encrypterWithPreviousKey =
        Encrypter(testKey, cipher: 'aes-256-cbc', previousKeys: [previousKey]);
    expect(encrypterWithPreviousKey.getPreviousKeys(), equals([previousKey]));
  });

  test('Throws EncryptException on encryption failure', () {
    expect(() => encrypter.encrypt(null), throwsA(isA<EncryptException>()));
  });

  test('Throws DecryptException on decryption failure', () {
    expect(() => encrypter.decrypt('invalid_payload'),
        throwsA(isA<DecryptException>()));
  });
}
