import 'dart:io';
import 'response_header_bag.dart';

class Response {
  // HTTP status codes
  static const int HTTP_CONTINUE = 100;
  static const int HTTP_SWITCHING_PROTOCOLS = 101;
  static const int HTTP_PROCESSING = 102; // RFC2518
  static const int HTTP_EARLY_HINTS = 103; // RFC8297
  static const int HTTP_OK = 200;
  static const int HTTP_CREATED = 201;
  static const int HTTP_ACCEPTED = 202;
  static const int HTTP_NON_AUTHORITATIVE_INFORMATION = 203;
  static const int HTTP_NO_CONTENT = 204;
  static const int HTTP_RESET_CONTENT = 205;
  static const int HTTP_PARTIAL_CONTENT = 206;
  static const int HTTP_MULTI_STATUS = 207; // RFC4918
  static const int HTTP_ALREADY_REPORTED = 208; // RFC5842
  static const int HTTP_IM_USED = 226; // RFC3229
  static const int HTTP_MULTIPLE_CHOICES = 300;
  static const int HTTP_MOVED_PERMANENTLY = 301;
  static const int HTTP_FOUND = 302;
  static const int HTTP_SEE_OTHER = 303;
  static const int HTTP_NOT_MODIFIED = 304;
  static const int HTTP_USE_PROXY = 305;
  static const int HTTP_RESERVED = 306;
  static const int HTTP_TEMPORARY_REDIRECT = 307;
  static const int HTTP_PERMANENTLY_REDIRECT = 308; // RFC7238
  static const int HTTP_BAD_REQUEST = 400;
  static const int HTTP_UNAUTHORIZED = 401;
  static const int HTTP_PAYMENT_REQUIRED = 402;
  static const int HTTP_FORBIDDEN = 403;
  static const int HTTP_NOT_FOUND = 404;
  static const int HTTP_METHOD_NOT_ALLOWED = 405;
  static const int HTTP_NOT_ACCEPTABLE = 406;
  static const int HTTP_PROXY_AUTHENTICATION_REQUIRED = 407;
  static const int HTTP_REQUEST_TIMEOUT = 408;
  static const int HTTP_CONFLICT = 409;
  static const int HTTP_GONE = 410;
  static const int HTTP_LENGTH_REQUIRED = 411;
  static const int HTTP_PRECONDITION_FAILED = 412;
  static const int HTTP_REQUEST_ENTITY_TOO_LARGE = 413;
  static const int HTTP_REQUEST_URI_TOO_LONG = 414;
  static const int HTTP_UNSUPPORTED_MEDIA_TYPE = 415;
  static const int HTTP_REQUESTED_RANGE_NOT_SATISFIABLE = 416;
  static const int HTTP_EXPECTATION_FAILED = 417;
  static const int HTTP_I_AM_A_TEAPOT = 418; // RFC2324
  static const int HTTP_MISDIRECTED_REQUEST = 421; // RFC7540
  static const int HTTP_UNPROCESSABLE_ENTITY = 422; // RFC4918
  static const int HTTP_LOCKED = 423; // RFC4918
  static const int HTTP_FAILED_DEPENDENCY = 424; // RFC4918
  static const int HTTP_TOO_EARLY = 425; // RFC-ietf-httpbis-replay-04
  static const int HTTP_UPGRADE_REQUIRED = 426; // RFC2817
  static const int HTTP_PRECONDITION_REQUIRED = 428; // RFC6585
  static const int HTTP_TOO_MANY_REQUESTS = 429; // RFC6585
  static const int HTTP_REQUEST_HEADER_FIELDS_TOO_LARGE = 431; // RFC6585
  static const int HTTP_UNAVAILABLE_FOR_LEGAL_REASONS = 451; // RFC7725
  static const int HTTP_INTERNAL_SERVER_ERROR = 500;
  static const int HTTP_NOT_IMPLEMENTED = 501;
  static const int HTTP_BAD_GATEWAY = 502;
  static const int HTTP_SERVICE_UNAVAILABLE = 503;
  static const int HTTP_GATEWAY_TIMEOUT = 504;
  static const int HTTP_VERSION_NOT_SUPPORTED = 505;
  static const int HTTP_VARIANT_ALSO_NEGOTIATES_EXPERIMENTAL = 506; // RFC2295
  static const int HTTP_INSUFFICIENT_STORAGE = 507; // RFC4918
  static const int HTTP_LOOP_DETECTED = 508; // RFC5842
  static const int HTTP_NOT_EXTENDED = 510; // RFC2774
  static const int HTTP_NETWORK_AUTHENTICATION_REQUIRED = 511; // RFC6585

