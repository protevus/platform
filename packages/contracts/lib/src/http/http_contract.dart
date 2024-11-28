import 'package:meta/meta.dart';

/// Contract for HTTP requests.
///
/// Laravel-compatible: Core request functionality matching Laravel's Request
/// interface, with platform-specific stream handling.
@sealed
abstract class RequestContract {
  /// Gets the request method.
  ///
  /// Laravel-compatible: HTTP method accessor.
  String get method;

  /// Gets the request URI.
  ///
  /// Laravel-compatible: Request URI using Dart's Uri class.
  Uri get uri;

  /// Gets request headers.
  ///
  /// Laravel-compatible: Header access with platform-specific
  /// multi-value support.
  Map<String, List<String>> get headers;

  /// Gets query parameters.
  ///
  /// Laravel-compatible: Query parameter access.
  Map<String, String> get query;

  /// Gets POST data.
  ///
  /// Laravel-compatible: POST data access.
  Map<String, dynamic> get post;

  /// Gets cookies.
  ///
  /// Laravel-compatible: Cookie access.
  Map<String, String> get cookies;

  /// Gets uploaded files.
  ///
  /// Laravel-compatible: File upload handling with
  /// platform-specific contract.
  Map<String, UploadedFileContract> get files;

  /// Gets the request body.
  ///
  /// Platform-specific: Stream-based body access.
  Stream<List<int>> get body;

  /// Gets a request header.
  ///
  /// Laravel-compatible: Single header access.
  String? header(String name, [String? defaultValue]);

  /// Gets a query parameter.
  ///
  /// Laravel-compatible: Single query parameter access.
  String? query_(String name, [String? defaultValue]);

  /// Gets a POST value.
  ///
  /// Laravel-compatible: Single POST value access.
  dynamic post_(String name, [dynamic defaultValue]);

  /// Gets a cookie value.
  ///
  /// Laravel-compatible: Single cookie access.
  String? cookie(String name, [String? defaultValue]);

  /// Gets an uploaded file.
  ///
  /// Laravel-compatible: Single file access.
  UploadedFileContract? file(String name);

  /// Gets all input data (query + post).
  ///
  /// Laravel-compatible: Combined input access.
  Map<String, dynamic> all();

  /// Gets input value from any source.
  ///
  /// Laravel-compatible: Universal input access.
  dynamic input(String name, [dynamic defaultValue]);

  /// Checks if input exists.
  ///
  /// Laravel-compatible: Input existence check.
  bool has(String name);

  /// Gets the raw request body as string.
  ///
  /// Platform-specific: Async text body access.
  Future<String> text();

  /// Gets the request body as JSON.
  ///
  /// Platform-specific: Async JSON body access.
  Future<dynamic> json();
}

/// Contract for HTTP responses.
///
/// Laravel-compatible: Core response functionality matching Laravel's Response
/// interface, with platform-specific async features.
@sealed
abstract class ResponseContract {
  /// Gets response headers.
  ///
  /// Laravel-compatible: Header access with platform-specific
  /// multi-value support.
  Map<String, List<String>> get headers;

  /// Gets the status code.
  ///
  /// Laravel-compatible: Status code accessor.
  int get status;

  /// Sets the status code.
  ///
  /// Laravel-compatible: Status code mutator.
  set status(int value);

  /// Sets a response header.
  ///
  /// Laravel-compatible: Single header setting.
  void header(String name, String value);

  /// Sets multiple headers.
  ///
  /// Laravel-compatible: Bulk header setting.
  void headers_(Map<String, String> headers);

  /// Sets a cookie.
  ///
  /// Laravel-compatible: Cookie setting with platform-specific
  /// security options.
  void cookie(
    String name,
    String value, {
    Duration? maxAge,
    DateTime? expires,
    String? domain,
    String? path,
    bool secure = false,
    bool httpOnly = false,
    String? sameSite,
  });

