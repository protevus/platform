/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'dart:math';

import 'package:protevus_openapi/documentable.dart';
import 'package:protevus_auth/auth.dart';
import 'package:protevus_openapi/v3.dart';
import 'package:crypto/crypto.dart';

/// A OAuth 2.0 authorization server.
///
/// This class implements the core functionality of an OAuth 2.0 authorization server,
/// including client management, token issuance, token refresh, and token verification.
/// It supports various OAuth 2.0 flows such as password, client credentials, authorization code,
/// and refresh token.
///
/// [AuthServer]s are typically used in conjunction with [AuthController] and [AuthRedirectController].
/// These controllers provide HTTP interfaces to the [AuthServer] for issuing and refreshing tokens.
/// Likewise, [Authorizer]s verify these issued tokens to protect endpoint controllers.
///
/// [AuthServer]s can be customized through their [delegate]. This required property manages persistent storage of authorization
/// objects among other tasks. There are security considerations for [AuthServerDelegate] implementations; prefer to use a tested
/// implementation like `ManagedAuthDelegate` from `package:conduit_core/managed_auth.dart`.
///
/// Usage example with `ManagedAuthDelegate`:
///
///         import 'package:conduit_core/conduit_core.dart';
///         import 'package:conduit_core/managed_auth.dart';
///
///         class User extends ManagedObject<_User> implements _User, ManagedAuthResourceOwner {}
///         class _User extends ManagedAuthenticatable {}
///
///         class Channel extends ApplicationChannel {
///           ManagedContext context;
///           AuthServer authServer;
///
///           @override
///           Future prepare() async {
///             context = createContext();
///
///             final delegate = new ManagedAuthStorage<User>(context);
///             authServer = new AuthServer(delegate);
///           }
///
///           @override
///           Controller get entryPoint {
///             final router = new Router();
///             router
///               .route("/protected")
///               .link(() =>new Authorizer(authServer))
///               .link(() => new ProtectedResourceController());
///
///             router
///               .route("/auth/token")
///               .link(() => new AuthController(authServer));
///
///             return router;
///           }
///         }
///
class AuthServer implements AuthValidator, APIComponentDocumenter {
  /// This constructor initializes an [AuthServer] with the provided [delegate],
  /// which is responsible for managing authentication-related data storage and retrieval.
  ///
  /// Parameters:
  /// - [delegate]: An instance of [AuthServerDelegate] that handles data persistence.
  /// - [hashRounds]: The number of iterations for password hashing. Defaults to 1000.
  /// - [hashLength]: The length of the generated hash in bytes. Defaults to 32.
  /// - [hashFunction]: The hash function to use. Defaults to [sha256].
  ///
  /// The [hashRounds], [hashLength], and [hashFunction] parameters configure the
  /// password hashing mechanism used by this [AuthServer] instance. These values
  /// affect the security and performance of password hashing operations.
  ///
  /// Example:
  /// ```dart
  /// final delegate = MyAuthServerDelegate();
  /// final authServer = AuthServer(
  ///   delegate,
  ///   hashRounds: 1000,
  ///   hashLength: 32,
  ///   hashFunction: sha256,
  /// );
  /// ```
  AuthServer(
    this.delegate, {
    this.hashRounds = 1000,
    this.hashLength = 32,
    this.hashFunction = sha256,
  });

  /// The object responsible for carrying out the storage mechanisms of this instance.
  ///
  /// This instance is responsible for storing, fetching and deleting instances of
  /// [AuthToken], [AuthCode] and [AuthClient] by implementing the [AuthServerDelegate] interface.
  ///
  /// It is preferable to use the implementation of [AuthServerDelegate] from 'package:conduit_core/managed_auth.dart'. See
  /// [AuthServer] for more details.
  ///
  /// This delegate plays a crucial role in the OAuth 2.0 flow by managing the persistence
  /// of authentication-related objects. It abstracts away the storage implementation,
  /// allowing for flexibility in how these objects are stored (e.g., in-memory, database).
  ///
  /// The delegate is responsible for the following main tasks:
  /// 1. Storing and retrieving AuthClient information
  /// 2. Managing AuthToken lifecycle (creation, retrieval, and revocation)
  /// 3. Handling AuthCode operations for the authorization code flow
  /// 4. Fetching ResourceOwner information for authentication purposes
  ///
  /// Implementations of this delegate should ensure thread-safety and efficient
  /// data access to maintain the performance and security of the authentication server.
  final AuthServerDelegate delegate;

  /// The number of hashing rounds performed by this instance when validating a password.
  ///
  /// This value determines the number of iterations the password hashing algorithm
  /// will perform. A higher number of rounds increases the computational cost and
  /// time required to hash a password, making it more resistant to brute-force attacks.
  /// However, it also increases the time needed for legitimate password verification.
  ///
  /// The optimal value balances security and performance based on the specific
  /// requirements of the application. Common values range from 1000 to 50000,
  /// but may need adjustment based on hardware capabilities and security needs.
  final int hashRounds;

