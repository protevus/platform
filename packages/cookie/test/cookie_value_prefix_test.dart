import 'package:test/test.dart';
import 'package:illuminate_cookie/src/cookie_value_prefix.dart';

void main() {
  group('CookieValuePrefix', () {
    test('create returns a valid prefix', () {
      final prefix = CookieValuePrefix.create('cookieName', 'secret');
      expect(prefix, hasLength(41));
      expect(prefix, endsWith('|'));
    });

    test('remove strips the prefix', () {
      const value = 'prefixValue|actualValue';
      expect(CookieValuePrefix.remove(value), equals('actualValue'));
    });

    test('validate returns the value without prefix for a valid cookie', () {
      const cookieName = 'testCookie';
      const key = 'secret';
      final prefix = CookieValuePrefix.create(cookieName, key);
      final cookieValue = '${prefix}actualValue';

      final result = CookieValuePrefix.validate(cookieName, cookieValue, [key]);
      expect(result, equals('actualValue'));
    });

    test('validate returns null for an invalid cookie', () {
      const cookieName = 'testCookie';
      const key = 'secret';
      const cookieValue = 'invalidPrefix|actualValue';

      final result = CookieValuePrefix.validate(cookieName, cookieValue, [key]);
      expect(result, isNull);
    });

    test('validate checks multiple keys', () {
      const cookieName = 'testCookie';
      const key1 = 'secret1';
      const key2 = 'secret2';
      final prefix = CookieValuePrefix.create(cookieName, key2);
      final cookieValue = '${prefix}actualValue';

      final result =
          CookieValuePrefix.validate(cookieName, cookieValue, [key1, key2]);
      expect(result, equals('actualValue'));
    });
  });
}
