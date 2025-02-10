/// Interface for objects that can be converted to HTML.
///
/// This contract defines a standard way for objects to be converted
/// to their HTML string representation. This is particularly useful
/// for components that need to render HTML content while ensuring
/// proper escaping and formatting.
///
/// Example:
/// ```dart
/// class HtmlComponent implements Htmlable {
///   final String content;
///   final Map<String, String> attributes;
///
///   HtmlComponent(this.content, this.attributes);
///
///   @override
///   String toHtml() {
///     final attrs = attributes.entries
///         .map((e) => '${e.key}="${escapeHtml(e.value)}"')
///         .join(' ');
///     return '<div $attrs>${escapeHtml(content)}</div>';
///   }
///
///   String escapeHtml(String text) {
///     return text
///         .replaceAll('&', '&amp;')
///         .replaceAll('<', '&lt;')
///         .replaceAll('>', '&gt;')
///         .replaceAll('"', '&quot;')
///         .replaceAll("'", '&#039;');
///   }
/// }
/// ```
abstract class Htmlable {
  /// Get content as a string of HTML.
  ///
  /// This method should return valid HTML markup. Implementations
  /// should ensure proper escaping of content to prevent XSS attacks
  /// and maintain valid HTML structure.
  String toHtml();
}
