/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_auth/auth.dart';
import 'package:protevus_http/http.dart';

/// Represents an OAuth 2.0 client ID and secret pair.
///
/// This class encapsulates the information necessary for OAuth 2.0 client authentication.
/// It can represent both public and confidential clients, with support for the authorization code grant flow.
///
/// Use the command line tool `conduit auth` to create instances of this type and store them to a database.
class AuthClient {
  /// Creates an instance of [AuthClient].
  ///
  /// This constructor creates an [AuthClient] with the given parameters.
  ///
  /// If this client supports scopes, [allowedScopes] must contain a list of scopes that tokens may request when authorized
  /// by this client.
  ///
  /// NOTE: [id] must not be null. [hashedSecret] and [salt] must either both be null or both be valid values. If [hashedSecret] and [salt]
  /// are valid values, this client is a confidential client. Otherwise, the client is public. The terms 'confidential' and 'public'
  /// are described by the OAuth 2.0 specification.
  AuthClient(
    String id,
    String? hashedSecret,
    String? salt, {
    List<AuthScope>? allowedScopes,
  }) : this.withRedirectURI(
          id,
          hashedSecret,
          salt,
          null,
          allowedScopes: allowedScopes,
        );

  /// Creates an instance of a public [AuthClient].
  ///
  /// This constructor creates a public [AuthClient] with the given [id].
  /// Public clients do not have a client secret.
  ///
  /// - [id]: The unique identifier for the client.
  /// - [allowedScopes]: Optional list of scopes that this client is allowed to request.
  /// - [redirectURI]: Optional URI to redirect to after authorization.
  ///
  /// This is equivalent to calling [AuthClient.withRedirectURI] with null values for
  /// hashedSecret and salt.
  AuthClient.public(String id,
      {List<AuthScope>? allowedScopes, String? redirectURI})
      : this.withRedirectURI(
          id,
          null,
          null,
          redirectURI,
          allowedScopes: allowedScopes,
        );

  /// Creates an instance of [AuthClient] that uses the authorization code grant flow.
  ///
  /// This constructor creates a confidential [AuthClient] with the given parameters.
  ///
  /// - [id]: The unique identifier for the client.
  /// - [hashedSecret]: The hashed secret of the client.
  /// - [salt]: The salt used to hash the client secret.
  /// - [redirectURI]: The URI to redirect to after authorization.
  /// - [allowedScopes]: Optional list of scopes that this client is allowed to request.
  ///
  /// This constructor is specifically for clients that use the authorization code grant flow,
  /// which requires a redirect URI. All parameters except [allowedScopes] must be non-null.
  /// The presence of [hashedSecret] and [salt] indicates that this is a confidential client.
  AuthClient.withRedirectURI(
    this.id,
    this.hashedSecret,
    this.salt,
    this.redirectURI, {
    List<AuthScope>? allowedScopes,
  }) {
    this.allowedScopes = allowedScopes;
  }

  /// The list of allowed scopes for this client.
  ///
  /// This private variable stores the allowed scopes for the AuthClient.
  /// It is used internally to manage and validate the scopes that this client
  /// is authorized to request during the authentication process.
  List<AuthScope>? _allowedScopes;

  /// The unique identifier for this OAuth 2.0 client.
  ///
  /// This is a required field for all OAuth 2.0 clients and is used to identify
  /// the client during the authentication and authorization process. It should
  /// be a string value that is unique among all clients registered with the
  /// authorization server.
  final String id;

  /// The hashed secret of the client.
  ///
  /// This property stores the hashed version of the client's secret, which is used for authentication
  /// in confidential clients. The secret is hashed for security reasons, to avoid storing the raw secret.
  ///
  /// This value may be null if the client is public. A null value indicates that this is a public client,
  /// which doesn't use a client secret for authentication. See [isPublic] for more information on
  /// determining if a client is public or confidential.
  ///
  /// The hashed secret is typically used in conjunction with the [salt] property to verify
  /// the client's credentials during the authentication process.
  String? hashedSecret;

  /// The salt used to hash the client secret.
  ///
  /// This value may be null if the client is public. See [isPublic].
  String? salt;

  /// The redirection URI for authorization codes and/or tokens.
  ///
  /// This property stores the URI where the authorization server should redirect
  /// the user after they grant or deny permission to the client. It is used in
  /// the authorization code grant flow of OAuth 2.0.
  ///
  /// In the context of OAuth 2.0:
  /// - For authorization code grant, this URI is where the authorization code is sent.
  /// - For implicit grant, this URI is where the access token is sent.
  ///
  /// This value may be null if the client doesn't support the authorization code flow.
  String? redirectURI;

