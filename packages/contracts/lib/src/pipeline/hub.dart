/// Interface for pipeline management.
abstract class Hub {
  /// Send an object through one of the available pipelines.
  dynamic pipe(dynamic object, [String? pipeline]);
}
