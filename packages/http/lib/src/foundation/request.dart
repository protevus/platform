import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

// Assuming these classes have been ported to Dart
import 'accept_header.dart';
import 'file_bag.dart';
import 'header_bag.dart';
import 'header_utils.dart';
import 'input_bag.dart';
import 'parameter_bag.dart';
import 'server_bag.dart';
import "package:protevus_http/foundation_session.dart";
import 'ip_utils.dart';

class Request {
  static const int HEADER_FORWARDED = 0b000001;
  static const int HEADER_X_FORWARDED_FOR = 0b000010;
  static const int HEADER_X_FORWARDED_HOST = 0b000100;
  static const int HEADER_X_FORWARDED_PROTO = 0b001000;
  static const int HEADER_X_FORWARDED_PORT = 0b010000;
  static const int HEADER_X_FORWARDED_PREFIX = 0b100000;

  static const int HEADER_X_FORWARDED_AWS_ELB = 0b0011010;
  static const int HEADER_X_FORWARDED_TRAEFIK = 0b0111110;

  static const String METHOD_HEAD = 'HEAD';
  static const String METHOD_GET = 'GET';
  static const String METHOD_POST = 'POST';
  static const String METHOD_PUT = 'PUT';
  static const String METHOD_PATCH = 'PATCH';
  static const String METHOD_DELETE = 'DELETE';
  static const String METHOD_PURGE = 'PURGE';
  static const String METHOD_OPTIONS = 'OPTIONS';
  static const String METHOD_TRACE = 'TRACE';
  static const String METHOD_CONNECT = 'CONNECT';

  static List<String> trustedProxies = [];
  static List<String> trustedHostPatterns = [];
  static List<String> trustedHosts = [];
  static bool httpMethodParameterOverride = false;

  late ParameterBag attributes;
  late InputBag request;
  late InputBag query;
  late ServerBag server;
  late FileBag files;
  late InputBag cookies;
  late HeaderBag headers;

  dynamic content;
  List<String>? languages;
  List<String>? charsets;
  List<String>? encodings;
  List<String>? acceptableContentTypes;

  String? pathInfo;
  String? requestUri;
  String? baseUrl;
  String? basePath;
  String? method;
  String? format;
  dynamic session;
  String? locale;
  String defaultLocale = 'en';

  static Map<String, List<String>>? formats;
  static Function? requestFactory;

  String? preferredFormat;
  bool isHostValid = true;
  bool isForwardedValid = true;
  late bool isSafeContentPreferred;

  Map<String, dynamic> trustedValuesCache = {};

  static int trustedHeaderSet = -1;

  static const Map<int, String> FORWARDED_PARAMS = {
    HEADER_X_FORWARDED_FOR: 'for',
    HEADER_X_FORWARDED_HOST: 'host',
    HEADER_X_FORWARDED_PROTO: 'proto',
    HEADER_X_FORWARDED_PORT: 'host',
  };

  static const Map<int, String> TRUSTED_HEADERS = {
    HEADER_FORWARDED: 'FORWARDED',
    HEADER_X_FORWARDED_FOR: 'X_FORWARDED_FOR',
    HEADER_X_FORWARDED_HOST: 'X_FORWARDED_HOST',
    HEADER_X_FORWARDED_PROTO: 'X_FORWARDED_PROTO',
    HEADER_X_FORWARDED_PORT: 'X_FORWARDED_PORT',
    HEADER_X_FORWARDED_PREFIX: 'X_FORWARDED_PREFIX',
  };

  bool isIisRewrite = false;

  Request({
    Map<String, dynamic> query = const {},
    Map<String, dynamic> request = const {},
    Map<String, dynamic> attributes = const {},
    Map<String, dynamic> cookies = const {},
    Map<String, dynamic> files = const {},
    Map<String, dynamic> server = const {},
    dynamic content,
  }) {
    initialize(query, request, attributes, cookies, files, server, content);
  }

  void initialize(
    Map<String, dynamic> query,
    Map<String, dynamic> request,
    Map<String, dynamic> attributes,
    Map<String, dynamic> cookies,
    Map<String, dynamic> files,
    Map<String, dynamic> server,
    dynamic content,
  ) {
    this.request = InputBag(request);
    this.query = InputBag(query);
    this.attributes = ParameterBag(attributes);
    this.cookies = InputBag(cookies);
    this.files = FileBag(files);
    this.server = ServerBag(server);
    this.headers = HeaderBag(this.server.getHeaders());

    this.content = content;
    this.languages = null;
    this.charsets = null;
    this.encodings = null;
    this.acceptableContentTypes = null;
    this.pathInfo = null;
    this.requestUri = null;
    this.baseUrl = null;
    this.basePath = null;
    this.method = null;
    this.format = null;
  }

