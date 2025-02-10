import 'package:illuminate_encryption/encryption.dart';
import 'package:illuminate_contracts/contracts.dart';

void main() {
  // Generate a key for AES-256-CBC
  final key = Encrypter.generateKey('aes-256-cbc');
  print('Generated key: $key');

  // Create an Encrypter instance
  final encrypter = Encrypter(key, cipher: 'aes-256-cbc');

  // Example 1: Encrypting and decrypting a string
  const originalString = 'Hello, Protevus Platform!';
  print('\nExample 1: String encryption');
  print('Original: $originalString');

  final encryptedString = encrypter.encryptString(originalString);
  print('Encrypted: $encryptedString');

  final decryptedString = encrypter.decryptString(encryptedString);
  print('Decrypted: $decryptedString');

  // Example 2: Encrypting and decrypting an object
  final originalObject = {
    'username': 'john_doe',
    'email': 'john@example.com',
    'age': 30,
  };
  print('\nExample 2: Object encryption');
  print('Original: $originalObject');

  final encryptedObject = encrypter.encrypt(originalObject);
  print('Encrypted: $encryptedObject');

  final decryptedObject = encrypter.decrypt(encryptedObject);
  print('Decrypted: $decryptedObject');

  // Example 3: Handling encryption exceptions
  print('\nExample 3: Handling exceptions');
  try {
    encrypter.encrypt(null);
  } on EncryptException catch (e) {
    print('Caught EncryptException: $e');
  }

  // Example 4: Handling decryption exceptions
  try {
    encrypter.decrypt('invalid_payload');
  } on DecryptException catch (e) {
    print('Caught DecryptException: $e');
  }

  // Example 5: Using previous keys
  print('\nExample 5: Using previous keys');
  final oldKey = Encrypter.generateKey('aes-256-cbc');
  final newKey = Encrypter.generateKey('aes-256-cbc');

  final oldEncrypter = Encrypter(oldKey, cipher: 'aes-256-cbc');
  final encryptedWithOldKey = oldEncrypter.encryptString('Secret message');
  print('Encrypted with old key: $encryptedWithOldKey');

  final newEncrypter =
      Encrypter(newKey, cipher: 'aes-256-cbc', previousKeys: [oldKey]);
  final decryptedWithNewEncrypter =
      newEncrypter.decryptString(encryptedWithOldKey);
  print('Decrypted with new encrypter: $decryptedWithNewEncrypter');
}
