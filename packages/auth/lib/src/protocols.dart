/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'package:protevus_auth/auth.dart';

/// Defines the interface for a Resource Owner in OAuth 2.0 authentication.
///
/// Your application's 'user' type must implement the methods declared in this interface. [AuthServer] can
/// validate the credentials of a [ResourceOwner] to grant authorization codes and access tokens on behalf of that
/// owner.
abstract class ResourceOwner {
  /// The username of the resource owner.
  ///
  /// This property represents the unique identifier for a resource owner, typically used for authentication purposes.
  /// It must be unique among all resource owners in the system. Often, this value is an email address.
  ///
  /// The username is used by authenticating users to identify their account when logging in or performing
  /// other authentication-related actions.
  ///
  /// This property is nullable, which means it can be null in some cases, such as when creating a new
  /// resource owner instance before setting the username.
  String? username;

  /// The hashed password of this instance.
  ///
  /// This property stores the password of the resource owner in a hashed format.
  /// Hashing is a one-way process that converts the plain text password into a
  /// fixed-length string of characters, which is more secure to store than the
  /// original password.
  ///
  /// The hashed password is used for password verification during authentication
  /// without storing the actual password. This enhances security by ensuring
  /// that even if the database is compromised, the original passwords remain
  /// unknown.
  ///
  /// This property is nullable, allowing for cases where a password might not
  /// be set or required for certain types of resource owners.
  String? hashedPassword;

  /// The salt used in the hashing process for [hashedPassword].
  ///
  /// A salt is a random string that is added to the password before hashing,
  /// which adds an extra layer of security to the hashed password. It helps
  /// protect against rainbow table attacks and ensures that even if two users
  /// have the same password, their hashed passwords will be different.
  ///
  /// This property is nullable to accommodate cases where a salt might not be
  /// used or stored separately from the hashed password.
  String? salt;

  /// A unique identifier of this resource owner.
  ///
  /// This property represents a unique identifier for the resource owner, typically
  /// used in authentication and authorization processes. The [AuthServer] uses this
  /// identifier to associate authorization codes and access tokens with the specific
  /// resource owner.
  ///
  /// The identifier is of type [int] and is nullable, allowing for cases where an ID
  /// might not be assigned yet (e.g., when creating a new resource owner instance).
  ///
  /// It's crucial to ensure that this ID remains unique across all resource owners
  /// in the system to maintain the integrity of the authentication and authorization
  /// processes.
  ///
  /// This getter method should be implemented to return the unique identifier of
  /// the resource owner.
  int? get id;
}

/// The methods used by an [AuthServer] to store information and customize behavior related to authorization.
///
/// An [AuthServer] requires an instance of this type to manage storage of [ResourceOwner]s, [AuthToken], [AuthCode],
/// and [AuthClient]s. You may also customize the token format or add more granular authorization scope rules.
///
/// Prefer to use `ManagedAuthDelegate` from 'package:conduit_core/managed_auth.dart' instead of implementing this interface;
/// there are important details to consider and test when implementing this interface.
///
/// This abstract class defines the contract for implementing an authentication and authorization system.
/// It provides methods for managing resource owners, clients, tokens, and authorization codes.
/// Implementations of this class are responsible for handling the storage, retrieval, and management
/// of these entities, as well as customizing certain behaviors of the authentication process.
///
/// Key responsibilities include:
/// - Managing resource owners (users)
/// - Handling client applications
/// - Storing and retrieving access and refresh tokens
/// - Managing authorization codes
/// - Customizing token formats and allowed scopes
///
/// Each method in this class corresponds to a specific operation in the OAuth 2.0 flow,
/// allowing for a flexible and extensible authentication system.
abstract class AuthServerDelegate {
  /// Retrieves a [ResourceOwner] based on the provided [username].
  ///
  /// This method must return an instance of [ResourceOwner] if one exists for [username]. Otherwise, it must return null.
  ///
  /// Every property declared by [ResourceOwner] must be non-null in the return value.
  ///
  /// [server] is the [AuthServer] invoking this method.
  FutureOr<ResourceOwner?> getResourceOwner(AuthServer server, String username);

  /// Stores a new [AuthClient] in the system.
  ///
  /// [client] must be returned by [getClient] after this method has been invoked, and until (if ever)
  /// [removeClient] is invoked.
  FutureOr addClient(AuthServer server, AuthClient client);

  /// Retrieves an [AuthClient] based on the provided client ID.
  ///
  /// This method must return an instance of [AuthClient] if one exists for [clientID]. Otherwise, it must return null.
  /// [server] is the [AuthServer] requesting the [AuthClient].
  FutureOr<AuthClient?> getClient(AuthServer server, String clientID);