  /// The list of scopes available when authorizing with this client.
  ///
  /// This getter returns the list of allowed scopes for the client. The setter
  /// filters the provided list to remove any redundant scopes.
  ///
  /// Scoping is determined by this instance; i.e. the authorizing client determines which scopes a token
  /// has. This list contains all valid scopes for this client. If null, client does not support scopes
  /// and all access tokens have same authorization.
  List<AuthScope>? get allowedScopes => _allowedScopes;
  set allowedScopes(List<AuthScope>? scopes) {
    _allowedScopes = scopes?.where((s) {
      return !scopes.any(
        (otherScope) =>
            s.isSubsetOrEqualTo(otherScope) && !s.isExactlyScope(otherScope),
      );
    }).toList();
  }

  /// Determines if this instance supports authorization scopes.
  ///
  /// In application's that do not use authorization scopes, this will return false.
  /// Otherwise, will return true.
  bool get supportsScopes => allowedScopes != null;

  /// Determines if this client can issue tokens for the provided [scope].
  ///
  /// This method checks if the given [scope] is allowed for this client by comparing it
  /// against the client's [allowedScopes]. It returns true if the provided [scope] is
  /// a subset of or equal to any of the scopes in [allowedScopes].
  ///
  /// If [allowedScopes] is null or empty, this method returns false, indicating that
  /// no scopes are allowed for this client.
  ///
  /// [scope]: The AuthScope to check against this client's allowed scopes.
  ///
  /// Returns true if the scope is allowed, false otherwise.
  bool allowsScope(AuthScope scope) {
    return allowedScopes
            ?.any((clientScope) => scope.isSubsetOrEqualTo(clientScope)) ??
        false;
  }

  /// Whether or not this is a public client.
  ///
  /// Public clients do not have a client secret and are used for clients that can't store
  /// their secret confidentially, i.e. JavaScript browser applications.
  bool get isPublic => hashedSecret == null;

  /// Determines whether this client is confidential or public.
  ///
  /// Confidential clients have a client secret that must be used when authenticating with
  /// a client-authenticated request. Confidential clients are used when you can
  /// be sure that the client secret cannot be viewed by anyone outside of the developer.
  bool get isConfidential => hashedSecret != null;

  /// Returns a string representation of the AuthClient instance.
  ///
  /// This method provides a human-readable description of the AuthClient, including:
  /// - Whether the client is public or confidential
  /// - The client's ID
  /// - The client's redirect URI (if set)
  ///
  /// The format of the returned string is:
  /// "AuthClient (public/confidential): [client_id] [redirect_uri]"
  ///
  /// @return A string representation of the AuthClient.
  @override
  String toString() {
    return "AuthClient (${isPublic ? "public" : "confidental"}): $id $redirectURI";
  }
}

/// Represents an OAuth 2.0 token.
///
/// This class encapsulates the properties and functionality of an OAuth 2.0 token,
/// including access token, refresh token, expiration details, and associated scopes.
/// It is used by [AuthServerDelegate] and [AuthServer] to exchange OAuth 2.0 tokens.
///
/// See the `package:conduit_core/managed_auth` library for a concrete implementation of this type.
class AuthToken {
  /// The access token string for OAuth 2.0 authentication.
  ///
  /// This token is used in the Authorization header of HTTP requests to authenticate
  /// the client. It should be included in the header as "Bearer <accessToken>".
  ///
  /// The access token is typically a short-lived credential that grants access to
  /// protected resources on behalf of the resource owner (user).
  ///
  /// This value may be null if the token has not been issued or has been invalidated.
  String? accessToken;

  /// The refresh token associated with this OAuth 2.0 token.
  ///
  /// A refresh token is a credential that can be used to obtain a new access token
  /// when the current access token becomes invalid or expires. This allows the client
  /// to obtain continued access to protected resources without requiring the resource
  /// owner to re-authorize the application.
  ///
  /// This value may be null if the authorization server does not issue refresh tokens
  /// or if the token has not been issued with a refresh token.
  String? refreshToken;

  /// The time this token was issued on.
  ///
  /// This property represents the date and time when the OAuth 2.0 token was originally issued.
  /// It can be used to calculate the age of the token or to implement token refresh policies.
  /// The value is stored as a [DateTime] object, which allows for easy manipulation and comparison.
  ///
  /// This value may be null if the issue date is not tracked or has not been set.
  DateTime? issueDate;

  /// The expiration date and time of this token.
  ///
  /// This property represents the point in time when the OAuth 2.0 token will become invalid.
  /// After this date and time, the token should no longer be accepted for authentication.
  ///
  /// The value is stored as a [DateTime] object, which allows for easy comparison with the current time
  /// to determine if the token has expired. This is typically used in conjunction with [issueDate]
  /// to calculate the token's lifespan and manage token refresh cycles.
  ///
  /// This value may be null if the token does not have an expiration date or if it has not been set.
  DateTime? expirationDate;

  /// The type of token used for authentication.
  ///
  /// This property specifies the type of token being used. In the OAuth 2.0 framework,
  /// the most common token type is 'bearer'. The token type is typically used in the
  /// HTTP Authorization header to indicate how the access token should be used.
  ///
  /// Currently, only 'bearer' is considered valid for this implementation.
  ///
  /// Example usage in an HTTP header:
  /// Authorization: Bearer <access_token>
  ///
  /// This value may be null if the token type has not been set or is unknown.
  String? type;

