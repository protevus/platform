
import 'broadcaster.dart';

abstract class Factory {
  /// Get a broadcaster implementation by name.
  ///
  /// @param [name] The name of the broadcaster.
  /// @return A [Broadcaster] implementation.
  Broadcaster connection([String? name]);
}
