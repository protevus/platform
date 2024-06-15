import 'authenticatable.dart';
abstract class Guard {
  /// Determine if the current user is authenticated.
  ///
  /// @return bool
  bool check();

  /// Determine if the current user is a guest.
  ///
  /// @return bool
  bool guest();

  /// Get the currently authenticated user.
  ///
  /// @return Authenticatable|null
  Authenticatable? user();

  /// Get the ID for the currently authenticated user.
  ///
  /// @return int|string|null
  dynamic id();

  /// Validate a user's credentials.
  ///
  /// @param  Map<String, dynamic>  credentials
  /// @return bool
  bool validate(Map<String, dynamic> credentials);

  /// Determine if the guard has a user instance.
  ///
  /// @return bool
  bool hasUser();

  /// Set the current user.
  ///
  /// @param  Authenticatable  user
  /// @return Guard
  Guard setUser(Authenticatable user);
}

//abstract class Authenticatable {
//  String getIdentifier();
//}
