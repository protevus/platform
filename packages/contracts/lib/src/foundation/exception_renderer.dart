/// Interface for rendering exceptions as HTML.
abstract class ExceptionRenderer {
  /// Renders the given exception as HTML.
  String render(Object throwable);
}