  /// Status codes translation table.
  ///
  /// The list of codes is complete according to the
  /// {@link https://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml Hypertext Transfer Protocol (HTTP) Status Code Registry}
  /// (last updated 2021-10-01).
  ///
  /// Unless otherwise noted, the status code is defined in RFC2616.
  static const Map<int, String> statusTexts = {
    100: 'Continue',
    101: 'Switching Protocols',
    102: 'Processing', // RFC2518
    103: 'Early Hints',
    200: 'OK',
    201: 'Created',
    202: 'Accepted',
    203: 'Non-Authoritative Information',
    204: 'No Content',
    205: 'Reset Content',
    206: 'Partial Content',
    207: 'Multi-Status', // RFC4918
    208: 'Already Reported', // RFC5842
    226: 'IM Used', // RFC3229
    300: 'Multiple Choices',
    301: 'Moved Permanently',
    302: 'Found',
    303: 'See Other',
    304: 'Not Modified',
    305: 'Use Proxy',
    307: 'Temporary Redirect',
    308: 'Permanent Redirect', // RFC7238
    400: 'Bad Request',
    401: 'Unauthorized',
    402: 'Payment Required',
    403: 'Forbidden',
    404: 'Not Found',
    405: 'Method Not Allowed',
    406: 'Not Acceptable',
    407: 'Proxy Authentication Required',
    408: 'Request Timeout',
    409: 'Conflict',
    410: 'Gone',
    411: 'Length Required',
    412: 'Precondition Failed',
    413: 'Content Too Large', // RFC-ietf-httpbis-semantics
    414: 'URI Too Long',
    415: 'Unsupported Media Type',
    416: 'Range Not Satisfiable',
    417: 'Expectation Failed',
    418: "I'm a teapot", // RFC2324
    421: 'Misdirected Request', // RFC7540
    422: 'Unprocessable Content', // RFC-ietf-httpbis-semantics
    423: 'Locked', // RFC4918
    424: 'Failed Dependency', // RFC4918
    425: 'Too Early', // RFC-ietf-httpbis-replay-04
    426: 'Upgrade Required', // RFC2817
    428: 'Precondition Required', // RFC6585
    429: 'Too Many Requests', // RFC6585
    431: 'Request Header Fields Too Large', // RFC6585
    451: 'Unavailable For Legal Reasons', // RFC7725
    500: 'Internal Server Error',
    501: 'Not Implemented',
    502: 'Bad Gateway',
    503: 'Service Unavailable',
    504: 'Gateway Timeout',
    505: 'HTTP Version Not Supported',
    506: 'Variant Also Negotiates', // RFC2295
    507: 'Insufficient Storage', // RFC4918
    508: 'Loop Detected', // RFC5842
    510: 'Not Extended', // RFC2774
    511: 'Network Authentication Required', // RFC6585
  };

  /// HTTP response cache control directives
  ///
  /// @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
  static const Map<String, bool> httpResponseCacheControlDirectives = {
    'must_revalidate': false,
    'no_cache': false,
    'no_store': false,
    'no_transform': false,
    'public': false,
    'private': false,
    'proxy_revalidate': false,
    'max_age': true,
    's_maxage': true,
    'stale_if_error': true, // RFC5861
    'stale_while_revalidate': true, // RFC5861
    'immutable': false,
    'last_modified': true,
    'etag': true,
  };