  /// The resulting key length of a password hash when generated by this instance.
  ///
  /// This value determines the length (in bytes) of the generated password hash.
  /// A longer hash length generally provides more security against certain types of attacks,
  /// but also requires more storage space. Common values range from 16 to 64 bytes.
  ///
  /// This parameter is used in conjunction with [hashRounds] and [hashFunction]
  /// to configure the password hashing algorithm (typically PBKDF2).
  final int hashLength;

  /// The [Hash] function used by the PBKDF2 algorithm to generate password hashes by this instance.
  ///
  /// This function is used in the password hashing process to create secure, one-way
  /// hashes of passwords. The PBKDF2 (Password-Based Key Derivation Function 2)
  /// algorithm uses this hash function repeatedly to increase the computational cost
  /// of cracking the resulting hash.
  ///
  /// By default, this is set to [sha256], but it can be customized to use other
  /// cryptographic hash functions if needed. The choice of hash function affects
  /// the security and performance characteristics of the password hashing process.
  ///
  /// This property works in conjunction with [hashRounds] and [hashLength] to
  /// configure the overall password hashing strategy of the AuthServer.
  final Hash hashFunction;

  /// Represents the OAuth 2.0 Authorization Code flow for OpenAPI documentation purposes.
  ///
  /// This property is used to document the Authorization Code flow in the OpenAPI
  /// specification generated for this AuthServer. It is initialized as an empty
  /// OAuth2 flow with an empty scopes map, which can be populated later with
  /// the specific scopes supported by the server.
  ///
  /// The Authorization Code flow is a secure way of obtaining access tokens
  /// that involves a client application directing the resource owner to an
  /// authorization server to grant permission, then using the resulting
  /// authorization code to obtain an access token.
  ///
  /// This property is typically used in conjunction with the `documentComponents`
  /// method to properly document the OAuth2 security scheme in the API specification.
  final APISecuritySchemeOAuth2Flow documentedAuthorizationCodeFlow =
      APISecuritySchemeOAuth2Flow.empty()..scopes = {};

  /// Represents the OAuth 2.0 Password flow for OpenAPI documentation purposes.
  ///
  /// This property is used to document the Password flow in the OpenAPI
  /// specification generated for this AuthServer. It is initialized as an empty
  /// OAuth2 flow with an empty scopes map, which can be populated later with
  /// the specific scopes supported by the server for the Password flow.
  ///
  /// The Password flow allows users to exchange their username and password
  /// directly for an access token. This flow should only be used by trusted
  /// applications due to its sensitivity in handling user credentials.
  ///
  /// This property is typically used in conjunction with the `documentComponents`
  /// method to properly document the OAuth2 security scheme in the API specification.
  final APISecuritySchemeOAuth2Flow documentedPasswordFlow =
      APISecuritySchemeOAuth2Flow.empty()..scopes = {};

  /// Represents the OAuth 2.0 Implicit flow for OpenAPI documentation purposes.
  ///
  /// This property is used to document the Implicit flow in the OpenAPI
  /// specification generated for this AuthServer. It is initialized as an empty
  /// OAuth2 flow with an empty scopes map, which can be populated later with
  /// the specific scopes supported by the server for the Implicit flow.
  ///
  /// The Implicit flow is designed for client-side applications (e.g., single-page web apps)
  /// where the access token is returned immediately without an extra authorization code
  /// exchange step. This flow has some security trade-offs and is generally not recommended
  /// for new implementations.
  ///
  /// This property is typically used in conjunction with the `documentComponents`
  /// method to properly document the OAuth2 security scheme in the API specification.
  final APISecuritySchemeOAuth2Flow documentedImplicitFlow =
      APISecuritySchemeOAuth2Flow.empty()..scopes = {};

  /// Constant representing the token type "bearer" for OAuth 2.0 access tokens.
  ///
  /// This value is used to specify the type of token issued by the authorization server.
  /// The "bearer" token type is defined in RFC 6750 and is the most common type used in OAuth 2.0.
  /// Bearer tokens can be used by any party in possession of the token to access protected resources
  /// without demonstrating possession of a cryptographic key.
  static const String tokenTypeBearer = "bearer";

  /// Hashes a password using the PBKDF2 algorithm.
  ///
  /// See [hashRounds], [hashLength] and [hashFunction] for more details. This method
  /// invoke [auth.generatePasswordHash] with the above inputs.
  String hashPassword(String password, String salt) {
    return generatePasswordHash(
      password,
      salt,
      hashRounds: hashRounds,
      hashLength: hashLength,
      hashFunction: hashFunction,
    );
  }

