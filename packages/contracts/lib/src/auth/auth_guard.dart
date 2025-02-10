import './auth_driver.dart';
import './auth_provider.dart';

class AuthGuard {
  final AuthDriver driver;
  final AuthProvider provider;

  const AuthGuard({
    required this.driver,
    required this.provider,
  });
}