  ResponseHeaderBag headers;
  String content;
  String version;
  int statusCode;
  String statusText;
  String? charset;

  Map<String, List<String>> sentHeaders = {};

  /// @param int $status The HTTP status code (200 "OK" by default)
  ///
  /// @throws \InvalidArgumentException When the HTTP status code is not valid
  Response({String? content = '', int status = HTTP_OK, Map<String, List<String?>>? headers})
      : headers = ResponseHeaderBag(headers ?? {}),
        content = content ?? '',
        version = '1.0',
        statusCode = status,
        statusText = statusTexts[status] ?? 'unknown status';

  /// Returns the Response as an HTTP string.
  ///
  /// The string representation of the Response is the same as the
  /// one that will be sent to the client only if the prepare() method
  /// has been called before.
  ///
  /// @see prepare()
  @override
  String toString() {
    return 'HTTP/$version $statusCode $statusText\r\n$headers\r\n$content';
  }

  /// Clones the current Response instance.
  Response clone() {
    return Response(content: content, status: statusCode, headers: headers.all());
  }

  /// Prepares the Response before it is sent to the client.
  ///
  /// This method tweaks the Response to ensure that it is
  /// compliant with RFC 2616. Most of the changes are based on
  /// the Request that is "associated" with this Response.
  ///
  /// @return $this
  void prepare(HttpRequest request) {
    if (isInformational() || isEmpty()) {
      content = '';
      headers.remove('Content-Type');
      headers.remove('Content-Length');
    } else {
      if (!headers.containsKey('Content-Type')) {
        headers.set('Content-Type', 'text/html; charset=${charset ?? 'UTF-8'}');
      } else if (headers.value('Content-Type')!.startsWith('text/') && !headers.value('Content-Type')!.contains('charset')) {
        headers.set('Content-Type', '${headers.value('Content-Type')}; charset=${charset ?? 'UTF-8'}');
      }

      if (headers.containsKey('Transfer-Encoding')) {
        headers.remove('Content-Length');
      }

      if (request.method == 'HEAD') {
        var length = headers.value('Content-Length');
        content = '';
        if (length != null) {
          headers.set('Content-Length', length);
        }
      }
    }

    if (request.protocolVersion != 'HTTP/1.0') {
      version = '1.1';
    }

    if (version == '1.0' && headers.value('Cache-Control')!.contains('no-cache')) {
      headers.set('pragma', 'no-cache');
      headers.set('expires', '-1');
    }

    ensureIEOverSSLCompatibility(request);

    if (request.uri.scheme == 'https') {
      headers.all('Set-Cookie')['set-cookie']?.forEach((cookie) {
        if (cookie.contains('; Secure')) return;
        headers.set('Set-Cookie', '$cookie; Secure', false);
      });
    }
  }

  /// Sends HTTP headers.
  ///
  /// @param positive-int|null $statusCode The status code to use, override the statusCode property if set and not null
  ///
  /// @return $this
  void sendHeaders([int? statusCode]) {
    if (HttpHeaders.headersSent) {
      return;
    }

    var informationalResponse = statusCode != null && statusCode >= 100 && statusCode < 200;

    headers.allPreserveCaseWithoutCookies().forEach((name, values) {
      var previousValues = sentHeaders[name];
      if (previousValues != null && previousValues == values) {
        return;
      }

      var replace = name.toLowerCase() == 'content-type';
      if (previousValues != null && !previousValues.every(values.contains)) {
        HttpHeaders.removeHeader(name);
        previousValues = null;
      }

      var newValues = previousValues == null ? values : values.where((v) => !previousValues!.contains(v)).toList();

      for (var value in newValues) {
        HttpHeaders.setHeader(name, value, replace: replace, statusCode: statusCode ?? this.statusCode);
      }

      if (informationalResponse) {
        sentHeaders[name] = values;
      }
    });

    if (informationalResponse) {
      return;
    }

    statusCode ??= this.statusCode;
    HttpHeaders.setHeader('Status', '$version $statusCode $statusText', replace: true, statusCode: statusCode);
  }

