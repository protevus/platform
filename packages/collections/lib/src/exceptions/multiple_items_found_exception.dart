/// Exception thrown when multiple items are found when only one was expected.
class MultipleItemsFoundException implements Exception {
  /// The number of items found.
  final int count;

  /// Optional message providing more details about the error.
  final String? message;

  /// Creates a new [MultipleItemsFoundException].
  ///
  /// The [count] parameter is the number of items that were found.
  /// An optional [message] can be provided for more details.
  const MultipleItemsFoundException([this.count = 0, this.message]);

  @override
  String toString() {
    if (message != null) {
      return 'Multiple items found: $message';
    }
    if (count > 0) {
      return 'Found $count items when expecting exactly one.';
    }
    return 'Multiple items found when expecting exactly one.';
  }
}