  /// The identifier of the resource owner.
  ///
  /// Tokens are owned by a resource owner, typically a User, Profile or Account
  /// in an application. This value is the primary key or identifying value of those
  /// instances.
  ///
  /// This property represents the unique identifier of the resource owner associated
  /// with the OAuth 2.0 token. It is typically used to link the token to a specific
  /// user or account in the system.
  ///
  /// The value is stored as an integer, which could be:
  /// - A database primary key
  /// - A unique user ID
  /// - Any other numeric identifier that uniquely identifies the resource owner
  ///
  /// This property may be null if the token is not associated with a specific
  /// resource owner or if the association has not been established.
  int? resourceOwnerIdentifier;

  /// The client ID associated with this token.
  ///
  /// This property represents the unique identifier of the OAuth 2.0 client
  /// that was used to obtain this token. It is used to link the token back
  /// to the client application that requested it.
  ///
  /// The client ID is typically assigned by the authorization server when
  /// the client application is registered, and it's used to identify the
  /// client during the authentication and token issuance process.
  late String clientID;

  /// The list of authorization scopes associated with this token.
  ///
  /// This property represents the set of permissions or access rights granted to this token.
  /// Each [AuthScope] in the list defines a specific area of access or functionality
  /// that the token holder is allowed to use.
  ///
  /// The scopes determine what actions or resources the token can access within the system.
  /// If this list is null, it typically means the token has no specific scope restrictions
  /// and may have full access (depending on the system's implementation).
  ///
  /// This property is crucial for implementing fine-grained access control in OAuth 2.0
  /// systems, allowing for precise definition of what each token is allowed to do.
  List<AuthScope>? scopes;

  /// Determines whether this token has expired.
  ///
  /// This getter compares the token's [expirationDate] with the current UTC time
  /// to determine if the token has expired. It returns true if the token has
  /// expired, and false if it is still valid.
  ///
  /// The comparison is done by calculating the difference in seconds between
  /// the expiration date and the current time. If this difference is less than
  /// or equal to zero, the token is considered expired.
  ///
  /// Returns:
  ///   [bool]: true if the token has expired, false otherwise.
  ///
  /// Note: This getter assumes that [expirationDate] is not null. If it is null,
  /// this will result in a null pointer exception.
  bool get isExpired {
    return expirationDate!.difference(DateTime.now().toUtc()).inSeconds <= 0;
  }

  /// Emits this instance as a [Map] according to the OAuth 2.0 specification.
  Map<String, dynamic> asMap() {
    final map = {
      "access_token": accessToken,
      "token_type": type,
      "expires_in":
          expirationDate!.difference(DateTime.now().toUtc()).inSeconds,
    };

    if (refreshToken != null) {
      map["refresh_token"] = refreshToken;
    }

    if (scopes != null) {
      map["scope"] = scopes!.map((s) => s.toString()).join(" ");
    }

    return map;
  }
}

/// Represents an OAuth 2.0 authorization code.
///
/// This class encapsulates the properties and functionality of an OAuth 2.0 authorization code,
/// which is used in the authorization code grant flow. It contains information such as the code itself,
/// associated client and resource owner details, issue and expiration dates, and requested scopes.
///
/// See the conduit/managed_auth library for a concrete implementation of this type.
class AuthCode {
  /// The actual one-time code used to exchange for tokens.
  ///
  /// This property represents the authorization code in the OAuth 2.0 authorization code flow.
  /// It is a short-lived, single-use code that is issued by the authorization server and can be
  /// exchanged for an access token and, optionally, a refresh token.
  ///
  /// The code is typically valid for a short period (usually a few minutes) and can only be
  /// used once. After it has been exchanged for tokens, it becomes invalid.
  ///
  /// This value may be null if the code has not been generated yet or has been invalidated.
  String? code;

  /// The client ID associated with this authorization code.
  ///
  /// This property represents the unique identifier of the OAuth 2.0 client
  /// that requested the authorization code. It is used to link the authorization
  /// code back to the client application that initiated the OAuth flow.
  ///
  /// The client ID is typically assigned by the authorization server when
  /// the client application is registered, and it's used to identify the
  /// client during the authorization code exchange process.
  ///
  /// This property is marked as 'late', indicating that it must be initialized
  /// before it's accessed, but not necessarily in the constructor.
  late String clientID;

  /// The identifier of the resource owner associated with this authorization code.
  ///
  /// Authorization codes are owned by a resource owner, typically a User, Profile or Account
  /// in an application. This value is the primary key or identifying value of those
  /// instances.
  int? resourceOwnerIdentifier;

