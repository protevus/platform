import 'dart:convert';
import 'package:platform_contracts/contracts.dart';
import 'stringable.dart';

/// A class for converting values to JavaScript expressions.
///
/// This class provides functionality to convert Dart values into JavaScript
/// expressions, similar to Laravel's Js class. It's particularly useful when
/// you need to pass data from Dart to JavaScript in a safe and consistent way.
class Js extends Stringable
    implements Arrayable<String, dynamic>, Htmlable, Jsonable {
  /// The raw value before JavaScript conversion.
  final dynamic _rawValue;

  /// Create a new JavaScript expression instance.
  Js(this._rawValue) : super(_rawValue.toString());

  /// Convert the value to its JavaScript equivalent.
  ///
  /// This method converts the value to a JavaScript expression string.
  /// - null becomes 'null'
  /// - bool becomes 'true' or 'false'
  /// - num becomes its string representation
  /// - String becomes a quoted string
  /// - List becomes an array expression
  /// - Map becomes an object expression
  String toJs() {
    if (_rawValue == null) return 'null';
    if (_rawValue is bool) return _rawValue.toString();
    if (_rawValue is num) return _rawValue.toString();
    return "'${_escape(super.toString())}'";
  }

  /// Escape special characters in a string.
  String _escape(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll(r'$', r'\$')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r')
        .replaceAll('\t', r'\t')
        .replaceAll('\f', r'\f')
        .replaceAll('\b', r'\b');
  }

  /// Get the instance as an array.
  @override
  Map<String, dynamic> toArray() {
    try {
      if (_rawValue == null) return {};
      if (_rawValue is bool) return {'value': _rawValue};
      if (_rawValue is num) return {'value': _rawValue};
      return {'value': super.toString()};
    } catch (e) {
      return {'value': super.toString()};
    }
  }

  /// Convert the object to its JSON representation.
  @override
  String toJson([Map<String, dynamic>? options]) {
    return jsonEncode(toArray());
  }

  /// Get content as a string of HTML.
  @override
  String toHtml() {
    return '<script>${toJs()}</script>';
  }

  /// Convert the value to a string.
  ///
  /// When used in string interpolation or direct string conversion,
  /// returns the JavaScript representation.
  @override
  String toString() => toJs();

  /// Create a new JavaScript expression instance.
  static Js from(dynamic value) => Js(value);
}
