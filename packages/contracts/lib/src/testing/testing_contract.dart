import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:meta/meta.dart';

/// Contract for mock HTTP requests.
///
/// This contract defines how HTTP requests should be mocked
/// for testing purposes.
@sealed
abstract class MockHttpRequestContract
    implements HttpRequest, StreamSink<List<int>>, StringSink {
  /// Gets the request method.
  @override
  String get method;

  /// Gets the request URI.
  @override
  Uri get uri;

  /// Gets request headers.
  @override
  HttpHeaders get headers;

  /// Gets request cookies.
  @override
  List<Cookie> get cookies;

  /// Gets connection info.
  @override
  HttpConnectionInfo get connectionInfo;

  /// Gets request session.
  @override
  HttpSession get session;

  /// Gets request content length.
  @override
  int get contentLength;

  /// Gets protocol version.
  @override
  String get protocolVersion;

  /// Gets SSL/TLS certificate.
  @override
  X509Certificate? get certificate;

  /// Gets whether connection is persistent.
  @override
  bool get persistentConnection;

  /// Gets requested URI.
  @override
  Uri get requestedUri;

  /// Sets requested URI.
  set requestedUri(Uri value);

  /// Gets response object.
  @override
  HttpResponse get response;
}

/// Contract for mock HTTP responses.
///
/// This contract defines how HTTP responses should be mocked
/// for testing purposes.
@sealed
abstract class MockHttpResponseContract
    implements HttpResponse, Stream<List<int>> {
  /// Gets/sets status code.
  @override
  int get statusCode;
  @override
  set statusCode(int value);

  /// Gets/sets reason phrase.
  @override
  String get reasonPhrase;
  @override
  set reasonPhrase(String value);

  /// Gets/sets content length.
  @override
  int get contentLength;
  @override
  set contentLength(int value);

  /// Gets/sets deadline.
  @override
  Duration? get deadline;
  @override
  set deadline(Duration? value);

  /// Gets/sets encoding.
  @override
  Encoding get encoding;
  @override
  set encoding(Encoding value);

  /// Gets/sets persistent connection flag.
  @override
  bool get persistentConnection;
  @override
  set persistentConnection(bool value);

  /// Gets/sets buffer output flag.
  @override
  bool get bufferOutput;
  @override
  set bufferOutput(bool value);

  /// Gets response headers.
  @override
  HttpHeaders get headers;

  /// Gets response cookies.
  @override
  List<Cookie> get cookies;

  /// Gets connection info.
  @override
  HttpConnectionInfo get connectionInfo;

  /// Gets done future.
  @override
  Future get done;

  /// Detaches socket.
  @override
  Future<Socket> detachSocket({bool writeHeaders = true});

  /// Redirects to location.
  @override
  Future redirect(Uri location, {int status = HttpStatus.movedTemporarily});
}

/// Contract for mock HTTP sessions.
///
/// This contract defines how HTTP sessions should be mocked
/// for testing purposes.
@sealed
abstract class MockHttpSessionContract implements HttpSession {
  /// Gets session ID.
  @override
  String get id;

  /// Gets/sets whether session is new.
  @override
  bool get isNew;
  @override
  set isNew(bool value);

  /// Gets session data.
  Map<String, dynamic> get data;

  /// Gets session value.
  @override
  dynamic operator [](Object? key);

  /// Sets session value.
  @override
  void operator []=(dynamic key, dynamic value);

  /// Removes session value.
  @override
  dynamic remove(Object? key);

  /// Clears all session data.
  @override
  void clear();

  /// Destroys the session.
  @override
  Future<void> destroy();
}

/// Contract for mock HTTP headers.
///
/// This contract defines how HTTP headers should be mocked
/// for testing purposes.
@sealed
abstract class MockHttpHeadersContract implements HttpHeaders {
  /// Gets header value.
  @override
  String? value(String name);

  /// Adds header value.
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false});

  /// Removes header.
  @override
  void remove(String name, Object value);

  /// Removes all headers.
  @override
  void removeAll(String name);

  /// Sets header value.
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false});

  /// Gets header values.
  @override
  List<String>? operator [](String name);

  /// Gets all header names.
  @override
  List<String> get names;

  /// Gets header values.
  @override
  Iterable<String>? getAll(String name);

  /// Clears all headers.
  @override
  void clear();

  /// Gets whether headers are mutable.
  @override
  bool get mutable;

  /// Gets content type.
  @override
  ContentType? get contentType;

  /// Sets content type.
  @override
  set contentType(ContentType? value);

  /// Gets date.
  @override
  DateTime? get date;

  /// Sets date.
  @override
  set date(DateTime? value);

  /// Gets expires date.
  @override
  DateTime? get expires;

  /// Sets expires date.
  @override
  set expires(DateTime? value);

  /// Gets if-modified-since date.
  @override
  DateTime? get ifModifiedSince;

  /// Sets if-modified-since date.
  @override
  set ifModifiedSince(DateTime? value);

  /// Gets host.
  @override
  String? get host;

  /// Sets host.
  @override
  set host(String? value);

  /// Gets port.
  @override
  int? get port;

  /// Sets port.
  @override
  set port(int? value);

  /// Locks headers from modification.
  void lock();

  /// Gets whether headers are locked.
  bool get locked;
}

/// Contract for mock connection info.
///
/// This contract defines how connection info should be mocked
/// for testing purposes.
@sealed
abstract class MockConnectionInfoContract implements HttpConnectionInfo {
  /// Gets local address.
  @override
  InternetAddress get localAddress;

  /// Gets local port.
  @override
  int get localPort;

  /// Gets remote address.
  @override
  InternetAddress get remoteAddress;

  /// Gets remote port.
  @override
  int get remotePort;
}
