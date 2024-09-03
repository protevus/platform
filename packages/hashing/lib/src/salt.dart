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

/// Generates a random salt of [length] bytes from a cryptographically secure random number generator.
///
/// Each element of this list is a byte.
List<int> generate(int length) {
  final buffer = Uint8List(length);
  final rng = Random.secure();
  for (var i = 0; i < length; i++) {
    buffer[i] = rng.nextInt(256);
  }

  return buffer;
}

/// Generates a random salt of [length] bytes from a cryptographically secure random number generator and encodes it to Base64.
///
/// [length] is the number of bytes generated, not the [length] of the base64 encoded string returned. Decoding
/// the base64 encoded string will yield [length] number of bytes.
String generateAsBase64String(int length) {
  const encoder = Base64Encoder();
  return encoder.convert(generate(length));
}
