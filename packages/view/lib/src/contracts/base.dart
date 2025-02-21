/// Interface for objects that can be converted to an array.
abstract class Arrayable {
  /// Get the instance as an array.
  Map<String, dynamic> toArray();
}

/// Interface for objects that can be converted to HTML.
abstract class Htmlable {
  /// Get content as a string of HTML.
  String toHtml();
}

/// Exception thrown when view operations fail.
class ViewException implements Exception {
  final String message;
  final dynamic cause;

  ViewException(this.message, [this.cause]);

  @override
  String toString() =>
      'ViewException: $message${cause != null ? ' ($cause)' : ''}';
}
