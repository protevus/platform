/// Exception thrown when an item is not found in a collection.
class ItemNotFoundException implements Exception {
  /// The key or index that was searched for.
  final dynamic key;

  /// Optional message providing more details about the error.
  final String? message;

  /// Creates a new [ItemNotFoundException].
  ///
  /// The [key] parameter is the key or index that was searched for.
  /// An optional [message] can be provided for more details.
  const ItemNotFoundException([this.key, this.message]);

  @override
  String toString() {
    if (message != null) {
      return 'Item not found: $message';
    }
    if (key != null) {
      return 'Item [$key] not found.';
    }
    return 'Item not found.';
  }
}
