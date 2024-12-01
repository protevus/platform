/// Exception thrown when a queued entity cannot be found.
class EntityNotFoundException implements Exception {
  /// The class name of the entity.
  final String type;

  /// The ID of the entity.
  final dynamic id;

  /// Create a new entity not found exception.
  EntityNotFoundException(this.type, this.id);

  @override
  String toString() => 'No query results for model [$type] $id';
}
