/// Interface for hashing.
abstract class Hasher {
  /// Get information about the given hashed value.
  Map<String, dynamic> info(String hashedValue);

  /// Hash the given value.
  String make(String value, [Map<String, dynamic> options = const {}]);

  /// Check the given plain value against a hash.
  bool check(String value, String hashedValue,
      [Map<String, dynamic> options = const {}]);

  /// Check if the given hash has been hashed using the given options.
  bool needsRehash(String hashedValue,
      [Map<String, dynamic> options = const {}]);
}
