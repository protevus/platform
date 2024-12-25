import 'package:dsr_container/container.dart';

/// Exception thrown when an entry is not found in the container.
class EntryNotFoundException implements NotFoundExceptionInterface {
  @override
  final String id;

  @override
  final String message;

  /// Creates a new [EntryNotFoundException] instance.
  EntryNotFoundException(this.id, [this.message = '']);

  @override
  String toString() {
    if (message.isEmpty) {
      return 'EntryNotFoundException: No entry was found for "$id" identifier';
    }
    return 'EntryNotFoundException: $message';
  }
}
