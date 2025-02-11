import 'package:illuminate_cookie/cookie.dart';

void main() {
  // Create a CookieJar instance
  final cookieJar = CookieJar(
    domain: 'example.com',
    secure: true,
    httpOnly: true,
    sameSite: 'Lax',
  );

  // Example 1: Create a simple cookie
  final simpleCookie = cookieJar.make('simple_cookie', 'Hello, Protevus!');
  print('Simple Cookie: $simpleCookie');

  // Example 2: Create a cookie with custom options
  final customCookie = cookieJar.make(
    'custom_cookie',
    'Custom Value',
    path: '/admin',
    minutes: 60,
    httpOnly: false,
  );
  print('Custom Cookie: $customCookie');

  // Example 3: Queue a cookie
  cookieJar.queue('queued_cookie', 'Queued Value', {'minutes': 30});
  print('Has Queued Cookie: ${cookieJar.hasQueued('queued_cookie')}');

  // Example 4: Get all queued cookies
  final queuedCookies = cookieJar.getQueuedCookies();
  print('Queued Cookies: $queuedCookies');

  // Example 5: Unqueue a cookie
  cookieJar.unqueue('queued_cookie');
  print(
      'Has Queued Cookie after unqueue: ${cookieJar.hasQueued('queued_cookie')}');

  // Example 6: Using CookieValuePrefix
  final cookieName = 'prefixed_cookie';
  final cookieValue = 'Prefixed Value';
  final key = 'secret_key';

  final prefix = CookieValuePrefix.create(cookieName, key);
  final prefixedValue = '$prefix$cookieValue';

  print('Prefixed Cookie Value: $prefixedValue');

  // Example 7: Validating and removing prefix
  final validatedValue =
      CookieValuePrefix.validate(cookieName, prefixedValue, [key]);
  print('Validated Cookie Value: $validatedValue');

  // Example 8: Creating a cookie with raw value
  final rawCookie =
      cookieJar.make('raw_cookie', 'Raw Value with spaces', raw: true);
  print('Raw Cookie: $rawCookie');

  // Example 9: Creating a cookie with encoded value
  final encodedCookie =
      cookieJar.make('encoded_cookie', 'Encoded Value with spaces');
  print('Encoded Cookie: $encodedCookie');
}
