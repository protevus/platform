/*
 * This file is part of the Protevus Platform.
 * This file is a port of the symfony ResponseHeaderBag.php class to Dart
 *
 * (C) Protevus <developers@protevus.com>
 * (C) Fabien Potencier <fabien@symfony.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'cookie.dart';
import 'header_utils.dart';
import 'header_bag.dart';

/// ResponseHeaderBag is a container for HTTP response headers.
///
/// This class extends HeaderBag and provides additional functionality specific to
/// handling response headers. It includes methods for managing cookies, cache control,
/// and other HTTP response-specific headers.
///
/// Key features:
/// - Manages cookies with support for different domains and paths
/// - Handles cache control headers and directives
/// - Preserves case-sensitive header names
/// - Provides methods for setting, getting, and removing headers
/// - Implements special handling for certain headers like 'Set-Cookie' and 'Cache-Control'
///
/// The class uses several data structures to manage headers efficiently:
/// - [computedCacheControl]: Stores parsed cache control directives
/// - [cookies]: A nested map structure for storing cookies by domain, path, and name
/// - [headerNames]: Preserves the original case of header names
///
/// It also provides constants for cookie formats and content disposition types.
///
/// This class is designed to be used in HTTP response handling, particularly
/// in web frameworks and server-side applications.
class ResponseHeaderBag extends HeaderBag {

  /// A constant string representing the 'flat' format for cookies.
  ///
  /// This constant is used in methods that deal with cookie formatting,
  /// particularly in the `getCookies` method, to specify that cookies
  /// should be returned in a flat list structure.
  static const String COOKIES_FLAT = 'flat';

  /// A constant string representing the 'array' format for cookies.
  ///
  /// This constant is used in methods that deal with cookie formatting,
  /// particularly in the `getCookies` method, to specify that cookies
  /// should be returned in an array structure.
  static const String COOKIES_ARRAY = 'array';

  /// A constant string representing the 'attachment' disposition type for headers.
  ///
  /// This constant is typically used when setting the Content-Disposition header
  /// to indicate that the content should be downloaded as an attachment rather
  /// than displayed inline in the browser.
  static const String DISPOSITION_ATTACHMENT = 'attachment';

  /// A constant string representing the 'inline' disposition type for headers.
  ///
  /// This constant is typically used when setting the Content-Disposition header
  /// to indicate that the content should be displayed inline in the browser
  /// rather than downloaded as an attachment.
  static const String DISPOSITION_INLINE = 'inline';

  /// A map that stores computed cache control directives.
  ///
  /// This map is used to cache the parsed values of the Cache-Control header.
  /// The keys are the directive names (e.g., 'max-age', 'public', 'private'),
  /// and the values are the corresponding directive values.
  ///
  /// This cache is updated whenever the Cache-Control header is set or modified,
  /// and it's used to provide quick access to cache control directives without
  /// having to re-parse the header string each time.
  Map<String, String> computedCacheControl = {};

/// A nested map structure representing cookies.
///
/// The structure is as follows:
/// - The outermost map's key is the domain (String).
/// - The middle map's key is the path (String).
/// - The innermost map's key is the cookie name (String).
/// - The value of the innermost map is the Cookie object.
///
/// This structure allows for efficient storage and retrieval of cookies
/// based on their domain, path, and name.
  Map<String, Map<String, Map<String, Cookie>>> cookies = {};

/// A map that stores the original case-sensitive names of headers.
///
/// This map is used to preserve the original capitalization of header names
/// when they are set or retrieved. The keys are the lowercase versions of
/// the header names, and the values are the original case-sensitive names.
///
/// For example, if a header "Content-Type" is set, this map would contain
/// an entry with key "content-type" and value "Content-Type".
///
/// This allows the class to maintain case-insensitive header lookup while
/// still being able to return headers with their original capitalization.
  Map<String, String> headerNames = {};

  /// Constructor for the ResponseHeaderBag class.
  ///
  /// This constructor initializes a new ResponseHeaderBag instance with the given headers.
  /// If no headers are provided, an empty map is used.
  ///
  /// The constructor performs two important initializations:
  /// 1. If the 'cache-control' header is not present in the provided headers,
  ///    it sets an empty 'Cache-Control' header.
  /// 2. If the 'date' header is not present, it initializes the 'Date' header
  ///    with the current date and time.
  ///
  /// These initializations ensure that the response complies with RFC2616 - 14.18,
  /// which states that all Responses need to have a Date header.
  ///
  /// @param headers An optional map of headers to initialize the ResponseHeaderBag with.
  ///                If not provided, an empty map is used.
  ResponseHeaderBag([Map<String, List<String?>>? headers]) : super(headers ?? {}) {
    if (!headers!.containsKey('cache-control')) {
      set('Cache-Control', '');
    }

    // RFC2616 - 14.18 says all Responses need to have a Date
    if (!headers.containsKey('date')) {
      initDate();
    }
  }

  /// Returns all headers with their original case-sensitive names preserved.
  ///
  /// This method creates a new map of headers where the keys (header names) 
  /// maintain their original capitalization as stored in the [headerNames] map.
  /// If a header name is not found in [headerNames], the original name is used.
  ///
  /// @return A Map<String, List<String?>> where keys are the original case-sensitive
  /// header names and values are lists of corresponding header values.
  Map<String, List<String?>> allPreserveCase() {
    final headers = <String, List<String?>>{};
    super.all().forEach((name, value) {
      headers[headerNames[name] ?? name] = value;
    });
    return headers;
  }

  /// Returns all headers with their original case-sensitive names preserved, excluding cookies.
  ///
  /// This method creates a new map of headers where the keys (header names) 
  /// maintain their original capitalization as stored in the [headerNames] map.
  /// It uses the [allPreserveCase] method to get all headers, and then removes
  /// the 'Set-Cookie' header (if present) from the result.
  ///
  /// @return A Map<String, List<String?>> where keys are the original case-sensitive
  /// header names (excluding 'Set-Cookie') and values are lists of corresponding header values.
  Map<String, List<String?>> allPreserveCaseWithoutCookies() {
    final headers = allPreserveCase();
    if (headerNames.containsKey('set-cookie')) {
      headers.remove(headerNames['set-cookie']);
    }
    return headers;
  }

  /// Replaces the current headers with new headers.
  ///
  /// This method clears the existing headers and replaces them with the provided ones.
  /// It also performs the following actions:
  /// 1. Resets the [headerNames] map, which is used to preserve the original case of header names.
  /// 2. If the new headers don't include a 'cache-control' header, it sets an empty 'Cache-Control' header.
  /// 3. If the new headers don't include a 'date' header, it initializes the 'Date' header with the current date and time.
  ///
  /// These actions ensure that the response always has the necessary headers as per HTTP standards,
  /// particularly adhering to RFC2616 - 14.18 which requires all Responses to have a Date header.
  ///
  /// @param headers An optional map of headers to replace the current headers.
  ///                If not provided, an empty map is used.
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
  ///
  /// If a [key] is provided, this method returns a map containing only the header
  /// for that key. The key is case-insensitive. If the key is 'set-cookie',
  /// it returns all cookies formatted as strings.
  ///
  /// If no [key] is provided, it returns all headers, including all cookies
  /// under the 'set-cookie' key.
  ///
  /// @param key An optional header key to filter the results.
  /// @return A map where keys are header names and values are lists of header values.
  ///         For 'set-cookie', each value in the list is a formatted cookie string.
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
  ///
  /// This method sets a header with the given key and value(s). It handles special cases for
  /// certain headers, particularly 'set-cookie' and cache-related headers.
  ///
  /// For 'set-cookie':
  /// - If replace is true, it clears existing cookies before setting new ones.
  /// - It creates Cookie objects from the provided string values.
  ///
  /// For cache-related headers ('cache-control', 'etag', 'last-modified', 'expires'):
  /// - It recalculates the Cache-Control header based on the new values.
  /// - It updates the computed cache control directives.
  ///
  /// @param key The name of the header to set.
  /// @param values The value(s) to set for the header. Can be a single value or a list.
  /// @param replace Whether to replace existing values (true) or append to them (false).
  ///                Defaults to true.
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

  /// Removes a header from the response.
  ///
  /// This method removes the specified header from the response. It handles special cases for
  /// certain headers:
  ///
  /// - For 'set-cookie': Clears all cookies.
  /// - For 'cache-control': Clears the computed cache control directives.
  /// - For 'date': Reinitializes the Date header with the current date and time.
  ///
  /// The method is case-insensitive for the header name.
  ///
  /// @param key The name of the header to remove.
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

  /// Checks if a specific cache-control directive exists in the computed cache control.
  ///
  /// This method checks whether the given [key] exists as a directive in the
  /// [computedCacheControl] map. The [computedCacheControl] map contains
  /// parsed cache control directives from the Cache-Control header.
  ///
  /// @param key The cache control directive to check for.
  /// @return true if the directive exists, false otherwise.
  @override
  bool hasCacheControlDirective(String key) {
    return computedCacheControl.containsKey(key);
  }

  /// Retrieves the value of a specific cache-control directive.
  ///
  /// This method returns the value associated with the given [key] from the
  /// [computedCacheControl] map. The [computedCacheControl] map contains
  /// parsed cache control directives from the Cache-Control header.
  ///
  /// @param key The cache control directive to retrieve.
  /// @return The value of the cache control directive, or null if the directive doesn't exist.
  @override
  dynamic getCacheControlDirective(String key) {
    return computedCacheControl[key];
  }

  /// Sets a cookie in the ResponseHeaderBag.
  ///
  /// This method adds or updates a cookie in the [cookies] map structure.
  /// If the cookie's domain or path doesn't exist in the map, it creates
  /// the necessary nested maps. The cookie is then stored using its name as the key.
  ///
  /// Additionally, it updates the [headerNames] map to ensure that 'set-cookie'
  /// is mapped to 'Set-Cookie', maintaining proper header capitalization.
  ///
  /// @param cookie The Cookie object to be set in the response.
  void setCookie(Cookie cookie) {
  cookies.putIfAbsent(cookie.domain ?? '', () => {})
      .putIfAbsent(cookie.path, () => {})[cookie.name] = cookie;
  headerNames['set-cookie'] = 'Set-Cookie';
  }

  /// Removes a cookie from the array, but does not unset it in the browser.
  ///
  /// This method removes the specified cookie from the internal [cookies] structure.
  /// It does not send any instructions to the browser to delete the cookie.
  ///
  /// The method navigates through the nested map structure of [cookies],
  /// removing the cookie and cleaning up empty maps along the way.
  ///
  /// If all cookies are removed, it also removes the 'set-cookie' entry from [headerNames].
  ///
  /// @param name The name of the cookie to remove.
  /// @param path The path of the cookie. Defaults to '/'.
  /// @param domain The domain of the cookie. If null, it will attempt to remove
  ///               the cookie from all domains.
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

  /// Returns an array of cookies based on the specified format.
  ///
  /// This method retrieves all cookies stored in the ResponseHeaderBag and returns them
  /// in the format specified by the [format] parameter.
  ///
  /// @param format The format in which to return the cookies. Can be either
  ///               [COOKIES_FLAT] (default) or [COOKIES_ARRAY].
  ///               - [COOKIES_FLAT]: Returns a flat list of all cookies.
  ///               - [COOKIES_ARRAY]: Returns a list of all cookies without flattening.
  ///
  /// @return A List<Cookie> containing all cookies in the specified format.
  ///
  /// @throws ArgumentError If the provided format is not valid (i.e., not COOKIES_FLAT or COOKIES_ARRAY).
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
  /// This method sets a cookie with the given name to null and expires it
  /// immediately, effectively clearing it from the browser.
  ///
  /// @param name The name of the cookie to clear.
  /// @param path The path for which the cookie is valid. Defaults to '/'.
  /// @param domain The domain for which the cookie is valid.
  /// @param secure Whether the cookie should only be transmitted over secure protocols. Defaults to false.
  /// @param httpOnly Whether the cookie should be accessible only through the HTTP protocol. Defaults to true.
  /// @param sameSite The SameSite attribute for the cookie. Can be 'Lax', 'Strict', or 'None'.
  /// @param partitioned Whether the cookie should be partitioned. Defaults to false.
  void clearCookie(String name,
      [String? path = '/', String? domain, bool secure = false, bool httpOnly = true, String? sameSite, bool partitioned = false]) {
    final cookieString = '$name=null; Expires=${DateTime.fromMillisecondsSinceEpoch(1).toUtc().toIso8601String()}; Path=${path ?? "/"}; Domain=$domain${secure ? "; Secure" : ""}${httpOnly ? "; HttpOnly" : ""}${sameSite != null ? "; SameSite=$sameSite" : ""}${partitioned ? "; Partitioned" : ""}';
    setCookie(Cookie.fromString(cookieString));
  }

  /// Creates a Content-Disposition header value.
  ///
  /// This method generates a Content-Disposition header value based on the provided parameters.
  /// It uses the HeaderUtils.makeDisposition method to create the header value.
  ///
  /// @param disposition The disposition type, typically either 'attachment' or 'inline'.
  /// @param filename The primary filename to be used in the Content-Disposition header.
  /// @param filenameFallback An optional fallback filename to be used if the primary filename
  ///        contains characters not supported by all user agents. Defaults to an empty string.
  ///
  /// @return A string representing the Content-Disposition header value.
  String makeDisposition(String disposition, String filename, [String filenameFallback = '']) {
    return HeaderUtils.makeDisposition(disposition, filename, filenameFallback);
  }

  /// Computes and returns the value for the Cache-Control header.
  ///
  /// This method determines the appropriate Cache-Control value based on the current state
  /// of the response headers and the computed cache control directives.
  ///
  /// The logic is as follows:
  /// 1. If no cache control directives have been computed:
  ///    - If 'Last-Modified' or 'Expires' headers are present, it returns 'private, must-revalidate'.
  ///    - Otherwise, it returns a conservative default of 'no-cache, private'.
  /// 2. If cache control directives have been computed:
  ///    - If 'public' or 'private' directives are present, it returns the current header as-is.
  ///    - If 's-maxage' is not present, it appends ', private' to the current header.
  ///    - Otherwise, it returns the current header as-is.
  ///
  /// This method ensures that appropriate caching behavior is set, defaulting to more
  /// restrictive caching when specific directives are not explicitly set.
  ///
  /// @return A String representing the computed Cache-Control header value.
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

  /// Parses a Cache-Control header string into a map of directives.
  ///
  /// This method takes a Cache-Control header value as input and breaks it down
  /// into individual directives. Each directive is then stored in a map where
  /// the key is the directive name and the value is the directive's value (if any).
  ///
  /// The method handles both directives with values (e.g., "max-age=3600") and
  /// those without values (e.g., "no-cache").
  ///
  /// @param header A string representing the Cache-Control header value.
  /// @return A Map<String, String> where keys are directive names and values are
  ///         directive values. For directives without values, an empty string is used.
  Map<String, String> parseCacheControl(String header) {
    final directives = <String, String>{};
    for (var directive in header.split(',')) {
      final parts = directive.trim().split('=');
      directives[parts[0]] = parts.length > 1 ? parts[1] : '';
    }
    return directives;
  }

  /// Initializes the Date header with the current UTC date and time.
  ///
  /// This method sets the 'Date' header of the HTTP response to the current
  /// date and time in UTC format. The date is formatted according to the
  /// ISO 8601 standard.
  ///
  /// The Date header is important for HTTP responses as it informs the
  /// client about the time at which the response was generated by the server.
  /// This can be useful for caching mechanisms and for calculating the age
  /// of the response.
  void initDate() {
    set('Date', DateTime.now().toUtc().toIso8601String());
  }

  /// Checks if a header exists in the ResponseHeaderBag.
  ///
  /// This method checks whether a header with the given [key] exists,
  /// regardless of the case of the key. It converts the [key] to lowercase
  /// before checking, ensuring case-insensitive matching.
  ///
  /// @param key The name of the header to check for.
  /// @return true if the header exists, false otherwise.
  bool containsKey(String key) {
    return super.all().containsKey(key.toLowerCase());
  }

  /// Gets the value of a header.
  ///
  /// This method retrieves the value of the header specified by [key].
  /// The key is case-insensitive. If the header exists, it returns all values
  /// joined by a comma and space. If the header doesn't exist, it returns null.
  ///
  /// @param key The name of the header to retrieve.
  /// @return A String containing the header value(s), or null if the header doesn't exist.
  String? value(String key) {
    return super.all()[key.toLowerCase()]?.join(', ');
  }
}
