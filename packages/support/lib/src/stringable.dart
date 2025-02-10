import 'package:illuminate_macroable/macroable.dart';
import 'package:illuminate_conditionable/conditionable.dart';
import 'traits/dumpable.dart';
import 'traits/tappable.dart';
import 'facades/date.dart';
import 'carbon.dart';
import 'str.dart';

/// A class that provides string manipulation capabilities.
class Stringable with Macroable, Conditionable, Dumpable, Tappable {
  /// The underlying string value.
  String _value;

  /// Create a new stringable instance.
  Stringable(this._value);

  /// Get the string length.
  int getLength() => Str.length(_value);

  /// Convert the given string to camel case.
  Stringable camel() {
    _value = Str.camel(_value);
    return this;
  }

  /// Convert the given string to studly caps case.
  Stringable studly() {
    _value = Str.studly(_value);
    return this;
  }

  /// Convert a string to snake case.
  Stringable snake([String separator = '_']) {
    if (_value.isEmpty) return this;

    final result = StringBuffer();
    result.write(_value[0].toLowerCase());

    for (var i = 1; i < _value.length; i++) {
      if (_value[i].toUpperCase() == _value[i] &&
          _value[i].toLowerCase() != _value[i]) {
        result.write(separator);
        result.write(_value[i].toLowerCase());
      } else {
        result.write(_value[i]);
      }
    }

    _value = result.toString().replaceAll('_', separator);
    return this;
  }

  /// Convert a string to kebab case.
  Stringable kebab() {
    _value = snake('-').toString();
    return this;
  }

  /// Convert the given string to title case.
  Stringable title() {
    _value = Str.title(_value);
    return this;
  }

  /// Convert the given string to lower case.
  Stringable lower() {
    _value = Str.lower(_value);
    return this;
  }

  /// Convert the given string to upper case.
  Stringable upper() {
    _value = Str.upper(_value);
    return this;
  }

  /// Generate a URL friendly "slug" from a given string.
  Stringable slug([String separator = '-']) {
    _value = Str.slug(_value, separator: separator);
    return this;
  }

  /// Convert a string to its ASCII representation.
  Stringable ascii() {
    _value = Str.ascii(_value);
    return this;
  }

  /// Determine if a given string starts with a given substring.
  bool startsWith(dynamic needles) => Str.startsWith(_value, needles);

  /// Determine if a given string ends with a given substring.
  bool endsWith(dynamic needles) => Str.endsWith(_value, needles);

  /// Cap a string with a single instance of a given value.
  Stringable finish(String cap) {
    _value = Str.finish(_value, cap);
    return this;
  }

  /// Begin a string with a single instance of a given value.
  Stringable start(String prefix) {
    _value = Str.start(_value, prefix);
    return this;
  }

  /// Determine if a given string contains a given substring.
  bool contains(dynamic needles) => Str.contains(_value, needles);

  /// Limit the number of characters in a string.
  Stringable limit(int limit, [String end = '...']) {
    _value = Str.limit(_value, limit, end);
    return this;
  }

  /// Convert the given string to base64.
  Stringable toBase64() {
    _value = Str.toBase64(_value);
    return this;
  }

  /// Convert the given base64 string back to a normal string.
  Stringable fromBase64() {
    _value = Str.fromBase64(_value);
    return this;
  }

  /// Parse a Class[@]method style callback string.
  List<String>? parseCallback([String separator = '@']) =>
      Str.parseCallback(_value, separator);

  /// Mask a portion of a string with a repeated character.
  Stringable mask(int start, [int? length, String mask = '*']) {
    if (start < 0 || start >= _value.length) return this;

    final maskLength = length ?? (_value.length - start);
    final end = start + maskLength;
    if (end > _value.length) return this;

    final original = _value;
    _value = original.substring(0, start) +
        (length != null ? mask * length : mask * (original.length - start)) +
        (length != null ? original.substring(end) : '');
    return this;
  }

  /// Pad both sides of a string with another.
  Stringable padBoth(int length, [String pad = ' ']) {
    final remaining = length - _value.length;
    if (remaining <= 0) return this;

    final leftPad = pad * (remaining ~/ 2);
    final rightPad = remaining % 2 == 0
        ? pad * (remaining ~/ 2)
        : pad * ((remaining - leftPad.length));
    _value = leftPad + _value + rightPad;
    return this;
  }

  /// Pad the left side of a string with another.
  Stringable padLeft(int length, [String pad = ' ']) {
    final remaining = length - _value.length;
    if (remaining <= 0) return this;
    _value = pad * remaining + _value;
    return this;
  }

