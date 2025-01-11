import 'package:mustache_template/mustache_template.dart';

/// Template engine for rendering notification content.
class TemplateEngine {
  /// The template cache to avoid re-parsing templates.
  static final Map<String, Template> _cache = {};

  /// Render a template with the given data.
  ///
  /// [template] The template string to render
  /// [data] The data to use for rendering
  /// [htmlEscape] Whether to HTML escape the output (default: true)
  static String render(String template, Map<String, dynamic> data,
      {bool htmlEscape = true}) {
    // Get or create template
    final compiledTemplate = _cache.putIfAbsent(
        template, () => Template(template, htmlEscapeValues: htmlEscape));

    // Render template with data
    return compiledTemplate.renderString(data);
  }

  /// Clear the template cache.
  static void clearCache() {
    _cache.clear();
  }
}
