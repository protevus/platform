import 'dart:async';
import 'dart:io';

import 'package:illuminate_http/http.dart' show Request, Response, DoxCookie;
import 'package:illuminate_contracts/contracts.dart';
import 'package:uuid/uuid.dart';

import '../config/session_config.dart';
import '../http/platform_http_session.dart';
import '../session_manager.dart';
import '../session_store.dart';

/// Extension to add session support to request
extension SessionRequestContext on Request {
  static final _sessions = Expando<HttpSession>('session');

  HttpSession? get platformSession => _sessions[this];
  set platformSession(HttpSession? value) => _sessions[this] = value;
}

/// Creates session middleware with the given configuration.
Future<bool> Function(Request, Response) session(
  SessionManager manager,
  SessionConfig config,
) {
  final uuid = const Uuid();

  return (Request request, Response response) async {
    // Get session ID from cookie
    var sessionCookie = request.httpRequest.cookies.firstWhere(
      (cookie) => cookie.name == config.cookieName,
      orElse: () => Cookie(config.cookieName, ''),
    );
    var id = sessionCookie.value.isNotEmpty ? sessionCookie.value : null;
    SessionStore? store;

    // Validate and load existing session
    if (id != null && _isValidId(id)) {
      store = manager.getSession(id);
      if (store != null) {
        await store.start();
      }
    }

    // Create new session if needed
    store ??= await manager.createSession();
    id = store.id;

    // Set session cookie
    final cookie = Cookie(config.cookieName, id)
      ..path = config.path
      ..secure = config.secure
      ..httpOnly = config.httpOnly
      ..maxAge = config.lifetime * 60; // Convert minutes to seconds

    if (config.domain != null) {
      cookie.domain = config.domain;
    }

    response.cookie(DoxCookie(cookie.name, cookie.value)
      ..path = cookie.path
      ..secure = cookie.secure
      ..httpOnly = cookie.httpOnly
      ..maxAge = Duration(seconds: cookie.maxAge ?? 0)
      ..domain = cookie.domain);

    // Create and attach platform session
    final platformSession = PlatformHttpSession(store);
    request.platformSession = platformSession;

    // Save session data when response is complete
    if (request.httpRequest.response.connectionInfo?.remoteAddress.isLoopback !=
        true) {
      await store.save();
    }

    return true;
  };
}

/// Validates a session ID.
bool _isValidId(String id) {
  try {
    return id.length == 36 && Uuid.isValidUUID(fromString: id);
  } catch (_) {
    return false;
  }
}
