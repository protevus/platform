/// Interface for objects that can control their string escaping behavior.
///
/// This contract allows objects to specify whether their string representation
/// should be HTML escaped when converted to a string. This is particularly
/// useful for objects that may contain HTML content that should sometimes be
/// escaped and other times rendered as-is.
abstract class CanBeEscapedWhenCastToString {
  /// Indicate that the object's string representation should be escaped when toString is invoked.
  ///
  /// Example:
  /// ```dart
  /// class HtmlContent implements CanBeEscapedWhenCastToString {
  ///   final String content;
  ///   bool _escape = false;
  ///
  ///   HtmlContent(this.content);
  ///
  ///   @override
  ///   CanBeEscapedWhenCastToString escapeWhenCastingToString([bool escape = true]) {
  ///     _escape = escape;
  ///     return this;
  ///   }
  ///
  ///   @override
  ///   String toString() {
  ///     if (_escape) {
  ///       return content
  ///         .replaceAll('&', '&amp;')
  ///         .replaceAll('<', '&lt;')
  ///         .replaceAll('>', '&gt;');
  ///     }
  ///     return content;
  ///   }
  /// }
  /// ```
  CanBeEscapedWhenCastToString escapeWhenCastingToString([bool escape = true]);
}
