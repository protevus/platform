/// Interface for authorization capabilities.
///
/// This contract defines how an entity can be checked for specific abilities
/// or permissions. It's typically implemented by user models to provide
/// authorization functionality.
abstract class Authorizable {
  /// Determine if the entity has a given ability.
  ///
  /// Example:
  /// ```dart
  /// class User implements Authorizable {
  ///   @override
  ///   Future<bool> can(dynamic abilities, [dynamic arguments = const []]) async {
  ///     if (abilities is String) {
  ///       // Check single ability
  ///       return await checkAbility(abilities, arguments);
  ///     } else if (abilities is Iterable) {
  ///       // Check multiple abilities
  ///       for (var ability in abilities) {
  ///         if (!await checkAbility(ability, arguments)) {
  ///           return false;
  ///         }
  ///       }
  ///       return true;
  ///     }
  ///     return false;
  ///   }
  /// }
  ///
  /// // Usage
  /// if (await user.can('edit-post', post)) {
  ///   // User can edit the post
  /// }
  ///
  /// if (await user.can(['edit-post', 'delete-post'], post)) {
  ///   // User can both edit and delete the post
  /// }
  /// ```
  Future<bool> can(dynamic abilities, [dynamic arguments = const []]);
}
