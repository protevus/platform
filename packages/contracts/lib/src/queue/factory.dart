
import 'queue.dart';

// TODO: Fix Imports

abstract class Factory {
  /// Resolve a queue connection instance.
  ///
  /// @param  String? name
  /// @return Queue
  Queue connection([String? name]);
}