  static Request createFromGlobals() {
    // Dart equivalent of PHP's superglobals
    var get = Platform.environment;
    var post = {}; // POST data needs to be handled differently in Dart
    var cookies = {}; // Cookie handling needs to be implemented
    var files = {}; // File uploads need to be handled differently
    var server = Platform.environment;

    var request = createRequestFromFactory(get, post, {}, cookies, files, server);

    if (request.headers.get('CONTENT_TYPE')?.startsWith('application/x-www-form-urlencoded') == true &&
        ['PUT', 'DELETE', 'PATCH'].contains(request.server.get('REQUEST_METHOD', 'GET').toUpperCase())) {
      // Parse request body
      var data = Uri(query: request.getContent()).queryParameters;
      request.request = InputBag(data);
    }

    return request;
  }

  static Request create(
    String uri, {
    String method = 'GET',
    Map<String, dynamic> parameters = const {},
    Map<String, dynamic> cookies = const {},
    Map<String, dynamic> files = const {},
    Map<String, dynamic> server = const {},
    dynamic content,
  }) {
    var defaultServer = {
      'SERVER_NAME': 'localhost',
      'SERVER_PORT': '80',
      'HTTP_HOST': 'localhost',
      'HTTP_USER_AGENT': 'Dart',
      'HTTP_ACCEPT': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'HTTP_ACCEPT_LANGUAGE': 'en-us,en;q=0.5',
      'HTTP_ACCEPT_CHARSET': 'ISO-8859-1,utf-8;q=0.7,*;q=0.7',
      'REMOTE_ADDR': '127.0.0.1',
      'SCRIPT_NAME': '',
      'SCRIPT_FILENAME': '',
      'SERVER_PROTOCOL': 'HTTP/1.1',
      'REQUEST_TIME': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'REQUEST_TIME_FLOAT': DateTime.now().millisecondsSinceEpoch / 1000,
    };

    server = {...defaultServer, ...server};

    server['PATH_INFO'] = '';
    server['REQUEST_METHOD'] = method.toUpperCase();

    var components = Uri.parse(uri);
    if (components.host != null) {
      server['SERVER_NAME'] = components.host!;
      server['HTTP_HOST'] = components.host!;
    }

    if (components.scheme != null) {
      if (components.scheme == 'https') {
        server['HTTPS'] = 'on';
        server['SERVER_PORT'] = '443';
      } else {
        server.remove('HTTPS');
        server['SERVER_PORT'] = '80';
      }
    }

    if (components.port != 0) {
      server['SERVER_PORT'] = components.port.toString();
      server['HTTP_HOST'] = '${server['HTTP_HOST']}:${components.port}';
    }

    if (components.userInfo.isNotEmpty) {
      var userInfoParts = components.userInfo.split(':');
      server['PHP_AUTH_USER'] = userInfoParts[0];
      if (userInfoParts.length > 1) {
        server['PHP_AUTH_PW'] = userInfoParts[1];
      }
    }

    if (components.path.isEmpty) {
      components = components.replace(path: '/');
    }

    Map<String, dynamic> request = {};
    Map<String, dynamic> query = {};

    switch (method.toUpperCase()) {
      case 'POST':
      case 'PUT':
      case 'DELETE':
        if (!server.containsKey('CONTENT_TYPE')) {
          server['CONTENT_TYPE'] = 'application/x-www-form-urlencoded';
        }
        request = parameters;
        break;
      case 'PATCH':
        request = parameters;
        break;
      default:
        query = parameters;
        break;
    }

    var queryString = '';
    if (components.query.isNotEmpty) {
      var qs = Uri.splitQueryString(components.query);
      if (query.isNotEmpty) {
        query = {...qs, ...query};
        queryString = Uri(queryParameters: query).query;
      } else {
        query = qs;
        queryString = components.query;
      }
    } else if (query.isNotEmpty) {
      queryString = Uri(queryParameters: query).query;
    }

    server['REQUEST_URI'] = '${components.path}${queryString.isNotEmpty ? '?$queryString' : ''}';
    server['QUERY_STRING'] = queryString;

    return createRequestFromFactory(query, request, {}, cookies, files, server, content);
  }

  static void setFactory(Function? callable) {
    requestFactory = callable;
  }

  Request duplicate({
    Map<String, dynamic>? query,
    Map<String, dynamic>? request,
    Map<String, dynamic>? attributes,
    Map<String, dynamic>? cookies,
    Map<String, dynamic>? files,
    Map<String, dynamic>? server,
  }) {
    var dup = Request();
    dup.query = query != null ? InputBag(query) : this.query;
    dup.request = request != null ? InputBag(request) : this.request;
    dup.attributes = attributes != null ? ParameterBag(attributes) : this.attributes;
    dup.cookies = cookies != null ? InputBag(cookies) : this.cookies;
    dup.files = files != null ? FileBag(files) : this.files;
    if (server != null) {
      dup.server = ServerBag(server);
      dup.headers = HeaderBag(dup.server.getHeaders());
    } else {
      dup.server = this.server;
      dup.headers = this.headers;
    }
    dup.languages = null;
    dup.charsets = null;
    dup.encodings = null;
    dup.acceptableContentTypes = null;
    dup.pathInfo = null;
    dup.requestUri = null;
    dup.baseUrl = null;
    dup.basePath = null;
    dup.method = null;
    dup.format = null;

    if (!dup.get('_format') && this.get('_format') != null) {
      dup.attributes.set('_format', this.get('_format'));
    }

    if (dup.getRequestFormat(null) == null) {
      dup.setRequestFormat(this.getRequestFormat(null));
    }

    return dup;
  }

