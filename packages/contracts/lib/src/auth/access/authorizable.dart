abstract class Authorizable {
  /// Determine if the entity has a given ability.
  ///
  /// [abilities] can be an Iterable or a String.
  /// [arguments] can be a List or a dynamic type.
  ///
  /// Returns a boolean indicating if the entity has the given ability.
  bool can(dynamic abilities, [List<dynamic> arguments = const []]);
}
