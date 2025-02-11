/// Interface for queueable collections.
abstract class QueueableCollection {
  /// Get the type of the entities being queued.
  String? getQueueableClass();

  /// Get the identifiers for all of the entities.
  List<dynamic> getQueueableIds();

  /// Get the relationships of the entities being queued.
  List<String> getQueueableRelations();

  /// Get the connection of the entities being queued.
  String? getQueueableConnection();
}
