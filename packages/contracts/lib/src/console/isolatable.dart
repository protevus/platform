/// Interface for console commands that can be run in isolation.
///
/// This contract serves as a marker interface for console commands that can
/// be run in isolation. While it doesn't define any methods, implementing
/// this interface signals that the command can be safely executed in an
/// isolated environment.
///
/// Example:
/// ```dart
/// class ImportDataCommand implements Isolatable {
///   Future<void> handle() async {
///     // Command can be run in isolation
///   }
/// }
/// ```
abstract class Isolatable {}
