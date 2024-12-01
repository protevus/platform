/// Interface for commands that prompt for missing input.
///
/// This contract serves as a marker interface for console commands that should
/// prompt for missing input arguments or options. While it doesn't define any
/// methods, implementing this interface signals that the command should
/// interactively prompt the user when required input is missing.
///
/// Example:
/// ```dart
/// class CreateUserCommand implements PromptsForMissingInput {
///   Future<void> handle() async {
///     // Command will prompt for missing input
///   }
/// }
/// ```
abstract class PromptsForMissingInput {}
