import 'dart:async';

import 'package:platform_foundation/core.dart';
import 'auth_token.dart';

typedef PlatformAuthCallback = FutureOr Function(
    RequestContext req, ResponseContext res, String token);

typedef PlatformAuthTokenCallback<User> = FutureOr Function(
    RequestContext req, ResponseContext res, AuthToken token, User user);

class PlatformAuthOptions<User> {
  PlatformAuthCallback? callback;
  PlatformAuthTokenCallback<User>? tokenCallback;
  String? successRedirect;
  String? failureRedirect;

  /// If `false` (default: `true`), then successful authentication will return `true` and allow the
  /// execution of subsequent handlers, just like any other middleware.
  ///
  /// Works well with `Basic` authentication.
  bool canRespondWithJson;

  PlatformAuthOptions(
      {this.callback,
      this.tokenCallback,
      this.canRespondWithJson = true,
      this.successRedirect,
      this.failureRedirect});
}
