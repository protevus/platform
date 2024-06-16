import 'dart:io';

abstract class ResponseFactory {
  /// Create a new response instance.
  ///
  /// [content] can be an array or a string.
  /// [status] is the HTTP status code.
  /// [headers] are the HTTP headers.
  /// Returns a Response object.
  HttpResponse make(dynamic content, {int status = 200, Map<String, String> headers = const {}});

  /// Create a new "no content" response.
  ///
  /// [status] is the HTTP status code.
  /// [headers] are the HTTP headers.
  /// Returns a Response object.
  HttpResponse noContent({int status = 204, Map<String, String> headers = const {}});

  /// Create a new response for a given view.
  ///
  /// [view] can be a string or an array.
  /// [data] is the data to be passed to the view.
  /// [status] is the HTTP status code.
  /// [headers] are the HTTP headers.
  /// Returns a Response object.
  HttpResponse view(dynamic view, {Map<String, dynamic> data = const {}, int status = 200, Map<String, String> headers = const {}});

  /// Create a new JSON response instance.
  ///
  /// [data] is the data to be returned as JSON.
  /// [status] is the HTTP status code.
  /// [headers] are the HTTP headers.
  /// [options] are the JSON options.
  /// Returns a JsonResponse object.
  HttpResponse json(dynamic data, {int status = 200, Map<String, String> headers = const {}, int options = 0});

  /// Create a new JSONP response instance.
  ///
  /// [callback] is the JSONP callback name.
  /// [data] is the data to be returned as JSONP.
  /// [status] is the HTTP status code.
  /// [headers] are the HTTP headers.
  /// [options] are the JSON options.
  /// Returns a JsonResponse object.
  HttpResponse jsonp(String callback, dynamic data, {int status = 200, Map<String, String> headers = const {}, int options = 0});

  /// Create a new streamed response instance.
  ///
  /// [callback] is the callback function for streaming.
  /// [status] is the HTTP status code.
  /// [headers] are the HTTP headers.
  /// Returns a StreamedResponse object.
  HttpResponse stream(Function callback, {int status = 200, Map<String, String> headers = const {}});

  /// Create a new streamed response instance as a file download.
  ///
  /// [callback] is the callback function for streaming.
  /// [name] is the name of the file.
  /// [headers] are the HTTP headers.
  /// [disposition] is the content disposition.
  /// Returns a StreamedResponse object.
  HttpResponse streamDownload(Function callback, {String? name, Map<String, String> headers = const {}, String disposition = 'attachment'});

  /// Create a new file download response.
  ///
  /// [file] is the file to be downloaded.
  /// [name] is the name of the file.
  /// [headers] are the HTTP headers.
  /// [disposition] is the content disposition.
  /// Returns a BinaryFileResponse object.
  HttpResponse download(dynamic file, {String? name, Map<String, String> headers = const {}, String disposition = 'attachment'});

  /// Return the raw contents of a binary file.
  ///
  /// [file] is the file to be returned.
  /// [headers] are the HTTP headers.
  /// Returns a BinaryFileResponse object.
  HttpResponse file(dynamic file, {Map<String, String> headers = const {}});

  /// Create a new redirect response to the given path.
  ///
  /// [path] is the path to redirect to.
  /// [status] is the HTTP status code.
  /// [headers] are the HTTP headers.
  /// [secure] indicates if the redirection should be secure.
  /// Returns a RedirectResponse object.
  HttpResponse redirectTo(String path, {int status = 302, Map<String, String> headers = const {}, bool? secure});

  /// Create a new redirect response to a named route.
  ///
  /// [route] is the name of the route.
  /// [parameters] are the parameters for the route.
  /// [status] is the HTTP status code.
  /// [headers] are the HTTP headers.
  /// Returns a RedirectResponse object.
  HttpResponse redirectToRoute(String route, {dynamic parameters = const {}, int status = 302, Map<String, String> headers = const {}});

  /// Create a new redirect response to a controller action.
  ///
  /// [action] is the action name.
  /// [parameters] are the parameters for the action.
  /// [status] is the HTTP status code.
  /// [headers] are the HTTP headers.
  /// Returns a RedirectResponse object.
  HttpResponse redirectToAction(dynamic action, {dynamic parameters = const {}, int status = 302, Map<String, String> headers = const {}});

  /// Create a new redirect response, while putting the current URL in the session.
  ///
  /// [path] is the path to redirect to.
  /// [status] is the HTTP status code.
  /// [headers] are the HTTP headers.
  /// [secure] indicates if the redirection should be secure.
  /// Returns a RedirectResponse object.
  HttpResponse redirectGuest(String path, {int status = 302, Map<String, String> headers = const {}, bool? secure});

  /// Create a new redirect response to the previously intended location.
  ///
  /// [defaultPath] is the default path if no intended location is found.
  /// [status] is the HTTP status code.
  /// [headers] are the HTTP headers.
  /// [secure] indicates if the redirection should be secure.
  /// Returns a RedirectResponse object.
  HttpResponse redirectToIntended({String defaultPath = '/', int status = 302, Map<String, String> headers = const {}, bool? secure});
}
