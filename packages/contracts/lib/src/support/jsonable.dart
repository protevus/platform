/// Interface for objects that can be converted to JSON.
///
/// This contract defines a standard way for objects to be converted
/// to their JSON string representation, which is useful for serialization
/// and data transfer operations.
abstract class Jsonable {
  /// Convert the object to its JSON representation.
  ///
  /// The [options] parameter can be used to customize the JSON encoding process.
  /// Implementations may define their own options to control the output format.
  ///
  /// Example:
  /// ```dart
  /// class User implements Jsonable {
  ///   final String name;
  ///   final int age;
  ///
  ///   User(this.name, this.age);
  ///
  ///   @override
  ///   String toJson([Map<String, dynamic>? options]) {
  ///     return json.encode({
  ///       'name': name,
  ///       'age': age,
  ///     });
  ///   }
  /// }
  /// ```
  String toJson([Map<String, dynamic>? options]);
}
