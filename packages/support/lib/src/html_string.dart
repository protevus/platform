import 'package:platform_contracts/contracts.dart';
import 'stringable.dart';

/// A string that should not be escaped when cast to HTML.
///
/// This class represents a string that contains HTML content that should be rendered
/// as-is without escaping. This is useful when you want to include raw HTML in your
/// output while still maintaining proper type safety and intent.
///
/// Example:
/// ```dart
/// final content = HtmlString('<p>Hello, <strong>world!</strong></p>');
/// print(content.toHtml()); // Outputs: <p>Hello, <strong>world!</strong></p>
/// ```
class HtmlString extends Stringable implements Htmlable {
  /// Create a new HTML string value.
  ///
  /// The provided string will be treated as raw HTML and will not be escaped
  /// when rendered.
  HtmlString(String html) : super(html);

  /// Get content as a string of HTML.
  ///
  /// Returns the raw HTML string without any escaping. This is safe because
  /// the string is explicitly marked as containing HTML through this class.
  @override
  String toHtml() => toString();

  /// Compare this HTML string with another object.
  ///
  /// Returns true if the other object is also an HtmlString and has the same
  /// HTML content.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HtmlString && other.toString() == toString();
  }

  /// Get the hash code for this HTML string.
  @override
  int get hashCode => toString().hashCode;

  /// Create a new HTML string from a regular string.
  ///
  /// This is a convenience method for creating an HtmlString instance.
  static HtmlString from(String html) => HtmlString(html);

  /// Create an empty HTML string.
  ///
  /// This is useful when you need to represent an empty HTML content.
  static final empty = HtmlString('');
}
