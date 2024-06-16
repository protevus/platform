abstract class Hasher {
  /// Get information about the given hashed value.
  ///
  /// @param  String  hashedValue
  /// @return Map<String, dynamic>
  Map<String, dynamic> info(String hashedValue);

  /// Hash the given value.
  ///
  /// @param  String  value
  /// @param  Map<String, dynamic>  options
  /// @return String
  String make(String value, {Map<String, dynamic> options = const {}});

  /// Check the given plain value against a hash.
  ///
  /// @param  String  value
  /// @param  String  hashedValue
  /// @param  Map<String, dynamic>  options
  /// @return bool
  bool check(String value, String hashedValue, {Map<String, dynamic> options = const {}});

  /// Check if the given hash has been hashed using the given options.
  ///
  /// @param  String  hashedValue
  /// @param  Map<String, dynamic>  options
  /// @return bool
  bool needsRehash(String hashedValue, {Map<String, dynamic> options = const {}});
}
