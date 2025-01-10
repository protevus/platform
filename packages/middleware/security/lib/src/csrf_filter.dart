import 'dart:async';
import 'package:platform_foundation/core.dart';
import 'cookie_signer.dart';

class CsrfToken {
  final String value;

  CsrfToken(this.value);
}

class CsrfFilter {
  final CookieSigner cookieSigner;

  CsrfFilter(this.cookieSigner);

  Future<CsrfToken> readCsrfToken(RequestContext req) async {
    // TODO: To be reviewed
    return CsrfToken(req.hostname);
  }
}
