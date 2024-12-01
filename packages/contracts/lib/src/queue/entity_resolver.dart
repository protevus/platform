/// Interface for resolving queue entities.
abstract class EntityResolver {
  /// Resolve the entity for the given ID.
  dynamic resolve(String type, dynamic id);
}
