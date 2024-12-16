import 'package:dsr_container/container.dart';

/// Exception thrown when the container fails to resolve a binding.
class BindingResolutionException implements ContainerExceptionInterface {
  /// The message describing the binding resolution failure.
  @override
  final String message;

  /// The original error that caused the binding resolution failure, if any.
  final Object? originalError;

  /// The stack trace associated with the original error, if any.
  final StackTrace? stackTrace;

  /// Creates a new [BindingResolutionException].
  ///
  /// The [message] parameter describes what went wrong during binding resolution.
  /// Optionally, you can provide the [originalError] and its [stackTrace] for
  /// more detailed debugging information.
  const BindingResolutionException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    if (originalError != null) {
      return 'BindingResolutionException: $message\nCaused by: $originalError';
    }
    return 'BindingResolutionException: $message';
  }
}