  /// Adds a new OAuth2 client to the authentication server.
  ///
  /// [delegate] will store this client for future use.
  Future addClient(AuthClient client) async {
    if (client.id.isEmpty) {
      throw ArgumentError(
        "A client must have an id.",
      );
    }

    if (client.redirectURI != null && client.hashedSecret == null) {
      throw ArgumentError(
        "A client with a redirectURI must have a client secret.",
      );
    }

    return delegate.addClient(this, client);
  }

  /// Retrieves an [AuthClient] record based on the provided [clientID].
  ///
  /// Returns null if none exists.
  Future<AuthClient?> getClient(String clientID) async {
    return delegate.getClient(this, clientID);
  }

  /// Revokes and removes an [AuthClient] record associated with the given [clientID].
  ///
  /// Removes cached occurrences of [AuthClient] for [clientID].
  /// Asks [delegate] to remove an [AuthClient] by its ID via [AuthServerDelegate.removeClient].
  Future removeClient(String clientID) async {
    if (clientID.isEmpty) {
      throw AuthServerException(AuthRequestError.invalidClient, null);
    }

    return delegate.removeClient(this, clientID);
  }

  /// Revokes all access grants for a specific resource owner.
  ///
  /// All authorization codes and tokens for the [ResourceOwner] identified by [identifier]
  /// will be revoked.
  Future revokeAllGrantsForResourceOwner(int? identifier) async {
    if (identifier == null) {
      throw ArgumentError.notNull("identifier");
    }

    await delegate.removeTokens(this, identifier);
  }

  /// Authenticates a username and password of a [ResourceOwner] and returns an [AuthToken] upon success.
  ///
  /// This method works with this instance's [delegate] to generate and store a new token if all credentials are correct.
  /// If credentials are not correct, it will throw the appropriate [AuthRequestError].
  ///
  /// After [expiration], this token will no longer be valid.
  Future<AuthToken> authenticate(
    String? username,
    String? password,
    String clientID,
    String? clientSecret, {
    Duration expiration = const Duration(hours: 24),
    List<AuthScope>? requestedScopes,
  }) async {
    if (clientID.isEmpty) {
      throw AuthServerException(AuthRequestError.invalidClient, null);
    }

    final client = await getClient(clientID);
    if (client == null) {
      throw AuthServerException(AuthRequestError.invalidClient, null);
    }

    if (username == null || password == null) {
      throw AuthServerException(AuthRequestError.invalidRequest, client);
    }

    if (client.isPublic) {
      if (!(clientSecret == null || clientSecret == "")) {
        throw AuthServerException(AuthRequestError.invalidClient, client);
      }
    } else {
      if (clientSecret == null) {
        throw AuthServerException(AuthRequestError.invalidClient, client);
      }

      if (client.hashedSecret != hashPassword(clientSecret, client.salt!)) {
        throw AuthServerException(AuthRequestError.invalidClient, client);
      }
    }

    final authenticatable = await delegate.getResourceOwner(this, username);
    if (authenticatable == null) {
      throw AuthServerException(AuthRequestError.invalidGrant, client);
    }

    final dbSalt = authenticatable.salt!;
    final dbPassword = authenticatable.hashedPassword;
    final hash = hashPassword(password, dbSalt);
    if (hash != dbPassword) {
      throw AuthServerException(AuthRequestError.invalidGrant, client);
    }

    final validScopes =
        _validatedScopes(client, authenticatable, requestedScopes);
    final token = _generateToken(
      authenticatable.id,
      client.id,
      expiration.inSeconds,
      allowRefresh: !client.isPublic,
      scopes: validScopes,
    );
    await delegate.addToken(this, token);

    return token;
  }

  /// Verifies the validity of an access token and returns an [Authorization] object.
  ///
  /// This method obtains an [AuthToken] for [accessToken] from [delegate] and then verifies that the token is valid.
  /// If the token is valid, an [Authorization] object is returned. Otherwise, an [AuthServerException] is thrown.
  Future<Authorization> verify(
    String? accessToken, {
    List<AuthScope>? scopesRequired,
  }) async {
    if (accessToken == null) {
      throw AuthServerException(AuthRequestError.invalidRequest, null);
    }

    final t = await delegate.getToken(this, byAccessToken: accessToken);
    if (t == null || t.isExpired) {
      throw AuthServerException(
        AuthRequestError.invalidGrant,
        AuthClient(t?.clientID ?? '', null, null),
      );
    }

    if (scopesRequired != null) {
      if (!AuthScope.verify(scopesRequired, t.scopes)) {
        throw AuthServerException(
          AuthRequestError.invalidScope,
          AuthClient(t.clientID, null, null),
        );
      }
    }

    return Authorization(
      t.clientID,
      t.resourceOwnerIdentifier,
      this,
      scopes: t.scopes,
    );
  }