  /// The timestamp when this authorization code was issued.
  ///
  /// This property represents the date and time when the OAuth 2.0 authorization code
  /// was originally created and issued by the authorization server. It can be used to:
  /// - Calculate the age of the authorization code
  /// - Implement expiration policies
  /// - Audit the authorization process
  ///
  /// The value is stored as a [DateTime] object, which allows for easy manipulation
  /// and comparison with other dates and times.
  ///
  /// This value may be null if the issue date is not tracked or has not been set.
  DateTime? issueDate;

  /// The expiration date and time of this authorization code.
  ///
  /// This property represents the point in time when the OAuth 2.0 authorization code
  /// will become invalid. After this date and time, the code should no longer be
  /// accepted for token exchange.
  ///
  /// It is recommended to set this value to 10 minutes after the [issueDate] to
  /// limit the window of opportunity for potential attacks using intercepted
  /// authorization codes.
  ///
  /// The value is stored as a [DateTime] object, which allows for easy comparison
  /// with the current time to determine if the code has expired. This is typically
  /// used in conjunction with [issueDate] to enforce the short-lived nature of
  /// authorization codes.
  ///
  /// This value may be null if the authorization code does not have an expiration
  /// date or if it has not been set.
  DateTime? expirationDate;

  /// Indicates whether this authorization code has already been exchanged for a token.
  ///
  /// In the OAuth 2.0 authorization code flow, an authorization code should only be used once
  /// to obtain an access token. This property helps track whether the code has been exchanged.
  ///
  /// - If `true`, the code has already been used to obtain a token and should not be accepted again.
  /// - If `false` or `null`, the code has not yet been exchanged and may still be valid for token issuance.
  ///
  /// This property is crucial for preventing authorization code replay attacks, where an attacker
  /// might attempt to use a single authorization code multiple times.
  bool? hasBeenExchanged;

  /// The list of scopes requested for the token to be exchanged.
  ///
  /// This property represents the set of permissions or access rights that are being
  /// requested for the OAuth 2.0 token during the authorization code exchange process.
  /// Each [AuthScope] in the list defines a specific area of access or functionality
  /// that the token is requesting to use.
  ///
  /// If this list is null, it typically means no specific scopes are being requested,
  /// and the token may receive default scopes or full access (depending on the system's
  /// implementation and configuration).
  ///
  /// The actual scopes granted to the token may be a subset of these requested scopes,
  /// based on the authorization server's policies and the resource owner's consent.
  List<AuthScope>? requestedScopes;

  /// Determines whether this authorization code has expired.
  ///
  /// This getter compares the [expirationDate] of the authorization code with the current UTC time
  /// to determine if the code has expired. It returns true if the code has expired, and false if it is still valid.
  ///
  /// The comparison is done by calculating the difference in seconds between the expiration date and the current time.
  /// If this difference is less than or equal to zero, the code is considered expired.
  ///
  /// Returns:
  ///   [bool]: true if the authorization code has expired, false otherwise.
  ///
  /// Note: This getter assumes that [expirationDate] is not null. If it is null,
  /// this will result in a null pointer exception.
  bool get isExpired {
    return expirationDate!.difference(DateTime.now().toUtc()).inSeconds <= 0;
  }
}

/// Authorization information for a [Request] after it has passed through an [Authorizer].
///
/// This class encapsulates various pieces of authorization information, including:
/// - The client ID under which the permission was granted
/// - The identifier for the resource owner (if applicable)
/// - The [AuthValidator] that granted the permission
/// - Basic authorization credentials (if provided)
/// - A list of scopes that this authorization has access to
///
/// It also provides a method to check if the authorization has access to a specific scope.
///
/// This class is typically used in conjunction with [Authorizer] and [AuthValidator]
/// to manage and verify authorization in a request-response cycle.
/// After a request has passed through an [Authorizer], an instance of this type
/// is created and attached to the request (see [Request.authorization]). Instances of this type contain the information
/// that the [Authorizer] obtained from an [AuthValidator] (typically an [AuthServer])
/// about the validity of the credentials in a request.
class Authorization {
  /// Creates an instance of [Authorization].
  ///
  /// This constructor initializes an [Authorization] object with the provided parameters:
  ///
  /// - [clientID]: The client ID under which the permission was granted.
  /// - [ownerID]: The identifier for the owner of the resource, if provided. Can be null.
  /// - [validator]: The [AuthValidator] that granted this permission.
  /// - [credentials]: Optional. Basic authorization credentials, if provided.
  /// - [scopes]: Optional. The list of scopes this authorization has access to.
  ///
  /// This class is typically used to represent the authorization information for a [Request]
  /// after it has passed through an [Authorizer].
  Authorization(
    this.clientID,
    this.ownerID,
    this.validator, {
    this.credentials,
    this.scopes,
  });

  /// The client ID associated with this authorization.
  ///
  /// This property represents the unique identifier of the OAuth 2.0 client
  /// that was granted permission. It is used to link the authorization
  /// back to the specific client application that requested it.
  ///
  /// The client ID is typically assigned by the authorization server when
  /// the client application is registered, and it's used to identify the
  /// client throughout the OAuth 2.0 flow.
  final String clientID;

