/// Interface for console application.
///
/// This contract defines how console commands should be executed and
/// their output managed at the application level.
abstract class ConsoleApplication {
  /// Run an Artisan console command by name.
  ///
  /// Example:
  /// ```dart
  /// var status = await app.call('migrate', ['--force']);
  /// ```
  Future<int> call(String command,
      [List<String> parameters = const [], dynamic outputBuffer]);

  /// Get the output from the last command.
  ///
  /// Example:
  /// ```dart
  /// var lastOutput = app.output();
  /// ```
  String output();
}
