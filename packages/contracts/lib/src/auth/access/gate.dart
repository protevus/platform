// import 'package:meta/meta.dart';

abstract class Gate {
  /// Determine if a given ability has been defined.
  bool has(String ability);

  /// Define a new ability.
  Gate define(String ability, dynamic callback);

  /// Define abilities for a resource.
  Gate resource(String name, String className, [List<String>? abilities]);

  /// Define a policy class for a given class type.
  Gate policy(String className, String policy);

  /// Register a callback to run before all Gate checks.
  Gate before(Function callback);

  /// Register a callback to run after all Gate checks.
  Gate after(Function callback);

  /// Determine if all of the given abilities should be granted for the current user.
  bool allows(dynamic ability, [dynamic arguments]);

  /// Determine if any of the given abilities should be denied for the current user.
  bool denies(dynamic ability, [dynamic arguments]);

  /// Determine if all of the given abilities should be granted for the current user.
  bool check(dynamic abilities, [dynamic arguments]);

  /// Determine if any one of the given abilities should be granted for the current user.
  bool any(dynamic abilities, [dynamic arguments]);

  /// Determine if the given ability should be granted for the current user.
  dynamic authorize(String ability, [dynamic arguments]);

  /// Inspect the user for the given ability.
  dynamic inspect(String ability, [dynamic arguments]);

  /// Get the raw result from the authorization callback.
  dynamic raw(String ability, [dynamic arguments]);

  /// Get a policy instance for a given class.
  dynamic getPolicyFor(dynamic className);

  /// Get a guard instance for the given user.
  Gate forUser(dynamic user);

  /// Get all of the defined abilities.
  List<String> abilities();
}
