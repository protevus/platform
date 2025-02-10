# Platform Cookie

A Dart implementation of Laravel-inspired cookie management for the Protevus platform.

## Features

- Create and manage cookies with various options (domain, path, secure, httpOnly, sameSite, etc.)
- Queue and unqueue cookies
- Handle cookie value prefixes
- Proper encoding of cookie values
- Expiration time handling

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  platform_cookie: ^1.0.0
```

Then run:

```
dart pub get
```

## Usage

Here's a basic example of how to use the `CookieJar` class:

```dart
import 'package:platform_cookie/platform_cookie.dart';

void main() {
  final cookieJar = CookieJar(
    domain: 'example.com',
    secure: true,
    httpOnly: true,
    sameSite: 'Lax',
  );

  // Create a simple cookie
  final simpleCookie = cookieJar.make('simple_cookie', 'Hello, Protevus!');
  print('Simple Cookie: $simpleCookie');

  // Create a cookie with custom options
  final customCookie = cookieJar.make(
    'custom_cookie',
    'Custom Value',
    path: '/admin',
    minutes: 60,
    httpOnly: false,
  );
  print('Custom Cookie: $customCookie');

  // Queue a cookie
  cookieJar.queue('queued_cookie', 'Queued Value', {'minutes': 30});
  print('Has Queued Cookie: ${cookieJar.hasQueued('queued_cookie')}');

  // Get all queued cookies
  final queuedCookies = cookieJar.getQueuedCookies();
  print('Queued Cookies: $queuedCookies');

  // Unqueue a cookie
  cookieJar.unqueue('queued_cookie');
  print('Has Queued Cookie after unqueue: ${cookieJar.hasQueued('queued_cookie')}');

  // Using CookieValuePrefix
  final cookieName = 'prefixed_cookie';
  final cookieValue = 'Prefixed Value';
  final key = 'secret_key';

  final prefix = CookieValuePrefix.create(cookieName, key);
  final prefixedValue = '$prefix$cookieValue';

  print('Prefixed Cookie Value: $prefixedValue');

  // Validating and removing prefix
  final validatedValue = CookieValuePrefix.validate(cookieName, prefixedValue, [key]);
  print('Validated Cookie Value: $validatedValue');
}
```

For more detailed examples, check the `example` folder in the package repository.

## Testing

To run the tests for this package, use the following command:

```
dart test
```

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

## License

This project is licensed under the MIT License.