  /// Refreshes a valid [AuthToken] instance.
  ///
  /// This method refreshes an existing [AuthToken] using its [refreshToken] for a given client ID.
  /// It coordinates with the instance's [delegate] to update the old token with a new access token
  /// and issue/expiration dates if successful. If unsuccessful, it throws an [AuthRequestError].
  ///
  /// The method performs several validation steps:
  /// 1. Verifies the client ID and retrieves the corresponding [AuthClient].
  /// 2. Checks for the presence of a refresh token.
  /// 3. Retrieves the existing token using the refresh token.
  /// 4. Validates the client secret.
  /// 5. Handles scope validation and updates:
  ///    - If new scopes are requested, it ensures they are subsets of existing scopes and allowed by the client.
  ///    - If no new scopes are requested, it verifies that existing scopes are still valid for the client.
  ///
  /// Parameters:
  /// - [refreshToken]: The refresh token of the [AuthToken] to be refreshed.
  /// - [clientID]: The ID of the client requesting the token refresh.
  /// - [clientSecret]: The secret of the client requesting the token refresh.
  /// - [requestedScopes]: Optional list of scopes to be applied to the refreshed token.
  ///
  /// Returns:
  /// A [Future] that resolves to a new [AuthToken] with updated access token, issue date, and expiration date.
  ///
  /// Throws:
  /// - [AuthServerException] with [AuthRequestError.invalidClient] if the client ID is invalid or empty.
  /// - [AuthServerException] with [AuthRequestError.invalidRequest] if the refresh token is missing.
  /// - [AuthServerException] with [AuthRequestError.invalidGrant] if the token is not found or doesn't match the client ID.
  /// - [AuthServerException] with [AuthRequestError.invalidClient] if the client secret is invalid.
  /// - [AuthServerException] with [AuthRequestError.invalidScope] if the requested scopes are invalid or not allowed.
  Future<AuthToken> refresh(
    String? refreshToken,
    String clientID,
    String? clientSecret, {
    List<AuthScope>? requestedScopes,
  }) async {
    if (clientID.isEmpty) {
      throw AuthServerException(AuthRequestError.invalidClient, null);
    }

    final client = await getClient(clientID);
    if (client == null) {
      throw AuthServerException(AuthRequestError.invalidClient, null);
    }

    if (refreshToken == null) {
      throw AuthServerException(AuthRequestError.invalidRequest, client);
    }

    final t = await delegate.getToken(this, byRefreshToken: refreshToken);
    if (t == null || t.clientID != clientID) {
      throw AuthServerException(AuthRequestError.invalidGrant, client);
    }

    if (clientSecret == null) {
      throw AuthServerException(AuthRequestError.invalidClient, client);
    }

    if (client.hashedSecret != hashPassword(clientSecret, client.salt!)) {
      throw AuthServerException(AuthRequestError.invalidClient, client);
    }

    var updatedScopes = t.scopes;
    if ((requestedScopes?.length ?? 0) != 0) {
      // If we do specify scope
      for (final incomingScope in requestedScopes!) {
        final hasExistingScopeOrSuperset = t.scopes!.any(
          (existingScope) => incomingScope.isSubsetOrEqualTo(existingScope),
        );

        if (!hasExistingScopeOrSuperset) {
          throw AuthServerException(AuthRequestError.invalidScope, client);
        }

        if (!client.allowsScope(incomingScope)) {
          throw AuthServerException(AuthRequestError.invalidScope, client);
        }
      }

      updatedScopes = requestedScopes;
    } else if (client.supportsScopes) {
      // Ensure we still have access to same scopes if we didn't specify any
      for (final incomingScope in t.scopes!) {
        if (!client.allowsScope(incomingScope)) {
          throw AuthServerException(AuthRequestError.invalidScope, client);
        }
      }
    }

    final diff = t.expirationDate!.difference(t.issueDate!);
    final now = DateTime.now().toUtc();
    final newToken = AuthToken()
      ..accessToken = randomStringOfLength(32)
      ..issueDate = now
      ..expirationDate = now.add(Duration(seconds: diff.inSeconds)).toUtc()
      ..refreshToken = t.refreshToken
      ..type = t.type
      ..scopes = updatedScopes
      ..resourceOwnerIdentifier = t.resourceOwnerIdentifier
      ..clientID = t.clientID;

    await delegate.updateToken(
      this,
      t.accessToken,
      newToken.accessToken,
      newToken.issueDate,
      newToken.expirationDate,
    );

    return newToken;
  }

