import '../http/request_interface.dart';

abstract class AuthInterface {
  Future<void> verifyToken(RequestInterface req);
  bool isLoggedIn();
  T? user<T>();
  Map<String, dynamic>? toJson();
}
