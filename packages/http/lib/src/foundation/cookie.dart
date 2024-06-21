/*
 * This file is part of the VieoFabric package.
 *
 * (c) Patrick Stewart <patrick@example.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'header_utils.dart';
import 'dart:math';

/// Represents a cookie.
class Cookie {
  static const String SAMESITE_NONE = 'none';
  static const String SAMESITE_LAX = 'lax';
  static const String SAMESITE_STRICT = 'strict';

  late String name;
  String? value;
  String? domain;
  late int expire;
  late String path;
  bool? secure;
  late bool httpOnly;

  late bool raw;
  String? sameSite;
  late bool partitioned;
  late bool secureDefault;

  static const String RESERVED_CHARS_LIST = "=,; \t\r\n\v\f";
  static const List<String> RESERVED_CHARS_FROM = ['=', ',', ';', ' ', "\t", "\r", "\n", "\v", "\f"];
  static const List<String> RESERVED_CHARS_TO = ['%3D', '%2C', '%3B', '%20', '%09', '%0D', '%0A', '%0B', '%0C'];

  /// Creates cookie from raw header string.
static Cookie fromString(String cookie, {bool decode = false}) {
  final data = <String, Object?>{
    'expires': 0,
    'path': '/',
    'domain': null,
    'secure': false,
    'httponly': false,
    'raw': !decode,
    'samesite': null,
    'partitioned': false,
  };

  final parts = HeaderUtils.split(cookie, ';=');
  final part = parts.removeAt(0);

  final name = decode ? Uri.decodeComponent(part[0]) : part[0];
  final value = part.length > 1 ? (decode ? Uri.decodeComponent(part[1]) : part[1]) : null;

  data.addAll(HeaderUtils.combine(parts));
  data['expires'] = _expiresTimestamp(data['expires']);

  if (data.containsKey('max-age') && data['max-age'] != null && data['expires'] != null) {
    if ((data['max-age'] as int) > 0 || (data['expires'] as int) > DateTime.now().millisecondsSinceEpoch) {
      data['expires'] = DateTime.now().millisecondsSinceEpoch + (data['max-age'] as int);
    }
  }

  return Cookie._internal(
    name,
    value,
    data['expires'] as int,
    data['path'] as String,
    data['domain'] as String?,
    data['secure'] as bool,
    data['httponly'] as bool,
    data['raw'] as bool,
    data['samesite'] as String?,
    data['partitioned'] as bool,
  );
}

  /// Factory constructor for creating a new cookie.
  factory Cookie.create(String name, {String? value, dynamic expire = 0, String? path = '/', String? domain, bool? secure, bool httpOnly = true, bool raw = false, String? sameSite = SAMESITE_LAX, bool partitioned = false}) {
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  Cookie._internal(this.name, this.value, dynamic expire, String? path, this.domain, this.secure, this.httpOnly, this.raw, this.sameSite, this.partitioned) {
    if (raw && name.contains(RegExp(r'[' + RESERVED_CHARS_LIST + r']'))) {
      throw ArgumentError('The cookie name "$name" contains invalid characters.');
    }

    if (name.isEmpty) {
      throw ArgumentError('The cookie name cannot be empty.');
    }

    this.expire = _expiresTimestamp(expire);
    this.path = path ?? '/';
    this.secureDefault = false;
  }

  /// Creates a cookie copy with a new value.
  Cookie withValue(String? value) {
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Creates a cookie copy with a new domain that the cookie is available to.
  Cookie withDomain(String? domain) {
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Creates a cookie copy with a new time the cookie expires.
  Cookie withExpires(dynamic expire) {
    return Cookie._internal(name, value, _expiresTimestamp(expire), path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Converts expires formats to a unix timestamp.
  static int _expiresTimestamp(dynamic expire) {
    if (expire is DateTime) {
      return expire.millisecondsSinceEpoch ~/ 1000;
    } else if (expire is int) {
      return expire;
    } else if (expire is String) {
      return DateTime.parse(expire).millisecondsSinceEpoch ~/ 1000;
    } else {
      throw ArgumentError('The cookie expiration time is not valid.');
    }
  }

  /// Creates a cookie copy with a new path on the server in which the cookie will be available on.
  Cookie withPath(String path) {
    return Cookie._internal(name, value, expire, path.isEmpty ? '/' : path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Creates a cookie copy that only be transmitted over a secure HTTPS connection from the client.
  Cookie withSecure(bool secure) {
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Creates a cookie copy that be accessible only through the HTTP protocol.
  Cookie withHttpOnly(bool httpOnly) {
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Creates a cookie copy that uses no url encoding.
  Cookie withRaw(bool raw) {
    if (raw && name.contains(RegExp(r'[' + RESERVED_CHARS_LIST + r']'))) {
      throw ArgumentError('The cookie name "$name" contains invalid characters.');
    }
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Creates a cookie copy with SameSite attribute.
  Cookie withSameSite(String? sameSite) {
    final validSameSite = [SAMESITE_LAX, SAMESITE_STRICT, SAMESITE_NONE, null];
    if (!validSameSite.contains(sameSite?.toLowerCase())) {
      throw ArgumentError('The "sameSite" parameter value is not valid.');
    }
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite?.toLowerCase(), partitioned);
  }

  /// Creates a cookie copy that is tied to the top-level site in cross-site context.
  Cookie withPartitioned(bool partitioned) {
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Returns the cookie as a string.
  @override
  String toString() {
    final buffer = StringBuffer();

    if (raw) {
      buffer.write(name);
    } else {
      buffer.write(Uri.encodeComponent(name));
    }

    buffer.write('=');

    if (value == null || value!.isEmpty) {
      buffer.write('deleted; expires=${DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch - 31536001).toUtc().toIso8601String()}; Max-Age=0');
    } else {
      buffer.write(raw ? value : Uri.encodeComponent(value!));

      if (expire != 0) {
        buffer.write('; expires=${DateTime.fromMillisecondsSinceEpoch(expire * 1000).toUtc().toIso8601String()}; Max-Age=${getMaxAge()}');
      }
    }

    if (path.isNotEmpty) {
      buffer.write('; path=$path');
    }

    if (domain != null && domain!.isNotEmpty) {
      buffer.write('; domain=$domain');
    }

    if (isSecure()) {
      buffer.write('; secure');
    }

    if (httpOnly) {
      buffer.write('; httponly');
    }

    if (sameSite != null) {
      buffer.write('; samesite=$sameSite');
    }

    if (partitioned) {
      buffer.write('; partitioned');
    }

    return buffer.toString();
  }

  /// Gets the name of the cookie.
  String getName() => name;

  /// Gets the value of the cookie.
  String? getValue() => value;

  /// Gets the domain that the cookie is available to.
  String? getDomain() => domain;

  /// Gets the time the cookie expires.
  int getExpiresTime() => expire;

  /// Gets the max-age attribute.
  int getMaxAge() {
    final maxAge = expire - (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    return max(0, maxAge);
  }

  /// Gets the path on the server in which the cookie will be available on.
  String getPath() => path;

  /// Checks whether the cookie should only be transmitted over a secure HTTPS connection from the client.
  bool isSecure() => secure ?? secureDefault;

  /// Checks whether the cookie will be made accessible only through the HTTP protocol.
  bool isHttpOnly() => httpOnly;

  /// Whether this cookie is about to be cleared.
  bool isCleared() => expire != 0 && expire < (DateTime.now().millisecondsSinceEpoch ~/ 1000);

  /// Checks if the cookie value should be sent with no url encoding.
  bool isRaw() => raw;

  /// Checks whether the cookie should be tied to the top-level site in cross-site context.
  bool isPartitioned() => partitioned;

  /// Gets the SameSite attribute of the cookie.
  String? getSameSite() => sameSite;

  /// Sets the default value of the "secure" flag when it is set to null.
  void setSecureDefault(bool defaultSecure) {
    secureDefault = defaultSecure;
  }
}
