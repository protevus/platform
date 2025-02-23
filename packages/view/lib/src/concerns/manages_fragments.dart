import '../contracts/base.dart';

/// A mixin that provides fragment management functionality.
mixin ManagesFragments {
  /// All of the captured, rendered fragments.
  final Map<String, String> _fragments = {};

  /// The stack of in-progress fragment renders.
  final List<String> _fragmentStack = [];

  /// Start injecting content into a fragment.
  void startFragment(String fragment) {
    _fragmentStack.add(fragment);
  }

  /// Stop injecting content into a fragment.
  String stopFragment() {
    if (_fragmentStack.isEmpty) {
      throw ViewException('Cannot end a fragment without first starting one.');
    }

    final last = _fragmentStack.removeLast();
    _fragments[last] = ''; // Content will be managed differently in Dart

    return _fragments[last]!;
  }

  /// Get the contents of a fragment.
  String? getFragment(String name, [String? defaultContent]) {
    return getFragments()[name] ?? defaultContent;
  }

  /// Get the entire array of rendered fragments.
  Map<String, String> getFragments() {
    return Map<String, String>.unmodifiable(_fragments);
  }

  /// Flush all of the fragments.
  void flushFragments() {
    _fragments.clear();
    _fragmentStack.clear();
  }
}
