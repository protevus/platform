import 'dart:collection';

/// HeaderBag is a container for HTTP headers.
///
/// Author: Fabien Potencier <fabien@symfony.com>
/// This file is part of the Symfony package.
class HeaderBag extends IterableBase<MapEntry<String, List<String?>>> {
  static const String upper = '_ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String lower = '-abcdefghijklmnopqrstuvwxyz';

  /// A map to store the headers.
  final Map<String, List<String?>> _headers = {};

  /// A map to store cache control directives.
  final Map<String, dynamic> _cacheControl = {};

  /// Constructor for HeaderBag
  HeaderBag([Map<String, List<String?>> headers = const {}]) {
    headers.forEach((key, values) {
      set(key, values);
    });
  }

  /// Returns the headers as a string.
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

  /// Returns the headers.
  ///
  /// @param key The name of the headers to return or null to get them all
  ///
  /// @return A map of headers.
  Map<String, List<String?>> all([String? key]) {
    if (key != null) {
      return {key.toLowerCase(): _headers[key.toLowerCase()] ?? []};
    }
    return _headers;
  }

  /// Returns the parameter keys.
  ///
  /// @return A list of keys.
  List<String> keys() {
    return _headers.keys.toList();
  }

  /// Replaces the current HTTP headers by a new set.
  void replace(Map<String, List<String?>> headers) {
    _headers.clear();
    add(headers);
  }

  /// Adds new headers to the current HTTP headers set.
  void add(Map<String, List<String?>> headers) {
    headers.forEach((key, values) {
      set(key, values);
    });
  }

  /// Returns the first header by name or the default one.
  String? get(String key, [String? defaultValue]) {
    var headers = all(key)[key.toLowerCase()];
    if (headers == null || headers.isEmpty) {
      return defaultValue;
    }
    return headers[0];
  }

  /// Sets a header by name.
  ///
  /// @param values The value or an array of values
  /// @param replace Whether to replace the actual value or not (true by default)
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

  /// Returns true if the HTTP header is defined.
  bool hasHeader(String key) {
    return _headers.containsKey(key.toLowerCase());
  }

  /// Returns true if the given HTTP header contains the given value.
  bool containsHeaderValue(String key, String value) {
    return _headers[key.toLowerCase()]?.contains(value) ?? false;
  }

  /// Removes a header.
  void remove(String key) {
    key = key.toLowerCase();
    _headers.remove(key);
    if (key == 'cache-control') {
      _cacheControl.clear();
    }
  }

  /// Returns the HTTP header value converted to a date.
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
  void addCacheControlDirective(String key, [dynamic value = true]) {
    _cacheControl[key] = value;
    set('Cache-Control', getCacheControlHeader());
  }

  /// Returns true if the Cache-Control directive is defined.
  bool hasCacheControlDirective(String key) {
    return _cacheControl.containsKey(key);
  }

  /// Returns a Cache-Control directive value by name.
  dynamic getCacheControlDirective(String key) {
    return _cacheControl[key];
  }

  /// Removes a Cache-Control directive.
  void removeCacheControlDirective(String key) {
    _cacheControl.remove(key);
    set('Cache-Control', getCacheControlHeader());
  }

  /// Returns an iterator for headers.
  ///
  /// @return An iterator of MapEntry.
  @override
  Iterator<MapEntry<String, List<String?>>> get iterator {
    return _headers.entries.iterator;
  }

  /// Returns the number of headers.
  @override
  int get length {
    return _headers.length;
  }

  /// Generates the Cache-Control header value.
  ///
  /// @return A string representation of the Cache-Control header.
  String getCacheControlHeader() {
    var sortedCacheControl = SplayTreeMap<String, dynamic>.from(_cacheControl);
    return sortedCacheControl.entries.map((e) => '${e.key}=${e.value}').join(', ');
  }

  /// Parses a Cache-Control HTTP header.
  ///
  /// @return A map of Cache-Control directives.
  Map<String, dynamic> _parseCacheControl(String header) {
    var parts = header.split(',').map((e) => e.split('=')).toList();
    var map = <String, dynamic>{};
    for (var part in parts) {
      map[part[0].trim()] = part.length > 1 ? part[1].trim() : true;
    }
    return map;
  }
}
