/// Interface for pipeline processing.
abstract class Pipeline {
  /// Set the traveler object being sent on the pipeline.
  Pipeline send(dynamic traveler);

  /// Set the stops of the pipeline.
  Pipeline through(dynamic stops);

  /// Set the method to call on the stops.
  Pipeline via(String method);

  /// Run the pipeline with a final destination callback.
  dynamic then(Function destination);
}
