/// Base exception for view related errors
class ViewException implements Exception {
  final String message;
  ViewException(this.message);
  
  @override
  String toString() => 'ViewException: $message';
}

/// Exception thrown when a view is not found
class ViewNotFoundException extends ViewException {
  ViewNotFoundException(String message) : super(message);
}

/// Exception thrown when there's an error compiling the view
class ViewCompileException extends ViewException {
  ViewCompileException(String message) : super(message);
}
