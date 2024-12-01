/// Interface for console command kernel.
///
/// This contract defines how console commands should be handled and managed.
/// It provides methods for bootstrapping, handling commands, and managing
/// command output.
abstract class ConsoleKernel {
  /// Bootstrap the application for artisan commands.
  ///
  /// Example:
  /// ```dart
  /// await kernel.bootstrap();
  /// ```
  Future<void> bootstrap();

  /// Handle an incoming console command.
  ///
  /// Example:
  /// ```dart
  /// var status = await kernel.handle(input, output);
  /// ```
  Future<int> handle(dynamic input, [dynamic output]);

  /// Run an Artisan console command by name.
  ///
  /// Example:
  /// ```dart
  /// var status = await kernel.call('migrate', ['--force']);
  /// ```
  Future<int> call(String command,
      [List<String> parameters = const [], dynamic outputBuffer]);

  /// Queue an Artisan console command by name.
  ///
  /// Example:
  /// ```dart
  /// var dispatch = await kernel.queue('email:send', ['user@example.com']);
  /// ```
  Future<dynamic> queue(String command, [List<String> parameters = const []]);

  /// Get all of the commands registered with the console.
  ///
  /// Example:
  /// ```dart
  /// var commands = kernel.all();
  /// ```
  Map<String, dynamic> all();

  /// Get the output for the last run command.
  ///
  /// Example:
  /// ```dart
  /// var lastOutput = kernel.output();
  /// ```
  String output();

  /// Terminate the application.
  ///
  /// Example:
  /// ```dart
  /// await kernel.terminate(input, 0);
  /// ```
  Future<void> terminate(dynamic input, int status);
}
