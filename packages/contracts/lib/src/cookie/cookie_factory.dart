/// Interface for cookie factory.
///
/// This contract defines the standard way to create cookie instances
/// in the application. It provides methods to create and expire cookies
/// with various attributes.
abstract class CookieFactory {
  /// Create a new cookie instance.
  ///
  /// Example:
  /// ```dart
  /// var cookie = cookies.make(
  ///   'preferences',
  ///   'theme=dark',
  ///   minutes: 60,
  ///   secure: true,
  ///   sameSite: 'Lax'
  /// );
  /// ```
  dynamic make(
    String name,
    String value, {
    int minutes = 0,
    String? path,
    String? domain,
    bool? secure,
    bool httpOnly = true,
    bool raw = false,
    String? sameSite,
  });

  /// Create a cookie that lasts "forever" (five years).
  ///
  /// Example:
  /// ```dart
  /// var cookie = cookies.forever(
  ///   'user_id',
  ///   '12345',
  ///   secure: true,
  ///   sameSite: 'Strict'
  /// );
  /// ```
  dynamic forever(
    String name,
    String value, {
    String? path,
    String? domain,
    bool? secure,
    bool httpOnly = true,
    bool raw = false,
    String? sameSite,
  });

  /// Expire the given cookie.
  ///
  /// Creates a new cookie instance that will expire the cookie
  /// when sent to the browser.
  ///
  /// Example:
  /// ```dart
  /// var cookie = cookies.forget('session_id');
  /// ```
  dynamic forget(
    String name, {
    String? path,
    String? domain,
  });
}
