abstract class Jsonable {
  /// Convert the object to its JSON representation.
  ///
  /// [options] Optional argument for JSON encoding options.
  /// Returns the JSON representation of the object as a String.
  String toJson({int options = 0});
}
