import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_http/http.dart';
import 'package:test/test.dart';

import '../integration/requirements/config/app.dart';

void main() {
  group('DoxCookie |', () {
    test('get', () {
      Application().config = config;
      DoxCookie cookie = DoxCookie('x-auth', 'Bearerxxxxxxxxx');
      String cookieValue = cookie.get();
      expect(cookieValue,
          'x-auth=EzBl7TV9yA+U1lLsyfMgTPjbCRh/5FQOODjbEwej58Y=; Max-Age=3600000');
    });

    test('expire', () {
      Application().config = config;
      DoxCookie cookie = DoxCookie('x-auth', '');
      String cookieValue = cookie.expire();
      expect(cookieValue, 'x-auth=; Max-Age=-1000');
    });
  });
}
