import 'package:meta/meta.dart';

/// Configuration options for the session system.
@immutable
class SessionConfig {
  /// The session storage driver to use.
  final String driver;

  /// The session lifetime in minutes.
  final int lifetime;

  /// Whether to expire the session on browser close.
  final bool expireOnClose;

  /// The session cookie name.
  final String cookieName;

  /// The path where the session cookie is valid.
  final String path;

  /// The domain where the session cookie is valid.
  final String? domain;

  /// Whether the cookie should only be sent over HTTPS.
  final bool secure;

  /// Whether the cookie should be HTTP only.
  final bool httpOnly;

  /// Whether to use same-site cookie attribute.
  final String sameSite;

  /// Whether to encrypt the session data.
  final bool encrypt;

  /// The serializer to use for session data.
  final String serializer;

  /// Creates a new session configuration.
  const SessionConfig({
    this.driver = 'file',
    this.lifetime = 120,
    this.expireOnClose = false,
    this.cookieName = 'platform_session',
    this.path = '/',
    this.domain,
    this.secure = false,
    this.httpOnly = true,
    this.sameSite = 'lax',
    this.encrypt = false,
    this.serializer = 'json',
  });

  /// Creates a copy of this configuration with the given changes.
  SessionConfig copyWith({
    String? driver,
    int? lifetime,
    bool? expireOnClose,
    String? cookieName,
    String? path,
    String? domain,
    bool? secure,
    bool? httpOnly,
    String? sameSite,
    bool? encrypt,
    String? serializer,
  }) {
    return SessionConfig(
      driver: driver ?? this.driver,
      lifetime: lifetime ?? this.lifetime,
      expireOnClose: expireOnClose ?? this.expireOnClose,
      cookieName: cookieName ?? this.cookieName,
      path: path ?? this.path,
      domain: domain ?? this.domain,
      secure: secure ?? this.secure,
      httpOnly: httpOnly ?? this.httpOnly,
      sameSite: sameSite ?? this.sameSite,
      encrypt: encrypt ?? this.encrypt,
      serializer: serializer ?? this.serializer,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionConfig &&
          runtimeType == other.runtimeType &&
          driver == other.driver &&
          lifetime == other.lifetime &&
          expireOnClose == other.expireOnClose &&
          cookieName == other.cookieName &&
          path == other.path &&
          domain == other.domain &&
          secure == other.secure &&
          httpOnly == other.httpOnly &&
          sameSite == other.sameSite &&
          encrypt == other.encrypt &&
          serializer == other.serializer;

  @override
  int get hashCode =>
      driver.hashCode ^
      lifetime.hashCode ^
      expireOnClose.hashCode ^
      cookieName.hashCode ^
      path.hashCode ^
      domain.hashCode ^
      secure.hashCode ^
      httpOnly.hashCode ^
      sameSite.hashCode ^
      encrypt.hashCode ^
      serializer.hashCode;

  @override
  String toString() =>
      'SessionConfig(driver: $driver, lifetime: $lifetime, expireOnClose: $expireOnClose, '
      'cookieName: $cookieName, path: $path, domain: $domain, secure: $secure, '
      'httpOnly: $httpOnly, sameSite: $sameSite, encrypt: $encrypt, serializer: $serializer)';
}