  /// Sends content for the current web response.
  ///
  /// @return $this
  void sendContent() {
    print(content);
  }

  /// Sends HTTP headers and content.
  ///
  /// @param bool $flush Whether output buffers should be flushed
  ///
  /// @return $this
  void send([bool flush = true]) {
    sendHeaders();
    sendContent();

    if (flush) {
      stdout.flush();
    }
  }

  /// Sets the response content.
  ///
  /// @return $this
  void setContent(String? content) {
    this.content = content ?? '';
  }

  /// Gets the current response content.
  String getContent() {
    return content;
  }

  /// Sets the HTTP protocol version (1.0 or 1.1).
  ///
  /// @return $this
  ///
  /// @final
  void setProtocolVersion(String version) {
    this.version = version;
  }

  /// Gets the HTTP protocol version.
  ///
  /// @final
  String getProtocolVersion() {
    return version;
  }

  /// Sets the response status code.
  ///
  /// If the status text is null it will be automatically populated for the known
  /// status codes and left empty otherwise.
  ///
  /// @return $this
  ///
  /// @throws \InvalidArgumentException When the HTTP status code is not valid
  ///
  /// @final
  void setStatusCode(int code, [String? text]) {
    statusCode = code;
    if (isInvalid()) {
      throw ArgumentError('The HTTP status code "$code" is not valid.');
    }

    statusText = text ?? statusTexts[code] ?? 'unknown status';
  }

  /// Retrieves the status code for the current web response.
  ///
  /// @final
  int getStatusCode() {
    return statusCode;
  }

  /// Sets the response charset.
  ///
  /// @return $this
  ///
  /// @final
  void setCharset(String charset) {
    this.charset = charset;
  }

  /// Retrieves the response charset.
  ///
  /// @final
  String? getCharset() {
    return charset;
  }

  /// Returns true if the response may safely be kept in a shared (surrogate) cache.
  ///
  /// Responses marked "private" with an explicit Cache-Control directive are
  /// considered uncacheable.
  ///
  /// Responses with neither a freshness lifetime (Expires, max-age) nor cache
  /// validator (Last-Modified, ETag) are considered uncacheable because there is
  /// no way to tell when or how to remove them from the cache.
  ///
  /// Note that RFC 7231 and RFC 7234 possibly allow for a more permissive implementation,
  /// for example "status codes that are defined as cacheable by default [...]
  /// can be reused by a cache with heuristic expiration unless otherwise indicated"
  /// (https://tools.ietf.org/html/rfc7231#section-6.1)
  ///
  /// @final
  bool isCacheable() {
    if (![200, 203, 300, 301, 302, 404, 410].contains(statusCode)) {
      return false;
    }

    if (headers.hasCacheControlDirective('no-store') || headers.hasCacheControlDirective('private')) {
      return false;
    }

    return isValidateable() || isFresh();
  }

  /// Returns true if the response is "fresh".
  ///
  /// Fresh responses may be served from cache without any interaction with the
  /// origin. A response is considered fresh when it includes a Cache-Control/max-age
  /// indicator or Expires header and the calculated age is less than the freshness lifetime.
  ///
  /// @final
  bool isFresh() {
    return getTtl() > 0;
  }

  /// Returns true if the response includes headers that can be used to validate
  /// the response with the origin server using a conditional GET request.
  ///
  /// @final
  bool isValidateable() {
    return headers.value('Last-Modified') != null || headers.value('ETag') != null;
  }

