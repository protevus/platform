/// Interface for incrementing and decrementing castable attributes.
///
/// This contract defines how model attributes should be modified when
/// performing increment and decrement operations. It allows custom casts
/// to handle these operations in a way that makes sense for their data type.
abstract class DeviatesCastableAttributes {
  /// Increment the attribute.
  ///
  /// Example:
  /// ```dart
  /// class JsonCounterCast implements DeviatesCastableAttributes {
  ///   @override
  ///   dynamic increment(
  ///     dynamic model,
  ///     String key,
  ///     dynamic value,
  ///     Map<String, dynamic> attributes,
  ///   ) {
  ///     var data = jsonDecode(attributes[key] ?? '{"count": 0}');
  ///     data['count'] += value;
  ///     return jsonEncode(data);
  ///   }
  /// }
  /// ```
  dynamic increment(
    dynamic model,
    String key,
    dynamic value,
    Map<String, dynamic> attributes,
  );

  /// Decrement the attribute.
  ///
  /// Example:
  /// ```dart
  /// class JsonCounterCast implements DeviatesCastableAttributes {
  ///   @override
  ///   dynamic decrement(
  ///     dynamic model,
  ///     String key,
  ///     dynamic value,
  ///     Map<String, dynamic> attributes,
  ///   ) {
  ///     var data = jsonDecode(attributes[key] ?? '{"count": 0}');
  ///     data['count'] -= value;
  ///     return jsonEncode(data);
  ///   }
  /// }
  /// ```
  dynamic decrement(
    dynamic model,
    String key,
    dynamic value,
    Map<String, dynamic> attributes,
  );
}
