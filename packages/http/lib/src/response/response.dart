import 'dart:io';

import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_http/http.dart';
import 'package:illuminate_storage/storage.dart';

class Response {
  /// content can be anything
  /// String, int, Map, json serializable object, Stream<List<int>>
  dynamic _contentData;

  Map<String, dynamic> _headers = <String, dynamic>{};
  int? _statusCode;
  ContentType? _contentType;

  final List<String> _cookies = <String>[];

  /// content can be anything
  /// String, int, Map, json serializable object, Stream<List<int>>
  Response(this._contentData) {
    if (_contentData is StreamFile) {
      _contentType = _contentData.contentType;
    }

    if (_contentData is DownloadableFile) {
      header(FILE_DOWNLOAD_HEADER, _contentData.contentDisposition);
      _contentType = _contentData.contentType;
      _contentData = _contentData.stream;
    }
  }

  /// Set response status code default 200
  /// ```
  /// res.statusCode(200);
  /// ```
  Response statusCode(int code) {
    _statusCode = code;
    return this;
  }

  /// Set response status code default 200
  /// ```
  /// res.setContent({"foo": "bar"});
  /// ```
  Response content(dynamic content) {
    _contentData = content;
    return this;
  }

  /// Get original content data
  /// ```
  /// res.getContent();
  /// ```
  dynamic getContent() {
    return _contentData;
  }

  /// set stream data to response
  /// ```
  /// res.stream(streamData);
  /// ```
  Response stream(Stream<List<int>> stream) {
    content(stream);
    return this;
  }

  /// set content type such as json, text, html
  /// ```
  /// res.statusCode(ContentType.json);
  /// ```
  Response contentType(ContentType contentType) {
    _contentType = contentType;
    return this;
  }

  /// set headers
  /// ```
  /// res.header('Authorization', 'Bearer xxx');
  /// ```
  Response header(String key, dynamic value) {
    _headers[key] = value;
    return this;
  }

  /// Set cookie
  /// ```
  /// var DoxCookie('key', 'value');
  /// res.cookie(cookie);
  /// ```
  Response cookie(DoxCookie cookie, {bool setExpire = false}) {
    _cookies.add(setExpire ? cookie.expire() : cookie.get());
    return this;
  }

  /// set cache
  /// ```
  /// res.cache(Duration(seconds: 10));
  /// ```
  Response cache(Duration duration) {
    _headers[HttpHeaders.cacheControlHeader] = 'max-age=${duration.inSeconds}';
    return this;
  }

  /// Set list of headers by Map
  /// ```
  /// res.withHeaders({'Authorization' : 'Bearer xxx'});
  /// ```
  Response withHeaders(Map<String, dynamic> values) {
    _headers = values;
    return this;
  }

  /// This function is for internal use only
  dynamic process(HttpRequest request) {
    _headers.forEach((String key, dynamic value) {
      request.response.headers.add(key, value);
    });
    if (_statusCode != null) {
      request.response.statusCode = _statusCode!;
    }
    if (_contentType != null) {
      request.response.headers.contentType = _contentType;
    }
    for (String cookie in _cookies) {
      request.response.headers.add(HttpHeaders.setCookieHeader, cookie);
    }
    return responseDataHandler(_contentData, request);
  }
}

/// content can be anything
/// String, int, Map, json serializable object, Stream<List<int>>
Response response([dynamic content]) {
  return Response(content);
}
