/// A minimal interface for reading the current time.
///
/// This interface follows PSR-20 Clock Interface specification.
abstract class ClockInterface {
  /// Returns the current time as a DateTime instance.
  ///
  /// The returned DateTime MUST be an immutable value object.
  /// The timezone of the returned value is not guaranteed and should not be relied upon.
  DateTime now();
}