  /// Creates a one-time use authorization code for a given client ID and user credentials.
  ///
  /// This method is part of the OAuth 2.0 Authorization Code flow. It authenticates a user
  /// with their username and password for a specific client, and if successful, generates
  /// a short-lived authorization code.
  ///
  /// The method performs several steps:
  /// 1. Validates the client ID and retrieves the client information.
  /// 2. Authenticates the user with the provided username and password.
  /// 3. Validates the requested scopes against the client's allowed scopes and the user's permissions.
  /// 4. Generates a new authorization code.
  /// 5. Stores the authorization code using the delegate.
  ///
  /// Parameters:
  /// - [username]: The username of the resource owner (user).
  /// - [password]: The password of the resource owner.
  /// - [clientID]: The ID of the client requesting the authorization code.
  /// - [expirationInSeconds]: The lifetime of the authorization code in seconds (default is 600 seconds or 10 minutes).
  /// - [requestedScopes]: Optional list of scopes the client is requesting access to.
  ///
  /// Returns:
  /// A [Future] that resolves to an [AuthCode] object representing the generated authorization code.
  ///
  /// Throws:
  /// - [AuthServerException] with [AuthRequestError.invalidClient] if the client ID is invalid or empty.
  /// - [AuthServerException] with [AuthRequestError.invalidRequest] if the username or password is missing.
  /// - [AuthServerException] with [AuthRequestError.unauthorizedClient] if the client doesn't have a redirect URI.
  /// - [AuthServerException] with [AuthRequestError.accessDenied] if the user credentials are invalid.
  ///
  /// The generated authorization code can later be exchanged for an access token using the `exchange` method.
  Future<AuthCode> authenticateForCode(
    String? username,
    String? password,
    String clientID, {
    int expirationInSeconds = 600,
    List<AuthScope>? requestedScopes,
  }) async {
    if (clientID.isEmpty) {
      throw AuthServerException(AuthRequestError.invalidClient, null);
    }

    final client = await getClient(clientID);
    if (client == null) {
      throw AuthServerException(AuthRequestError.invalidClient, null);
    }

    if (username == null || password == null) {
      throw AuthServerException(AuthRequestError.invalidRequest, client);
    }

    if (client.redirectURI == null) {
      throw AuthServerException(AuthRequestError.unauthorizedClient, client);
    }

    final authenticatable = await delegate.getResourceOwner(this, username);
    if (authenticatable == null) {
      throw AuthServerException(AuthRequestError.accessDenied, client);
    }

    final dbSalt = authenticatable.salt;
    final dbPassword = authenticatable.hashedPassword;
    if (hashPassword(password, dbSalt!) != dbPassword) {
      throw AuthServerException(AuthRequestError.accessDenied, client);
    }

    final validScopes =
        _validatedScopes(client, authenticatable, requestedScopes);
    final authCode = _generateAuthCode(
      authenticatable.id,
      client,
      expirationInSeconds,
      scopes: validScopes,
    );
    await delegate.addCode(this, authCode);
    return authCode;
  }

  /// Exchanges a valid authorization code for an [AuthToken].
  ///
  /// This method is part of the OAuth 2.0 Authorization Code flow. It allows a client
  /// to exchange a previously obtained authorization code for an access token.
  ///
  /// The method performs several validation steps:
  /// 1. Verifies the client ID and retrieves the corresponding [AuthClient].
  /// 2. Checks for the presence of the authorization code.
  /// 3. Validates the client secret.
  /// 4. Retrieves and validates the stored authorization code.
  /// 5. Checks if the authorization code is still valid and hasn't been used.
  /// 6. Ensures the client ID matches the one associated with the authorization code.
  ///
  /// If all validations pass, it generates a new access token and stores it using the delegate.
  ///
  /// Parameters:
  /// - [authCodeString]: The authorization code to be exchanged.
  /// - [clientID]: The ID of the client requesting the token exchange.
  /// - [clientSecret]: The secret of the client requesting the token exchange.
  /// - [expirationInSeconds]: The lifetime of the generated access token in seconds (default is 3600 seconds or 1 hour).
  ///
  /// Returns:
  /// A [Future] that resolves to an [AuthToken] representing the newly created access token.
  ///
  /// Throws:
  /// - [AuthServerException] with [AuthRequestError.invalidClient] if the client ID is invalid or empty, or if the client secret is incorrect.
  /// - [AuthServerException] with [AuthRequestError.invalidRequest] if the authorization code is missing.
  /// - [AuthServerException] with [AuthRequestError.invalidGrant] if the authorization code is invalid, expired, or has been used before.
  ///
  /// This method is crucial for completing the Authorization Code flow, allowing clients
  /// to securely obtain access tokens after receiving user authorization.
  Future<AuthToken> exchange(
    String? authCodeString,
    String clientID,
    String? clientSecret, {
    int expirationInSeconds = 3600,
  }) async {
    if (clientID.isEmpty) {
      throw AuthServerException(AuthRequestError.invalidClient, null);
    }

    final client = await getClient(clientID);
    if (client == null) {
      throw AuthServerException(AuthRequestError.invalidClient, null);
    }

    if (authCodeString == null) {
      throw AuthServerException(AuthRequestError.invalidRequest, null);
    }

    if (clientSecret == null) {
      throw AuthServerException(AuthRequestError.invalidClient, client);
    }

    if (client.hashedSecret != hashPassword(clientSecret, client.salt!)) {
      throw AuthServerException(AuthRequestError.invalidClient, client);
    }

    final authCode = await delegate.getCode(this, authCodeString);
    if (authCode == null) {
      throw AuthServerException(AuthRequestError.invalidGrant, client);
    }

    // check if valid still
    if (authCode.isExpired) {
      await delegate.removeCode(this, authCode.code);
      throw AuthServerException(AuthRequestError.invalidGrant, client);
    }

    // check that client ids match
    if (authCode.clientID != client.id) {
      throw AuthServerException(AuthRequestError.invalidGrant, client);
    }

    // check to see if has already been used
    if (authCode.hasBeenExchanged!) {
      await delegate.removeToken(this, authCode);

      throw AuthServerException(AuthRequestError.invalidGrant, client);
    }
    final token = _generateToken(
      authCode.resourceOwnerIdentifier,
      client.id,
      expirationInSeconds,
      scopes: authCode.requestedScopes,
    );
    await delegate.addToken(this, token, issuedFrom: authCode);

    return token;
  }