  /// Removes an [AuthClient] for a given client ID.
  ///
  /// This method must delete the [AuthClient] for [clientID]. Subsequent requests to this
  /// instance for [getClient] must return null after this method completes. If there is no
  /// matching [clientID], this method may choose whether to throw an exception or fail silently.
  ///
  /// [server] is the [AuthServer] requesting the [AuthClient].
  FutureOr removeClient(AuthServer server, String clientID);

  /// Retrieves an [AuthToken] based on either its access token or refresh token.
  ///
  /// Exactly one of [byAccessToken] and [byRefreshToken] may be non-null, if not, this method must throw an error.
  ///
  /// If [byAccessToken] is not-null and there exists a matching [AuthToken.accessToken], return that token.
  /// If [byRefreshToken] is not-null and there exists a matching [AuthToken.refreshToken], return that token.
  ///
  /// If no match is found, return null.
  ///
  /// [server] is the [AuthServer] requesting the [AuthToken].
  FutureOr<AuthToken?> getToken(
    AuthServer server, {
    String? byAccessToken,
    String? byRefreshToken,
  });

  /// Deletes all [AuthToken]s and [AuthCode]s associated with a specific [ResourceOwner].
  ///
  /// [server] is the requesting [AuthServer]. [resourceOwnerID] is the [ResourceOwner.id].
  FutureOr removeTokens(AuthServer server, int resourceOwnerID);

  /// Deletes an [AuthToken] that was granted by a specific [AuthCode].
  ///
  /// If an [AuthToken] has been granted by exchanging [AuthCode], that token must be revoked
  /// and can no longer be used to authorize access to a resource. [grantedByCode] should
  /// also be removed.
  ///
  /// This method is invoked when attempting to exchange an authorization code that has already granted a token.
  FutureOr removeToken(AuthServer server, AuthCode grantedByCode);

  /// Stores an [AuthToken] in the system.
  ///
  /// [token] must be stored such that it is accessible from [getToken], and until it is either
  /// revoked via [removeToken] or [removeTokens], or until it has expired and can reasonably
  /// be believed to no longer be in use.
  ///
  /// You may alter [token] prior to storing it. This may include replacing [AuthToken.accessToken] with another token
  /// format. The default token format will be a random 32 character string.
  ///
  /// If this token was granted through an authorization code, [issuedFrom] is that code. Otherwise, [issuedFrom]
  /// is null.
  FutureOr addToken(AuthServer server, AuthToken token, {AuthCode? issuedFrom});

  /// Updates an existing [AuthToken] with new values.
  ///
  /// This method must must update an existing [AuthToken], found by [oldAccessToken],
  /// with the values [newAccessToken], [newIssueDate] and [newExpirationDate].
  ///
  /// You may alter the token in addition to the provided values, and you may override the provided values.
  /// [newAccessToken] defaults to a random 32 character string.
  FutureOr updateToken(
    AuthServer server,
    String? oldAccessToken,
    String? newAccessToken,
    DateTime? newIssueDate,
    DateTime? newExpirationDate,
  );

  /// Stores an [AuthCode] in the system.
  ///
  /// [code] must be accessible until its expiration date.
  FutureOr addCode(AuthServer server, AuthCode code);

  /// Retrieves an [AuthCode] based on its identifying code.
  ///
  /// This must return an instance of [AuthCode] where [AuthCode.code] matches [code].
  /// Return null if no matching code.
  FutureOr<AuthCode?> getCode(AuthServer server, String code);

  /// Removes an [AuthCode] from the system based on its identifying code.
  ///
  /// The [AuthCode.code] matching [code] must be deleted and no longer accessible.
  FutureOr removeCode(AuthServer server, String? code);

  /// Returns a list of allowed scopes for a given [ResourceOwner].
  ///
  /// Subclasses override this method to return a list of [AuthScope]s based on some attribute(s) of an [ResourceOwner].
  /// That [ResourceOwner] is then restricted to only those scopes, even if the authenticating client would allow other scopes
  /// or scopes with higher privileges.
  ///
  /// By default, this method returns [AuthScope.any] - any [ResourceOwner] being authenticated has full access to the scopes
  /// available to the authenticating client.
  ///
  /// When overriding this method, it is important to note that (by default) only the properties declared by [ResourceOwner]
  /// will be valid for [owner]. If [owner] has properties that are application-specific (like a `role`),
  /// [getResourceOwner] must also be overridden to ensure those values are fetched.
  List<AuthScope>? getAllowedScopes(ResourceOwner owner) => AuthScope.any;
}