  @override
  String toString() {
    var content = getContent();

    var cookieHeader = '';
    var cookies = [];

    for (var entry in this.cookies.all().entries) {
      if (entry.value is List) {
        cookies.add(Uri(queryParameters: {entry.key: entry.value}).query.replaceAll('&', '; '));
      } else {
        cookies.add('${entry.key}=${entry.value}');
      }
    }

    if (cookies.isNotEmpty) {
      cookieHeader = 'Cookie: ${cookies.join('; ')}\r\n';
    }

    return '${getMethod()} ${getRequestUri()} ${server.get('SERVER_PROTOCOL')}\r\n'
        '${headers.toString()}'
        '$cookieHeader\r\n'
        '$content';
  }

  void overrideGlobals() {
    // This method is not directly applicable in Dart as it doesn't have global variables like PHP
    // You might need to implement a global state management solution in your Dart application
  }

  static void setTrustedProxies(List<String> proxies, int trustedHeaderSet) {
    trustedProxies = proxies.where((proxy) => proxy != 'REMOTE_ADDR').toList();
    if (proxies.contains('REMOTE_ADDR')) {
      var remoteAddr = Platform.environment['REMOTE_ADDR'];
      if (remoteAddr != null) {
        trustedProxies.add(remoteAddr);
      }
    }
    Request.trustedHeaderSet = trustedHeaderSet;
  }

  static List<String> getTrustedProxies() {
    return trustedProxies;
  }

  static int getTrustedHeaderSet() {
    return trustedHeaderSet;
  }

  static void setTrustedHosts(List<String> hostPatterns) {
    trustedHostPatterns = hostPatterns.map((hostPattern) => RegExp(hostPattern, caseSensitive: false).pattern).toList();
    trustedHosts = [];
  }

  static List<String> getTrustedHosts() {
    return trustedHostPatterns;
  }

  static String normalizeQueryString(String? qs) {
    if (qs == null || qs.isEmpty) {
      return '';
    }

    var queryParams = Uri.splitQueryString(qs);
    var sortedKeys = queryParams.keys.toList()..sort();
    var normalizedParams = sortedKeys.map((key) => '$key=${Uri.encodeQueryComponent(queryParams[key]!)}');

    return normalizedParams.join('&');
  }

  static void enableHttpMethodParameterOverride() {
    httpMethodParameterOverride = true;
  }

  static bool getHttpMethodParameterOverride() {
    return httpMethodParameterOverride;
  }

  dynamic get(String key, [dynamic defaultValue]) {
    if (attributes.get(key) != null) {
      return attributes.get(key);
    }

    if (query.has(key)) {
      return query.all()[key];
    }

    if (request.has(key)) {
      return request.all()[key];
    }

    return defaultValue;
  }

  SessionInterface getSession() {
    if (session == null) {
      throw Exception('Session has not been set.');
    }
    if (session is Function) {
      session = session();
    }
    return session as SessionInterface;
  }

  bool hasPreviousSession() {
    return hasSession() && cookies.has(getSession().getName());
  }

  bool hasSession([bool skipIfUninitialized = false]) {
    return session != null && (!skipIfUninitialized || session is SessionInterface);
  }
void setSession(SessionInterface session) {
    this.session = session;
  }

  void setSessionFactory(Function factory) {
    this.session = factory;
  }

  List<String> getClientIps() {
    var ip = server.get('REMOTE_ADDR');

    if (!isFromTrustedProxy()) {
      return [ip];
    }

    var trustedValues = getTrustedValues(HEADER_X_FORWARDED_FOR, ip);
    return trustedValues.isNotEmpty ? trustedValues : [ip];
  }

  String? getClientIp() {
    var ips = getClientIps();
    return ips.isNotEmpty ? ips[0] : null;
  }

  String getScriptName() {
    return server.get('SCRIPT_NAME', server.get('ORIG_SCRIPT_NAME', ''));
  }

  String getPathInfo() {
    return pathInfo ??= preparePathInfo();
  }

  String getBasePath() {
    return basePath ??= prepareBasePath();
  }

  String getBaseUrl() {
    var trustedPrefix = '';

    if (isFromTrustedProxy() && getTrustedValues(HEADER_X_FORWARDED_PREFIX).isNotEmpty) {
      trustedPrefix = getTrustedValues(HEADER_X_FORWARDED_PREFIX)[0].trimRight('/');
    }

    return '$trustedPrefix${getBaseUrlReal()}';
  }

  String getBaseUrlReal() {
    return baseUrl ??= prepareBaseUrl();
  }

  String getScheme() {
    return isSecure() ? 'https' : 'http';
  }

