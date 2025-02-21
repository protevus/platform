import 'dart:convert';

/// Represents a cursor for paginating through a dataset.
///
/// Cursors are particularly useful for APIs and real-time data where
/// offset-based pagination might lead to skipped or duplicated items.
class Cursor {
  /// The target parameter value.
  final dynamic _parameter;

  /// Create a new cursor instance.
  const Cursor(this._parameter);

  /// Get the cursor's parameter value.
  dynamic get parameter => _parameter;

  /// Create a cursor from the given parameters.
  ///
  /// Example:
  /// ```dart
  /// final cursor = Cursor.fromParameters({
  ///   'created_at': '2024-02-19T00:00:00Z',
  ///   'id': 123,
  /// });
  /// ```
  static Cursor? fromParameters(Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return null;
    return Cursor(parameters);
  }

  /// Convert the cursor to a query string parameter.
  ///
  /// This method encodes the cursor's parameter value as a base64 string
  /// to ensure safe transmission in URLs.
  String? encode() {
    if (_parameter == null) return null;
    final jsonString = _parameter.toString();
    final bytes = utf8.encode(jsonString);
    return base64Url.encode(bytes);
  }

  /// Create a cursor from an encoded string.
  ///
  /// This method decodes a base64-encoded cursor string back into a Cursor object.
  static Cursor? decode(String? encoded) {
    if (encoded == null || encoded.isEmpty) return null;
    try {
      final bytes = base64Url.decode(encoded);
      final jsonString = utf8.decode(bytes);
      return Cursor(jsonString);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => 'Cursor(parameter: $_parameter)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cursor && other._parameter == _parameter;
  }

  @override
  int get hashCode => _parameter.hashCode;
}
