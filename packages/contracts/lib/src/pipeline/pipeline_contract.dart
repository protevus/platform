import 'package:meta/meta.dart';

/// Contract for a pipe that processes objects in a pipeline.
///
/// Laravel-compatible: Core pipe functionality matching Laravel's
/// pipe interface, with platform-specific async handling.
@sealed
abstract class PipeContract {
  /// Handles the passable object.
  ///
  /// Laravel-compatible: Core pipe handling with platform-specific
  /// async processing.
  ///
  /// Parameters:
  ///   - [passable]: The object being passed through the pipeline.
  ///   - [next]: Function to pass the object to the next pipe.
  ///
  /// Returns the processed object, possibly modified.
  Future<dynamic> handle(
      dynamic passable, Future<dynamic> Function(dynamic) next);
}

/// Contract for a pipeline that processes objects through a series of pipes.
///
/// Laravel-compatible: Core pipeline functionality matching Laravel's
/// Pipeline class, with platform-specific fluent interface.
@sealed
abstract class PipelineContract {
  /// Sets the object to be passed through the pipeline.
  ///
  /// Laravel-compatible: Pipeline input setting.
  ///
  /// Parameters:
  ///   - [passable]: The object to process.
  ///
  /// Returns the pipeline instance for fluent chaining.
  PipelineContract send(dynamic passable);

  /// Sets the array of pipes to process the object through.
  ///
  /// Laravel-compatible: Pipe configuration with platform-specific
  /// flexibility for pipe types.
  ///
  /// Parameters:
  ///   - [pipes]: The pipes to process the object through.
  ///     Can be a single pipe or an iterable of pipes.
  ///
  /// Returns the pipeline instance for fluent chaining.
  PipelineContract through(dynamic pipes);

  /// Adds additional pipes to the pipeline.
  ///
  /// Platform-specific: Additional method for pipe configuration
  /// following Laravel's fluent pattern.
  ///
  /// Parameters:
  ///   - [pipes]: The pipes to add.
  ///     Can be a single pipe or an iterable of pipes.
  ///
  /// Returns the pipeline instance for fluent chaining.
  PipelineContract pipe(dynamic pipes);

  /// Sets the method to call on the pipes.
  ///
  /// Laravel-compatible: Method name configuration.
  ///
  /// Parameters:
  ///   - [method]: The name of the method to call.
  ///
  /// Returns the pipeline instance for fluent chaining.
  PipelineContract via(String method);

  /// Runs the pipeline with a final destination callback.
  ///
  /// Laravel-compatible: Pipeline execution with platform-specific
  /// async processing.
  ///
  /// Parameters:
  ///   - [destination]: Function to process the final result.
  ///
  /// Returns the processed result.
  Future<dynamic> then(dynamic Function(dynamic) destination);

  /// Runs the pipeline and returns the result.
  ///
  /// Platform-specific: Direct result access following Laravel's
  /// pipeline execution pattern.
  ///
  /// Returns the processed object directly.
  Future<dynamic> thenReturn();
}

/// Contract for a pipeline hub that manages multiple pipelines.
///
/// Laravel-compatible: Pipeline management functionality matching
/// Laravel's pipeline hub features.
@sealed
abstract class PipelineHubContract {
  /// Gets or creates a pipeline with the given name.
  ///
  /// Laravel-compatible: Named pipeline access.
  ///
  /// Parameters:
  ///   - [name]: The name of the pipeline.
  ///
  /// Returns the pipeline instance.
  PipelineContract pipeline(String name);

  /// Sets the default pipes for a pipeline.
  ///
  /// Laravel-compatible: Default pipe configuration.
  ///
  /// Parameters:
  ///   - [name]: The name of the pipeline.
  ///   - [pipes]: The default pipes for the pipeline.
  void defaults(String name, List<dynamic> pipes);

  /// Registers a pipe type with a name.
  ///
  /// Platform-specific: Named pipe type registration following
  /// Laravel's service registration pattern.
  ///
  /// Parameters:
  ///   - [name]: The name to register the pipe type under.
  ///   - [type]: The pipe type to register.
  void registerPipeType(String name, Type type);
}
