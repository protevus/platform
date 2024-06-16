abstract class QueueableCollection {
  /// Get the type of the entities being queued.
  ///
  /// @return String|null
  String? getQueueableClass();

  /// Get the identifiers for all of the entities.
  ///
  /// @return List<int, dynamic>
  List<dynamic> getQueueableIds();

  /// Get the relationships of the entities being queued.
  ///
  /// @return List<int, String>
  List<String> getQueueableRelations();

  /// Get the connection of the entities being queued.
  ///
  /// @return String|null
  String? getQueueableConnection();
}
