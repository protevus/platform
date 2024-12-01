/// Class for model serialization.
///
/// This class is used to identify models during serialization.
class ModelIdentifier {
  /// The class name of the model.
  final String className;

  /// The unique identifier of the model.
  ///
  /// This may be either a single ID or an array of IDs.
  final dynamic id;

  /// The relationships loaded on the model.
  final List<String> relations;

  /// The connection name of the model.
  final String? connection;

  /// The class name of the model collection.
  String? collectionClass;

  /// Create a new model identifier.
  ModelIdentifier(
    this.className,
    this.id,
    this.relations,
    this.connection,
  );

  /// Specify the collection class that should be used when serializing / restoring collections.
  ModelIdentifier useCollectionClass(String? collectionClass) {
    this.collectionClass = collectionClass;
    return this;
  }
}