  /// Pad the right side of a string with another.
  Stringable padRight(int length, [String pad = ' ']) {
    final remaining = length - _value.length;
    if (remaining <= 0) return this;
    _value = _value + pad * remaining;
    return this;
  }

  /// Split a string by a regular expression.
  List<String> split(Pattern pattern) => _value.split(pattern);

  /// Get a substring of the given string.
  Stringable substr(int start, [int? length]) {
    if (start < 0) start = _value.length + start;
    if (start < 0) start = 0;
    if (start >= _value.length) return this;

    final end = length != null ? start + length : _value.length;
    _value = _value.substring(start, end > _value.length ? _value.length : end);
    return this;
  }

  /// Replace all occurrences of the search string with the replacement string.
  Stringable replace(Pattern from, String replace) {
    _value = _value.replaceAll(from, replace);
    return this;
  }

  /// Replace the first occurrence of the search string with the replacement string.
  Stringable replaceFirst(Pattern from, String replace) {
    _value = _value.replaceFirst(from, replace);
    return this;
  }

  /// Replace the last occurrence of the search string with the replacement string.
  Stringable replaceLast(Pattern from, String replace) {
    final matches = from.allMatches(_value).toList();
    if (matches.isNotEmpty) {
      final lastMatch = matches.last;
      _value = _value.substring(0, lastMatch.start) +
          replace +
          _value.substring(lastMatch.end);
    }
    return this;
  }

  /// Convert the string to a boolean value.
  bool toBoolean() {
    final lower = _value.toLowerCase();
    return lower == 'true' || lower == '1' || lower == 'yes' || lower == 'on';
  }

  /// Trim the string of whitespace.
  Stringable trim() {
    _value = _value.trim();
    return this;
  }

  /// Trim the string of the given characters.
  Stringable trimChars(String chars) {
    for (var i = 0; i < chars.length; i++) {
      final char = chars[i];
      while (_value.startsWith(char)) {
        _value = _value.substring(1);
      }
      while (_value.endsWith(char)) {
        _value = _value.substring(0, _value.length - 1);
      }
    }
    return this;
  }

  /// Get the string between the given start and end delimiters.
  Stringable between(String start, String end) {
    final startPos = _value.indexOf(start);
    if (startPos != -1) {
      final endPos = _value.indexOf(end, startPos + start.length);
      if (endPos != -1) {
        _value = _value.substring(startPos + start.length, endPos);
      }
    }
    return this;
  }

  /// Get the portion of a string before a given value.
  Stringable before(String search) {
    final pos = _value.indexOf(search);
    if (pos != -1) {
      _value = _value.substring(0, pos);
    }
    return this;
  }

  /// Get the portion of a string after a given value.
  Stringable after(String search) {
    final pos = _value.indexOf(search);
    if (pos != -1) {
      _value = _value.substring(pos + search.length);
    }
    return this;
  }

  /// Get the portion of a string before the last occurrence of a given value.
  Stringable beforeLast(String search) {
    final pos = _value.lastIndexOf(search);
    if (pos != -1) {
      _value = _value.substring(0, pos);
    }
    return this;
  }

  /// Get the portion of a string after the last occurrence of a given value.
  Stringable afterLast(String search) {
    final pos = _value.lastIndexOf(search);
    if (pos != -1) {
      _value = _value.substring(pos + search.length);
    }
    return this;
  }

  /// Determine if a given string matches a given pattern.
  bool matches(Pattern pattern) => pattern.allMatches(_value).isNotEmpty;

  /// Parse the string into a Carbon instance.
  Carbon toDate() => Date.parse(_value);

  /// Get the string value.
  @override
  String toString() => _value;

  /// Compare this string with another string.
  bool equals(String other) => _value == other;

  /// Get the hash code for this string.
  @override
  int get hashCode => _value.hashCode;

  /// Compare this string with another object.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Stringable && other._value == _value;
  }

  /// Create a new stringable instance from a string.
  static Stringable from(String value) => Stringable(value);

  /// Dump the string value.
  @override
  T dump<T extends Object>([List<Object?>? args]) {
    print(_value);
    if (args != null) {
      for (final arg in args) {
        print(arg);
      }
    }
    return this as T;
  }

  /// Dump the string value and die.
  @override
  Never dd([List<Object?>? args]) {
    dump(args);
    throw Exception('Dump and die');
  }
}