  /// Marks the response as "private".
  ///
  /// It makes the response ineligible for serving other clients.
  ///
  /// @return $this
  ///
  /// @final
  void setPrivate() {
    headers.remove('Cache-Control');
    headers.set('Cache-Control', 'private');
  }

  /// Marks the response as "public".
  ///
  /// It makes the response eligible for serving other clients.
  ///
  /// @return $this
  ///
  /// @final
  void setPublic() {
    headers.remove('Cache-Control');
    headers.set('Cache-Control', 'public');
  }

  /// Marks the response as "immutable".
  ///
  /// @return $this
  ///
  /// @final
  void setImmutable(bool immutable) {
    if (immutable) {
      headers.set('Cache-Control', 'immutable');
    } else {
      headers.remove('Cache-Control');
    }
  }

  /// Returns true if the response is marked as "immutable".
  ///
  /// @final
  bool isImmutable() {
    return headers.hasCacheControlDirective('immutable');
  }

  /// Returns true if the response must be revalidated by shared caches once it has become stale.
  ///
  /// This method indicates that the response must not be served stale by a
  /// cache in any circumstance without first revalidating with the origin.
  /// When present, the TTL of the response should not be overridden to be
  /// greater than the value provided by the origin.
  ///
  /// @final
  bool mustRevalidate() {
    return headers.hasCacheControlDirective('must-revalidate') || headers.hasCacheControlDirective('proxy-revalidate');
  }

  /// Returns the Date header as a DateTime instance.
  ///
  /// @throws \RuntimeException When the header is not parseable
  ///
  /// @final
  DateTime? getDate() {
    var date = headers.value('Date');
    if (date == null) return null;
    return HttpDate.parse(date);
  }

  /// Sets the Date header.
  ///
  /// @return $this
  ///
  /// @final
  void setDate(DateTime date) {
    headers.set('Date', HttpDate.format(date.toUtc()));
  }

  /// Returns the age of the response in seconds.
  ///
  /// @final
  int getAge() {
    var age = headers.value('Age');
    if (age != null) return int.parse(age);
    var date = getDate();
    if (date == null) return 0;
    return DateTime.now().toUtc().difference(date).inSeconds;
  }

  /// Marks the response stale by setting the Age header to be equal to the maximum age of the response.
  ///
  /// @return $this
  void expire() {
    if (isFresh()) {
      headers.set('Age', getMaxAge().toString());
      headers.remove('Expires');
    }
  }

  /// Returns the value of the Expires header as a DateTime instance.
  ///
  /// @final
  DateTime? getExpires() {
    var expires = headers.value('Expires');
    if (expires == null) return null;
    try {
      return HttpDate.parse(expires);
    } catch (_) {
      return DateTime.now().subtract(Duration(days: 2));
    }
  }

  /// Sets the Expires HTTP header with a DateTime instance.
  ///
  /// Passing null as value will remove the header.
  ///
  /// @return $this
  ///
  /// @final
  void setExpires(DateTime? date) {
    if (date == null) {
      headers.remove('Expires');
    } else {
      headers.set('Expires', HttpDate.format(date.toUtc()));
    }
  }

  /// Returns the number of seconds after the time specified in the response's Date
  /// header when the response should no longer be considered fresh.
  ///
  /// First, it checks for a s-maxage directive, then a max-age directive, and then it falls
  /// back on an expires header. It returns null when no maximum age can be established.
  ///
  /// @final
  int? getMaxAge() {
    if (headers.hasCacheControlDirective('s-maxage')) {
      return int.parse(headers.getCacheControlDirective('s-maxage'));
    }

    if (headers.hasCacheControlDirective('max-age')) {
      return int.parse(headers.getCacheControlDirective('max-age'));
    }

    var expires = getExpires();
    if (expires != null) {
      return DateTime.now().difference(expires).inSeconds;
    }

    return null;
  }

