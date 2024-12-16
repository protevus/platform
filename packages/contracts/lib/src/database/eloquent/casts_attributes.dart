/// Interface for custom attribute casting.
///
/// This contract defines how model attributes should be cast to and from
/// their database representation. It provides methods for transforming
/// attributes when they are retrieved from or set on a model.
abstract class CastsAttributes<TGet, TSet> {
  /// Transform the attribute from the underlying model values.
  ///
  /// Example:
  /// ```dart
  /// class JsonCast implements CastsAttributes<Map<String, dynamic>, String> {
  ///   @override
  ///   Map<String, dynamic>? get(
  ///     Model model,
  ///     String key,
  ///     dynamic value,
  ///     Map<String, dynamic> attributes,
  ///   ) {
  ///     return value != null ? jsonDecode(value) : null;
  ///   }
  /// }
  /// ```
  TGet? get(
    dynamic model,
    String key,
    dynamic value,
    Map<String, dynamic> attributes,
  );

  /// Transform the attribute to its underlying model values.
  ///
  /// Example:
  /// ```dart
  /// class JsonCast implements CastsAttributes<Map<String, dynamic>, String> {
  ///   @override
  ///   dynamic set(
  ///     Model model,
  ///     String key,
  ///     String? value,
  ///     Map<String, dynamic> attributes,
  ///   ) {
  ///     return value != null ? jsonEncode(value) : null;
  ///   }
  /// }
  /// ```
  dynamic set(
    dynamic model,
    String key,
    TSet? value,
    Map<String, dynamic> attributes,
  );
}