  //////
  // APIDocumentable overrides
  //////

  /// Generates and registers security schemes for API documentation.
  ///
  /// This method is responsible for documenting the security components of the API,
  /// specifically the OAuth2 client authentication and standard OAuth2 flows.
  ///
  /// It performs the following tasks:
  /// 1. Registers a basic HTTP authentication scheme for OAuth2 client authentication.
  /// 2. Creates and registers an OAuth2 security scheme with authorization code and password flows.
  /// 3. Defers cleanup of unused flows based on the presence of required URLs.
  ///
  /// The method uses the [APIDocumentContext] to register these security schemes,
  /// making them available for use in the API documentation.
  ///
  /// Parameters:
  /// - [context]: The [APIDocumentContext] used to register security schemes and defer cleanup operations.
  @override
  void documentComponents(APIDocumentContext context) {
    final basic = APISecurityScheme.http("basic")
      ..description =
          "This endpoint requires an OAuth2 Client ID and Secret as the Basic Authentication username and password. "
              "If the client ID does not have a secret (public client), the password is the empty string (retain the separating colon, e.g. 'com.conduit.app:').";
    context.securitySchemes.register("oauth2-client-authentication", basic);

    final oauth2 = APISecurityScheme.oauth2({
      "authorizationCode": documentedAuthorizationCodeFlow,
      "password": documentedPasswordFlow
    })
      ..description = "Standard OAuth 2.0";

    context.securitySchemes.register("oauth2", oauth2);

    context.defer(() {
      if (documentedAuthorizationCodeFlow.authorizationURL == null) {
        oauth2.flows!.remove("authorizationCode");
      }

      if (documentedAuthorizationCodeFlow.tokenURL == null) {
        oauth2.flows!.remove("authorizationCode");
      }

      if (documentedPasswordFlow.tokenURL == null) {
        oauth2.flows!.remove("password");
      }
    });
  }

  /////
  // AuthValidator overrides
  /////

  /// Documents the security requirements for an [Authorizer] in the API specification.
  ///
  /// This method generates the appropriate [APISecurityRequirement] objects
  /// based on the type of authorization parser used by the [Authorizer].
  ///
  /// For basic authentication (AuthorizationBasicParser), it specifies the
  /// requirement for OAuth2 client authentication.
  ///
  /// For bearer token authentication (AuthorizationBearerParser), it specifies
  /// the requirement for OAuth2 with optional scopes.
  ///
  /// Parameters:
  /// - [context]: The API documentation context.
  /// - [authorizer]: The Authorizer instance for which to generate requirements.
  /// - [scopes]: Optional list of scopes to be included in the OAuth2 requirement.
  ///
  /// Returns:
  /// A list of [APISecurityRequirement] objects representing the security
  /// requirements for the given authorizer. Returns an empty list if the
  /// parser type is not recognized.
  @override
  List<APISecurityRequirement> documentRequirementsForAuthorizer(
    APIDocumentContext context,
    Authorizer authorizer, {
    List<AuthScope>? scopes,
  }) {
    if (authorizer.parser is AuthorizationBasicParser) {
      return [
        APISecurityRequirement({"oauth2-client-authentication": []})
      ];
    } else if (authorizer.parser is AuthorizationBearerParser) {
      return [
        APISecurityRequirement(
          {"oauth2": scopes?.map((s) => s.toString()).toList() ?? []},
        )
      ];
    }

    return [];
  }

