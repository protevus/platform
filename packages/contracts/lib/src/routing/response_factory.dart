/// Interface for HTTP response creation.
abstract class ResponseFactory {
  /// Create a new response instance.
  dynamic make(
      [dynamic content = '',
      int status = 200,
      Map<String, dynamic> headers = const {}]);

  /// Create a new "no content" response.
  dynamic noContent(
      [int status = 204, Map<String, dynamic> headers = const {}]);

  /// Create a new response for a given view.
  dynamic view(dynamic view,
      [Map<String, dynamic> data = const {},
      int status = 200,
      Map<String, dynamic> headers = const {}]);

  /// Create a new JSON response instance.
  dynamic json(
      [dynamic data = const {},
      int status = 200,
      Map<String, dynamic> headers = const {},
      int options = 0]);

  /// Create a new JSONP response instance.
  dynamic jsonp(String callback,
      [dynamic data = const {},
      int status = 200,
      Map<String, dynamic> headers = const {},
      int options = 0]);

  /// Create a new streamed response instance.
  dynamic stream(Function callback,
      [int status = 200, Map<String, dynamic> headers = const {}]);

  /// Create a new streamed response instance as a file download.
  dynamic streamDownload(Function callback,
      [String? name,
      Map<String, dynamic> headers = const {},
      String disposition = 'attachment']);

  /// Create a new file download response.
  dynamic download(dynamic file,
      [String? name,
      Map<String, dynamic> headers = const {},
      String disposition = 'attachment']);

  /// Return the raw contents of a binary file.
  dynamic file(dynamic file, [Map<String, dynamic> headers = const {}]);

  /// Create a new redirect response to the given path.
  dynamic redirectTo(String path,
      [int status = 302,
      Map<String, dynamic> headers = const {},
      bool? secure]);

  /// Create a new redirect response to a named route.
  dynamic redirectToRoute(String route,
      [dynamic parameters = const {},
      int status = 302,
      Map<String, dynamic> headers = const {}]);

  /// Create a new redirect response to a controller action.
  dynamic redirectToAction(dynamic action,
      [dynamic parameters = const {},
      int status = 302,
      Map<String, dynamic> headers = const {}]);

  /// Create a new redirect response, while putting the current URL in the session.
  dynamic redirectGuest(String path,
      [int status = 302,
      Map<String, dynamic> headers = const {},
      bool? secure]);

  /// Create a new redirect response to the previously intended location.
  dynamic redirectToIntended(
      [String default_ = '/',
      int status = 302,
      Map<String, dynamic> headers = const {},
      bool? secure]);
}
