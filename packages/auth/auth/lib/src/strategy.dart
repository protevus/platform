import 'dart:async';
import 'package:platform_foundation/core.dart';
import 'options.dart';

/// A function that handles login and signup for an Angel application.
abstract class AuthStrategy<User> {
  /// Authenticates or rejects an incoming user.
  FutureOr<User?> authenticate(RequestContext req, ResponseContext res,
      [PlatformAuthOptions<User>? options]);
}
