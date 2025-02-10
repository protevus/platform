import './auth_guard.dart';

class AuthConfig {
  final String defaultGuard;
  final Map<String, AuthGuard> guards;

  AuthConfig({
    required this.defaultGuard,
    this.guards = const <String, AuthGuard>{},
  });
}
