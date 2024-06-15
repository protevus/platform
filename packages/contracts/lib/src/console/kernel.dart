import 'package:symfony_console/symfony_console.dart';

// TODO: Replace missing imports with dart equivalents.

abstract class Kernel {
  /// Bootstrap the application for artisan commands.
  void bootstrap();

  /// Handle an incoming console command.
  ///
  /// @param InputInterface input
  /// @param OutputInterface? output
  /// @return int
  int handle(InputInterface input, [OutputInterface? output]);

  /// Run an Artisan console command by name.
  ///
  /// @param String command
  /// @param List<dynamic> parameters
  /// @param OutputInterface? outputBuffer
  /// @return int
  int call(String command, [List<dynamic> parameters = const [], OutputInterface? outputBuffer]);

  /// Queue an Artisan console command by name.
  ///
  /// @param String command
  /// @param List<dynamic> parameters
  /// @return PendingDispatch
  PendingDispatch queue(String command, [List<dynamic> parameters = const []]);

  /// Get all of the commands registered with the console.
  ///
  /// @return List<dynamic>
  List<dynamic> all();

  /// Get the output for the last run command.
  ///
  /// @return String
  String output();

  /// Terminate the application.
  ///
  /// @param InputInterface input
  /// @param int status
  /// @return void
  void terminate(InputInterface input, int status);
}

class PendingDispatch {
  // Implement the PendingDispatch class here
}
