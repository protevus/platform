/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_auth/auth.dart';

/// An exception class for handling authentication server errors.
///
/// This class implements the [Exception] interface and is used to represent
/// various errors that can occur during the authentication process.
///
/// The [AuthServerException] contains:
/// - [reason]: An [AuthRequestError] enum value representing the specific error.
/// - [client]: An optional [AuthClient] associated with the error.
///
/// It also provides utility methods:
/// - [errorString]: A static method that converts [AuthRequestError] enum values to standardized error strings.
/// - [reasonString]: A getter that returns the error string for the current [reason].
///
/// The [toString] method is overridden to provide a custom string representation of the exception.
class AuthServerException implements Exception {
  /// Creates an [AuthServerException] with the specified [reason] and optional [client].
  ///
  /// The [reason] parameter is an [AuthRequestError] enum value representing the specific error.
  /// The [client] parameter is an optional [AuthClient] associated with the error.
  ///
  /// Example:
  /// ```dart
  /// var exception = AuthServerException(AuthRequestError.invalidRequest, null);
  /// ```
  AuthServerException(this.reason, this.client);

  /// Converts an [AuthRequestError] enum value to its corresponding string representation.
  ///
  /// This static method takes an [AuthRequestError] as input and returns a standardized
  /// string that represents the error. These strings are suitable for inclusion in
  /// query strings or JSON response bodies when indicating errors during the processing
  /// of OAuth 2.0 requests.
  ///
  /// The returned strings conform to the error codes defined in the OAuth 2.0 specification,
  /// with the exception of 'invalid_token', which is a custom addition.
  ///
  /// Example:
  /// ```dart
  /// var errorString = AuthServerException.errorString(AuthRequestError.invalidRequest);
  /// print(errorString); // Outputs: "invalid_request"
  /// ```
  ///
  /// @param error The [AuthRequestError] enum value to convert.
  /// @return A string representation of the error.
  static String errorString(AuthRequestError error) {
    switch (error) {
      case AuthRequestError.invalidRequest:
        return "invalid_request";
      case AuthRequestError.invalidClient:
        return "invalid_client";
      case AuthRequestError.invalidGrant:
        return "invalid_grant";
      case AuthRequestError.invalidScope:
        return "invalid_scope";
      case AuthRequestError.invalidToken:
        return "invalid_token";

      case AuthRequestError.unsupportedGrantType:
        return "unsupported_grant_type";
      case AuthRequestError.unsupportedResponseType:
        return "unsupported_response_type";

      case AuthRequestError.unauthorizedClient:
        return "unauthorized_client";
      case AuthRequestError.accessDenied:
        return "access_denied";

      case AuthRequestError.serverError:
        return "server_error";
      case AuthRequestError.temporarilyUnavailable:
        return "temporarily_unavailable";
    }
  }

  /// The specific reason for the authentication error.
  ///
  /// This property holds an [AuthRequestError] enum value that represents
  /// the specific error that occurred during the authentication process.
  /// It provides detailed information about why the authentication request failed.
  AuthRequestError reason;

  /// The optional [AuthClient] associated with this exception.
  ///
  /// This property may contain an [AuthClient] instance that is related to the
  /// authentication error. It can be null if no specific client is associated
  /// with the error or if the error occurred before client authentication.
  ///
  /// This information can be useful for debugging or logging purposes, providing
  /// context about which client encountered the authentication error.
  AuthClient? client;

  /// Returns a string representation of the [reason] for this exception.
  ///
  /// This getter utilizes the static [errorString] method to convert the
  /// [AuthRequestError] enum value stored in [reason] to its corresponding
  /// string representation.
  ///
  /// @return A standardized string representation of the error reason.
  String get reasonString {
    return errorString(reason);
  }

  /// Returns a string representation of the [AuthServerException].
  ///
  /// This method overrides the default [Object.toString] method to provide
  /// a custom string representation of the exception. The returned string
  /// includes the exception class name, the [reason] for the exception,
  /// and the associated [client] (if any).
  ///
  /// @return A string in the format "AuthServerException: [reason] [client]".
  @override
  String toString() {
    return "AuthServerException: $reason $client";
  }
}

