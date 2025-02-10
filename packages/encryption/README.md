# Platform Encryption

A robust and flexible encryption package for the Protevus platform, implementing Laravel-inspired encryption functionality in Dart.

## Features

- Support for multiple cipher types (AES-128-CBC, AES-256-CBC, AES-128-GCM, AES-256-GCM)
- Encryption and decryption of both strings and objects
- Key management with support for previous keys
- Proper error handling with EncryptException and DecryptException

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  platform_encryption: ^1.0.0
```

Then run:

```
dart pub get
```

## Usage

Here's a basic example of how to use the Encrypter class:

```dart
import 'package:platform_encryption/platform_encryption.dart';

void main() {
  // Generate a key for AES-256-CBC
  final key = Encrypter.generateKey('aes-256-cbc');

  // Create an Encrypter instance
  final encrypter = Encrypter(key, cipher: 'aes-256-cbc');

  // Encrypt a string
  const originalString = 'Hello, Protevus Platform!';
  final encryptedString = encrypter.encryptString(originalString);

  // Decrypt the string
  final decryptedString = encrypter.decryptString(encryptedString);

  print('Original: $originalString');
  print('Encrypted: $encryptedString');
  print('Decrypted: $decryptedString');
}
```

### Encrypting and Decrypting Objects

You can also encrypt and decrypt objects:

```dart
final originalObject = {'username': 'john_doe', 'email': 'john@example.com'};
final encryptedObject = encrypter.encrypt(originalObject);
final decryptedObject = encrypter.decrypt(encryptedObject);
```

### Using Previous Keys

To support key rotation, you can provide previous keys when creating an Encrypter instance:

```dart
final oldKey = Encrypter.generateKey('aes-256-cbc');
final newKey = Encrypter.generateKey('aes-256-cbc');

final encrypter = Encrypter(newKey, cipher: 'aes-256-cbc', previousKeys: [oldKey]);
```

This allows the Encrypter to decrypt messages that were encrypted with the old key.

### Error Handling

The package throws `EncryptException` and `DecryptException` for encryption and decryption errors respectively:

```dart
try {
  encrypter.encrypt(null);
} on EncryptException catch (e) {
  print('Encryption failed: $e');
}

try {
  encrypter.decrypt('invalid_payload');
} on DecryptException catch (e) {
  print('Decryption failed: $e');
}
```

## API Reference

For detailed API documentation, please refer to the [API Reference](link-to-api-docs).

## Contributing

Contributions are welcome! Please read our [contributing guidelines](link-to-contributing-guidelines) before submitting pull requests.

## License

This project is licensed under the [MIT License](link-to-license).