  /// The identifier for the owner of the resource, if provided.
  ///
  /// This property represents the unique identifier of the resource owner associated
  /// with this authorization. In OAuth 2.0 terminology, the resource owner is typically
  /// the end-user who grants permission to an application to access their data.
  ///
  /// If this authorization does not refer to a specific resource owner, this value will be null.
  final int? ownerID;

  /// The [AuthValidator] that granted this permission.
  ///
  /// This property represents the [AuthValidator] instance that was responsible
  /// for validating and granting the authorization. It can be used to trace
  /// the origin of the authorization or to perform additional validation
  /// if needed.
  ///
  /// The validator might be null in cases where the authorization was not
  /// granted through a standard validation process or if the information
  /// about the validator is not relevant or available.
  final AuthValidator? validator;

  /// Basic authorization credentials, if provided.
  ///
  /// This property holds the parsed basic authorization credentials if they were
  /// present in the authorization header of the request. If the request did not
  /// use basic authorization, or if the credentials were not successfully parsed,
  /// this property will be null.
  ///
  /// The [AuthBasicCredentials] object typically contains a username and password
  /// pair extracted from the 'Authorization' header of an HTTP request using the
  /// Basic authentication scheme.
  ///
  /// This can be useful for endpoints that support both OAuth 2.0 token-based
  /// authentication and traditional username/password authentication via Basic Auth.
  final AuthBasicCredentials? credentials;

  /// The list of scopes this authorization has access to.
  ///
  /// This property represents the set of permissions or access rights granted to this authorization.
  /// Each [AuthScope] in the list defines a specific area of access or functionality
  /// that the authorization is allowed to use.
  ///
  /// If the access token used to create this instance has scopes associated with it,
  /// those scopes will be available in this list. If no scopes were associated with
  /// the access token, or if scopes are not being used in the system, this property will be null.
  ///
  /// Scopes are crucial for implementing fine-grained access control in OAuth 2.0 systems,
  /// allowing for precise definition of what each authorization is allowed to do.
  ///
  /// This list can be used in conjunction with the [isAuthorizedForScope] method to check
  /// if the authorization has access to a specific scope.
  List<AuthScope>? scopes;

  /// Determines if this authorization has access to a specific scope.
  ///
  /// This method checks each element in [scopes] for any that gives privileges
  /// to access [scope].
  bool isAuthorizedForScope(String scope) {
    final asScope = AuthScope(scope);
    return scopes?.any(asScope.isSubsetOrEqualTo) ?? false;
  }
}

/// Represents and manages OAuth 2.0 scopes.
///
/// An OAuth 2.0 token may optionally have authorization scopes. An authorization scope provides more granular
/// authorization to protected resources. Without authorization scopes, any valid token can pass through an
/// [Authorizer.bearer]. Scopes allow [Authorizer]s to restrict access to routes that do not have the
/// appropriate scope values.
///
/// An [AuthClient] has a list of valid scopes (see `conduit auth` tool). An access token issued for an [AuthClient] may ask for
/// any of the scopes the client provides. Scopes are then granted to the access token. An [Authorizer] may specify
/// a one or more required scopes that a token must have to pass to the next controller.
class AuthScope {
  /// Creates an instance of [AuthScope] from a [scopeString].
  ///
  /// A simple authorization scope string is a single keyword. Valid characters are
  ///
  ///         A-Za-z0-9!#\$%&'`()*+,./:;<=>?@[]^_{|}-.
  ///
  /// For example, 'account' is a valid scope. An [Authorizer] can require an access token to have
  /// the 'account' scope to pass through it. Access tokens without the 'account' scope are unauthorized.
  ///
  /// More advanced scopes may contain multiple segments and a modifier. For example, the following are valid scopes:
  ///
  ///     user
  ///     user:settings
  ///     user:posts
  ///     user:posts.readonly
  ///
  /// Segments are delimited by the colon character (`:`). Segments allow more granular scoping options. Each segment adds a
  /// restriction to the segment prior to it. For example, the scope `user`
  /// would allow all user actions, whereas `user:settings` would only allow access to a user's settings. Routes that are secured
  /// to either `user:settings` or `user:posts.readonly` are accessible by an access token with `user` scope. A token with `user:settings`
  /// would not be able to access a route limited to `user:posts`.
  ///
  /// A modifier is an additional restrictive measure and follows scope segments and the dot character (`.`). A scope may only
  /// have one modifier at the very end of the scope. A modifier can be any string, as long as its characters are in the above
  /// list of valid characters. A modifier adds an additional restriction to a scope, without having to make up a new segment.
  /// An example is the 'readonly' modifier above. A route that requires `user:posts.readonly` would allow passage when the token
  /// has `user`, `user:posts` or `user:posts.readonly`. A route that required `user:posts` would not allow `user:posts.readonly`.
  factory AuthScope(String scopeString) {
    final cached = _cache[scopeString];
    if (cached != null) {
      return cached;
    }

    final scope = AuthScope._parse(scopeString);
    _cache[scopeString] = scope;
    return scope;
  }

