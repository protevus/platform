/// Interface for objects that can be rendered to a string.
///
/// This contract defines a standard way for objects to be rendered
/// into their string representation. This is particularly useful
/// for views, templates, and other UI components that need to
/// produce output for display.
///
/// Example:
/// ```dart
/// class Template implements Renderable {
///   final String template;
///   final Map<String, dynamic> data;
///
///   Template(this.template, this.data);
///
///   @override
///   String render() {
///     // Process template with data and return result
///     return processTemplate(template, data);
///   }
/// }
/// ```
abstract class Renderable {
  /// Get the evaluated contents of the object.
  ///
  /// This method should return the final string representation
  /// of the object after all processing and evaluation is complete.
  String render();
}
