/// Interface for inbound attribute casting.
///
/// This contract defines how model attributes should be cast when they are
/// set on a model. Unlike [CastsAttributes], this interface only handles
/// the transformation of values being set, not retrieved.
abstract class CastsInboundAttributes {
  /// Transform the attribute to its underlying model values.
  ///
  /// Example:
  /// ```dart
  /// class PasswordCast implements CastsInboundAttributes {
  ///   @override
  ///   dynamic set(
  ///     dynamic model,
  ///     String key,
  ///     dynamic value,
  ///     Map<String, dynamic> attributes,
  ///   ) {
  ///     return value != null ? hashPassword(value) : null;
  ///   }
  /// }
  /// ```
  dynamic set(
    dynamic model,
    String key,
    dynamic value,
    Map<String, dynamic> attributes,
  );
}
