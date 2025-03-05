import 'dart:async';
import 'package:meta/meta.dart';
import 'command.dart';
import 'commands/system/list_command.dart';
import 'output/output.dart';
import 'parser.dart';

/// The console application class.
///
/// This class manages the registration and execution of console commands.
class Application {
  /// The application name.
  final String name;

  /// The application version.
  final String version;

  /// The registered commands.
  final Map<String, Command> _commands = {};

  /// The output instance.
  final Output _output;

  /// Create a new console application instance.
  Application({
    this.name = 'Console Application',
    this.version = '0.5.1',
    Output? output,
  }) : _output = output ?? ConsoleOutput() {
    // Register built-in commands
    add(ListCommand());
  }

  /// Register a command with the application.
  ///
  /// The command can be provided as an instance or a type that will be
  /// instantiated when needed.
  void add(Command command) {
    command.setApplication(this);
    command.setOutput(_output);
    _commands[command.name] = command;
  }

  /// Register multiple commands with the application.
  void addCommands(List<Command> commands) {
    for (final command in commands) {
      add(command);
    }
  }

  /// Get a registered command by name.
  Command? getCommand(String name) => _commands[name];

  /// Get all registered commands.
  List<Command> get commands => _commands.values.toList();

  /// Get a list of available commands, excluding hidden ones.
  List<Command> get visibleCommands =>
      commands.where((command) => !command.hidden).toList();

  /// Run a console command by name.
  ///
  /// Throws a [CommandNotFoundException] if the command does not exist.
  Future<void> run(String commandName,
      [List<dynamic> arguments = const []]) async {
    final command = getCommand(commandName);

    if (command == null) {
      throw CommandNotFoundException(
        'The command "$commandName" does not exist.',
      );
    }

    final args = arguments.map((e) => e.toString()).toList();

    if (args.contains('--help') || args.contains('-h')) {
      _showCommandHelp(command);
      return;
    }

    await command.run(args);
  }

  /// Show help information for a command.
  void _showCommandHelp(Command command) {
    _output.writeln('${command.name} - ${command.description}');
    _output.newLine();

    if (command.help != command.description) {
      _output.writeln(command.help);
      _output.newLine();
    }

    // Show usage
    _output.writeln('Usage:');
    _output.writeln('  ${command.name} [arguments] [options]');
    _output.newLine();

    // Show options
    final parser = command.argumentParser;
    if (parser.options.isNotEmpty) {
      _output.writeln('Options:');
      for (final option in parser.options.entries) {
        final name = option.key;
        final opt = option.value;

        // Format flag options
        if (opt.type == bool) {
          _output.write('    --[no-]$name');
        } else {
          _output.write('    --$name');
          if (opt.isMultiple) {
            _output.write('=VALUE...');
          } else if (opt.valueHelp != null) {
            _output.write('=${opt.valueHelp?.toUpperCase()}');
          }
        }

        // Add shortcut if available
        if (opt.abbr != null) {
          _output.write(', -${opt.abbr}');
        }

        // Add help text
        if (opt.help != null && opt.help!.isNotEmpty) {
          _output.write('    ${opt.help}');
        }

        _output.newLine();
      }
      _output.newLine();
    }

    // Show positional arguments if using signature
    final arguments = command.argumentDefinitions;
    if (arguments.isNotEmpty) {
      _output.writeln('Arguments:');
      for (final arg in arguments) {
        final required = arg.mode == InputArgumentMode.required
            ? '(required)'
            : '(optional)';
        _output.writeln('  ${arg.name} $required');
        if (arg.description.isNotEmpty) {
          _output.writeln('    ${arg.description}');
        }
      }
      _output.newLine();
    }
  }

  /// Run the application with the given arguments.
  ///
  /// This is typically called from the main function with the process arguments.
  Future<void> runWithArguments(List<String> arguments) async {
    if (arguments.isEmpty) {
      // Show list of available commands
      await run('list');
      return;
    }

    final commandName = arguments.first;
    final commandArgs = arguments.length > 1 ? arguments.sublist(1) : const [];

    await run(commandName, commandArgs);
  }
}

/// Exception thrown when a command is not found.
class CommandNotFoundException implements Exception {
  final String message;

  CommandNotFoundException(this.message);

  @override
  String toString() => message;
}