  /// Parses and creates an [AuthScope] instance from a given scope string.
  ///
  /// This factory method performs several validation checks on the input [scopeString]:
  /// 1. Ensures the string is not empty.
  /// 2. Validates that each character in the string is within the allowed set of characters.
  /// 3. Parses the string into segments and extracts the modifier (if any).
  ///
  /// The allowed characters are: A-Za-z0-9!#$%&'`()*+,./:;<=>?@[]^_{|}-
  ///
  /// If any validation fails, a [FormatException] is thrown with a descriptive error message.
  ///
  /// After successful validation and parsing, it creates and returns a new [AuthScope] instance.
  ///
  /// Parameters:
  ///   [scopeString]: The string representation of the scope to parse.
  ///
  /// Returns:
  ///   A new [AuthScope] instance representing the parsed scope.
  ///
  /// Throws:
  ///   [FormatException] if the [scopeString] is empty or contains invalid characters.
  factory AuthScope._parse(String scopeString) {
    if (scopeString.isEmpty) {
      throw FormatException(
        "Invalid AuthScope. May not an empty string.",
        scopeString,
      );
    }

    for (final c in scopeString.codeUnits) {
      if (!(c == 33 || (c >= 35 && c <= 91) || (c >= 93 && c <= 126))) {
        throw FormatException(
          "Invalid authorization scope. May only contain "
          "the following characters: A-Za-z0-9!#\$%&'`()*+,./:;<=>?@[]^_{|}-",
          scopeString,
          scopeString.codeUnits.indexOf(c),
        );
      }
    }

    final segments = _parseSegments(scopeString);
    final lastModifier = segments.last.modifier;

    return AuthScope._(scopeString, segments, lastModifier);
  }

  /// Private constructor for creating an [AuthScope] instance.
  ///
  /// This constructor is used internally by the class to create instances
  /// after parsing and validating the scope string.
  ///
  /// Parameters:
  ///   [_scopeString]: The original, unparsed scope string.
  ///   [_segments]: A list of parsed [_AuthScopeSegment] objects representing the scope's segments.
  ///   [_lastModifier]: The modifier of the last segment, if any.
  ///
  /// This constructor is marked as `const` to allow for compile-time constant instances,
  /// which can improve performance and memory usage in certain scenarios.
  const AuthScope._(this._scopeString, this._segments, this._lastModifier);

  /// Represents a special constant for indicating 'any' scope in [AuthServerDelegate.getAllowedScopes].
  ///
  /// See [AuthServerDelegate.getAllowedScopes] for more details.
  static const List<AuthScope> any = [
    AuthScope._("_scope:_constant:_marker", [], null)
  ];

  /// Verifies if the provided scopes fulfill the required scopes.
  ///
  /// For all [requiredScopes], there must be a scope in [requiredScopes] that meets or exceeds
  /// that scope for this method to return true. If [requiredScopes] is null, this method
  /// return true regardless of [providedScopes].
  static bool verify(
    List<AuthScope>? requiredScopes,
    List<AuthScope>? providedScopes,
  ) {
    if (requiredScopes == null) {
      return true;
    }

    return requiredScopes.every((requiredScope) {
      final tokenHasValidScope = providedScopes
          ?.any((tokenScope) => requiredScope.isSubsetOrEqualTo(tokenScope));

      return tokenHasValidScope ?? false;
    });
  }

  /// A cache to store previously created AuthScope instances.
  ///
  /// This static map serves as a cache to store AuthScope instances that have been
  /// previously created. The key is the string representation of the scope, and
  /// the value is the corresponding AuthScope instance.
  ///
  /// Caching AuthScope instances can improve performance by avoiding repeated
  /// parsing and object creation for frequently used scopes. When an AuthScope
  /// is requested with a scope string that already exists in this cache, the
  /// cached instance is returned instead of creating a new one.
  static final Map<String, AuthScope> _cache = {};

  /// The original, unparsed scope string.
  ///
  /// This private field stores the complete scope string as it was originally provided
  /// when creating the AuthScope instance. It represents the full, unmodified scope
  /// including all segments and modifiers.
  ///
  /// This string is used for caching purposes and when converting the AuthScope
  /// back to its string representation (e.g., in the toString() method).
  final String _scopeString;

  /// Returns an iterable of individual segments of this AuthScope instance.
  ///
  /// Will always have a length of at least 1.
  Iterable<String?> get segments => _segments.map((s) => s.name);