  /// Validates an authorization request using the specified parser and authorization data.
  ///
  /// This method is responsible for validating different types of authorization,
  /// including client credentials (Basic) and bearer tokens.
  ///
  /// Parameters:
  /// - [parser]: An instance of [AuthorizationParser] used to parse the authorization data.
  /// - [authorizationData]: The authorization data to be validated, type depends on the parser.
  /// - [requiredScope]: Optional list of [AuthScope]s required for the authorization.
  ///
  /// Returns:
  /// A [FutureOr<Authorization>] representing the validated authorization.
  ///
  /// Throws:
  /// - [ArgumentError] if an invalid parser is provided.
  ///
  /// The method behaves differently based on the type of parser:
  /// - For [AuthorizationBasicParser], it validates client credentials.
  /// - For [AuthorizationBearerParser], it verifies the bearer token.
  @override
  FutureOr<Authorization> validate<T>(
    AuthorizationParser<T> parser,
    T authorizationData, {
    List<AuthScope>? requiredScope,
  }) {
    if (parser is AuthorizationBasicParser) {
      final credentials = authorizationData as AuthBasicCredentials;
      return _validateClientCredentials(credentials);
    } else if (parser is AuthorizationBearerParser) {
      return verify(authorizationData as String, scopesRequired: requiredScope);
    }

    throw ArgumentError(
      "Invalid 'parser' for 'AuthServer.validate'. Use 'AuthorizationBasicParser' or 'AuthorizationBearerHeader'.",
    );
  }

  /// Validates client credentials for OAuth 2.0 client authentication.
  ///
  /// This method is used to authenticate a client using its client ID and secret
  /// as part of the OAuth 2.0 client authentication process.
  ///
  /// The method performs the following steps:
  /// 1. Retrieves the client using the provided client ID (username).
  /// 2. Validates the client's existence and secret.
  /// 3. For public clients (no secret), it allows authentication with an empty password.
  /// 4. For confidential clients, it verifies the provided password against the stored hashed secret.
  ///
  /// Parameters:
  /// - [credentials]: An [AuthBasicCredentials] object containing the client ID (username) and secret (password).
  ///
  /// Returns:
  /// A [Future<Authorization>] representing the authenticated client.
  ///
  /// Throws:
  /// - [AuthServerException] with [AuthRequestError.invalidClient] if:
  ///   - The client is not found.
  ///   - A public client provides a non-empty password.
  ///   - A confidential client provides an incorrect secret.
  ///
  /// This method is typically used in the context of the client credentials grant type
  /// or when a client needs to authenticate itself for other OAuth 2.0 flows.
  Future<Authorization> _validateClientCredentials(
    AuthBasicCredentials credentials,
  ) async {
    final username = credentials.username;
    final password = credentials.password;

    final client = await getClient(username);

    if (client == null) {
      throw AuthServerException(AuthRequestError.invalidClient, null);
    }

    if (client.hashedSecret == null) {
      if (password == "") {
        return Authorization(client.id, null, this, credentials: credentials);
      }

      throw AuthServerException(AuthRequestError.invalidClient, client);
    }

    if (client.hashedSecret != hashPassword(password, client.salt!)) {
      throw AuthServerException(AuthRequestError.invalidClient, client);
    }

    return Authorization(client.id, null, this, credentials: credentials);
  }

  /// Validates and filters the requested scopes for a client and resource owner.
  ///
  /// This method checks the requested scopes against the client's allowed scopes
  /// and the resource owner's permitted scopes. It ensures that only valid and
  /// authorized scopes are granted.
  ///
  /// Parameters:
  /// - [client]: The [AuthClient] requesting the scopes.
  /// - [authenticatable]: The [ResourceOwner] being authenticated.
  /// - [requestedScopes]: The list of [AuthScope]s requested by the client.
  ///
  /// Returns:
  /// A list of validated [AuthScope]s that are allowed for both the client and
  /// the resource owner. Returns null if the client doesn't support scopes.
  ///
  /// Throws:
  /// - [AuthServerException] with [AuthRequestError.invalidScope] if:
  ///   - The client supports scopes but no scopes are requested.
  ///   - None of the requested scopes are allowed for the client.
  ///   - The filtered scopes are not allowed for the resource owner.
  ///
  /// This method is crucial for maintaining the principle of least privilege
  /// in OAuth 2.0 flows by ensuring that tokens are issued with appropriate scopes.
  List<AuthScope>? _validatedScopes(
    AuthClient client,
    ResourceOwner authenticatable,
    List<AuthScope>? requestedScopes,
  ) {
    List<AuthScope>? validScopes;
    if (client.supportsScopes) {
      if ((requestedScopes?.length ?? 0) == 0) {
        throw AuthServerException(AuthRequestError.invalidScope, client);
      }

      validScopes = requestedScopes!
          .where((incomingScope) => client.allowsScope(incomingScope))
          .toList();

      if (validScopes.isEmpty) {
        throw AuthServerException(AuthRequestError.invalidScope, client);
      }

      final validScopesForAuthenticatable =
          delegate.getAllowedScopes(authenticatable);
      if (!identical(validScopesForAuthenticatable, AuthScope.any)) {
        validScopes.retainWhere(
          (clientAllowedScope) => validScopesForAuthenticatable!.any(
            (userScope) => clientAllowedScope.isSubsetOrEqualTo(userScope),
          ),
        );

        if (validScopes.isEmpty) {
          throw AuthServerException(AuthRequestError.invalidScope, client);
        }
      }
    }

    return validScopes;
  }

