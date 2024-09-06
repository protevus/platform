/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_auth/auth.dart';
import 'package:protevus_hashing/hashing.dart';
import 'package:crypto/crypto.dart';

export 'src/auth_code_controller.dart';
export 'src/auth_controller.dart';
export 'src/auth_redirect_controller.dart';
export 'src/authorization_parser.dart';
export 'src/authorization_server.dart';
export 'src/authorizer.dart';
export 'src/exceptions.dart';
export 'src/objects.dart';
export 'src/protocols.dart';
export 'src/validator.dart';

/// A utility method to generate a password hash using the PBKDF2 scheme.
///
/// This function takes a password and salt as input and generates a secure hash
/// using the PBKDF2 (Password-Based Key Derivation Function 2) algorithm.
String generatePasswordHash(
  String password,
  String salt, {
  int hashRounds = 1000,
  int hashLength = 32,
  Hash? hashFunction,
}) {
  final generator = PBKDF2(hashAlgorithm: hashFunction ?? sha256);
  return generator.generateBase64Key(password, salt, hashRounds, hashLength);
}

/// A utility method to generate a random base64 salt.
///
/// This function generates a random salt encoded as a base64 string.
/// The salt is useful for adding randomness to password hashing processes,
/// making them more resistant to attacks.
String generateRandomSalt({int hashLength = 32}) {
  return generateAsBase64String(hashLength);
}

/// A utility method to generate a ClientID and Client Secret Pair.
///
/// This function creates an [AuthClient] instance, which can be either public or confidential,
/// depending on whether a secret is provided.
///
/// Any client that allows the authorization code flow must include [redirectURI].
///
/// Note that [secret] is hashed with a randomly generated salt, and therefore cannot be retrieved
/// later. The plain-text secret must be stored securely elsewhere.
AuthClient generateAPICredentialPair(
  String clientID,
  String? secret, {
  String? redirectURI,
  int hashLength = 32,
  int hashRounds = 1000,
  Hash? hashFunction,
}) {
  if (secret == null) {
    return AuthClient.public(clientID, redirectURI: redirectURI);
  }

  final salt = generateRandomSalt(hashLength: hashLength);
  final hashed = generatePasswordHash(
    secret,
    salt,
    hashRounds: hashRounds,
    hashLength: hashLength,
    hashFunction: hashFunction,
  );

  return AuthClient.withRedirectURI(clientID, hashed, salt, redirectURI);
}
