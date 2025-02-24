import '../contracts/base.dart';

/// A mixin that provides section management functionality.
mixin ManagesLayouts {
  /// All of the finished, captured sections.
  final Map<String, String> _sections = {};

  /// The stack of in-progress sections.
  final List<String> _sectionStack = [];

  /// Start injecting content into a section.
  void startSection(String section, [String? content]) {
    if (content == null) {
      _sectionStack.add(section);
    } else {
      extendSection(section, content);
    }
  }

  /// Stop injecting content into a section.
  ///
  /// Throws [ViewException] if no section has been started.
  String stopSection({bool overwrite = false}) {
    if (_sectionStack.isEmpty) {
      throw ViewException('Cannot end a section without first starting one.');
    }

    final last = _sectionStack.removeLast();

    if (overwrite) {
      _sections[last] =
          ''; // In Dart we'll need to manage content differently than PHP's ob_get_clean
    } else {
      extendSection(last, ''); // Content will be managed differently
    }

    return last;
  }

  /// Stop injecting content into a section and append it.
  String appendSection() {
    if (_sectionStack.isEmpty) {
      throw ViewException('Cannot end a section without first starting one.');
    }

    final last = _sectionStack.removeLast();
    _sections[last] = (_sections[last] ?? '') +
        ''; // Content appending will be handled differently

    return last;
  }

  /// Get the string contents of a section.
  String yieldContent(String section, [String defaultContent = '']) {
    // Return default content if section exists
    if (hasSection(section)) {
      return defaultContent;
    }

    // Otherwise return section content with parent placeholder replacement
    var content = _sections[section] ?? defaultContent;
    content = content.replaceAll('@@parent', '--parent--holder--');
    return content.replaceAll('--parent--holder--', '@parent');
  }

  /// Append content to a given section.
  void extendSection(String section, String content) {
    if (_sections.containsKey(section)) {
      content = _sections[section]!.replaceAll('@parent', content);
    }
    _sections[section] = content;
  }

  /// Check if section exists.
  bool hasSection(String name) => _sections.containsKey(name);

  /// Check if section does not exist.
  bool sectionMissing(String name) => !hasSection(name);

  /// Get the contents of a section.
  String? getSection(String name, [String? defaultContent]) {
    return _sections[name] ?? defaultContent;
  }

  /// Get all sections.
  Map<String, String> get sections => Map.unmodifiable(_sections);

  /// Flush all of the sections.
  void flushSections() {
    _sections.clear();
    _sectionStack.clear();
  }
}
