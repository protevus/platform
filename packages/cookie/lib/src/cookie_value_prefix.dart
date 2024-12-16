import 'dart:convert';
import 'package:crypto/crypto.dart';

class CookieValuePrefix {
  /// Create a new cookie value prefix for the given cookie name.
  static String create(String cookieName, String key) {
    final hmac = Hmac(sha1, utf8.encode(key));
    final digest = hmac.convert(utf8.encode('${cookieName}v2'));
    return '${digest.toString()}|';
  }

  /// Remove the cookie value prefix.
  static String remove(String cookieValue) {
    final separatorIndex = cookieValue.indexOf('|');
    if (separatorIndex == -1 || separatorIndex == cookieValue.length - 1) {
      return cookieValue; // Return original value if no separator or separator at the end
    }
    return cookieValue.substring(separatorIndex + 1);
  }

  /// Validate a cookie value contains a valid prefix.
  /// If it does, return the cookie value with the prefix removed.
  /// Otherwise, return null.
  static String? validate(
      String cookieName, String cookieValue, List<String> keys) {
    for (final key in keys) {
      final prefix = create(cookieName, key);
      if (cookieValue.startsWith(prefix)) {
        return remove(cookieValue);
      }
    }
    return null;
  }
}
