abstract class CanBeEscapedWhenCastToString {
  /// Indicate that the object's string representation should be escaped when toString is invoked.
  ///
  /// @param bool escape
  /// @return this
  CanBeEscapedWhenCastToString escapeWhenCastingToString(bool escape);
}
