abstract class Castable {
  /// Get the name of the caster class to use when casting from / to this cast target.
  ///
  /// @param  List  arguments
  /// @return Type
  static Type castUsing(List arguments);
}