  /// Sets the number of seconds after which the response should no longer be considered fresh.
  ///
  /// This method sets the Cache-Control max-age directive.
  ///
  /// @return $this
  ///
  /// @final
  void setMaxAge(int value) {
    headers.set('Cache-Control', 'max-age=$value');
  }

  /// Sets the number of seconds after which the response should no longer be returned by shared caches when backend is down.
  ///
  /// This method sets the Cache-Control stale-if-error directive.
  ///
  /// @return $this
  ///
  /// @final
  void setStaleIfError(int value) {
    headers.set('Cache-Control', 'stale-if-error=$value');
  }

  /// Sets the number of seconds after which the response should no longer return stale content by shared caches.
  ///
  /// This method sets the Cache-Control stale-while-revalidate directive.
  ///
  /// @return $this
  ///
  /// @final
  void setStaleWhileRevalidate(int value) {
    headers.set('Cache-Control', 'stale-while-revalidate=$value');
  }

  /// Sets the number of seconds after which the response should no longer be considered fresh by shared caches.
  ///
  /// This method sets the Cache-Control s-maxage directive.
  ///
  /// @return $this
  ///
  /// @final
  void setSharedMaxAge(int value) {
    setPublic();
    headers.set('Cache-Control', 's-maxage=$value');
  }

  /// Returns the response's time-to-live in seconds.
  ///
  /// It returns null when no freshness information is present in the response.
  ///
  /// When the response's TTL is 0, the response may not be served from cache without first
  /// revalidating with the origin.
  ///
  /// @final
  int? getTtl() {
    var maxAge = getMaxAge();
    return maxAge != null ? maxAge - getAge() : null;
  }

  /// Sets the response's time-to-live for shared caches in seconds.
  ///
  /// This method adjusts the Cache-Control/s-maxage directive.
  ///
  /// @return $this
  ///
  /// @final
  void setTtl(int seconds) {
    setSharedMaxAge(getAge() + seconds);
  }

  /// Sets the response's time-to-live for private/client caches in seconds.
  ///
  /// This method adjusts the Cache-Control/max-age directive.
  ///
  /// @return $this
  ///
  /// @final
  void setClientTtl(int seconds) {
    setMaxAge(getAge() + seconds);
  }

  /// Returns the Last-Modified HTTP header as a DateTime instance.
  ///
  /// @throws \RuntimeException When the HTTP header is not parseable
  ///
  /// @final
  DateTime? getLastModified() {
    var lastModified = headers.value('Last-Modified');
    if (lastModified == null) return null;
    return HttpDate.parse(lastModified);
  }

  /// Sets the Last-Modified HTTP header with a DateTime instance.
  ///
  /// Passing null as value will remove the header.
  ///
  /// @return $this
  ///
  /// @final
  void setLastModified(DateTime? date) {
    if (date == null) {
      headers.remove('Last-Modified');
    } else {
      headers.set('Last-Modified', HttpDate.format(date.toUtc()));
    }
  }

  /// Returns the literal value of the ETag HTTP header.
  ///
  /// @final
  String? getEtag() {
    return headers.value('ETag');
  }

  /// Sets the ETag value.
  ///
  /// @param string|null $etag The ETag unique identifier or null to remove the header
  /// @param bool        $weak Whether you want a weak ETag or not
  ///
  /// @return $this
  ///
  /// @final
  void setEtag(String? etag, {bool weak = false}) {
    if (etag == null) {
      headers.remove('ETag');
    } else {
      if (!etag.startsWith('"')) {
        etag = '"$etag"';
      }
      headers.set('ETag', '${weak ? 'W/' : ''}$etag');
    }
  }

