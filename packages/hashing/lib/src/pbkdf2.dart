/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Implements the PBKDF2 (Password-Based Key Derivation Function 2) algorithm.
///
/// This class is used to derive a key from a password, salt, and hash function.
/// It's particularly useful for secure password storage and key generation.
///
/// https://en.wikipedia.org/wiki/PBKDF2
class PBKDF2 {
  /// Creates an instance of PBKDF2 capable of generating a key.
  ///
  /// [hashAlgorithm] specifies the hash function to use. Defaults to [sha256].
  PBKDF2({Hash? hashAlgorithm}) {
    this.hashAlgorithm = hashAlgorithm ?? sha256;
  }

  /// Gets the current hash algorithm used by this PBKDF2 instance.
  Hash get hashAlgorithm => _hashAlgorithm;

  /// Sets the hash algorithm to be used by this PBKDF2 instance.
  ///
  /// This also updates the internal block size based on the new algorithm.
  set hashAlgorithm(Hash algorithm) {
    _hashAlgorithm = algorithm;
    _blockSize = _hashAlgorithm.convert([1, 2, 3]).bytes.length;
  }

  /// The hash algorithm used for key derivation.
  ///
  /// This is marked as 'late' because it's initialized in the constructor or
  /// when the setter is called, but not at the point of declaration.
  late Hash _hashAlgorithm;

  /// The block size used in the PBKDF2 algorithm.
  ///
  /// This value is determined by the output size of the hash function being used.
  /// It's initialized when the hash algorithm is set, either in the constructor
  /// or when the hashAlgorithm setter is called.
  late int _blockSize;

  /// Generates a key from the given password and salt.
  ///
  /// [password] is the password to hash.
  /// [salt] is the salt to use in the hashing process.
  /// [rounds] is the number of iterations to perform.
  /// [keyLength] is the desired length of the output key in bytes.
  ///
  /// Returns a [List<int>] representing the generated key.
  ///
  /// Throws a [PBKDF2Exception] if the derived key would be too long.
  List<int> generateKey(
    String password,
    String salt,
    int rounds,
    int keyLength,
  ) {
    if (keyLength > (pow(2, 32) - 1) * _blockSize) {
      throw PBKDF2Exception("Derived key too long");
    }

    final numberOfBlocks = (keyLength / _blockSize).ceil();
    final hmac = Hmac(hashAlgorithm, utf8.encode(password));
    final key = ByteData(keyLength);
    var offset = 0;

    final saltBytes = utf8.encode(salt);
    final saltLength = saltBytes.length;
    final inputBuffer = ByteData(saltBytes.length + 4)
      ..buffer.asUint8List().setRange(0, saltBytes.length, saltBytes);

    for (var blockNumber = 1; blockNumber <= numberOfBlocks; blockNumber++) {
      inputBuffer.setUint8(saltLength, blockNumber >> 24);
      inputBuffer.setUint8(saltLength + 1, blockNumber >> 16);
      inputBuffer.setUint8(saltLength + 2, blockNumber >> 8);
      inputBuffer.setUint8(saltLength + 3, blockNumber);

      final block = _XORDigestSink.generate(inputBuffer, hmac, rounds);
      var blockLength = _blockSize;
      if (offset + blockLength > keyLength) {
        blockLength = keyLength - offset;
      }
      key.buffer.asUint8List().setRange(offset, offset + blockLength, block);

      offset += blockLength;
    }

    return key.buffer.asUint8List();
  }

  /// Generates a base64-encoded key from the given password and salt.
  ///
  /// This method invokes [generateKey] and base64 encodes the result.
  ///
  /// [password] is the password to hash.
  /// [salt] is the salt to use in the hashing process.
  /// [rounds] is the number of iterations to perform.
  /// [keyLength] is the desired length of the output key in bytes.
  ///
  /// Returns a [String] representing the base64-encoded generated key.
  String generateBase64Key(
    String password,
    String salt,
    int rounds,
    int keyLength,
  ) {
    const converter = Base64Encoder();

    return converter.convert(generateKey(password, salt, rounds, keyLength));
  }
}

/// Exception thrown when an error occurs during PBKDF2 key generation.
class PBKDF2Exception implements Exception {
  /// Creates a new PBKDF2Exception with the given error message.
  PBKDF2Exception(this.message);

  /// The error message describing the exception.
  String message;

  /// Returns a string representation of the PBKDF2Exception.
  ///
  /// This method overrides the default [Object.toString] method to provide
  /// a more descriptive string representation of the exception. The returned
  /// string includes the exception type ("PBKDF2Exception") followed by the
  /// error message.
  ///
  /// Returns a [String] in the format "PBKDF2Exception: [error message]".
  @override
  String toString() => "PBKDF2Exception: $message";
}

/// A helper class for XOR operations on digests during PBKDF2 key generation.
class _XORDigestSink implements Sink<Digest> {
  /// Creates a new _XORDigestSink with the given input buffer and HMAC.
  _XORDigestSink(ByteData inputBuffer, Hmac hmac) {
    lastDigest = hmac.convert(inputBuffer.buffer.asUint8List()).bytes;
    bytes = ByteData(lastDigest.length)
      ..buffer.asUint8List().setRange(0, lastDigest.length, lastDigest);
  }

  /// Generates a hash by repeatedly applying HMAC and XOR operations.
  ///
  /// [inputBuffer] is the initial input data.
  /// [hmac] is the HMAC instance to use for hashing.
  /// [rounds] is the number of iterations to perform.
  ///
  /// Returns a [Uint8List] representing the generated hash.
  static Uint8List generate(ByteData inputBuffer, Hmac hmac, int rounds) {
    final hashSink = _XORDigestSink(inputBuffer, hmac);

    // If rounds == 1, we have already run the first hash in the constructor
    // so this loop won't run.
    for (var round = 1; round < rounds; round++) {
      final hmacSink = hmac.startChunkedConversion(hashSink);
      hmacSink.add(hashSink.lastDigest);
      hmacSink.close();
    }

    return hashSink.bytes.buffer.asUint8List();
  }

  /// Stores the intermediate XOR results.
  late ByteData bytes;

  /// Stores the last computed digest.
  late List<int> lastDigest;

  /// Adds a new digest to the sink by performing an XOR operation.
  ///
  /// [digest] is the digest to add to the sink.
  @override
  void add(Digest digest) {
    lastDigest = digest.bytes;
    for (var i = 0; i < digest.bytes.length; i++) {
      bytes.setUint8(i, bytes.getUint8(i) ^ lastDigest[i]);
    }
  }

  /// Closes the sink and performs any necessary cleanup.
  ///
  /// This method is required by the [Sink] interface but does not perform
  /// any additional actions in this implementation.
  @override
  void close() {}
}
