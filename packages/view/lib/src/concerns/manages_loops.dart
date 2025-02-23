/// A mixin that provides loop management functionality.
mixin ManagesLoops {
  /// The stack of in-progress loops.
  final List<Map<String, dynamic>> _loopsStack = [];

  /// Add new loop to the stack.
  void addLoop(dynamic data) {
    final length = data is Iterable ? data.length : null;
    final parent = _loopsStack.isNotEmpty ? _loopsStack.last : null;

    _loopsStack.add({
      'iteration': 0,
      'index': 0,
      'remaining': length,
      'count': length,
      'first': true,
      'last': length != null ? length == 1 : null,
      'odd': false,
      'even': true,
      'depth': _loopsStack.length + 1,
      'parent': parent != null ? Map<String, dynamic>.from(parent) : null,
    });
  }

  /// Increment the top loop's indices.
  void incrementLoopIndices() {
    if (_loopsStack.isEmpty) return;

    final index = _loopsStack.length - 1;
    final loop = _loopsStack[index];

    _loopsStack[index] = {
      ...loop,
      'iteration': loop['iteration'] + 1,
      'index': loop['iteration'],
      'first': loop['iteration'] == 0,
      'odd': !loop['odd'],
      'even': !loop['even'],
      'remaining': loop['count'] != null ? loop['remaining'] - 1 : null,
      'last':
          loop['count'] != null ? loop['iteration'] == loop['count'] - 1 : null,
    };
  }

  /// Pop a loop from the top of the loop stack.
  void popLoop() {
    if (_loopsStack.isNotEmpty) {
      _loopsStack.removeLast();
    }
  }

  /// Get an instance of the last loop in the stack.
  Map<String, dynamic>? getLastLoop() {
    return _loopsStack.isNotEmpty
        ? Map<String, dynamic>.from(_loopsStack.last)
        : null;
  }

  /// Get the entire loop stack.
  List<Map<String, dynamic>> getLoopStack() {
    return List<Map<String, dynamic>>.from(_loopsStack);
  }

  /// Flush all loops.
  void flushLoops() {
    _loopsStack.clear();
  }
}
