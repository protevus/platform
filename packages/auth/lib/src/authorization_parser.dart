/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:convert';

/// An abstract class for parsing authorization headers.
///
/// This class defines a common interface for parsing different types of
/// authorization headers. Implementations of this class should provide
/// specific parsing logic for different authorization schemes (e.g., Bearer, Basic).
///
/// The type parameter [T] represents the return type of the [parse] method,
/// allowing for flexibility in the parsed result (e.g., String for Bearer tokens,
/// custom credential objects for other schemes).
abstract class AuthorizationParser<T> {
  const AuthorizationParser();

  T parse(String authorizationHeader);
}

/// Parses a Bearer token from an Authorization header.
///
/// This class extends [AuthorizationParser] and specializes in parsing Bearer tokens
/// from Authorization headers. It implements the [parse] method to extract the token
/// from a given header string.
///
/// Usage:
/// ```dart
/// final parser = AuthorizationBearerParser();
/// final token = parser.parse("Bearer myToken123");
/// print(token); // Outputs: myToken123
/// ```
///
/// If the header is invalid or missing, it throws an [AuthorizationParserException]
/// with an appropriate [AuthorizationParserExceptionReason].
class AuthorizationBearerParser extends AuthorizationParser<String?> {
  const AuthorizationBearerParser();

  /// Parses a Bearer token from an Authorization header.
  ///
  /// For example, if the input to this method is "Bearer token" it would return 'token'.
  ///
  /// If [authorizationHeader] is malformed or null, throws an [AuthorizationParserException].
  @override
  String? parse(String authorizationHeader) {
    if (authorizationHeader.isEmpty) {
      throw AuthorizationParserException(
        AuthorizationParserExceptionReason.missing,
      );
    }

    final matcher = RegExp("Bearer (.+)");
    final match = matcher.firstMatch(authorizationHeader);
    if (match == null) {
      throw AuthorizationParserException(
        AuthorizationParserExceptionReason.malformed,
      );
    }
    return match[1];
  }
}

/// A structure to hold Basic authorization credentials.
///
/// This class represents the credentials used in Basic HTTP Authentication.
/// It contains two properties: [username] and [password].
///
/// The [username] and [password] are marked as `late final`, indicating that
/// they must be initialized before use, but can only be set once.
///
/// This class is typically used in conjunction with [AuthorizationBasicParser]
/// to parse and store credentials from a Basic Authorization header.
///
/// The [toString] method is overridden to provide a string representation
/// of the credentials in the format "username:password".
///
/// Example usage:
/// ```dart
/// final credentials = AuthBasicCredentials()
///   ..username = 'john_doe'
///   ..password = 'secret123';
/// print(credentials); // Outputs: john_doe:secret123
/// ```
///
/// See [AuthorizationBasicParser] for getting instances of this type.
class AuthBasicCredentials {
  /// The username of a Basic Authorization header.
  late final String username;

  /// The password of a Basic Authorization header.
  late final String password;

  @override
  String toString() => "$username:$password";
}

/// Parses a Basic Authorization header.
///
/// This class extends [AuthorizationParser] and specializes in parsing Basic Authentication
/// credentials from Authorization headers. It implements the [parse] method to extract
/// the username and password from a given header string.
///
/// The parser expects the header to be in the format "Basic <base64-encoded-credentials>",
/// where the credentials are a string of "username:password" encoded in Base64.
///
/// Usage:
/// ```dart
/// final parser = AuthorizationBasicParser();
/// final credentials = parser.parse("Basic dXNlcm5hbWU6cGFzc3dvcmQ=");
/// print(credentials.username); // Outputs: username
/// print(credentials.password); // Outputs: password
/// ```
///
/// If the header is invalid, missing, or cannot be properly decoded, it throws an
/// [AuthorizationParserException] with an appropriate [AuthorizationParserExceptionReason].
class AuthorizationBasicParser
    extends AuthorizationParser<AuthBasicCredentials> {
  /// Creates a constant instance of [AuthorizationBasicParser].
  ///
  /// This constructor allows for the creation of immutable instances of the parser,
  /// which can be safely shared and reused across multiple parts of an application.
  ///
  /// Example usage:
  /// ```dart
  /// final parser = const AuthorizationBasicParser();
  /// ```
  const AuthorizationBasicParser();

  /// Parses a Basic Authorization header and returns [AuthBasicCredentials].
  ///
  /// If [authorizationHeader] is malformed or null, throws an [AuthorizationParserException].
  @override
  AuthBasicCredentials parse(String? authorizationHeader) {
    if (authorizationHeader == null) {
      throw AuthorizationParserException(
        AuthorizationParserExceptionReason.missing,
      );
    }

    final matcher = RegExp("Basic (.+)");
    final match = matcher.firstMatch(authorizationHeader);
    if (match == null) {
      throw AuthorizationParserException(
        AuthorizationParserExceptionReason.malformed,
      );
    }

    final base64String = match[1]!;
    String decodedCredentials;
    try {
      decodedCredentials =
          String.fromCharCodes(const Base64Decoder().convert(base64String));
    } catch (e) {
      throw AuthorizationParserException(
        AuthorizationParserExceptionReason.malformed,
      );
    }

    final splitCredentials = decodedCredentials.split(":");
    if (splitCredentials.length != 2) {
      throw AuthorizationParserException(
        AuthorizationParserExceptionReason.malformed,
      );
    }

    return AuthBasicCredentials()
      ..username = splitCredentials.first
      ..password = splitCredentials.last;
  }
}

/// Enumerates the possible reasons for authorization parsing failures.
///
/// This enum is used in conjunction with [AuthorizationParserException] to
/// provide more specific information about why the parsing of an authorization
/// header failed.
///
/// The enum contains two values:
/// - [missing]: Indicates that the required authorization header was not present.
/// - [malformed]: Indicates that the authorization header was present but its
///   format was incorrect or could not be properly parsed.
///
/// This enum is typically used by [AuthorizationBearerParser] and
/// [AuthorizationBasicParser] to specify the nature of parsing failures.
enum AuthorizationParserExceptionReason { missing, malformed }

/// An exception class for errors encountered during authorization parsing.
///
/// This exception is thrown when there's an issue parsing an authorization header.
/// It contains a [reason] field of type [AuthorizationParserExceptionReason]
/// which provides more specific information about why the parsing failed.
///
/// The [reason] can be either [AuthorizationParserExceptionReason.missing]
/// (indicating the absence of a required authorization header) or
/// [AuthorizationParserExceptionReason.malformed] (indicating an incorrectly
/// formatted authorization header).
///
/// This exception is typically thrown by implementations of [AuthorizationParser],
/// such as [AuthorizationBearerParser] and [AuthorizationBasicParser].
///
/// Example usage:
/// ```dart
/// try {
///   parser.parse(header);
/// } catch (e) {
///   if (e is AuthorizationParserException) {
///     if (e.reason == AuthorizationParserExceptionReason.missing) {
///       print('Authorization header is missing');
///     } else if (e.reason == AuthorizationParserExceptionReason.malformed) {
///       print('Authorization header is malformed');
///     }
///   }
/// }
/// ```
class AuthorizationParserException implements Exception {
  AuthorizationParserException(this.reason);

  AuthorizationParserExceptionReason reason;
}
