import 'dart:io';
import '../auth/auth_interface.dart';

abstract class RequestInterface {
  late Uri uri;
  String method = 'GET';
  HttpRequest get httpRequest;
  ContentType? get contentType;
  String getRouteIdentifier();
  dynamic getRouteData();
  Map<String, dynamic> get headers;
  String? header(String key);
  void add(String key, dynamic value);
  void merge(Map<String, dynamic> values);
  dynamic input(String key);
  bool isFormData();
  bool isJson();
  Map<String, dynamic> all();
  Map<String, dynamic> only(List<String> keys);
  String ip();
  AuthInterface? get auth;
  bool has(String key);
  String? cookie(String key, {bool decrypt = true});
  String userAgent();
  String host();
  String? origin();
  String? referer();
  void validate(Map<String, String> rules,
      {Map<String, String> messages = const <String, String>{}});
  void processInputMapper(Map<String, String> mapper);
  Map<String, dynamic> toJson();
}
