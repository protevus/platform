/// Represents a series of "pipes" through which an object can be passed.
abstract class PipelineContract {
  PipelineContract send(dynamic passable);
  PipelineContract through(dynamic pipes);
  PipelineContract pipe(dynamic pipes);
  PipelineContract via(String method);
  Future<dynamic> then(dynamic Function(dynamic) destination);
  Future<dynamic> thenReturn();
}
