/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:protevus_http/http.dart';

/// Represents the information in an HTTP response.
///
/// This object can be used to write an HTTP response and contains conveniences
/// for creating these objects.
class Response implements RequestOrResponse {
  /// The default constructor.
  ///
  /// There exist convenience constructors for common response status codes
  /// and you should prefer to use those.
  ///
  /// [statusCode] The HTTP status code for this response.
  /// [headers] A map of HTTP headers for this response.
  /// [body] The body content of this response.
  Response(int this.statusCode, Map<String, dynamic>? headers, dynamic body) {
    this.body = body;
    this.headers = LinkedHashMap<String, dynamic>(
        equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
        hashCode: (key) => key.toLowerCase().hashCode);
    this.headers.addAll(headers ?? {});
  }

  /// Represents a 200 OK response.
  ///
  /// [body] The body content of this response.
  /// [headers] Optional map of HTTP headers for this response.
  Response.ok(dynamic body, {Map<String, dynamic>? headers})
      : this(HttpStatus.ok, headers, body);

  /// Represents a 201 Created response.
  ///
  /// [location] A URI that is added as the Location header.
  /// [body] Optional body content of this response.
  /// [headers] Optional map of HTTP headers for this response.
  Response.created(
    String location, {
    dynamic body,
    Map<String, dynamic>? headers,
  }) : this(
          HttpStatus.created,
          _headersWith(headers, {HttpHeaders.locationHeader: location}),
          body,
        );

  /// Represents a 202 Accepted response.
  ///
  /// [headers] Optional map of HTTP headers for this response.
  Response.accepted({Map<String, dynamic>? headers})
      : this(HttpStatus.accepted, headers, null);

  /// Represents a 204 No Content response.
  ///
  /// [headers] Optional map of HTTP headers for this response.
  Response.noContent({Map<String, dynamic>? headers})
      : this(HttpStatus.noContent, headers, null);

  /// Represents a 304 Not Modified response.
  ///
  /// [lastModified] The last modified date of the resource.
  /// [cachePolicy] The same policy as applied when this resource was first fetched.
  Response.notModified(DateTime lastModified, this.cachePolicy) {
    statusCode = HttpStatus.notModified;
    headers = {HttpHeaders.lastModifiedHeader: HttpDate.format(lastModified)};
  }

  /// Represents a 400 Bad Request response.
  ///
  /// [headers] Optional map of HTTP headers for this response.
  /// [body] Optional body content of this response.
  Response.badRequest({Map<String, dynamic>? headers, dynamic body})
      : this(HttpStatus.badRequest, headers, body);

  /// Represents a 401 Unauthorized response.
  ///
  /// [headers] Optional map of HTTP headers for this response.
  /// [body] Optional body content of this response.
  Response.unauthorized({Map<String, dynamic>? headers, dynamic body})
      : this(HttpStatus.unauthorized, headers, body);

  /// Represents a 403 Forbidden response.
  ///
  /// [headers] Optional map of HTTP headers for this response.
  /// [body] Optional body content of this response.
  Response.forbidden({Map<String, dynamic>? headers, dynamic body})
      : this(HttpStatus.forbidden, headers, body);

  /// Represents a 404 Not Found response.
  ///
  /// [headers] Optional map of HTTP headers for this response.
  /// [body] Optional body content of this response.
  Response.notFound({Map<String, dynamic>? headers, dynamic body})
      : this(HttpStatus.notFound, headers, body);

  /// Represents a 409 Conflict response.
  ///
  /// [headers] Optional map of HTTP headers for this response.
  /// [body] Optional body content of this response.
  Response.conflict({Map<String, dynamic>? headers, dynamic body})
      : this(HttpStatus.conflict, headers, body);

  /// Represents a 410 Gone response.
  ///
  /// [headers] Optional map of HTTP headers for this response.
  /// [body] Optional body content of this response.
  Response.gone({Map<String, dynamic>? headers, dynamic body})
      : this(HttpStatus.gone, headers, body);

  /// Represents a 500 Internal Server Error response.
  ///
  /// [headers] Optional map of HTTP headers for this response.
  /// [body] Optional body content of this response.
  Response.serverError({Map<String, dynamic>? headers, dynamic body})
      : this(HttpStatus.internalServerError, headers, body);

  /// The default value of a [contentType].
  ///
  /// If no [contentType] is set for an instance, this is the value used. By default, this value is
  /// [ContentType.json].
  static ContentType defaultContentType = ContentType.json;

  /// An object representing the body of the [Response], which will be encoded when used to [Request.respond].
  ///
  /// This is typically a map or list of maps that will be encoded to JSON. If the [body] was previously set with a [Serializable] object
  /// or a list of [Serializable] objects, this property will be the already serialized (but not encoded) body.
  dynamic get body => _body;