  dynamic getPort() {
    String? host;
    if (isFromTrustedProxy()) {
      var forwardedPort = getTrustedValues(HEADER_X_FORWARDED_PORT);
      if (forwardedPort.isNotEmpty) {
        host = forwardedPort[0];
      } else {
        var forwardedHost = getTrustedValues(HEADER_X_FORWARDED_HOST);
        if (forwardedHost.isNotEmpty) {
          host = forwardedHost[0];
        }
      }
    }

    if (host == null) {
      host = headers.get('HOST');
    }

    if (host == null) {
      return server.get('SERVER_PORT');
    }

    if (host.startsWith('[')) {
      var pos = host.lastIndexOf(']');
      if (pos > 0) {
        host = host.substring(pos + 1);
      }
    }

    var pos = host.lastIndexOf(':');
    if (pos > 0) {
      return int.tryParse(host.substring(pos + 1)) ?? (getScheme() == 'https' ? 443 : 80);
    }

    return getScheme() == 'https' ? 443 : 80;
  }

  String? getUser() {
    return headers.get('PHP_AUTH_USER');
  }

  String? getPassword() {
    return headers.get('PHP_AUTH_PW');
  }

  String? getUserInfo() {
    var userInfo = getUser();
    var pass = getPassword();
    if (pass != null && pass.isNotEmpty) {
      userInfo = '$userInfo:$pass';
    }
    return userInfo;
  }

  String getHttpHost() {
    var scheme = getScheme();
    var port = getPort();

    if ((scheme == 'http' && port == 80) || (scheme == 'https' && port == 443)) {
      return getHost();
    }

    return '${getHost()}:$port';
  }

  String getRequestUri() {
    return requestUri ??= prepareRequestUri();
  }

  String getSchemeAndHttpHost() {
    return '${getScheme()}://${getHttpHost()}';
  }

  String getUri() {
    var qs = getQueryString();
    if (qs != null && qs.isNotEmpty) {
      qs = '?$qs';
    } else {
      qs = '';
    }

    return '${getSchemeAndHttpHost()}${getBaseUrl()}${getPathInfo()}$qs';
  }

  String getUriForPath(String path) {
    return '${getSchemeAndHttpHost()}${getBaseUrl()}$path';
  }

  String getRelativeUriForPath(String path) {
    if (path.isEmpty || path[0] != '/') {
      return path;
    }

    var basePath = getPathInfo();
    if (path == basePath) {
      return '';
    }

    var sourceDirs = basePath.split('/');
    var targetDirs = path.split('/');
    sourceDirs = sourceDirs.sublist(1, sourceDirs.length - 1);
    var targetFile = targetDirs.removeLast();

    for (var i = 0; i < sourceDirs.length; i++) {
      if (i < targetDirs.length && sourceDirs[i] == targetDirs[i]) {
        sourceDirs.removeAt(i);
        targetDirs.removeAt(i);
        i--;
      } else {
        break;
      }
    }

    targetDirs.add(targetFile);
    var relativePath = '../' * sourceDirs.length + targetDirs.join('/');

    return relativePath.isEmpty || relativePath[0] == '/' || relativePath.contains(':')
        ? './$relativePath'
        : relativePath;
  }

  String? getQueryString() {
    var qs = normalizeQueryString(server.get('QUERY_STRING'));
    return qs.isEmpty ? null : qs;
  }

  bool isSecure() {
    if (isFromTrustedProxy()) {
      var proto = getTrustedValues(HEADER_X_FORWARDED_PROTO);
      if (proto.isNotEmpty) {
        return ['https', 'on', 'ssl', '1'].contains(proto[0].toLowerCase());
      }
    }

    var https = server.get('HTTPS');
    return https != null && https.toLowerCase() != 'off';
  }

  String getHost() {
    var host = '';
    if (isFromTrustedProxy()) {
      var trustedValues = getTrustedValues(HEADER_X_FORWARDED_HOST);
      if (trustedValues.isNotEmpty) {
        host = trustedValues[0];
      }
    }

    if (host.isEmpty) {
      host = headers.get('HOST') ?? '';
    }

    if (host.isEmpty) {
      host = server.get('SERVER_NAME') ?? '';
    }

    if (host.isEmpty) {
      host = server.get('SERVER_ADDR') ?? '';
    }

    // Trim and remove port number from host
    host = host.toLowerCase().replaceAll(RegExp(r':\d+$'), '').trim();

    // Check for forbidden characters
    if (host.isNotEmpty && !RegExp(r'^(\[)?[a-zA-Z0-9-:\]_]+\.?$').hasMatch(host)) {
      if (!isHostValid) {
        return '';
      }
      isHostValid = false;
      throw Exception('Invalid Host "$host".');
    }

    if (trustedHostPatterns.isNotEmpty) {
      if (trustedHosts.contains(host)) {
        return host;
      }

      for (var pattern in trustedHostPatterns) {
        if (RegExp(pattern).hasMatch(host)) {
          trustedHosts.add(host);
          return host;
        }
      }

      if (!isHostValid) {
        return '';
      }
      isHostValid = false;
      throw Exception('Untrusted Host "$host".');
    }

    return host;
  }

