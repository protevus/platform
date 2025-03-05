import 'package:illuminate_console/console.dart';
import 'package:meta/meta.dart';

import 'commands/make/model_command.dart';
import 'commands/make/controller_command.dart';
import 'commands/make/middleware_command.dart';
import 'commands/make/request_command.dart';
import 'commands/make/serializer_command.dart';
import 'commands/serve/serve_command.dart';
import 'commands/key/generate_command.dart';
import 'commands/project/create_command.dart';
import 'commands/update_command.dart';

/// The Artisan console application.
class Artisan extends Application {
  /// Create a new Artisan console application.
  Artisan({
    String name = 'Illuminate Framework',
    String version = '1.0.0',
    Output? output,
  }) : super(
          name: name,
          version: version,
          output: output ?? ConsoleOutput(),
        ) {
    // Register commands
    add(MakeModelCommand());
    add(MakeControllerCommand());
    add(MakeMiddlewareCommand());
    add(MakeRequestCommand());
    add(MakeSerializerCommand());
    add(ServeCommand());
    add(KeyGenerateCommand());
    add(ProjectCreateCommand());
    add(UpdateCommand());
  }

  /// Get the output instance.
  @protected
  Output get output => getCommand('list')!.output;

  /// Run an Artisan console command.
  ///
  /// This method provides a more convenient API for running commands
  /// compared to the base Application class.
  @override
  Future<void> run(String commandName,
      [List<dynamic> arguments = const []]) async {
    try {
      await super.run(commandName, arguments);
    } catch (e) {
      if (e is CommandNotFoundException) {
        output.error('Command "$commandName" is not defined.');
        return;
      }
      rethrow;
    }
  }

  /// Run Artisan with command line arguments.
  ///
  /// This is the main entry point when running from the command line.
  @override
  Future<void> runWithArguments(List<String> arguments) async {
    try {
      if (arguments.isEmpty) {
        // Show list of available commands
        await run('list');
        return;
      }

      final commandName = arguments.first;
      final commandArgs =
          arguments.length > 1 ? arguments.sublist(1) : const [];

      await run(commandName, commandArgs);
    } catch (e) {
      output.error(e.toString());
      // Exit with error code
      rethrow;
    }
  }
}
