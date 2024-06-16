// file: lib/src/contracts/redis/factory.dart

import 'connection.dart';

abstract class Factory {
  /// Get a Redis connection by name.
  ///
  /// @param [String] name
  /// @return [Connection]
  Connection connection([String? name]);
}
