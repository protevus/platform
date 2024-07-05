/*
 * This file is part of the Protevus Platform.
 * This file is a port of the symfony Cookie.php class to Dart
 *
 * (C) Protevus <developers@protevus.com>
 * (C) Fabien Potencier <fabien@symfony.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:math';
import 'package:protevus_http/foundation.dart';

/// Represents an HTTP cookie.
///
/// This class encapsulates all the attributes and behaviors of an HTTP cookie,
/// including its name, value, expiration, path, domain, security settings,
/// and other properties like SameSite and Partitioned.
///
/// It provides methods to create, modify, and inspect cookie properties,
/// as well as to convert cookies to their string representation for use
/// in HTTP headers.
///
/// The Cookie class supports various cookie attributes and security features,
/// allowing for fine-grained control over cookie behavior in web applications.
class Cookie {

/// Constant representing the 'None' value for the SameSite cookie attribute.
///
/// When set to 'none', the cookie will be sent with all cross-site requests,
/// including both cross-site reading and cross-site writing. This setting
/// requires the 'Secure' flag to be set in modern browsers.
///
/// Note: Using 'none' may have security implications and should be used
/// carefully, as it allows the cookie to be sent in all contexts.
  static const String SAMESITE_NONE = 'none';

/// Constant representing the 'Lax' value for the SameSite cookie attribute.
///
/// When set to 'lax', the cookie will be sent with top-level navigations and
/// will be sent along with GET requests initiated by third party websites.
/// This is less restrictive than 'Strict' but provides some protection against
/// CSRF attacks while allowing the cookie to be sent in more scenarios.
///
/// This is often used as a balance between security and functionality.
  static const String SAMESITE_LAX = 'lax';

/// Constant representing the 'Strict' value for the SameSite cookie attribute.
///
/// When set to 'strict', the cookie will only be sent for same-site requests.
/// This is the most restrictive setting and provides the highest level of protection
/// against cross-site request forgery (CSRF) attacks.
///
/// With this setting, the cookie will not be sent with any cross-site requests,
/// including when a user follows a link from an external site. This can enhance
/// security but may impact functionality in some cases where cross-site cookie
/// access is required.
  static const String SAMESITE_STRICT = 'strict';

/// The name of the cookie.
///
/// This property represents the name of the cookie, which is used to identify
/// the cookie when it's sent between the server and the client. The name is
/// a required field for any cookie and must be set when the cookie is created.
///
/// The 'late' keyword indicates that this property will be initialized before
/// it's used, but not necessarily at the point of declaration.
  late String name;

/// The value of the cookie.
///
/// This property represents the actual data stored in the cookie. It can be null
/// if the cookie is used for deletion (setting an expired cookie) or if it's a
/// flag-type cookie where the presence of the cookie itself is meaningful.
///
/// The value is typically a string, but it's declared as nullable (String?) to
/// allow for cases where a cookie might be set without a value or to represent
/// a not-yet-initialized state.
  String? value;

/// The domain that the cookie is available to.
///
/// This property represents the domain attribute of the cookie. When set, it specifies
/// which hosts are allowed to receive the cookie. It's important for controlling
/// the scope of the cookie, especially in scenarios involving subdomains.
///
/// If null, the cookie will only be sent to the host that set the cookie.
///
/// Note: The domain must be a valid domain string. Setting this incorrectly can
/// lead to security vulnerabilities or the cookie not being sent as expected.
  String? domain;

/// The expiration time of the cookie.
///
/// This property represents the time at which the cookie should expire, stored as a Unix timestamp
/// (seconds since the Unix epoch). When this time is reached, the cookie is considered expired
/// and should be discarded by the client.
///
/// The 'late' keyword indicates that this property will be initialized before it's used,
/// but not necessarily at the point of declaration. This allows for flexible initialization
/// patterns, such as setting the expiration time in a constructor or method after the object
/// is created.
///
/// A value of 0 typically indicates that the cookie does not have a specific expiration time
/// and should be treated as a session cookie (expires when the browsing session ends).
  late int expire;

/// The path on the server where the cookie will be available.
///
/// This property represents the path attribute of the cookie. It specifies the
/// subset of URLs in a domain for which the cookie is valid. When a cookie has a
/// path set, it will only be sent to the server for requests to that path and
/// its subdirectories.
///
/// The 'late' keyword indicates that this property will be initialized before
/// it's used, but not necessarily at the point of declaration. Typically, it's
/// set in the constructor or a method that initializes the cookie.
///
/// If not explicitly set, the default path is usually '/'.
  late String path;

/// Indicates whether the cookie should only be transmitted over a secure HTTPS connection.
///
/// This property is nullable:
/// - If set to true, the cookie will only be sent over secure connections.
/// - If set to false, the cookie can be sent over any connection.
/// - If null, the default secure setting (secureDefault) will be used.
///
/// The actual security behavior is determined by the [isSecure] method,
/// which considers both this property and the [secureDefault] value.
  bool? secure;

/// Indicates whether the cookie should be accessible only through the HTTP protocol.
///
/// When set to true, the cookie is not accessible to client-side scripts (such as JavaScript),
/// which helps mitigate cross-site scripting (XSS) attacks.
///
/// The 'late' keyword indicates that this property will be initialized before it's used,
/// but not necessarily at the point of declaration.
  late bool httpOnly;

/// Indicates whether the cookie should be sent with no URL encoding.
///
/// When set to true, the cookie name and value will not be URL-encoded when the cookie
/// is converted to a string representation. This can be useful in situations where
/// the cookie value contains characters that don't need to be encoded or when working
/// with systems that expect raw cookie values.
///
/// The 'late' keyword indicates that this property will be initialized before it's used,
/// but not necessarily at the point of declaration.
  late bool raw;

/// The SameSite attribute of the cookie.
///
/// This property represents the SameSite attribute for the cookie, which controls how the cookie is sent with cross-site requests.
/// It can have one of three values:
/// - 'strict': The cookie is only sent for same-site requests.
/// - 'lax': The cookie is sent for same-site requests and top-level navigation from external sites.
/// - 'none': The cookie is sent for all cross-site requests.
/// - null: If the SameSite attribute is not set.
///
/// The SameSite attribute helps protect against cross-site request forgery (CSRF) attacks.
  String? sameSite;

/// Indicates whether the cookie should be tied to the top-level site in cross-site context.
///
/// When set to true, the cookie will be partitioned, meaning it will be associated with
/// the top-level site in cross-site contexts. This can enhance privacy and security by
/// preventing tracking across different sites.
///
/// The 'late' keyword indicates that this property will be initialized before it's used,
/// but not necessarily at the point of declaration.
  late bool partitioned;

/// Indicates the default value for the "secure" flag when it's not explicitly set.
///
/// This property determines whether cookies should be marked as secure by default
/// when the [secure] property is null. If set to true, cookies will be treated
/// as secure unless explicitly set otherwise.
///
/// The 'late' keyword indicates that this property will be initialized before
/// it's used, but not necessarily at the point of declaration.
  late bool secureDefault;

/// A string containing characters that are reserved and cannot be used in cookie names.
///
/// This constant defines a list of characters that are considered reserved in the context of cookies.
/// These characters have special meanings in cookie syntax and therefore cannot be used directly
/// in cookie names, especially when the 'raw' flag is set to true.
///
/// The reserved characters are:
/// - '=': Used to separate cookie name and value
/// - ',': Used to separate multiple cookies
/// - ';': Used to separate cookie attributes
/// - ' ': Space character
/// - '\t': Tab character
/// - '\r': Carriage return
/// - '\n': Line feed
/// - '\v': Vertical tab
/// - '\f': Form feed
///
/// This constant is used in validation checks to ensure cookie names do not contain these characters
/// when creating or manipulating cookies with the 'raw' option enabled.
  static const String RESERVED_CHARS_LIST = "=,; \t\r\n\v\f";

/// A list of reserved characters in their original form.
///
/// This constant defines a list of characters that are considered reserved in the context of cookies.
/// These characters have special meanings in cookie syntax and therefore need to be encoded
/// when used in cookie names or values.
///
/// The reserved characters are:
/// - '=': Used to separate cookie name and value
/// - ',': Used to separate multiple cookies
/// - ';': Used to separate cookie attributes
/// - ' ': Space character
/// - '\t': Tab character
/// - '\r': Carriage return
/// - '\n': Line feed
/// - '\v': Vertical tab
/// - '\f': Form feed
///
/// This list is typically used in conjunction with RESERVED_CHARS_TO for encoding/decoding
/// cookie names and values to ensure proper handling of these special characters.
  static const List<String> RESERVED_CHARS_FROM = ['=', ',', ';', ' ', "\t", "\r", "\n", "\v", "\f"];

/// A list of URL-encoded representations of reserved characters.
///
/// This constant defines a list of URL-encoded versions of characters that are considered
/// reserved in the context of cookies. These encoded versions correspond to the characters
/// in RESERVED_CHARS_FROM.
///
/// The encoded characters are:
/// - '%3D': Encoded form of '=' (equals sign)
/// - '%2C': Encoded form of ',' (comma)
/// - '%3B': Encoded form of ';' (semicolon)
/// - '%20': Encoded form of ' ' (space)
/// - '%09': Encoded form of '\t' (tab)
/// - '%0D': Encoded form of '\r' (carriage return)
/// - '%0A': Encoded form of '\n' (line feed)
/// - '%0B': Encoded form of '\v' (vertical tab)
/// - '%0C': Encoded form of '\f' (form feed)
///
/// This list is typically used in conjunction with RESERVED_CHARS_FROM for encoding/decoding
/// cookie names and values to ensure proper handling of these special characters.
  static const List<String> RESERVED_CHARS_TO = ['%3D', '%2C', '%3B', '%20', '%09', '%0D', '%0A', '%0B', '%0C'];

/// Creates a Cookie object from a string representation of a cookie.
///
/// This static method parses a cookie string and creates a corresponding Cookie object.
///
/// Parameters:
/// - [cookie]: A string representation of the cookie.
/// - [decode]: A boolean flag indicating whether to decode the cookie name and value (default is false).
///
/// Returns:
/// A Cookie object created from the parsed cookie string.
///
/// The method performs the following steps:
/// 1. Initializes default values for cookie attributes.
/// 2. Splits the cookie string into parts.
/// 3. Extracts the cookie name and value.
/// 4. Parses additional cookie attributes.
/// 5. Handles the 'expires' and 'max-age' attributes.
/// 6. Creates and returns a new Cookie object with the parsed attributes.
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

  /// Creates a new Cookie instance with the specified parameters.
  ///
  /// Parameters:
  /// - [name]: The name of the cookie (required).
  /// - [value]: The value of the cookie (optional).
  /// - [expire]: The expiration time of the cookie (default: 0).
  /// - [path]: The path on the server where the cookie will be available (default: '/').
  /// - [domain]: The domain that the cookie is available to (optional).
  /// - [secure]: Whether the cookie should only be transmitted over secure HTTPS (optional).
  /// - [httpOnly]: Whether the cookie should be accessible only through HTTP protocol (default: true).
  /// - [raw]: Whether the cookie should use no URL encoding (default: false).
  /// - [sameSite]: The SameSite attribute of the cookie (default: SAMESITE_LAX).
  /// - [partitioned]: Whether the cookie should be tied to the top-level site in cross-site context (default: false).
  ///
  /// Returns a new Cookie instance with the specified attributes.
  factory Cookie.create(String name, {String? value, dynamic expire = 0, String? path = '/', String? domain, bool? secure, bool httpOnly = true, bool raw = false, String? sameSite = SAMESITE_LAX, bool partitioned = false}) {
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Internal constructor for creating a Cookie instance.
  ///
  /// This constructor initializes a Cookie object with the provided parameters.
  /// It performs validation checks on the cookie name and sets default values for certain attributes.
  ///
  /// Parameters:
  /// - [name]: The name of the cookie.
  /// - [value]: The value of the cookie.
  /// - [expire]: The expiration time of the cookie (can be DateTime, int, or String).
  /// - [path]: The path on the server where the cookie will be available (default is '/').
  /// - [domain]: The domain that the cookie is available to.
  /// - [secure]: Whether the cookie should only be transmitted over secure HTTPS.
  /// - [httpOnly]: Whether the cookie should be accessible only through HTTP protocol.
  /// - [raw]: Whether the cookie should use no URL encoding.
  /// - [sameSite]: The SameSite attribute of the cookie.
  /// - [partitioned]: Whether the cookie should be tied to the top-level site in cross-site context.
  ///
  /// Throws:
  /// - [ArgumentError] if the cookie name contains invalid characters when [raw] is true.
  /// - [ArgumentError] if the cookie name is empty.
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
  ///
  /// This method returns a new Cookie instance with the same attributes as the current cookie,
  /// but with the provided [value]. All other attributes remain unchanged.
  ///
  /// Parameters:
  /// - [value]: The new value to set for the cookie. Can be null to create a cookie without a value.
  ///
  /// Returns:
  /// A new Cookie instance with the updated value.
  Cookie withValue(String? value) {
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Creates a cookie copy with a new domain that the cookie is available to.
  ///
  /// This method returns a new Cookie instance with the same attributes as the current cookie,
  /// but with the provided [domain]. All other attributes remain unchanged.
  ///
  /// Parameters:
  /// - [domain]: The new domain to set for the cookie. Can be null to remove the domain restriction.
  ///
  /// Returns:
  /// A new Cookie instance with the updated domain.
  Cookie withDomain(String? domain) {
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Creates a cookie copy with a new time the cookie expires.
  ///
  /// This method returns a new Cookie instance with the same attributes as the current cookie,
  /// but with the provided [expire] time. All other attributes remain unchanged.
  ///
  /// Parameters:
  /// - [expire]: The new expiration time for the cookie. Can be a DateTime, int (Unix timestamp),
  ///   or String (parseable date format).
  ///
  /// Returns:
  /// A new Cookie instance with the updated expiration time.
  ///
  /// Throws:
  /// - [ArgumentError] if the provided [expire] value is not a valid expiration time format.
  Cookie withExpires(dynamic expire) {
    return Cookie._internal(name, value, _expiresTimestamp(expire), path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

/// Converts various expiration time formats to a Unix timestamp.
///
/// This method takes a dynamic [expire] parameter and converts it to a Unix timestamp
/// (seconds since the Unix epoch). It supports the following input types:
///
/// - [DateTime]: Converts the DateTime to a Unix timestamp.
/// - [int]: Assumes the input is already a Unix timestamp and returns it as-is.
/// - [String]: Parses the string as a DateTime and converts it to a Unix timestamp.
///
/// If the input doesn't match any of these types, an [ArgumentError] is thrown.
///
/// Parameters:
/// - [expire]: The expiration time in one of the supported formats.
///
/// Returns:
/// An integer representing the expiration time as a Unix timestamp.
///
/// Throws:
/// - [ArgumentError] if the input format is not recognized or cannot be parsed.
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

  /// Creates a cookie copy with a new path on the server where the cookie will be available.
  ///
  /// This method returns a new Cookie instance with the same attributes as the current cookie,
  /// but with the provided [path]. All other attributes remain unchanged.
  ///
  /// Parameters:
  /// - [path]: The new path to set for the cookie. If an empty string is provided, it defaults to '/'.
  ///
  /// Returns:
  /// A new Cookie instance with the updated path.
  Cookie withPath(String path) {
    return Cookie._internal(name, value, expire, path.isEmpty ? '/' : path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Creates a cookie copy that can only be transmitted over a secure HTTPS connection from the client.
  ///
  /// This method returns a new Cookie instance with the same attributes as the current cookie,
  /// but with the provided [secure] flag. All other attributes remain unchanged.
  ///
  /// Parameters:
  /// - [secure]: A boolean value indicating whether the cookie should only be transmitted over HTTPS.
  ///   If true, the cookie will only be sent over secure connections.
  ///
  /// Returns:
  /// A new Cookie instance with the updated secure flag.
  Cookie withSecure(bool secure) {
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Creates a cookie copy that can be accessible only through the HTTP protocol.
  ///
  /// This method returns a new Cookie instance with the same attributes as the current cookie,
  /// but with the provided [httpOnly] flag. All other attributes remain unchanged.
  ///
  /// Parameters:
  /// - [httpOnly]: A boolean value indicating whether the cookie should be accessible only through
  ///   the HTTP protocol. If true, the cookie will not be accessible through client-side scripts.
  ///
  /// Returns:
  /// A new Cookie instance with the updated httpOnly flag.
  Cookie withHttpOnly(bool httpOnly) {
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Creates a cookie copy that uses no URL encoding.
  ///
  /// This method returns a new Cookie instance with the same attributes as the current cookie,
  /// but with the provided [raw] flag. All other attributes remain unchanged.
  ///
  /// Parameters:
  /// - [raw]: A boolean value indicating whether the cookie should use no URL encoding.
  ///   If true, the cookie name and value will not be URL-encoded.
  ///
  /// Returns:
  /// A new Cookie instance with the updated raw flag.
  ///
  /// Throws:
  /// - [ArgumentError] if [raw] is set to true and the cookie name contains invalid characters.
  Cookie withRaw(bool raw) {
    if (raw && name.contains(RegExp(r'[' + RESERVED_CHARS_LIST + r']'))) {
      throw ArgumentError('The cookie name "$name" contains invalid characters.');
    }
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Creates a cookie copy with a new SameSite attribute.
  ///
  /// This method returns a new Cookie instance with the same attributes as the current cookie,
  /// but with the provided [sameSite] value. All other attributes remain unchanged.
  ///
  /// Parameters:
  /// - [sameSite]: The new SameSite attribute value for the cookie. Valid values are:
  ///   - [SAMESITE_LAX]: Cookies are not sent on normal cross-site subrequests but are sent when a user navigates to the origin site.
  ///   - [SAMESITE_STRICT]: Cookies are only sent in a first-party context and not sent along with requests initiated by third party websites.
  ///   - [SAMESITE_NONE]: Cookies are sent in all contexts, i.e., in responses to both first-party and cross-origin requests.
  ///   - null: The SameSite attribute is not set.
  ///
  /// Returns:
  /// A new Cookie instance with the updated SameSite attribute.
  ///
  /// Throws:
  /// - [ArgumentError] if the provided [sameSite] value is not one of the valid options.
  Cookie withSameSite(String? sameSite) {
    final validSameSite = [SAMESITE_LAX, SAMESITE_STRICT, SAMESITE_NONE, null];
    if (!validSameSite.contains(sameSite?.toLowerCase())) {
      throw ArgumentError('The "sameSite" parameter value is not valid.');
    }
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite?.toLowerCase(), partitioned);
  }

  /// Creates a cookie copy that is tied to the top-level site in cross-site context.
  ///
  /// This method returns a new Cookie instance with the same attributes as the current cookie,
  /// but with the provided [partitioned] flag. All other attributes remain unchanged.
  ///
  /// Parameters:
  /// - [partitioned]: A boolean value indicating whether the cookie should be tied to the top-level site
  ///   in cross-site context. If true, the cookie will be partitioned.
  ///
  /// Returns:
  /// A new Cookie instance with the updated partitioned flag.
  Cookie withPartitioned(bool partitioned) {
    return Cookie._internal(name, value, expire, path, domain, secure, httpOnly, raw, sameSite, partitioned);
  }

  /// Converts the cookie to its string representation.
  ///
  /// This method generates a string that represents the cookie in the format used in HTTP headers.
  /// It includes all the cookie's attributes such as name, value, expiration, path, domain, secure flag,
  /// HTTP-only flag, SameSite attribute, and partitioned flag.
  ///
  /// The method handles the following cases:
  /// - If the cookie is raw, the name and value are not URL-encoded.
  /// - If the value is null or empty, the cookie is treated as deleted with immediate expiration.
  /// - If an expiration time is set, it's included in both 'expires' and 'Max-Age' attributes.
  /// - All other attributes (path, domain, secure, httpOnly, sameSite, partitioned) are added if set.
  ///
  /// Returns:
  /// A string representation of the cookie suitable for use in an HTTP header.
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
  ///
  /// Returns:
  /// A string representing the name of the cookie.
  String getName() => name;

  /// Gets the value of the cookie.
  ///
  /// Returns:
  /// A string representing the value of the cookie, or null if the cookie has no value.
  String? getValue() => value;

  /// Gets the domain that the cookie is available to.
  ///
  /// Returns:
  /// A string representing the domain of the cookie, or null if no domain is set.
  String? getDomain() => domain;

  /// Gets the expiration time of the cookie.
  ///
  /// Returns:
  /// An integer representing the expiration time of the cookie as a Unix timestamp.
  /// If the cookie doesn't have an expiration time set, it returns 0.
  int getExpiresTime() => expire;

  /// Calculates and returns the Max-Age attribute value for the cookie.
  ///
  /// This method computes the number of seconds until the cookie expires.
  /// It does this by subtracting the current Unix timestamp from the cookie's
  /// expiration timestamp. The result is always non-negative, with a minimum
  /// value of 0.
  ///
  /// Returns:
  /// An integer representing the number of seconds until the cookie expires.
  /// If the cookie has already expired, it returns 0.
  int getMaxAge() {
    final maxAge = expire - (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    return max(0, maxAge);
  }

  /// Gets the path on the server where the cookie will be available.
  ///
  /// This method returns the path attribute of the cookie, which specifies the
  /// subset of URLs in a domain for which the cookie is valid.
  ///
  /// Returns:
  /// A string representing the path of the cookie.
  String getPath() => path;

  /// Checks whether the cookie should only be transmitted over a secure HTTPS connection from the client.
  ///
  /// This method returns the value of the 'secure' flag for the cookie. If the 'secure' flag
  /// is explicitly set (either true or false), it returns that value. If 'secure' is null,
  /// it falls back to the default secure setting (secureDefault).
  ///
  /// Returns:
  /// A boolean value: true if the cookie should only be sent over secure connections,
  /// false otherwise.
  bool isSecure() => secure ?? secureDefault;

  /// Checks whether the cookie is accessible only through the HTTP protocol.
  ///
  /// This method returns the value of the 'httpOnly' flag for the cookie.
  /// If true, the cookie is inaccessible to client-side scripts like JavaScript,
  /// which helps mitigate cross-site scripting (XSS) attacks.
  ///
  /// Returns:
  /// A boolean value: true if the cookie is HTTP-only, false otherwise.
  bool isHttpOnly() => httpOnly;

  /// Checks if the cookie has been cleared or has expired.
  ///
  /// This method determines whether the cookie is considered cleared by checking two conditions:
  /// 1. The cookie has an expiration time set (expire != 0).
  /// 2. The expiration time is in the past (earlier than the current time).
  ///
  /// Returns:
  /// A boolean value: true if the cookie has been cleared or has expired, false otherwise.
  bool isCleared() => expire != 0 && expire < (DateTime.now().millisecondsSinceEpoch ~/ 1000);

  /// Checks if the cookie value should be sent with no URL encoding.
  ///
  /// This method returns the value of the 'raw' flag for the cookie.
  /// If true, the cookie name and value will not be URL-encoded when the cookie is converted to a string.
  ///
  /// Returns:
  /// A boolean value: true if the cookie should be sent raw (without URL encoding), false otherwise.
  bool isRaw() => raw;

  /// Checks whether the cookie should be tied to the top-level site in cross-site context.
  ///
  /// This method returns the value of the 'partitioned' flag for the cookie.
  /// If true, the cookie will be partitioned, meaning it will be tied to the top-level site
  /// in cross-site contexts, which can help improve privacy and security.
  ///
  /// Returns:
  /// A boolean value: true if the cookie is partitioned, false otherwise.
  bool isPartitioned() => partitioned;

  /// Gets the SameSite attribute of the cookie.
  ///
  /// This method returns the value of the SameSite attribute for the cookie.
  /// The SameSite attribute is used to control how cookies are sent with cross-site requests.
  ///
  /// Returns:
  /// A string representing the SameSite attribute of the cookie, which can be:
  /// - 'strict': The cookie is only sent for same-site requests.
  /// - 'lax': The cookie is sent for same-site requests and top-level navigation from external sites.
  /// - 'none': The cookie is sent for all cross-site requests.
  /// - null: If the SameSite attribute is not set.
  String? getSameSite() => sameSite;

  /// Sets the default value for the "secure" flag when it is not explicitly set.
  ///
  /// This method allows you to specify a default value for the "secure" flag
  /// that will be used when the secure property of the cookie is null.
  ///
  /// Parameters:
  /// - [defaultSecure]: A boolean value indicating whether cookies should be
  ///   secure by default. If true, cookies will be marked as secure by default
  ///   when the secure property is not explicitly set.
  ///
  /// This setting affects the behavior of the [isSecure] method when the
  /// secure property is null.
  void setSecureDefault(bool defaultSecure) {
    secureDefault = defaultSecure;
  }
}
