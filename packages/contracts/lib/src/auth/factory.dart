//import 'package:your_project_path/contracts/auth/guard.dart';
//import 'package:your_project_path/contracts/auth/stateful_guard.dart';
import 'package:protevus_contracts/auth.dart';

abstract class Factory {
  /// Get a guard instance by name.
  ///
  /// @param [name] The name of the guard instance to retrieve.
  /// @return An instance of [Guard] or [StatefulGuard].
  Guard guard(String? name);

  /// Set the default guard the factory should serve.
  ///
  /// @param [name] The name of the default guard.
  void shouldUse(String name);
}
