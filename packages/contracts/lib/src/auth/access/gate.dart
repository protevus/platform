/// Interface for authorization management.
///
/// This contract defines how authorization rules and policies should be managed
/// and checked. It provides methods for defining abilities, registering policies,
/// and performing authorization checks.
abstract class Gate {
  /// Determine if a given ability has been defined.
  ///
  /// Example:
  /// ```dart
  /// if (gate.has('edit-posts')) {
  ///   print('Edit posts ability is defined');
  /// }
  /// ```
  bool has(String ability);

  /// Define a new ability.
  ///
  /// Example:
  /// ```dart
  /// gate.define('edit-post', (user, post) async {
  ///   return post.userId == user.id;
  /// });
  /// ```
  Gate define(String ability, Function callback);

  /// Define abilities for a resource.
  ///
  /// Example:
  /// ```dart
  /// gate.resource('posts', Post, {
  ///   'view': (user, post) async => true,
  ///   'create': (user) async => user.isAdmin,
  ///   'update': (user, post) async => post.userId == user.id,
  ///   'delete': (user, post) async => user.isAdmin,
  /// });
  /// ```
  Gate resource(String name, Type resourceClass,
      [Map<String, Function>? abilities]);

  /// Define a policy class for a given class type.
  ///
  /// Example:
  /// ```dart
  /// gate.policy(Post, PostPolicy);
  /// ```
  Gate policy(Type class_, Type policy);

  /// Register a callback to run before all Gate checks.
  ///
  /// Example:
  /// ```dart
  /// gate.before((user, ability) {
  ///   if (user.isAdmin) return true;
  /// });
  /// ```
  Gate before(Function callback);

  /// Register a callback to run after all Gate checks.
  ///
  /// Example:
  /// ```dart
  /// gate.after((user, ability, result, arguments) {
  ///   logAuthCheck(user, ability, result);
  /// });
  /// ```
  Gate after(Function callback);

  /// Determine if all of the given abilities should be granted for the current user.
  ///
  /// Example:
  /// ```dart
  /// if (await gate.allows('edit-post', [post])) {
  ///   // User can edit the post
  /// }
  /// ```
  Future<bool> allows(dynamic ability, [dynamic arguments = const []]);

  /// Determine if any of the given abilities should be denied for the current user.
  ///
  /// Example:
  /// ```dart
  /// if (await gate.denies('edit-post', [post])) {
  ///   // User cannot edit the post
  /// }
  /// ```
  Future<bool> denies(dynamic ability, [dynamic arguments = const []]);

  /// Determine if all of the given abilities should be granted for the current user.
  ///
  /// Example:
  /// ```dart
  /// if (await gate.check(['edit-post', 'delete-post'], [post])) {
  ///   // User can both edit and delete the post
  /// }
  /// ```
  Future<bool> check(dynamic abilities, [dynamic arguments = const []]);

  /// Determine if any one of the given abilities should be granted for the current user.
  ///
  /// Example:
  /// ```dart
  /// if (await gate.any(['edit-post', 'view-post'], [post])) {
  ///   // User can either edit or view the post
  /// }
  /// ```
  Future<bool> any(dynamic abilities, [dynamic arguments = const []]);

  /// Determine if the given ability should be granted for the current user.
  ///
  /// Example:
  /// ```dart
  /// if (await gate.authorize('edit-post', [post])) {
  ///   // User is authorized to edit the post
  /// }
  /// ```
  Future<bool> authorize(String ability, [dynamic arguments = const []]);

  /// Inspect the user for the given ability.
  ///
  /// Example:
  /// ```dart
  /// if (await gate.inspect('edit-post', [post])) {
  ///   // User has the ability to edit the post
  /// }
  /// ```
  Future<bool> inspect(String ability, [dynamic arguments = const []]);

  /// Get the raw result from the authorization callback.
  ///
  /// Example:
  /// ```dart
  /// var result = await gate.raw('edit-post', [post]);
  /// ```
  Future<dynamic> raw(String ability, [dynamic arguments = const []]);

  /// Get a policy instance for a given class.
  ///
  /// Example:
  /// ```dart
  /// var policy = gate.getPolicyFor(Post);
  /// ```
  dynamic getPolicyFor(dynamic class_);

  /// Get a gate instance for the given user.
  ///
  /// Example:
  /// ```dart
  /// var userGate = gate.forUser(user);
  /// ```
  Gate forUser(dynamic user);

  /// Get all of the defined abilities.
  ///
  /// Example:
  /// ```dart
  /// var abilities = gate.abilities();
  /// print('Defined abilities: ${abilities.keys.join(', ')}');
  /// ```
  Map<String, Function> abilities();
}