  /// Generates a new [AuthToken] with the specified parameters.
  ///
  /// This method creates and initializes a new [AuthToken] object with the given
  /// owner ID, client ID, and expiration time. It also sets other properties such
  /// as the access token, issue date, token type, and optional refresh token.
  ///
  /// Parameters:
  /// - [ownerID]: The identifier of the resource owner (user).
  /// - [clientID]: The identifier of the client application.
  /// - [expirationInSeconds]: The number of seconds until the token expires.
  /// - [allowRefresh]: Whether to generate a refresh token (default is true).
  /// - [scopes]: Optional list of scopes associated with the token.
  ///
  /// Returns:
  /// A new [AuthToken] instance with all properties set according to the input parameters.
  ///
  /// The access token and refresh token (if allowed) are generated as random strings.
  /// The token type is set to "bearer" as defined by [tokenTypeBearer].
  AuthToken _generateToken(
    int? ownerID,
    String clientID,
    int expirationInSeconds, {
    bool allowRefresh = true,
    List<AuthScope>? scopes,
  }) {
    final now = DateTime.now().toUtc();
    final token = AuthToken()
      ..accessToken = randomStringOfLength(32)
      ..issueDate = now
      ..expirationDate = now.add(Duration(seconds: expirationInSeconds))
      ..type = tokenTypeBearer
      ..resourceOwnerIdentifier = ownerID
      ..scopes = scopes
      ..clientID = clientID;

    if (allowRefresh) {
      token.refreshToken = randomStringOfLength(32);
    }

    return token;
  }

  /// Generates a new [AuthCode] with the specified parameters.
  ///
  /// This method creates and initializes a new [AuthCode] object with the given
  /// owner ID, client, and expiration time. It also sets other properties such
  /// as the authorization code, issue date, and optional scopes.
  ///
  /// Parameters:
  /// - [ownerID]: The identifier of the resource owner (user).
  /// - [client]: The [AuthClient] for which the auth code is being generated.
  /// - [expirationInSeconds]: The number of seconds until the auth code expires.
  /// - [scopes]: Optional list of scopes associated with the auth code.
  ///
  /// Returns:
  /// A new [AuthCode] instance with all properties set according to the input parameters.
  ///
  /// The authorization code is generated as a random string of 32 characters.
  /// The issue date is set to the current UTC time, and the expiration date is
  /// calculated based on the [expirationInSeconds] parameter.
  AuthCode _generateAuthCode(
    int? ownerID,
    AuthClient client,
    int expirationInSeconds, {
    List<AuthScope>? scopes,
  }) {
    final now = DateTime.now().toUtc();
    return AuthCode()
      ..code = randomStringOfLength(32)
      ..clientID = client.id
      ..resourceOwnerIdentifier = ownerID
      ..issueDate = now
      ..requestedScopes = scopes
      ..expirationDate = now.add(Duration(seconds: expirationInSeconds));
  }
}

/// Generates a random string of specified length.
///
/// This function creates a random string using a combination of uppercase letters,
/// lowercase letters, and digits. It uses a cryptographically secure random number
/// generator to ensure unpredictability.
///
/// The function works by repeatedly selecting random characters from a predefined
/// set of possible characters and appending them to a string buffer. The selection
/// process uses the modulo operation to ensure an even distribution across the
/// character set.
///
/// Returns:
/// A string of the specified [length] containing random characters.
String randomStringOfLength(int length) {
  const possibleCharacters =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  final buff = StringBuffer();

  final r = Random.secure();
  for (int i = 0; i < length; i++) {
    buff.write(
      possibleCharacters[r.nextInt(1000) % possibleCharacters.length],
    );
  }

  return buff.toString();
}
