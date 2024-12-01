/// Interface for queueable entities.
abstract class QueueableEntity {
  /// Get the queueable identity for the entity.
  dynamic getQueueableId();

  /// Get the relationships for the entity.
  List<dynamic> getQueueableRelations();

  /// Get the connection of the entity.
  String? getQueueableConnection();
}