  /// Returns the modifier of this scope, if it exists.
  ///
  /// The modifier is an optional component of an AuthScope that provides additional
  /// specification or restriction to the scope. It is typically the last part of a
  /// scope string, following a dot (.) after the last segment.
  ///
  /// For example, in the scope "user:profile.readonly", "readonly" is the modifier.
  ///
  /// Returns:
  ///   A [String] representing the modifier if one exists, or null if this AuthScope
  ///   does not have a modifier.
  ///
  /// This getter provides access to the private [_lastModifier] field, allowing
  /// external code to check for the presence and value of a modifier without
  /// directly accessing the internal state of the AuthScope.
  String? get modifier => _lastModifier;

  /// List of segments that make up this AuthScope.
  ///
  /// This private field stores the parsed segments of the scope string as a list of
  /// [_AuthScopeSegment] objects. Each segment represents a part of the scope,
  /// separated by colons in the original scope string.
  ///
  /// For example, for a scope string "user:profile:read", this list would contain
  /// three _AuthScopeSegment objects representing "user", "profile", and "read"
  /// respectively.
  ///
  /// This list is used internally for scope comparisons and validations.
  final List<_AuthScopeSegment> _segments;

  /// The modifier of the last segment in this AuthScope.
  ///
  /// This private field stores the modifier of the last segment in the AuthScope,
  /// if one exists. A modifier provides additional specification or restriction
  /// to a scope and is typically the part following a dot (.) in the last segment
  /// of a scope string.
  ///
  /// For example, in the scope "user:profile.readonly", "readonly" would be stored
  /// in this field.
  ///
  /// The value is null if the AuthScope does not have a modifier in its last segment.
  final String? _lastModifier;

  /// Parses the given scope string into a list of [_AuthScopeSegment] objects.
  ///
  /// This method performs the following steps:
  /// 1. Checks if the input string is empty and throws a [FormatException] if it is.
  /// 2. Splits the string by ':' and creates [_AuthScopeSegment] objects for each segment.
  /// 3. Validates each segment, ensuring:
  ///    - Only the last segment can have a modifier.
  ///    - There are no empty segments.
  ///    - There are no leading or trailing colons.
  ///
  /// If any validation fails, a [FormatException] is thrown with a descriptive error message
  /// and the position in the string where the error occurred.
  ///
  /// Parameters:
  ///   [scopeString]: The string representation of the scope to parse.
  ///
  /// Returns:
  ///   A list of [_AuthScopeSegment] objects representing the parsed segments of the scope.
  ///
  /// Throws:
  ///   [FormatException] if the [scopeString] is empty or contains invalid segments.
  static List<_AuthScopeSegment> _parseSegments(String scopeString) {
    if (scopeString.isEmpty) {
      throw FormatException(
        "Invalid AuthScope. May not be empty string.",
        scopeString,
      );
    }

    final elements =
        scopeString.split(":").map((seg) => _AuthScopeSegment(seg)).toList();

    var scannedOffset = 0;
    for (var i = 0; i < elements.length - 1; i++) {
      if (elements[i].modifier != null) {
        throw FormatException(
          "Invalid AuthScope. May only contain modifiers on the last segment.",
          scopeString,
          scannedOffset,
        );
      }

      if (elements[i].name == "") {
        throw FormatException(
          "Invalid AuthScope. May not contain empty segments or, leading or trailing colons.",
          scopeString,
          scannedOffset,
        );
      }

      scannedOffset += elements[i].toString().length + 1;
    }

    if (elements.last.name == "") {
      throw FormatException(
        "Invalid AuthScope. May not contain empty segments.",
        scopeString,
        scannedOffset,
      );
    }

    return elements;
  }

  /// Determines if this [AuthScope] is a subset of or equal to the [incomingScope].
  ///
  /// The scope `users:posts` is a subset of `users`.
  ///
  /// This check is used to determine if an [Authorizer] can allow a [Request]
  /// to pass if the [Request]'s [Request.authorization] has a scope that has
  /// the same or more scope than the required scope of an [Authorizer].
  bool isSubsetOrEqualTo(AuthScope incomingScope) {
    if (incomingScope._lastModifier != null) {
      // If the modifier of the incoming scope is restrictive,
      // and this scope requires no restrictions, then it's not allowed.
      if (_lastModifier == null) {
        return false;
      }

      // If the incoming scope's modifier doesn't match this one,
      // then we also don't have access.
      if (_lastModifier != incomingScope._lastModifier) {
        return false;
      }
    }

    final thisIterator = _segments.iterator;
    for (final incomingSegment in incomingScope._segments) {
      // If the incoming scope is more restrictive than this scope,
      // then it's not allowed.
      if (!thisIterator.moveNext()) {
        return false;
      }
      final current = thisIterator.current;

      // If we have a mismatch here, then we're going
      // down the wrong path.
      if (incomingSegment.name != current.name) {
        return false;
      }
    }

    return true;
  }