  /// Sets the response's cache headers (validation and/or expiration).
  ///
  /// Available options are: must_revalidate, no_cache, no_store, no_transform, public, private, proxy_revalidate, max_age, s_maxage, immutable, last_modified and etag.
  ///
  /// @return $this
  ///
  /// @throws \InvalidArgumentException
  ///
  /// @final
  void setCache(Map<String, dynamic> options) {
    var diff = options.keys.toSet().difference(httpResponseCacheControlDirectives.keys.toSet());
    if (diff.isNotEmpty) {
      throw ArgumentError('Response does not support the following options: "${diff.join(', ')}".');
    }

    if (options.containsKey('etag')) {
      setEtag(options['etag']);
    }

    if (options.containsKey('last_modified')) {
      setLastModified(options['last_modified']);
    }

    if (options.containsKey('max_age')) {
      setMaxAge(options['max_age']);
    }

    if (options.containsKey('s_maxage')) {
      setSharedMaxAge(options['s_maxage']);
    }

    if (options.containsKey('stale_while_revalidate')) {
      setStaleWhileRevalidate(options['stale_while_revalidate']);
    }

    if (options.containsKey('stale_if_error')) {
      setStaleIfError(options['stale_if_error']);
    }

    httpResponseCacheControlDirectives.forEach((directive, hasValue) {
      if (!hasValue && options.containsKey(directive)) {
        if (options[directive]) {
          headers.set('Cache-Control', directive.replaceAll('_', '-'));
        } else {
          headers.remove(directive.replaceAll('_', '-'));
        }
      }
    });

    if (options.containsKey('public')) {
      if (options['public']) {
        setPublic();
      } else {
        setPrivate();
      }
    }

    if (options.containsKey('private')) {
      if (options['private']) {
        setPrivate();
      } else {
        setPublic();
      }
    }
  }

  /// Modifies the response so that it conforms to the rules defined for a 304 status code.
  ///
  /// This sets the status, removes the body, and discards any headers
  /// that MUST NOT be included in 304 responses.
  ///
  /// @return $this
  void setNotModified() {
    setStatusCode(304);
    content = '';

    ['Allow', 'Content-Encoding', 'Content-Language', 'Content-Length', 'Content-MD5', 'Content-Type', 'Last-Modified'].forEach(headers.remove);
  }

  /// Returns true if the response includes a Vary header.
  ///
  /// @final
  bool hasVary() {
    return headers.value('Vary') != null;
  }

  /// Returns an array of header names given in the Vary header.
  ///
  /// @final
  List<String> getVary() {
    var vary = headers.all('Vary')['Vary'];
    if (vary == null) return [];
    return vary.expand((v) => v.split(RegExp(r'[\s,]+'))).toList();
  }

  /// Sets the Vary header.
  ///
  /// @param bool $replace Whether to replace the actual value or not (true by default)
  ///
  /// @return $this
  ///
  /// @final
  void setVary(List<String> headers, [bool replace = true]) {
    this.headers.set('Vary', headers.join(', '), replace: replace);
  }

  /// Determines if the Response validators (ETag, Last-Modified) match
  /// a conditional value specified in the Request.
  ///
  /// If the Response is not modified, it sets the status code to 304 and
  /// removes the actual content by calling the setNotModified() method.
  ///
  /// @final
  bool isNotModified(HttpRequest request) {
    if (!['GET', 'HEAD'].contains(request.method)) {
      return false;
    }

    var notModified = false;
    var lastModified = headers.value('Last-Modified');
    var modifiedSince = request.headers.value(HttpHeaders.ifModifiedSinceHeader);

    var ifNoneMatchEtags = request.headers[HttpHeaders.ifNoneMatchHeader];
    var etag = getEtag();

    if (ifNoneMatchEtags != null && etag != null) {
      if (etag.startsWith('W/')) {
        etag = etag.substring(2);
      }

      for (var ifNoneMatchEtag in ifNoneMatchEtags) {
        if (ifNoneMatchEtag.startsWith('W/')) {
          ifNoneMatchEtag = ifNoneMatchEtag.substring(2);
        }

        if (ifNoneMatchEtag == etag || ifNoneMatchEtag == '*') {
          notModified = true;
          break;
        }
      }
    } else if (modifiedSince != null && lastModified != null) {
      notModified = DateTime.parse(modifiedSince).isAfter(DateTime.parse(lastModified));
    }

    if (notModified) {
      setNotModified();
    }

    return notModified;
  }