  /// Writes response body content.
  ///
  /// Laravel-compatible: Content writing.
  void write(dynamic content);

  /// Sends JSON response.
  ///
  /// Laravel-compatible: JSON response.
  void json(dynamic data);

  /// Sends file download.
  ///
  /// Laravel-compatible: File download with platform-specific
  /// async handling.
  Future<void> download(String path, [String? name]);

  /// Redirects to another URL.
  ///
  /// Laravel-compatible: Redirect response.
  void redirect(String url, [int status = 302]);

  /// Sends the response.
  ///
  /// Platform-specific: Async response sending.
  Future<void> send();
}

/// Contract for uploaded files.
///
/// Laravel-compatible: File upload handling matching Laravel's UploadedFile
/// interface, with platform-specific async operations.
@sealed
abstract class UploadedFileContract {
  /// Gets the original client filename.
  ///
  /// Laravel-compatible: Original filename.
  String get filename;

  /// Gets the file MIME type.
  ///
  /// Laravel-compatible: MIME type.
  String get mimeType;

  /// Gets the file size in bytes.
  ///
  /// Laravel-compatible: File size.
  int get size;

  /// Gets temporary file path.
  ///
  /// Laravel-compatible: Temporary storage.
  String get path;

  /// Moves file to new location.
  ///
  /// Laravel-compatible: File movement with platform-specific
  /// async handling.
  Future<void> moveTo(String path);

  /// Gets file contents as bytes.
  ///
  /// Platform-specific: Async binary content access.
  Future<List<int>> bytes();

  /// Gets file contents as string.
  ///
  /// Platform-specific: Async text content access.
  Future<String> text();
}

/// Contract for HTTP middleware.
///
/// Laravel-compatible: Middleware functionality matching Laravel's Middleware
/// interface, with platform-specific async handling.
@sealed
abstract class MiddlewareContract {
  /// Handles the request.
  ///
  /// Laravel-compatible: Middleware handling with platform-specific
  /// async processing.
  ///
  /// Parameters:
  ///   - [request]: The incoming request.
  ///   - [next]: Function to pass to next middleware.
  Future<ResponseContract> handle(RequestContract request,
      Future<ResponseContract> Function(RequestContract) next);
}

/// Contract for HTTP kernel.
///
/// Laravel-compatible: HTTP kernel functionality matching Laravel's HttpKernel
/// interface, with platform-specific async processing.
@sealed
abstract class HttpKernelContract {
  /// Gets global middleware.
  ///
  /// Laravel-compatible: Global middleware list.
  List<MiddlewareContract> get middleware;

  /// Gets middleware groups.
  ///
  /// Laravel-compatible: Middleware grouping.
  Map<String, List<MiddlewareContract>> get middlewareGroups;

  /// Gets route middleware.
  ///
  /// Laravel-compatible: Route middleware mapping.
  Map<String, MiddlewareContract> get routeMiddleware;

  /// Handles an HTTP request.
  ///
  /// Laravel-compatible: Request handling with platform-specific
  /// async processing.
  Future<ResponseContract> handle(RequestContract request);

  /// Terminates the request/response cycle.
  ///
  /// Laravel-compatible: Request termination with platform-specific
  /// async processing.
  Future<ResponseContract> terminate(
      RequestContract request, ResponseContract response);
}

/// Contract for HTTP context.
///
/// Platform-specific: Provides request context beyond Laravel's
/// standard request handling.
@sealed
abstract class HttpContextContract {
  /// Gets the current request.
  RequestContract get request;

  /// Gets the current response.
  ResponseContract get response;

  /// Gets context attributes.
  Map<String, dynamic> get attributes;

  /// Gets a context attribute.
  T? getAttribute<T>(String key);

  /// Sets a context attribute.
  void setAttribute(String key, dynamic value);

  /// Gets the route parameters.
  Map<String, dynamic> get routeParams;

  /// Gets a route parameter.
  T? getRouteParam<T>(String name);
}
