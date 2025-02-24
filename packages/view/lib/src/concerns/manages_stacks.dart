import '../contracts/base.dart';

/// A mixin that provides stack management functionality.
mixin ManagesStacks {
  /// All of the finished, captured push sections.
  final Map<String, Map<int, String>> _pushes = {};

  /// All of the finished, captured prepend sections.
  final Map<String, Map<int, String>> _prepends = {};

  /// The stack of in-progress push sections.
  final List<String> _pushStack = [];

  /// The current render count.
  int get renderCount;

  /// Start injecting content into a push section.
  void startPush(String section, [String content = '']) {
    _pushStack.add(section);
    if (content.isNotEmpty) {
      extendPush(section, content);
    }
  }

  /// Stop injecting content into a push section.
  String stopPush() {
    if (_pushStack.isEmpty) {
      throw ViewException(
          'Cannot end a push stack without first starting one.');
    }

    final last = _pushStack.removeLast();
    extendPush(last, ''); // Content will be managed differently in Dart
    return last;
  }

  /// Append content to a given push section.
  void extendPush(String section, String content) {
    _pushes[section] ??= {};
    _pushes[section]![renderCount] ??= '';
    _pushes[section]![renderCount] = _pushes[section]![renderCount]! + content;
  }

  /// Start prepending content into a push section.
  void startPrepend(String section, [String content = '']) {
    if (content.isEmpty) {
      _pushStack.add(section);
    } else {
      extendPrepend(section, content);
    }
  }

  /// Stop prepending content into a push section.
  String stopPrepend() {
    if (_pushStack.isEmpty) {
      throw ViewException(
          'Cannot end a prepend operation without first starting one.');
    }

    final last = _pushStack.removeLast();
    extendPrepend(last, ''); // Content will be managed differently in Dart
    return last;
  }

  /// Prepend content to a given stack.
  void extendPrepend(String section, String content) {
    _prepends[section] ??= {};
    _prepends[section]![renderCount] ??= '';
    _prepends[section]![renderCount] =
        content + _prepends[section]![renderCount]!;
  }

  /// Get the string contents of a push section.
  String yieldPushContent(String section, [String defaultContent = '']) {
    if (!_pushes.containsKey(section) && !_prepends.containsKey(section)) {
      return defaultContent;
    }

    final buffer = StringBuffer();

    if (_prepends.containsKey(section)) {
      final prependContent = _prepends[section]!.values.toList().reversed;
      buffer.writeAll(prependContent);
    }

    if (_pushes.containsKey(section)) {
      final pushContent = _pushes[section]!.values;
      buffer.writeAll(pushContent);
    }

    return buffer.toString();
  }

  /// Flush all of the stacks.
  void flushStacks() {
    _pushes.clear();
    _prepends.clear();
    _pushStack.clear();
  }
}