  /// Sets the unencoded response body.
  ///
  /// This may be any value that can be encoded into an HTTP response body. If this value is a [Serializable] or a [List] of [Serializable],
  /// each instance of [Serializable] will transformed via its [Serializable.asMap] method before being set.
  set body(dynamic initialResponseBody) {
    dynamic serializedBody;
    if (initialResponseBody is Serializable) {
      serializedBody = initialResponseBody.asMap();
    } else if (initialResponseBody is List<Serializable>) {
      serializedBody =
          initialResponseBody.map((value) => value.asMap()).toList();
    }

    _body = serializedBody ?? initialResponseBody;
  }

  /// The internal storage for the response body.
  ///
  /// This private variable holds the actual content of the response body.
  /// It can be of any type (dynamic) to accommodate various types of response data.
  /// The public 'body' getter and setter methods interact with this variable
  /// to provide controlled access and manipulation of the response body.
  dynamic _body;

  /// Whether or not this instance should buffer its output or send it right away.
  ///
  /// In general, output should be buffered and therefore this value defaults to 'true'.
  ///
  /// For long-running requests where data may be made available over time,
  /// this value can be set to 'false' to emit bytes to the HTTP client
  /// as they are provided.
  ///
  /// This property has no effect if [body] is not a [Stream].
  bool bufferOutput = true;

  /// Map of headers to send in this response.
  ///
  /// Where the key is the Header name and value is the Header value. Values are added to the Response body
  /// according to [HttpHeaders.add].
  ///
  /// The keys of this map are case-insensitive - they will always be lowercased. If the value is a [List],
  /// each item in the list will be added separately for the same header name.
  ///
  /// See [contentType] for behavior when setting 'content-type' in this property.
  Map<String, dynamic> get headers => _headers;

  /// Sets the headers for this response.
  ///
  /// Clears existing headers and adds all headers from the provided map.
  set headers(Map<String, dynamic> h) {
    _headers.clear();
    _headers.addAll(h);
  }

  /// A case-insensitive map for storing HTTP headers.
  ///
  /// This map uses a custom equality and hash function to ensure that header names
  /// are treated case-insensitively. For example, 'Content-Type' and 'content-type'
  /// are considered the same key.
  ///
  /// The map is implemented as a [LinkedHashMap] to maintain the order of insertion.
  final Map<String, dynamic> _headers = LinkedHashMap<String, Object?>(
      equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
      hashCode: (key) => key.toLowerCase().hashCode);

  /// The HTTP status code of this response.
  int? statusCode;

  /// Cache policy that sets 'Cache-Control' headers for this instance.
  ///
  /// If null (the default), no 'Cache-Control' headers are applied. Otherwise,
  /// the value returned by [CachePolicy.headerValue] will be applied to this instance for the header name
  /// 'Cache-Control'.
  CachePolicy? cachePolicy;

  /// The content type of the body of this response.
  ///
  /// Defaults to [defaultContentType]. This response's body will be encoded according to this value.
  /// The Content-Type header of the HTTP response will always be set according to this value.
  ///
  /// If this value is set directly, then this instance's Content-Type will be that value.
  /// If this value is not set, then the [headers] property is checked for the key 'content-type'.
  /// If the key is not present in [headers], this property's value is [defaultContentType].
  ///
  /// If the key is present and the value is a [String], this value is the result of passing the value to [ContentType.parse].
  /// If the key is present and the value is a [ContentType], this property is equal to that value.
  ContentType? get contentType {
    if (_contentType != null) {
      return _contentType;
    }

    final inHeaders = _headers[HttpHeaders.contentTypeHeader];
    if (inHeaders == null) {
      return defaultContentType;
    }

    if (inHeaders is ContentType) {
      return inHeaders;
    }

    if (inHeaders is String) {
      return ContentType.parse(inHeaders);
    }

    throw StateError(
      "Invalid content-type response header. Is not 'String' or 'ContentType'.",
    );
  }

  /// Sets the content type for this response.
  set contentType(ContentType? t) {
    _contentType = t;
  }

  ContentType? _contentType;

  /// Whether or not this instance has explicitly set its [contentType] property.
  ///
  /// This value indicates whether or not [contentType] has been set, or is still using its default value.
  bool get hasExplicitlySetContentType => _contentType != null;

  /// Whether or not the body object of this instance should be encoded.
  ///
  /// By default, a body object is encoded according to its [contentType] and the corresponding
  /// [Codec] in [CodecRegistry].
  ///
  /// If this instance's body object has already been encoded as a list of bytes by some other mechanism,
  /// this property should be set to false to avoid the encoding process. This is useful when streaming a file
  /// from disk where it is already stored as an encoded list of bytes.
  bool encodeBody = true;

  /// Combines two header maps into a single map.
  ///
  /// [inputHeaders] The initial set of headers.
  /// [otherHeaders] Additional headers to be added.
  /// Returns a new map containing all headers from both input maps.
  static Map<String, dynamic> _headersWith(
    Map<String, dynamic>? inputHeaders,
    Map<String, dynamic> otherHeaders,
  ) {
    final m = LinkedHashMap<String, Object?>(
        equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
        hashCode: (key) => key.toLowerCase().hashCode);
    if (inputHeaders != null) {
      m.addAll(inputHeaders);
    }
    m.addAll(otherHeaders);
    return m;
  }
}
