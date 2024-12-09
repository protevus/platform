import 'package:dsr_container/container.dart';

/// Exception thrown when an entry is not found in the container.
class EntryNotFoundException implements Exception, NotFoundExceptionInterface {
  @override
  final String message;

  @override
  final String id;

  /// Creates a new entry not found exception.
  const EntryNotFoundException(this.id, [this.message = '']);

  @override
  String toString() {
    if (message.isEmpty) {
      return 'EntryNotFoundException: No entry was found for "$id" identifier';
    }
    return 'EntryNotFoundException: $message';
  }
}
