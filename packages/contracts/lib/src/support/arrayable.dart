/// Interface for objects that can be converted to an array.
///
/// This contract defines a standard way for objects to be converted
/// to array representation, which is useful for serialization,
/// data transfer, and other operations requiring array format.
abstract class Arrayable<TKey, TValue> {
  /// Get the instance as an array.
  ///
  /// Implementations should convert their internal state to a Map/array
  /// representation that can be easily serialized or manipulated.
  ///
  /// Example:
  /// ```dart
  /// class User implements Arrayable<String, dynamic> {
  ///   final String name;
  ///   final int age;
  ///
  ///   User(this.name, this.age);
  ///
  ///   @override
  ///   Map<String, dynamic> toArray() {
  ///     return {
  ///       'name': name,
  ///       'age': age,
  ///     };
  ///   }
  /// }
  /// ```
  Map<TKey, TValue> toArray();
}
