/// A class that ensures a callback is only executed once.
///
/// This class provides functionality similar to Laravel's once helper,
/// ensuring that a callback is only executed one time.
class Once {
  /// Whether the callback has been executed.
  bool _executed = false;

  /// The result of the callback execution.
  dynamic _result;

  /// Execute the callback only once and return the result.
  ///
  /// Example:
  /// ```dart
  /// final once = Once();
  /// final result1 = once.call(() => expensiveOperation()); // Executes
  /// final result2 = once.call(() => expensiveOperation()); // Returns cached result
  /// ```
  T call<T>(T Function() callback) {
    if (!_executed) {
      _result = callback();
      _executed = true;
    }
    return _result as T;
  }

  /// Reset the execution state.
  ///
  /// This allows the callback to be executed again.
  ///
  /// Example:
  /// ```dart
  /// final once = Once();
  /// once.call(() => print('First')); // Prints
  /// once.call(() => print('Second')); // Doesn't print
  /// once.reset();
  /// once.call(() => print('Third')); // Prints
  /// ```
  void reset() {
    _executed = false;
    _result = null;
  }

  /// Check if the callback has been executed.
  ///
  /// Example:
  /// ```dart
  /// final once = Once();
  /// print(once.executed); // false
  /// once.call(() => print('Hello'));
  /// print(once.executed); // true
  /// ```
  bool get executed => _executed;
}
