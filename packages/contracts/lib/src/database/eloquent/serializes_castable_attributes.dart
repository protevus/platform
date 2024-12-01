/// Interface for serializing castable attributes.
///
/// This contract defines how model attributes should be serialized when
/// converting a model to an array or JSON. It allows custom casts to
/// control how their values are represented in array/JSON form.
abstract class SerializesCastableAttributes {
  /// Serialize the attribute when converting the model to an array.
  ///
  /// Example:
  /// ```dart
  /// class DateCast implements SerializesCastableAttributes {
  ///   @override
  ///   dynamic serialize(
  ///     dynamic model,
  ///     String key,
  ///     dynamic value,
  ///     Map<String, dynamic> attributes,
  ///   ) {
  ///     return value?.toIso8601String();
  ///   }
  /// }
  /// ```
  dynamic serialize(
    dynamic model,
    String key,
    dynamic value,
    Map<String, dynamic> attributes,
  );
}
