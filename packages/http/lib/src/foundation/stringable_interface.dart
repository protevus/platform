/// Abstract class representing a Stringable object.
///
/// This class is the Dart equivalent of PHP's Stringable interface.
/// Classes that implement this abstract class must provide an implementation
/// for the toString() method.
abstract class Stringable {
  /// Converts the object to its string representation.
  ///
  /// This method should be implemented by any class that wants to be Stringable.
  /// It's the equivalent of PHP's __toString() magic method.
  ///
  /// Returns:
  /// A string representation of the object.
  @override
  String toString();
}
