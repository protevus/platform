import 'authenticatable.dart';
import  'guard.dart';

abstract class StatefulGuard extends Guard {
  /// Attempt to authenticate a user using the given credentials.
  ///
  /// [credentials] are the user's credentials.
  /// [remember] indicates if the user should be remembered.
  /// Returns true if authentication was successful.
  Future<bool> attempt(Map<String, dynamic> credentials, {bool remember = false});

  /// Log a user into the application without sessions or cookies.
  ///
  /// [credentials] are the user's credentials.
  /// Returns true if authentication was successful.
  Future<bool> once(Map<String, dynamic> credentials);

  /// Log a user into the application.
  ///
  /// [user] is the user to log in.
  /// [remember] indicates if the user should be remembered.
  void login(Authenticatable user, {bool remember = false});

  /// Log the given user ID into the application.
  ///
  /// [id] is the ID of the user.
  /// [remember] indicates if the user should be remembered.
  /// Returns the authenticated user or false if authentication failed.
  Future<Authenticatable?> loginUsingId(dynamic id, {bool remember = false});

  /// Log the given user ID into the application without sessions or cookies.
  ///
  /// [id] is the ID of the user.
  /// Returns the authenticated user or false if authentication failed.
  Future<Authenticatable?> onceUsingId(dynamic id);

  /// Determine if the user was authenticated via "remember me" cookie.
  ///
  /// Returns true if authenticated via "remember me" cookie.
  bool viaRemember();

  /// Log the user out of the application.
  void logout();
}
