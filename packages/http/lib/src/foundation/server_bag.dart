import 'dart:collection';
import 'dart:convert';
import 'package:protevus_http/foundation.dart';
import 'package:protevus_http/src/foundation/parameter_bag.dart';

/// ServerBag is a container for HTTP headers from the server environment.
///
/// This class extends ParameterBag and provides functionality to handle
/// HTTP headers, including special cases for authentication headers.
class ServerBag extends ParameterBag
    with IterableMixin<MapEntry<String, dynamic>> {
  final Map<String, dynamic> _parameters;

  /// Creates a new ServerBag instance.
  ///
  /// The constructor takes a map of server parameters and initializes
  /// the ParameterBag with these parameters.
  ServerBag([Map<String, dynamic> parameters = const {}])
      : _parameters = Map<String, dynamic>.from(parameters),
        super();

  // Override the getter from ParameterBag
  @override
  Map<String, dynamic> get parameters => _parameters;

  /// Gets the HTTP headers from the server parameters.
  ///
  /// This method processes the server parameters to extract and normalize
  /// HTTP headers, including special handling for authentication headers.
  ///
  /// Returns:
  ///   A Map<String, String> containing the extracted HTTP headers.
  Map<String, String> getHeaders() {
    var headers = <String, String>{};

    parameters.forEach((key, value) {
      if (key.startsWith('HTTP_')) {
        headers[key.substring(5)] = value.toString();
      } else if (['CONTENT_TYPE', 'CONTENT_LENGTH', 'CONTENT_MD5']
              .contains(key) &&
          value.toString().isNotEmpty) {
        headers[key] = value.toString();
      }
    });

    if (parameters.containsKey('PHP_AUTH_USER')) {
      headers['PHP_AUTH_USER'] = parameters['PHP_AUTH_USER'].toString();
      headers['PHP_AUTH_PW'] = parameters['PHP_AUTH_PW']?.toString() ?? '';
    } else {
      String? authorizationHeader;
      if (parameters.containsKey('HTTP_AUTHORIZATION')) {
        authorizationHeader = parameters['HTTP_AUTHORIZATION'].toString();
      } else if (parameters.containsKey('REDIRECT_HTTP_AUTHORIZATION')) {
        authorizationHeader =
            parameters['REDIRECT_HTTP_AUTHORIZATION'].toString();
      }

      if (authorizationHeader != null) {
        if (authorizationHeader.toLowerCase().startsWith('basic ')) {
          // Decode AUTHORIZATION header into PHP_AUTH_USER and PHP_AUTH_PW
          var decoded =
              utf8.decode(base64.decode(authorizationHeader.substring(6)));
          var exploded = decoded.split(':');
          if (exploded.length == 2) {
            headers['PHP_AUTH_USER'] = exploded[0];
            headers['PHP_AUTH_PW'] = exploded[1];
          }
        } else if (!parameters.containsKey('PHP_AUTH_DIGEST') &&
            authorizationHeader.toLowerCase().startsWith('digest ')) {
          headers['PHP_AUTH_DIGEST'] = authorizationHeader;
          parameters['PHP_AUTH_DIGEST'] = authorizationHeader;
        } else if (authorizationHeader.toLowerCase().startsWith('bearer ')) {
          headers['AUTHORIZATION'] = authorizationHeader;
        }
      }
    }

    if (headers.containsKey('AUTHORIZATION')) {
      return headers;
    }

    // PHP_AUTH_USER/PHP_AUTH_PW
    if (headers.containsKey('PHP_AUTH_USER')) {
      var authUser = headers['PHP_AUTH_USER']!;
      var authPw = headers['PHP_AUTH_PW'] ?? '';
      headers['AUTHORIZATION'] =
          'Basic ${base64.encode(utf8.encode('$authUser:$authPw'))}';
    } else if (headers.containsKey('PHP_AUTH_DIGEST')) {
      headers['AUTHORIZATION'] = headers['PHP_AUTH_DIGEST']!;
    }

    return headers;
  }
}
