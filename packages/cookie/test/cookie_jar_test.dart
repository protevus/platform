import 'package:test/test.dart';
import 'package:illuminate_cookie/src/cookie_jar.dart';

void main() {
  group('CookieJar', () {
    late CookieJar cookieJar;

    setUp(() {
      cookieJar = CookieJar();
    });

    test('make creates a cookie with default values', () {
      final cookie = cookieJar.make('name', 'value');
      expect(cookie['name'], equals('name'));
      expect(cookie['value'], equals('value'));
      expect(cookie['path'], equals('/'));
      expect(cookie['secure'], equals('false'));
      expect(cookie['httponly'], equals('true'));
    });

    test('make creates a cookie with custom values', () {
      final cookie = cookieJar.make('name', 'value',
          domain: 'example.com',
          path: '/custom',
          secure: true,
          httpOnly: false,
          sameSite: 'Strict');
      expect(cookie['name'], equals('name'));
      expect(cookie['value'], equals('value'));
      expect(cookie['domain'], equals('example.com'));
      expect(cookie['path'], equals('/custom'));
      expect(cookie['secure'], equals('true'));
      expect(cookie['httponly'], equals('false'));
      expect(cookie['samesite'], equals('Strict'));
    });

    test('queue adds a cookie to the queue', () {
      cookieJar.queue('name', 'value');
      expect(cookieJar.hasQueued('name'), isTrue);
    });

    test('unqueue removes a cookie from the queue', () {
      cookieJar.queue('name', 'value');
      cookieJar.unqueue('name');
      expect(cookieJar.hasQueued('name'), isFalse);
    });

    test('getQueuedCookies returns all queued cookies', () {
      cookieJar.queue('name1', 'value1');
      cookieJar.queue('name2', 'value2');
      final queuedCookies = cookieJar.getQueuedCookies();
      expect(queuedCookies.length, equals(2));
      expect(queuedCookies['name1']?['value'], equals('value1'));
      expect(queuedCookies['name2']?['value'], equals('value2'));
    });

    test('make encodes value when raw is false', () {
      final cookie = cookieJar.make('name', 'value with spaces');
      expect(cookie['value'], equals('value%20with%20spaces'));
    });

    test('make does not encode value when raw is true', () {
      final cookie = cookieJar.make('name', 'value with spaces', raw: true);
      expect(cookie['value'], equals('value with spaces'));
    });

    test('make sets expiration time when minutes are provided', () {
      final cookie = cookieJar.make('name', 'value', minutes: 30);
      expect(cookie['expires'], isNotEmpty);
    });
  });
}
