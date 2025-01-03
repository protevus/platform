/// Flutter-compatible client library for the Angel framework.
library angel_client.flutter;

import 'dart:async';
import 'package:http/http.dart' as http;
import 'base_platform_client.dart';
export 'platform_client.dart';

/// Queries an Angel server via REST.
class Rest extends BaseAngelClient {
  Rest(String basePath) : super(http.Client() as http.BaseClient, basePath);

  @override
  Stream<String> authenticateViaPopup(String url,
      {String eventName = 'token'}) {
    throw UnimplementedError(
        'Opening popup windows is not supported in the `flutter` client.');
  }
}
