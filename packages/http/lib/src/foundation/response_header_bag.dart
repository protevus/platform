/*
 * This file is part of the Symfony package.
 *
 * (c) Fabien Potencier <fabien@symfony.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'header_bag.dart';
import 'cookie.dart';
import 'header_utils.dart';

/// ResponseHeaderBag is a container for Response HTTP headers.
///
/// Author: Fabien Potencier <fabien@symfony.com>
class ResponseHeaderBag extends HeaderBag {
  static const String COOKIES_FLAT = 'flat';
  static const String COOKIES_ARRAY = 'array';

  static const String DISPOSITION_ATTACHMENT = 'attachment';
  static const String DISPOSITION_INLINE = 'inline';

  Map<String, String> computedCacheControl = {};
  Map<String, Map<String, Map<String, Cookie>>> cookies = {};
  Map<String, String> headerNames = {};

  /// Constructor for the ResponseHeaderBag class.
  ResponseHeaderBag([Map<String, List<String?>>? headers]) : super(headers ?? {}) {
    if (!headers!.containsKey('cache-control')) {
      set('Cache-Control', '');
    }

    // RFC2616 - 14.18 says all Responses need to have a Date
    if (!headers.containsKey('date')) {
      initDate();
    }
  }

  /// Returns the headers, with original capitalizations.
  Map<String, List<String?>> allPreserveCase() {
    final headers = <String, List<String?>>{};
    super.all().forEach((name, value) {
      headers[headerNames[name] ?? name] = value;
    });
    return headers;
  }

  /// Returns the headers with original capitalizations, excluding cookies.
  Map<String, List<String?>> allPreserveCaseWithoutCookies() {
    final headers = allPreserveCase();
    if (headerNames.containsKey('set-cookie')) {
      headers.remove(headerNames['set-cookie']);
    }
    return headers;
  }

  /// Replaces the current headers with new headers.
  @override
  void replace([Map<String, List<String?>>? headers]) {
    headerNames = {};
    super.replace(headers ?? {});
    if (!headers!.containsKey('cache-control')) {
      set('Cache-Control', '');
    }
    if (!headers.containsKey('date')) {
      initDate();
    }
  }

  /// Returns all headers, optionally filtered by a key.
  @override
  Map<String, List<String?>> all([String? key]) {
    final headers = super.all();
    if (key != null) {
      final uniqueKey = key.toLowerCase();
      if (uniqueKey != 'set-cookie') {
        return {uniqueKey: headers[uniqueKey] ?? []};
      } else {
        return {'set-cookie': cookies.values.expand((path) => path.values.expand((cookie) => cookie.values)).map((cookie) => cookie.toString()).toList()};
      }
    }

    for (var path in cookies.values) {
      for (var cookie in path.values) {
        headers['set-cookie'] ??= [];
        headers['set-cookie']!.add(cookie.toString());
      }
    }
    return headers;
  }

  /// Sets a header value.
  @override
  void set(String key, dynamic values, [bool replace = true]) {
    final uniqueKey = key.toLowerCase();
    if (uniqueKey == 'set-cookie') {
      if (replace) {
        cookies = {};
      }
      for (var cookie in List<String>.from(values)) {
        setCookie(Cookie.fromString(cookie));
      }
      headerNames[uniqueKey] = key;
      return;
    }
    headerNames[uniqueKey] = key;
    super.set(key, values, replace);

    // Ensure the cache-control header has sensible defaults
    if (['cache-control', 'etag', 'last-modified', 'expires'].contains(uniqueKey)) {
      final computedValue = computeCacheControlValue();
      super.set('Cache-Control', computedValue, replace);
      headerNames['cache-control'] = 'Cache-Control';
      computedCacheControl = parseCacheControl(computedValue);
    }
  }

  /// Removes a header.
  @override
  void remove(String key) {
    final uniqueKey = key.toLowerCase();
    headerNames.remove(uniqueKey);
    if (uniqueKey == 'set-cookie') {
      cookies = {};
      return;
    }
    super.remove(key);
    if (uniqueKey == 'cache-control') {
      computedCacheControl = {};
    }
    if (uniqueKey == 'date') {
      initDate();
    }
  }

  /// Checks if the cache-control directive exists.
  @override
  bool hasCacheControlDirective(String key) {
    return computedCacheControl.containsKey(key);
  }

  /// Gets the value of a cache-control directive.
  @override
  dynamic getCacheControlDirective(String key) {
    return computedCacheControl[key];
  }

  /// Sets a cookie.
  void setCookie(Cookie cookie) {
  cookies.putIfAbsent(cookie.domain ?? '', () => {})
      .putIfAbsent(cookie.path, () => {})[cookie.name] = cookie;
  headerNames['set-cookie'] = 'Set-Cookie';
}

  /// Removes a cookie from the array, but does not unset it in the browser.
  void removeCookie(String name, [String? path = '/', String? domain]) {
    path ??= '/';
    final domainCookies = cookies[domain] ?? {};
    final pathCookies = domainCookies[path] ?? {};
    pathCookies.remove(name);

    if (pathCookies.isEmpty) {
      domainCookies.remove(path);
      if (domainCookies.isEmpty) {
        cookies.remove(domain);
      }
    }

    if (cookies.isEmpty) {
      headerNames.remove('set-cookie');
    }
  }

  /// Returns an array with all cookies.
  ///
  /// @return List<Cookie>
  ///
  /// @throws ArgumentError When the format is invalid
  List<Cookie> getCookies([String format = COOKIES_FLAT]) {
  if (!([COOKIES_FLAT, COOKIES_ARRAY].contains(format))) {
    throw ArgumentError('Format "$format" invalid (${[COOKIES_FLAT, COOKIES_ARRAY].join(', ')}).');
  }

  if (format == COOKIES_ARRAY) {
    return cookies.values.expand((path) => path.values.expand((cookie) => cookie.values)).toList();
  }

  final flattenedCookies = <Cookie>[];
  for (var path in cookies.values) {
    for (var domainCookies in path.values) {
      for (var cookie in domainCookies.values) {
        flattenedCookies.add(cookie);
      }
    }
  }
  return flattenedCookies;
}

  /// Clears a cookie in the browser.
  ///
  /// @param bool partitioned
  void clearCookie(String name,
      [String? path = '/', String? domain, bool secure = false, bool httpOnly = true, String? sameSite, bool partitioned = false]) {
    final cookieString = '$name=null; Expires=${DateTime.fromMillisecondsSinceEpoch(1).toUtc().toIso8601String()}; Path=${path ?? "/"}; Domain=$domain${secure ? "; Secure" : ""}${httpOnly ? "; HttpOnly" : ""}${sameSite != null ? "; SameSite=$sameSite" : ""}${partitioned ? "; Partitioned" : ""}';
    setCookie(Cookie.fromString(cookieString));
  }

  /// Makes a disposition header.
  ///
  /// @see HeaderUtils::makeDisposition()
  String makeDisposition(String disposition, String filename, [String filenameFallback = '']) {
    return HeaderUtils.makeDisposition(disposition, filename, filenameFallback);
  }

  /// Returns the calculated value of the cache-control header.
  ///
  /// This considers several other headers and calculates or modifies the
  /// cache-control header to a sensible, conservative value.
  String computeCacheControlValue() {
    if (computedCacheControl.isEmpty) {
      if (hasHeader('Last-Modified') || hasHeader('Expires')) {
        return 'private, must-revalidate'; // allows for heuristic expiration (RFC 7234 Section 4.2.2) in the case of "Last-Modified"
      }

      // Conservative by default
      return 'no-cache, private';
    }

    final header = getCacheControlHeader();
    if (computedCacheControl.containsKey('public') || computedCacheControl.containsKey('private')) {
      return header;
    }

    // Public if s-maxage is defined, private otherwise
    if (!computedCacheControl.containsKey('s-maxage')) {
      return '$header, private';
    }

    return header;
  }

  /// Parses the cache-control header value into a map.
  Map<String, String> parseCacheControl(String header) {
    final directives = <String, String>{};
    for (var directive in header.split(',')) {
      final parts = directive.trim().split('=');
      directives[parts[0]] = parts.length > 1 ? parts[1] : '';
    }
    return directives;
  }

  /// Initializes the Date header to the current date and time.
  void initDate() {
    set('Date', DateTime.now().toUtc().toIso8601String());
  }

  /// Checks if a header exists.
  bool containsKey(String key) {
    return super.all().containsKey(key.toLowerCase());
  }

  /// Gets the value of a header.
  String? value(String key) {
    return super.all()[key.toLowerCase()]?.join(', ');
  }
}
