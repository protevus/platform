/// Interface for validated data that can be accessed like an array.
abstract class ValidatedData {
  /// Get the instance as an array.
  Map<String, dynamic> toArray();

  /// Determine if an offset exists.
  bool containsKey(String key);

  /// Get an item at a given offset.
  dynamic operator [](String key);

  /// Set the item at a given offset.
  void operator []=(String key, dynamic value);

  /// Remove an item at a given offset.
  void remove(String key);

  /// Get an iterator for the data.
  Iterator<MapEntry<String, dynamic>> get iterator;
}