/// Enum representing possible errors as defined by the OAuth 2.0 specification.
///
/// Auth endpoints will use this list of values to determine the response sent back
/// to a client upon a failed request.
enum AuthRequestError {
  /// Represents an invalid request error.
  ///
  /// The request is missing a required parameter, includes an
  /// unsupported parameter value (other than grant type),
  /// repeats a parameter, includes multiple credentials,
  /// utilizes more than one mechanism for authenticating the
  /// client, or is otherwise malformed.
  invalidRequest,

  /// Represents an invalid client error.
  ///
  /// Client authentication failed (e.g., unknown client, no
  /// client authentication included, or unsupported
  /// authentication method).  The authorization server MAY
  /// return an HTTP 401 (Unauthorized) status code to indicate
  /// which HTTP authentication schemes are supported.  If the
  /// client attempted to authenticate via the "Authorization"
  /// request header field, the authorization server MUST
  /// respond with an HTTP 401 (Unauthorized) status code and
  /// include the "WWW-Authenticate" response header field
  /// matching the authentication scheme used by the client.
  invalidClient,

  /// Represents an invalid grant error.
  ///
  /// The provided authorization grant (e.g., authorization
  /// code, resource owner credentials) or refresh token is
  /// invalid, expired, revoked, does not match the redirection
  /// URI used in the authorization request, or was issued to
  /// another client.
  invalidGrant,

  /// Represents an invalid scope error.
  ///
  /// This error occurs when the requested scope is invalid, unknown, malformed,
  /// or exceeds the scope granted by the resource owner. It typically indicates
  /// that the client has requested access to resources or permissions that are
  /// either not recognized by the authorization server or not authorized for
  /// the particular client or user.
  ///
  /// In the OAuth 2.0 flow, this error might be returned if a client requests
  /// access to a scope that doesn't exist or that the user hasn't granted
  /// permission for.
  invalidScope,

  /// Represents an unsupported grant type error.
  ///
  /// This error occurs when the authorization server does not support the
  /// grant type requested by the client. It typically indicates that the
  /// client has specified a grant type that is either not recognized or
  /// not implemented by the authorization server.
  ///
  /// In the OAuth 2.0 flow, this error might be returned if, for example,
  /// a client requests a grant type like "password" when the server only
  /// supports "authorization_code" and "refresh_token" grant types.
  unsupportedGrantType,

  /// Represents an unsupported response type error.
  ///
  /// This error occurs when the authorization server does not support obtaining
  /// an authorization code using the specified response type. It typically
  /// indicates that the client has requested a response type that is not
  /// recognized or not implemented by the authorization server.
  unsupportedResponseType,

  /// Represents an unauthorized client error.
  ///
  /// This error occurs when the client is not authorized to request an
  /// authorization code using this method. It typically indicates that
  /// the client does not have the necessary permissions or credentials
  /// to perform the requested action, even though it may be properly
  /// authenticated.
  unauthorizedClient,

  /// Represents an access denied error.
  ///
  /// This error occurs when the resource owner or authorization server denies the request.
  /// It is typically used when the authenticated user does not have sufficient permissions
  /// to perform the requested action, or when the user explicitly denies authorization
  /// during the OAuth flow.
  accessDenied,

  /// Represents a server error.
  ///
  /// This error occurs when the authorization server encounters an unexpected
  /// condition that prevented it from fulfilling the request. This is typically
  /// used for internal server errors or other unexpected issues that prevent
  /// the server from properly processing the authentication request.
  serverError,

  /// Represents a temporarily unavailable error.
  ///
  /// This error occurs when the authorization server is temporarily unable to handle
  /// the request due to a temporary overloading or maintenance of the server.
  /// The client may repeat the request at a later time. The server SHOULD include
  /// a Retry-After HTTP header field in the response indicating how long the client
  /// should wait before retrying the request.
  temporarilyUnavailable,

  /// Represents an invalid token error.
  ///
  /// This error occurs when the provided token is invalid, expired, or otherwise
  /// not acceptable for the requested operation. It is typically used when a client
  /// presents an access token that cannot be validated or is no longer valid.
  ///
  /// Note: This particular error reason is not part of the standard OAuth 2.0
  /// specification. It is a custom addition to handle scenarios specific to
  /// token validation that are not covered by other standard error types.
  invalidToken
}
