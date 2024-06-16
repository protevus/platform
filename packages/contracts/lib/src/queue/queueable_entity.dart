abstract class QueueableEntity {
  /// Get the queueable identity for the entity.
  ///
  /// @return dynamic
  dynamic getQueueableId();

  /// Get the relationships for the entity.
  ///
  /// @return List
  List<dynamic> getQueueableRelations();

  /// Get the connection of the entity.
  ///
  /// @return String?
  String? getQueueableConnection();
}