  /// Is response invalid?
  ///
  /// @see https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
  ///
  /// @final
  bool isInvalid() {
    return statusCode < 100 || statusCode >= 600;
  }

  /// Is response informative?
  ///
  /// @final
  bool isInformational() {
    return statusCode >= 100 && statusCode < 200;
  }

  /// Is response successful?
  ///
  /// @final
  bool isSuccessful() {
    return statusCode >= 200 && statusCode < 300;
  }

  /// Is the response a redirect?
  ///
  /// @final
  bool isRedirection() {
    return statusCode >= 300 && statusCode < 400;
  }

  /// Is there a client error?
  ///
  /// @final
  bool isClientError() {
    return statusCode >= 400 && statusCode < 500;
  }

  /// Was there a server side error?
  ///
  /// @final
  bool isServerError() {
    return statusCode >= 500 && statusCode < 600;
  }

  /// Is the response OK?
  ///
  /// @final
  bool isOk() {
    return statusCode == HTTP_OK;
  }

  /// Is the response forbidden?
  ///
  /// @final
  bool isForbidden() {
    return statusCode == HTTP_FORBIDDEN;
  }

  /// Is the response a not found error?
  ///
  /// @final
  bool isNotFound() {
    return statusCode == HTTP_NOT_FOUND;
  }

  /// Is the response a redirect of some form?
  ///
  /// @final
  bool isRedirect([String? location]) {
    return [HTTP_CREATED, HTTP_MOVED_PERMANENTLY, HTTP_FOUND, HTTP_SEE_OTHER, HTTP_TEMPORARY_REDIRECT, HTTP_PERMANENTLY_REDIRECT].contains(statusCode) &&
        (location == null || location == headers.value('Location'));
  }

  /// Is the response empty?
  ///
  /// @final
  bool isEmpty() {
    return [HTTP_NO_CONTENT, HTTP_NOT_MODIFIED].contains(statusCode);
  }

  /// Cleans or flushes output buffers up to target level.
  ///
  /// Resulting level can be greater than target level if a non-removable buffer has been encountered.
  ///
  /// @final
  static void closeOutputBuffers(int targetLevel, bool flush) {
    while (stdout.hasTerminal && stdout.terminalOutputMode != null && targetLevel > 0) {
      if (flush) {
        stdout.flush();
      } else {
        stdout.clear();
      }
      targetLevel--;
    }
  }

  /// Marks a response as safe according to RFC8674.
  ///
  /// @see https://tools.ietf.org/html/rfc8674
  void setContentSafe(bool safe) {
    if (safe) {
      headers.set('Preference-Applied', 'safe');
    } else if (headers.value('Preference-Applied') == 'safe') {
      headers.remove('Preference-Applied');
    }
    setVary(['Prefer'], false);
  }

  /// Checks if we need to remove Cache-Control for SSL encrypted downloads when using IE < 9.
  ///
  /// @see http://support.microsoft.com/kb/323308
  ///
  /// @final
  void ensureIEOverSSLCompatibility(HttpRequest request) {
    if (headers.value('Content-Disposition')?.contains('attachment') == true &&
        request.headers.value(HttpHeaders.userAgentHeader)?.contains(RegExp(r'MSIE (\d+)')) == true &&
        request.uri.scheme == 'https') {
      var match = RegExp(r'MSIE (\d+)').firstMatch(request.headers.value(HttpHeaders.userAgentHeader) ?? '');
      if (match != null && int.parse(match.group(1)!) < 9) {
        headers.remove('Cache-Control');
      }
    }
  }
}
