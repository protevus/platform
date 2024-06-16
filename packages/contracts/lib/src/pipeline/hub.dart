// Define a Dart interface for Hub

abstract class Hub {
  /// Send an object through one of the available pipelines.
  ///
  /// @param object The object to be piped.
  /// @param pipeline The name of the pipeline, or null to use the default.
  /// @return The processed object.
  dynamic pipe(dynamic object, [String? pipeline]);
}
