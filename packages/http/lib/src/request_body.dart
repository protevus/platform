/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'dart:io';
import 'package:protevus_http/http.dart';

/// Objects that represent a request body, and can be decoded into Dart objects.
///
/// Every instance of [Request] has a [Request.body] property of this type. Use
/// [decode] to convert the contents of this object into a Dart type (e.g, [Map] or [List]).
///
/// See also [CodecRegistry] for how decoding occurs.
class RequestBody extends BodyDecoder {
  /// Creates a new instance of this type.
  ///
  /// Instances of this type decode [request]'s body based on its content-type.
  ///
  /// See [CodecRegistry] for more information about how data is decoded.
  ///
  /// Decoded data is cached the after it is decoded.
  ///
  /// [request] The HttpRequest object to be decoded.
  RequestBody(HttpRequest super.request)
      : _request = request,
        _originalByteStream = request;

  /// The maximum size of a request body.
  ///
  /// A request with a body larger than this size will be rejected. Value is in bytes. Defaults to 10MB (1024 * 1024 * 10).
  static int maxSize = 1024 * 1024 * 10;

  /// The original HttpRequest object.
  final HttpRequest _request;

  /// Checks if the request has content.
  ///
  /// Returns true if the request has a content length or uses chunked transfer encoding.
  bool get _hasContent =>
      _hasContentLength || _request.headers.chunkedTransferEncoding;

  /// Checks if the request has a content length.
  ///
  /// Returns true if the request has a content length greater than 0.
  bool get _hasContentLength => (_request.headers.contentLength) > 0;

  /// Gets the byte stream of the request body.
  ///
  /// If the content length is specified and doesn't exceed [maxSize], returns the original stream.
  /// Otherwise, buffers the stream and checks for size limits.
  ///
  /// Throws a [Response] with status 413 if the body size exceeds [maxSize].
  @override
  Stream<List<int>> get bytes {
    // If content-length is specified, then we can check it for maxSize
    // and just return the original stream.
    if (_hasContentLength) {
      if (_request.headers.contentLength > maxSize) {
        throw Response(
          HttpStatus.requestEntityTooLarge,
          null,
          {"error": "entity length exceeds maximum"},
        );
      }

      return _originalByteStream;
    }

    // If content-length is not specified (e.g., chunked),
    // then we need to check how many bytes we've read to ensure we haven't
    // crossed maxSize
    if (_bufferingController == null) {
      _bufferingController = StreamController<List<int>>(sync: true);

      _originalByteStream.listen(
        (chunk) {
          _bytesRead += chunk.length;
          if (_bytesRead > maxSize) {
            _bufferingController!.addError(
              Response(
                HttpStatus.requestEntityTooLarge,
                null,
                {"error": "entity length exceeds maximum"},
              ),
            );
            _bufferingController!.close();
            return;
          }

          _bufferingController!.add(chunk);
        },
        onDone: () {
          _bufferingController!.close();
        },
        onError: (Object e, StackTrace st) {
          if (!_bufferingController!.isClosed) {
            _bufferingController!.addError(e, st);
            _bufferingController!.close();
          }
        },
        cancelOnError: true,
      );
    }

    return _bufferingController!.stream;
  }

  /// Gets the content type of the request.
  ///
  /// Returns null if no content type is specified.
  @override
  ContentType? get contentType => _request.headers.contentType;

  /// Checks if the request body is empty.
  ///
  /// Returns true if the request has no content.
  @override
  bool get isEmpty => !_hasContent;

  /// Checks if the request body is form data.
  ///
  /// Returns true if the content type is "application/x-www-form-urlencoded".
  bool get isFormData =>
      contentType != null &&
      contentType!.primaryType == "application" &&
      contentType!.subType == "x-www-form-urlencoded";

  /// The original byte stream of the request.
  final Stream<List<int>> _originalByteStream;

  /// A buffering controller for the byte stream when content length is not specified.
  StreamController<List<int>>? _bufferingController;

  /// The number of bytes read from the request body.
  int _bytesRead = 0;
}