  void setMethod(String method) {
    this.method = null;
    server.set('REQUEST_METHOD', method);
  }

  String getMethod() {
    if (method != null) {
      return method!;
    }

    method = server.get('REQUEST_METHOD', 'GET').toUpperCase();

    if (method != 'POST') {
      return method!;
    }

    var methodOverride = headers.get('X-HTTP-METHOD-OVERRIDE');

    if (methodOverride == null && httpMethodParameterOverride) {
      methodOverride = request.get('_method', query.get('_method', 'POST'));
    }

    if (methodOverride is String) {
      methodOverride = methodOverride.toUpperCase();
      if (['GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'CONNECT', 'OPTIONS', 'PATCH', 'PURGE', 'TRACE'].contains(methodOverride)) {
        method = methodOverride;
      }

      if (!RegExp(r'^[A-Z]+$').hasMatch(methodOverride)) {
        throw Exception('Invalid method override "$methodOverride".');
      }

      method = methodOverride;
    }

    return method!;
  }

  String getRealMethod() {
    return server.get('REQUEST_METHOD', 'GET').toUpperCase();
  }

  String? getMimeType(String format) {
    if (formats == null) {
      initializeFormats();
    }
    return formats![format]?.first;
  }

  static List<String> getMimeTypes(String format) {
    if (formats == null) {
      initializeFormats();
    }
    return formats![format] ?? [];
  }

  String? getFormat(String? mimeType) {
    var canonicalMimeType = mimeType;
    if (mimeType != null && mimeType.contains(';')) {
      canonicalMimeType = mimeType.split(';').first.trim();
    }

    if (formats == null) {
      initializeFormats();
    }

    for (var entry in formats!.entries) {
      if (entry.value.contains(mimeType) || entry.value.contains(canonicalMimeType)) {
        return entry.key;
      }
    }

    return null;
  }

  void setFormat(String? format, dynamic mimeTypes) {
    if (formats == null) {
      initializeFormats();
    }
    formats![format!] = mimeTypes is List ? mimeTypes : [mimeTypes];
  }

  String? getRequestFormat([String? defaultFormat = 'html']) {
    if (format == null) {
      format = attributes.get('_format');
    }
    return format ?? defaultFormat;
  }

  void setRequestFormat(String? format) {
    this.format = format;
  }

  String? getContentTypeFormat() {
    return getFormat(headers.get('CONTENT_TYPE', ''));
  }

  void setDefaultLocale(String locale) {
    defaultLocale = locale;

    if (this.locale == null) {
      setPhpDefaultLocale(locale);
    }
  }

  String getDefaultLocale() {
    return defaultLocale;
  }

  void setLocale(String locale) {
    setPhpDefaultLocale(this.locale = locale);
  }

  String getLocale() {
    return locale ?? defaultLocale;
  }

  bool isMethod(String method) {
    return getMethod() == method.toUpperCase();
  }

  bool isMethodSafe() {
    return ['GET', 'HEAD', 'OPTIONS', 'TRACE'].contains(getMethod());
  }

  bool isMethodIdempotent() {
    return ['HEAD', 'GET', 'PUT', 'DELETE', 'TRACE', 'OPTIONS', 'PURGE'].contains(getMethod());
  }

  bool isMethodCacheable() {
    return ['GET', 'HEAD'].contains(getMethod());
  }

  String? getProtocolVersion() {
    if (isFromTrustedProxy()) {
      var viaHeader = headers.get('Via');
      if (viaHeader != null) {
        var matches = RegExp(r'^(HTTP/)?([1-9]\.[0-9]) ').firstMatch(viaHeader);
        if (matches != null) {
          return 'HTTP/${matches.group(2)}';
        }
      }
    }

    return server.get('SERVER_PROTOCOL');
  }

  dynamic getContent({bool asResource = false}) {
    if (content is IOSink && asResource) {
      return content;
    }

    if (asResource) {
      content = File('php://input').openRead();
      return content;
    }

    if (content is IOSink) {
      var stringContent = StringBuffer();
      content.stream.transform(utf8.decoder).listen((data) {
        stringContent.write(data);
      });
      content = stringContent.toString();
    }

    if (content == null || content == false) {
      content = File('php://input').readAsStringSync();
    }

    return content;
  }

  InputBag getPayload() {
    if (request.count() > 0) {
      return InputBag(Map.from(request.all()));
    }

    var content = getContent();
    if (content.isEmpty) {
      return InputBag({});
    }

    try {
      var decodedContent = json.decode(content);
      if (decodedContent is! Map) {
        throw FormatException('JSON content was expected to decode to a Map, "${decodedContent.runtimeType}" returned.');
      }
      return InputBag(decodedContent);
    } catch (e) {
      throw FormatException('Could not decode request body.', e);
    }
  }

  Map<String, dynamic> toArray() {
    var content = getContent();
    if (content.isEmpty) {
      throw FormatException('Request body is empty.');
    }

    try {
      var decodedContent = json.decode(content);
      if (decodedContent is! Map) {
        throw FormatException('JSON content was expected to decode to a Map, "${decodedContent.runtimeType}" returned.');
      }
      return decodedContent;
    } catch (e) {
      throw FormatException('Could not decode request body.', e);
    }
  }

  List<String> getETags() {
    return headers.get('If-None-Match', '').split(RegExp(r'\s*,\s*'))..removeWhere((e) => e.isEmpty);
  }

  bool isNoCache() {
    return headers.hasCacheControlDirective('no-cache') || headers.get('Pragma') == 'no-cache';
  }

  String? getPreferredFormat([String? defaultFormat = 'html']) {
    if (preferredFormat == null) {
      preferredFormat = getRequestFormat(null);
    }

    if (preferredFormat != null) {
      return preferredFormat;
    }

    for (var mimeType in getAcceptableContentTypes()) {
      preferredFormat = getFormat(mimeType);
      if (preferredFormat != null) {
        return preferredFormat;
      }
    }

    return defaultFormat;
  }

  String? getPreferredLanguage([List<String>? locales]) {
    var preferredLanguages = getLanguages();

    if (locales == null || locales.isEmpty) {
      return preferredLanguages.isNotEmpty ? preferredLanguages.first : null;
    }

    locales = locales.map(formatLocale).toList();
    if (preferredLanguages.isEmpty) {
      return locales.first;
    }

    var matches = preferredLanguages.where((lang) => locales!.contains(lang)).toList();
    if (matches.isNotEmpty) {
      return matches.first;
    }

    var combinations = preferredLanguages.expand(getLanguageCombinations).toList();
    for (var combination in combinations) {
      for (var locale in locales) {
        if (locale.startsWith(combination)) {
          return locale;
        }
      }
    }

    return locales.first;
  }

  List<String> getLanguages() {
    if (languages !=null) {
      return languages!;
    }

    languages = [];
    var acceptLanguage = headers.get('Accept-Language');
    if (acceptLanguage != null) {
      var acceptHeader = AcceptHeader.fromString(acceptLanguage);
      for (var item in acceptHeader.all()) {
        languages!.add(formatLocale(item.value));
      }
    }
    languages = languages!.toSet().toList(); // Remove duplicates
    return languages!;
  }

  static String formatLocale(String locale) {
    var components = getLanguageComponents(locale);
    return [components[0], components[1], components[2]].where((e) => e != null).join('_');
  }

  static List<String> getLanguageCombinations(String locale) {
    var components = getLanguageComponents(locale);
    var language = components[0];
    var script = components[1];
    var region = components[2];

    return [
      [language, script, region].where((e) => e != null).join('_'),
      [language, script].where((e) => e != null).join('_'),
      [language, region].where((e) => e != null).join('_'),
      language,
    ].toSet().toList(); // Remove duplicates
  }

  static List<String?> getLanguageComponents(String locale) {
    locale = locale.toLowerCase().replaceAll('_', '-');
    var pattern = RegExp(r'^([a-zA-Z]{2,3}|i-[a-zA-Z]{5,})(?:-([a-zA-Z]{4}))?(?:-([a-zA-Z]{2}))?(?:-(.+))?$');
    var match = pattern.firstMatch(locale);
    
    if (match == null) {
      return [locale, null, null];
    }

    var language = match.group(1);
    if (language!.startsWith('i-')) {
      language = language.substring(2);
    }

    var script = match.group(2);
    script = script != null ? script[0].toUpperCase() + script.substring(1).toLowerCase() : null;

    var region = match.group(3);
    region = region?.toUpperCase();

    return [language, script, region];
  }

  List<String> getCharsets() {
    if (charsets == null) {
      var acceptCharset = headers.get('Accept-Charset');
      if (acceptCharset != null) {
        charsets = AcceptHeader.fromString(acceptCharset).keys.map((e) => e.toString()).toList();
      } else {
        charsets = [];
      }
    }
    return charsets!;
  }

  List<String> getEncodings() {
    if (encodings == null) {
      var acceptEncoding = headers.get('Accept-Encoding');
      if (acceptEncoding != null) {
        encodings = AcceptHeader.fromString(acceptEncoding).keys.map((e) => e.toString()).toList();
      } else {
        encodings = [];
      }
    }
    return encodings!;
  }

  List<String> getAcceptableContentTypes() {
    if (acceptableContentTypes == null) {
      var accept = headers.get('Accept');
      if (accept != null) {
        acceptableContentTypes = AcceptHeader.fromString(accept).keys.map((e) => e.toString()).toList();
      } else {
        acceptableContentTypes = [];
      }
    }
    return acceptableContentTypes!;
  }

  bool isXmlHttpRequest() {
    return headers.get('X-Requested-With') == 'XMLHttpRequest';
  }

  bool preferSafeContent() {
    if (isSafeContentPreferred != null) {
      return isSafeContentPreferred;
    }

    if (!isSecure()) {
      return isSafeContentPreferred = false;
    }

    return isSafeContentPreferred = AcceptHeader.fromString(headers.get('Prefer') ?? '').has('safe');
  }

  String prepareRequestUri() {
    var requestUri = '';

    if (isIisRewrite() && server.get('UNENCODED_URL') != null) {
      requestUri = server.get('UNENCODED_URL')!;
      server.remove('UNENCODED_URL');
    } else if (server.get('REQUEST_URI') != null) {
      requestUri = server.get('REQUEST_URI')!;
      if (requestUri.isNotEmpty && requestUri[0] != '/') {
        var uriComponents = Uri.parse(requestUri);
        requestUri = uriComponents.path;
        if (uriComponents.query != null) {
          requestUri += '?${uriComponents.query}';
        }
      }
    } else if (server.get('ORIG_PATH_INFO') != null) {
      requestUri = server.get('ORIG_PATH_INFO')!;
      if (server.get('QUERY_STRING') != null) {
        requestUri += '?${server.get('QUERY_STRING')}';
      }
      server.remove('ORIG_PATH_INFO');
    }

    server.set('REQUEST_URI', requestUri);

    return requestUri;
  }

  String prepareBaseUrl() {
    var filename = basename(server.get('SCRIPT_FILENAME') ?? '');
    var scriptName = server.get('SCRIPT_NAME');
    var phpSelf = server.get('PHP_SELF');
    var origScriptName = server.get('ORIG_SCRIPT_NAME');

    if (scriptName != null && basename(scriptName) == filename) {
      return scriptName;
    }

    if (phpSelf != null && basename(phpSelf) == filename) {
      return phpSelf;
    }

    if (origScriptName != null && basename(origScriptName) == filename) {
      return origScriptName;
    }

    var requestUri = getRequestUri();
    var baseUrl = '';

    if (requestUri == '/' || requestUri.isEmpty) {
      return '';
    }

    if (requestUri != null) {
      var filenameParts = filename.split('/').reversed;
      var uriParts = requestUri.split('/');

      var i = 0;
      for (var part in filenameParts) {
        if (i >= uriParts.length || uriParts[uriParts.length - 1 - i] != part) {
          break;
        }
        i++;
      }

      if (i > 0) {
        baseUrl = uriParts.sublist(0, uriParts.length - i).join('/');
      }
    }

    return baseUrl;
  }

  String prepareBasePath() {
    var baseUrl = getBaseUrl();
    if (baseUrl.isEmpty) {
      return '';
    }

    var filename = basename(server.get('SCRIPT_FILENAME') ?? '');
    var basePath = baseUrl;

    if (basename(baseUrl) == filename) {
      basePath = dirname(baseUrl);
    }

    if (basePath == '\\') {
      return '';
    }

    return basePath;
  }

  String preparePathInfo() {
    var requestUri = getRequestUri();

    if (requestUri == null || requestUri.isEmpty) {
      return '/';
    }

    var baseUrl = getBaseUrlReal();
    if (baseUrl != null && baseUrl.isNotEmpty) {
      var pathInfo = substring(requestUri, baseUrl.length);
      if (pathInfo.isEmpty || pathInfo[0] != '/') {
        pathInfo = '/$pathInfo';
      }
      return pathInfo;
    }

    return requestUri;
  }

  static void initializeFormats() {
    formats = {
      'html': ['text/html', 'application/xhtml+xml'],
      'txt': ['text/plain'],
      'js': ['application/javascript', 'application/x-javascript', 'text/javascript'],
      'css': ['text/css'],
      'json': ['application/json', 'application/x-json'],
      'jsonld': ['application/ld+json'],
      'xml': ['text/xml', 'application/xml', 'application/x-xml'],
      'rdf': ['application/rdf+xml'],
      'atom': ['application/atom+xml'],
      'rss': ['application/rss+xml'],
      'form': ['application/x-www-form-urlencoded', 'multipart/form-data'],
    };
  }

  void setPhpDefaultLocale(String locale) {
    // This is a no-op in Dart as it doesn't have a direct equivalent to PHP's setlocale
  }

  String? getUrlencodedPrefix(String string, String prefix) {
    if (isIisRewrite()) {
      if (!string.toLowerCase().startsWith(prefix.toLowerCase())) {
        return null;
      }
    } else if (!string.startsWith(prefix)) {
      return null;
    }

    var len = prefix.length;
    var match = RegExp('^((?:%[0-9A-Fa-f]{2}|.){$len})').firstMatch(string);
    return match != null ? match.group(1) : null;
  }

  static Request createRequestFromFactory(
    Map<String, dynamic> query,
    Map<String, dynamic> request,
    Map<String, dynamic> attributes,
    Map<String, dynamic> cookies,
    Map<String, dynamic> files,
    Map<String, dynamic> server,
    [dynamic content]
  ) {
    if (requestFactory != null) {
      var factoryRequest = requestFactory!(query, request, attributes, cookies, files, server, content);
      if (factoryRequest is! Request) {
        throw Exception('The Request factory must return an instance of Symfony\\Component\\HttpFoundation\\Request.');
      }
      return factoryRequest;
    }

    return Request(
      query: query,
      request: request,
      attributes: attributes,
      cookies: cookies,
      files: files,
      server: server,
      content: content,
    );
  }

  bool isFromTrustedProxy() {
    return trustedProxies.isNotEmpty && IpUtils.checkIp(server.get('REMOTE_ADDR', ''), trustedProxies);
  }

  List<String> getTrustedValues(int type, [String? ip]) {
    var cacheKey = '$type${(trustedHeaderSet & type) != 0 ? headers.get(TRUSTED_HEADERS[type]) : ''}$ip${headers.get(TRUSTED_HEADERS[HEADER_FORWARDED])}';

    if (trustedValuesCache.containsKey(cacheKey)) {
      return trustedValuesCache[cacheKey];
    }

    var clientValues = <String>[];
    var forwardedValues = <String>[];

    if ((trustedHeaderSet & type) != 0 && headers.has(TRUSTED_HEADERS[type]!)) {
      clientValues = headers.get(TRUSTED_HEADERS[type]!)!.split(',').map((v) {
        return type == HEADER_X_FORWARDED_PORT ? '0.0.0.0:$v' : v.trim();
      }).toList();
    }

    if ((trustedHeaderSet & HEADER_FORWARDED) != 0 && FORWARDED_PARAMS.containsKey(type) && headers.has(TRUSTED_HEADERS[HEADER_FORWARDED]!)) {
      var forwarded = headers.get(TRUSTED_HEADERS[HEADER_FORWARDED]);
      var parts = HeaderUtils.split(forwarded!, ',;=');
      var param = FORWARDED_PARAMS[type];
      for (var subParts in parts) {
        var combinedParts = HeaderUtils.combine(subParts);
        var v = combinedParts[param];
        if (v == null) {
          continue;
        }
        if (type == HEADER_X_FORWARDED_PORT) {
          if (v.endsWith(']') || !v.contains(':')) {
            v = isSecure() ? ':443' : ':80';
          }
          v = '0.0.0.0$v';
        }
        forwardedValues.add(v);
      }
    }

    if (ip != null) {
      clientValues = normalizeAndFilterClientIps(clientValues, ip);
      forwardedValues = normalizeAndFilterClientIps(forwardedValues, ip);
    }

    if (forwardedValues == clientValues || clientValues.isEmpty) {
      return trustedValuesCache[cacheKey] = forwardedValues;
    }

    if (forwardedValues.isEmpty) {
      return trustedValuesCache[cacheKey] = clientValues;
    }

    if (!isForwardedValid) {
      return trustedValuesCache[cacheKey] = ip != null ? ['0.0.0.0', ip] : [];
    }
    isForwardedValid = false;

    throw Exception('The request has both a trusted "${TRUSTED_HEADERS[HEADER_FORWARDED]}" header and a trusted "${TRUSTED_HEADERS[type]}" header, conflicting with each other. You should either configure your proxy to remove one of them, or configure your project to distrust the offending one.');
  }

  List<String> normalizeAndFilterClientIps(List<String> clientIps, String ip) {
    if (clientIps.isEmpty) {
      return [];
    }
    clientIps.add(ip); // Complete the IP chain with the IP the request actually came from
    String? firstTrustedIp;

    for (var i = 0; i < clientIps.length; i++) {
      var clientIp = clientIps[i];
      if (clientIp.contains('.')) {
        // Strip :port from IPv4 addresses. This is allowed in Forwarded
        // and may occur in X-Forwarded-For.
        var pos = clientIp.indexOf(':');
        if (pos != -1) {
          clientIps[i] = clientIp = clientIp.substring(0, pos);
        }
      } else if (clientIp.startsWith('[')) {
        // Strip brackets and :port from IPv6 addresses.
        var pos = clientIp.indexOf(']', 1);
        clientIps[i] = clientIp = clientIp.substring(1, pos);
      }

      if (!isValidIp(clientIp)) {
        clientIps.removeAt(i);
        i--;
        continue;
      }

      if (IpUtils.checkIp(clientIp, trustedProxies)) {
        clientIps.removeAt(i);
        i--;

        // Fallback to this when the client IP falls into the range of trusted proxies
        firstTrustedIp ??= clientIp;
      }
    }

    // Now the IP chain contains only untrusted proxies and the client IP
    return clientIps.isNotEmpty ? clientIps.reversed.toList() : [if (firstTrustedIp != null) firstTrustedIp];
  }

  bool isIisRewrite() {
    if (server.getInt('IIS_WasUrlRewritten') == 1) {
      isIisRewrite = true;
      server.remove('IIS_WasUrlRewritten');
    }
    return isIisRewrite;
  }

  bool isValidIp(String ip) {
    return RegExp(r'^(\d{1,3}\.){3}\d{1,3}$').hasMatch(ip) || RegExp(r'^[0-9a-fA-F:]+$').hasMatch(ip);
  }
}
