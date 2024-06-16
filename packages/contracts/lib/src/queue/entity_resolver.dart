abstract class EntityResolver {
  /// Resolve the entity for the given ID.
  ///
  /// @param  String type
  /// @param  dynamic id
  /// @return dynamic
  dynamic resolve(String type, dynamic id);
}
