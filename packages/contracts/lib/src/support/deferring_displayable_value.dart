import 'htmlable.dart';

/// Interface for values that defer their display representation.
///
/// This contract is used for objects that need to defer the resolution of their
/// displayable value until it's actually needed. This can be useful for lazy
/// loading of expensive-to-compute display values or for values that might
/// change based on runtime conditions.
///
/// Example:
/// ```dart
/// class LazyHtmlContent implements DeferringDisplayableValue {
///   final Function _valueFactory;
///
///   LazyHtmlContent(this._valueFactory);
///
///   @override
///   dynamic resolveDisplayableValue() {
///     final value = _valueFactory();
///     if (value is Htmlable) {
///       return value;
///     }
///     return value.toString();
///   }
/// }
/// ```
abstract class DeferringDisplayableValue {
  /// Resolve the displayable value that the class is deferring.
  ///
  /// Returns either an [Htmlable] object or a [String].
  dynamic resolveDisplayableValue();
}
