import 'package:symfony_console/symfony_console.dart';

abstract class Application {
  /// Run an Artisan console command by name.
  ///
  /// [command] is the name of the command to run.
  /// [parameters] is the list of parameters to pass to the command.
  /// [outputBuffer] is the buffer to capture the command output.
  ///
  /// Returns the exit code of the command.
  int call(String command, {List<String> parameters = const [], OutputInterface? outputBuffer});

  /// Get the output from the last command.
  ///
  /// Returns the output as a string.
  String output();
}
