/// Exception thrown when view compilation fails.
class ViewCompilationException implements Exception {
  /// The message describing the compilation error.
  final String message;

  /// Create a new view compilation exception.
  ViewCompilationException(this.message);

  @override
  String toString() => 'ViewCompilationException: $message';
}
