import 'package:symfony_http_foundation/symfony_http_foundation.dart';

// TODO: Replace missing import with dart equivelant.

abstract class Factory {
  /// Create a new cookie instance.
  ///
  /// @param  String  name
  /// @param  String  value
  /// @param  int  minutes
  /// @param  String?  path
  /// @param  String?  domain
  /// @param  bool?  secure
  /// @param  bool  httpOnly
  /// @param  bool  raw
  /// @param  String?  sameSite
  /// @return Cookie
  Cookie make(String name, String value, {int minutes = 0, String? path, String? domain, bool? secure, bool httpOnly = true, bool raw = false, String? sameSite});

  /// Create a cookie that lasts "forever" (five years).
  ///
  /// @param  String  name
  /// @param  String  value
  /// @param  String?  path
  /// @param  String?  domain
  /// @param  bool?  secure
  /// @param  bool  httpOnly
  /// @param  bool  raw
  /// @param  String?  sameSite
  /// @return Cookie
  Cookie forever(String name, String value, {String? path, String? domain, bool? secure, bool httpOnly = true, bool raw = false, String? sameSite});

  /// Expire the given cookie.
  ///
  /// @param  String  name
  /// @param  String?  path
  /// @param  String?  domain
  /// @return Cookie
  Cookie forget(String name, {String? path, String? domain});
}