  /// Alias of [isSubsetOrEqualTo].
  ///
  /// This method is deprecated and will be removed in a future version.
  /// Use [isSubsetOrEqualTo] instead.
  ///
  /// Determines if this [AuthScope] allows the [incomingScope].
  /// It is equivalent to calling [isSubsetOrEqualTo] with the same argument.
  ///
  /// [incomingScope]: The AuthScope to compare against this instance.
  ///
  /// Returns true if this AuthScope is a subset of or equal to the [incomingScope],
  /// false otherwise.
  @Deprecated('Use AuthScope.isSubsetOrEqualTo() instead')
  bool allowsScope(AuthScope incomingScope) => isSubsetOrEqualTo(incomingScope);

  /// Checks if this AuthScope is a subset of or equal to the given scope string.
  ///
  /// Parses an instance of this type from [scopeString] and invokes
  /// [isSubsetOrEqualTo].
  bool allows(String scopeString) => isSubsetOrEqualTo(AuthScope(scopeString));

  /// Determines if this [AuthScope] is exactly the same as the given [scope].
  ///
  /// This method compares each segment and modifier of both scopes to ensure they are identical.
  ///
  /// Parameters:
  ///   [scope]: The [AuthScope] to compare against this instance.
  ///
  /// Returns:
  ///   [bool]: true if both scopes are exactly the same, false otherwise.
  ///
  /// The comparison is performed as follows:
  /// 1. Iterates through each segment of both scopes simultaneously.
  /// 2. If the given scope has fewer segments, returns false.
  /// 3. Compares the name and modifier of each segment.
  /// 4. If any segment's name or modifier doesn't match, returns false.
  /// 5. If all segments match and both scopes have the same number of segments, returns true.
  bool isExactlyScope(AuthScope scope) {
    final incomingIterator = scope._segments.iterator;
    for (final segment in _segments) {
      /// the scope has less segments so no match.
      if (!incomingIterator.moveNext()) {
        return false;
      }

      final incomingSegment = incomingIterator.current;

      if (incomingSegment.name != segment.name ||
          incomingSegment.modifier != segment.modifier) {
        return false;
      }
    }

    return true;
  }

  /// Checks if this AuthScope is exactly the same as the given scope string.
  ///
  /// Parses an instance of this type from [scopeString] and invokes [isExactlyScope].
  bool isExactly(String scopeString) {
    return isExactlyScope(AuthScope(scopeString));
  }

  /// Returns a string representation of this AuthScope.
  ///
  /// This method overrides the default [Object.toString] method to provide
  /// a string representation of the AuthScope instance. It returns the
  /// original, unparsed scope string that was used to create this AuthScope.
  ///
  /// Returns:
  ///   A [String] representing the complete scope, including all segments
  ///   and modifiers, exactly as it was originally provided.
  ///
  /// Example:
  ///   final scope = AuthScope('user:profile.readonly');
  ///   print(scope.toString()); // Outputs: 'user:profile.readonly'
  @override
  String toString() => _scopeString;
}

/// Represents a segment of an AuthScope.
///
/// An AuthScope can be composed of one or more segments, where each segment
/// may have a name and an optional modifier. This class parses and stores
/// the components of a single segment.
class _AuthScopeSegment {
  /// Constructs an AuthScopeSegment from the given [segment] string.
  ///
  /// The [segment] string is expected to be in the format "name.modifier" or "name".
  /// If a modifier is present, it is stored in the [modifier] field. If not, [modifier]
  /// remains null. The [name] field always contains the name of the segment.
  ///
  /// Parameters:
  ///   [segment]: A [String] representing the segment, which may include a modifier.
  _AuthScopeSegment(String segment) {
    final split = segment.split(".");
    if (split.length == 2) {
      name = split.first;
      modifier = split.last;
    } else {
      name = segment;
    }
  }

  /// The name of the segment.
  ///
  /// This property represents the main part of the segment before any modifier.
  /// For example, in the segment "user.readonly", "user" would be the name.
  ///
  /// This value can be null if the segment is empty or malformed.
  String? name;

  /// The modifier of the segment, if present.
  ///
  /// This property represents the optional part of the segment after the name,
  /// if a modifier is specified. For example, in the segment "user.readonly",
  /// "readonly" would be the modifier.
  ///
  /// If no modifier is present in the segment, this value is null.
  String? modifier;

  /// Returns a string representation of this AuthScopeSegment.
  ///
  /// This method overrides the default [Object.toString] method to provide
  /// a string representation of the AuthScopeSegment instance.
  ///
  /// If the segment has a modifier, it returns the name and modifier
  /// separated by a dot (e.g., "name.modifier").
  /// If there's no modifier, it returns just the name.
  ///
  /// Returns:
  ///   A [String] representing the complete segment, including the
  ///   modifier if present.
  ///
  /// Example:
  ///   final segment = _AuthScopeSegment('user.readonly');
  ///   print(segment.toString()); // Outputs: 'user.readonly'
  ///
  ///   final segmentNoModifier = _AuthScopeSegment('user');
  ///   print(segmentNoModifier.toString()); // Outputs: 'user'
  @override
  String toString() {
    if (modifier == null) {
      return name!;
    }
    return "$name.$modifier";
  }
}
