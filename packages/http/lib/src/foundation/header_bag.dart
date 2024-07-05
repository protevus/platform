/*
 * This file is part of the Protevus Platform.
 * This file is a port of the symfony HeaderBag.php class to Dart
 *
 * (C) Protevus <developers@protevus.com>
 * (C) Fabien Potencier <fabien@symfony.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:collection';

/// HeaderBag is a class that manages HTTP headers.
///
/// This class provides functionality to store, retrieve, and manipulate HTTP headers.
/// It supports operations such as adding, removing, and checking for the presence of headers,
/// as well as special handling for Cache-Control directives.
///
/// Key features:
/// - Case-insensitive header names
/// - Support for multiple values per header
/// - Special handling for Cache-Control headers
/// - Methods to add, remove, and check headers
/// - Implements Iterable for easy traversal of headers
///
/// Usage:
/// ```dart
/// var headers = HeaderBag();
/// headers.set('Content-Type', 'application/json');
/// headers.add({'Accept': ['text/html', 'application/xhtml+xml']});
/// print(headers.get('content-type')); // Prints: application/json
/// ```
///
/// This class is particularly useful for HTTP clients and servers that need to
/// manage complex header scenarios, including multiple header values and
/// Cache-Control directives.
class HeaderBag extends IterableBase<MapEntry<String, List<String?>>> {
  
  /// A constant string containing uppercase letters and underscore.
  ///
  /// This constant is used for case-insensitive string operations,
  /// particularly in header name formatting. It includes the underscore
  /// character followed by all uppercase letters of the English alphabet.
  ///
  /// The string is defined as:
  /// - Underscore: '_'
  /// - Uppercase letters: 'A' through 'Z'
  ///
  /// This constant is typically used in conjunction with the 'lower' constant
  /// for case conversion operations within the HeaderBag class.
  static const String upper = '_ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  /// A constant string containing lowercase letters and hyphen.
  ///
  /// This constant is used for case-insensitive string operations,
  /// particularly in header name formatting. It includes the hyphen
  /// character followed by all lowercase letters of the English alphabet.
  ///
  /// The string is defined as:
  /// - Hyphen: '-'
  /// - Lowercase letters: 'a' through 'z'
  ///
  /// This constant is typically used in conjunction with the 'upper' constant
  /// for case conversion operations within the HeaderBag class.
  static const String lower = '-abcdefghijklmnopqrstuvwxyz';

  /// A map to store the headers.
  ///
  /// This private field stores all the HTTP headers in the HeaderBag.
  /// The keys of the map are header names (stored in lowercase),
  /// and the values are lists of header values.
  ///
  /// Using a list for values allows for multiple values per header,
  /// which is common in HTTP headers (e.g., multiple Set-Cookie headers).
  ///
  /// The use of nullable String (String?) in the list allows for the
  /// possibility of null values, which might occur in some edge cases.
  final Map<String, List<String?>> _headers = {};

  /// A map to store cache control directives.
  ///
  /// This map holds key-value pairs representing Cache-Control directives.
  /// Keys are directive names (e.g., "max-age", "no-cache"), and values are
  /// the corresponding directive values or true for valueless directives.
  ///
  /// This map is used internally to manage and manipulate Cache-Control
  /// header information efficiently, allowing for easy addition, removal,
  /// and retrieval of individual directives.
  final Map<String, dynamic> _cacheControl = {};

  /// Constructor for HeaderBag
  ///
  /// Creates a new HeaderBag instance with the given headers.
  ///
  /// @param headers An optional map of headers to initialize the HeaderBag with.
  ///                The map keys are header names, and the values are lists of
  ///                header values. If not provided, an empty map is used.
  ///
  /// This constructor initializes the HeaderBag by setting each header in the
  /// provided map using the `set` method, which ensures proper formatting and
  /// handling of special headers like 'Cache-Control'.
  HeaderBag([Map<String, List<String?>> headers = const {}]) {
    headers.forEach((key, values) {
      set(key, values);
    });
  }

  /// Returns a string representation of the headers.
  ///
  /// This method creates a formatted string of all headers in the HeaderBag.
  /// The headers are sorted alphabetically by key, and each header is
  /// presented on a new line with the header name capitalized appropriately.
  /// The header names are right-padded to align all header values.
  ///
  /// If the HeaderBag is empty, an empty string is returned.
  ///
  /// @return A formatted string representation of all headers.
  @override
  String toString() {
    if (_headers.isEmpty) {
      return '';
    }

    var sortedHeaders = SplayTreeMap<String, List<String?>>.from(_headers);
    var max = sortedHeaders.keys.map((k) => k.length).reduce((a, b) => a > b ? a : b) + 1;
    var content = StringBuffer();

    for (var entry in sortedHeaders.entries) {
      var name = entry.key.replaceAllMapped(RegExp(r'-([a-z])'), (match) => '-${match.group(1)!.toUpperCase()}');
      for (var value in entry.value) {
        content.write('${name.padRight(max)}: $value\r\n');
      }
    }

    return content.toString();
  }

  /// Returns all headers or headers for a specific key.
  ///
  /// If a [key] is provided, this method returns a map containing only that key
  /// (in lowercase) and its associated list of values. If the key doesn't exist,
  /// an empty list is returned for that key.
  ///
  /// If no [key] is provided, this method returns all headers in the HeaderBag.
  ///
  /// @param key The optional key to retrieve specific headers.
  /// @return A map of headers. If a key is provided, the map will contain only
  ///         that key-value pair. If no key is provided, all headers are returned.
  Map<String, List<String?>> all([String? key]) {
    if (key != null) {
      return {key.toLowerCase(): _headers[key.toLowerCase()] ?? []};
    }
    return _headers;
  }

  /// Returns the parameter keys.
  ///
  /// This method retrieves all the keys from the internal _headers map
  /// and returns them as a list of strings. The keys represent the names
  /// of all the headers stored in this HeaderBag.
  ///
  /// @return A list of strings containing all the header names.
  List<String> keys() {
    return _headers.keys.toList();
  }

  /// Replaces the current HTTP headers with a new set of headers.
  ///
  /// This method first clears all existing headers in the HeaderBag,
  /// then adds the new headers provided in the [headers] parameter.
  ///
  /// @param headers A map of new headers to replace the existing ones.
  ///                The map keys are header names, and the values are
  ///                lists of header values.
  void replace(Map<String, List<String?>> headers) {
    _headers.clear();
    add(headers);
  }

  /// Adds new headers to the current HTTP headers set.
  ///
  /// This method takes a map of headers and adds them to the existing headers
  /// in the HeaderBag. If a header with the same name already exists, its values
  /// are appended to the existing values.
  ///
  /// @param headers A map where keys are header names and values are lists of
  ///                header values to be added.
  ///
  /// Each header in the input map is added using the `set` method, which handles
  /// the details of appending values and updating special headers like 'Cache-Control'.
  void add(Map<String, List<String?>> headers) {
    headers.forEach((key, values) {
      set(key, values);
    });
  }

  /// Returns the first value of the specified HTTP header.
  ///
  /// This method retrieves the first value of the header specified by [key].
  /// If the header doesn't exist or has no values, it returns the [defaultValue].
  ///
  /// @param key The name of the HTTP header to retrieve.
  /// @param defaultValue An optional default value to return if the header
  ///        doesn't exist or has no values. Defaults to null if not specified.
  /// @return The first value of the specified header, or the default value
  ///         if the header doesn't exist or has no values.
  String? get(String key, [String? defaultValue]) {
    var headers = all(key)[key.toLowerCase()];
    if (headers == null || headers.isEmpty) {
      return defaultValue;
    }
    return headers[0];
  }

  /// Sets a header by name.
  ///
  /// This method sets or adds a header to the HeaderBag. It can handle both
  /// single values and lists of values.
  ///
  /// @param key The name of the header to set. This will be converted to lowercase.
  /// @param values The value or list of values to set for the header.
  /// @param replace Whether to replace the existing values (if any) or append to them.
  ///                Defaults to true.
  ///
  /// If [replace] is true or the header doesn't exist, it will overwrite any existing
  /// values. If [replace] is false and the header exists, it will append the new values.
  ///
  /// For the 'cache-control' header, this method also updates the internal
  /// cache control directives by parsing the new header value.
  void set(String key, dynamic values, [bool replace = true]) {
    key = key.toLowerCase();
    List<String?> valueList;

    if (values is List) {
      valueList = List<String?>.from(values);
      if (replace || !_headers.containsKey(key)) {
        _headers[key] = valueList;
      } else {
        _headers[key] = List<String?>.from(_headers[key]!)..addAll(valueList);
      }
    } else {
      if (replace || !_headers.containsKey(key)) {
        _headers[key] = [values];
      } else {
        _headers[key]!.add(values);
      }
    }

    if (key == 'cache-control') {
      _cacheControl.addAll(_parseCacheControl(_headers[key]!.join(', ')));
    }
  }

  /// Checks if a specific HTTP header is present in the HeaderBag.
  ///
  /// This method determines whether a header with the given [key] exists
  /// in the HeaderBag. The header name (key) is case-insensitive.
  ///
  /// @param key The name of the HTTP header to check for.
  /// @return true if the header exists, false otherwise.
  bool hasHeader(String key) {
    return _headers.containsKey(key.toLowerCase());
  }

  /// Checks if a specific HTTP header contains a given value.
  ///
  /// This method determines whether the header specified by [key] contains
  /// the given [value]. The header name (key) is case-insensitive.
  ///
  /// @param key The name of the HTTP header to check.
  /// @param value The value to search for in the header.
  /// @return true if the header contains the value, false otherwise.
  /// If the header doesn't exist, this method returns false.
  bool containsHeaderValue(String key, String value) {
    return _headers[key.toLowerCase()]?.contains(value) ?? false;
  }

  /// Removes a header from the HeaderBag.
  ///
  /// This method removes the header specified by [key] from the HeaderBag.
  /// The key is case-insensitive and will be converted to lowercase before removal.
  ///
  /// If the removed header is 'cache-control', this method also clears
  /// the internal cache control directives.
  ///
  /// @param key The name of the header to remove.
  void remove(String key) {
    key = key.toLowerCase();
    _headers.remove(key);
    if (key == 'cache-control') {
      _cacheControl.clear();
    }
  }

  /// Returns the HTTP header value converted to a date.
  ///
  /// This method retrieves the value of the specified HTTP header and attempts
  /// to parse it as a DateTime object. If the header doesn't exist or its value
  /// is null, the method returns the provided default value.
  ///
  /// @param key The name of the HTTP header to retrieve and parse as a date.
  /// @param defaultValue An optional DateTime object to return if the header
  ///        doesn't exist or its value is null. Defaults to null if not specified.
  /// @return A DateTime object representing the parsed header value, or the
  ///         default value if the header doesn't exist or its value is null.
  /// @throws Exception if the header value cannot be parsed as a valid date.
  ///
  /// Throws an exception when the HTTP header is not parseable.
  DateTime? getDate(String key, [DateTime? defaultValue]) {
    var value = get(key);
    if (value == null) {
      return defaultValue;
    }

    try {
      return DateTime.parse(value);
    } catch (e) {
      throw Exception('The "$key" HTTP header is not parseable ($value).');
    }
  }

  /// Adds a custom Cache-Control directive.
  ///
  /// This method adds a new directive to the Cache-Control header or updates
  /// an existing one. The directive is specified by [key], and an optional
  /// [value] can be provided.
  ///
  /// @param key The name of the Cache-Control directive to add or update.
  /// @param value The value of the directive. Defaults to true if not specified.
  ///
  /// After updating the internal cache control directives, this method
  /// regenerates the Cache-Control header string and sets it using the `set` method.
  void addCacheControlDirective(String key, [dynamic value = true]) {
    _cacheControl[key] = value;
    set('Cache-Control', getCacheControlHeader());
  }

  /// Checks if a specific Cache-Control directive is present.
  ///
  /// This method determines whether a Cache-Control directive with the given [key]
  /// exists in the internal cache control directives map.
  ///
  /// @param key The name of the Cache-Control directive to check for.
  /// @return true if the directive exists, false otherwise.
  bool hasCacheControlDirective(String key) {
    return _cacheControl.containsKey(key);
  }

  /// Returns the value of a specific Cache-Control directive.
  ///
  /// This method retrieves the value associated with the given Cache-Control
  /// directive [key] from the internal cache control directives map.
  ///
  /// @param key The name of the Cache-Control directive to retrieve.
  /// @return The value of the specified Cache-Control directive, or null if
  ///         the directive doesn't exist. The return type is dynamic as
  ///         Cache-Control directive values can be of various types.
  dynamic getCacheControlDirective(String key) {
    return _cacheControl[key];
  }

  /// Removes a Cache-Control directive.
  ///
  /// This method removes the specified Cache-Control directive from the internal
  /// cache control directives map and updates the Cache-Control header accordingly.
  ///
  /// @param key The name of the Cache-Control directive to remove.
  ///
  /// After removing the directive from the internal map, this method regenerates
  /// the Cache-Control header string and sets it using the `set` method.
  void removeCacheControlDirective(String key) {
    _cacheControl.remove(key);
    set('Cache-Control', getCacheControlHeader());
  }

  /// Returns an iterator for the headers.
  ///
  /// This method provides an iterator that allows iteration over all headers
  /// in the HeaderBag. Each iteration yields a MapEntry where the key is the
  /// header name (as a String) and the value is a List of String? representing
  /// the header values.
  ///
  /// This implementation directly returns the iterator of the internal _headers
  /// map entries, allowing for efficient iteration over all headers.
  ///
  /// @return An Iterator<MapEntry<String, List<String?>>> for iterating over
  ///         all headers in the HeaderBag.
  @override
  Iterator<MapEntry<String, List<String?>>> get iterator {
    return _headers.entries.iterator;
  }

  /// Returns the number of headers.
  ///
  /// This getter provides the count of unique headers in the HeaderBag.
  /// It directly returns the length of the internal _headers map,
  /// which represents the number of distinct header names stored.
  ///
  /// @return An integer representing the number of headers in the HeaderBag.
  @override
  int get length {
    return _headers.length;
  }

  /// Generates the Cache-Control header value.
  ///
  /// This method creates a string representation of the Cache-Control header
  /// based on the directives stored in the internal _cacheControl map.
  ///
  /// The method performs the following steps:
  /// 1. Creates a sorted copy of the _cacheControl map using a SplayTreeMap.
  /// 2. Iterates through the entries of the sorted map.
  /// 3. Formats each entry as "key=value".
  /// 4. Joins all formatted entries with ", " as separator.
  ///
  /// @return A string representation of the Cache-Control header, where
  ///         directives are sorted alphabetically by key and separated by commas.
  ///         For example: "max-age=300, must-revalidate, no-cache".
  String getCacheControlHeader() {
    var sortedCacheControl = SplayTreeMap<String, dynamic>.from(_cacheControl);
    return sortedCacheControl.entries.map((e) => '${e.key}=${e.value}').join(', ');
  }

  /// Parses a Cache-Control HTTP header string into a map of directives.
  ///
  /// This method takes a Cache-Control header value as a string and converts it
  /// into a map where keys are directive names and values are directive values.
  ///
  /// The method performs the following steps:
  /// 1. Splits the header string by commas to separate individual directives.
  /// 2. For each directive, splits by '=' to separate the name and value.
  /// 3. Trims whitespace from directive names and values.
  /// 4. If a directive has no value (no '='), it's set to true.
  ///
  /// @param header A string containing the Cache-Control header value.
  /// @return A Map<String, dynamic> where keys are directive names (String)
  ///         and values are either String (for directives with values) or
  ///         bool (true for directives without values).
  Map<String, dynamic> _parseCacheControl(String header) {
    var parts = header.split(',').map((e) => e.split('=')).toList();
    var map = <String, dynamic>{};
    for (var part in parts) {
      map[part[0].trim()] = part.length > 1 ? part[1].trim() : true;
    }
    return map;
  }
}
