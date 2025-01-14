import 'dart:async';
import 'package:args/args.dart';
import 'package:meta/meta.dart';
import 'application.dart';
import 'output/output.dart';
import 'parser.dart';
import 'prompt/prompt.dart';

/// Base class for all console commands.
///
/// Commands can be defined using a signature string or by overriding the
/// [configure] method to manually configure arguments and options.
///
/// This class provides the foundation for creating console commands with a similar
/// API to Laravel's Artisan commands.
abstract class Command {
  /// The console command name.
  String get name;

  /// The console command description shown in the command listing.
  String get description;

  /// The console command signature.
  ///
  /// This property provides a convenient way of defining the command name,
  /// arguments, and options. For example:
  ///
  /// ```dart
  /// String get signature => 'email:send {user} {--queue}';
  /// ```
  String? get signature => null;

  /// The console command help text.
  String get help => description;

  /// Indicates whether the command should be shown in the commands list.
  bool get hidden => false;

  /// The command's arguments parser.
  late final ArgParser _argParser;

  /// The parsed command arguments.
  ArgResults? _argResults;

  /// The application instance.
  Application? _application;

  /// The output instance.
  Output? _output;

  /// The prompt instance for interactive input.
  Prompt? _prompt;

  /// The command's argument definitions.
  List<InputArgument> _arguments = [];

  /// The positional arguments passed to the command.
  List<String> _positionalArgs = [];

  /// Create a new console command instance.
  Command() {
    _argParser = ArgParser();
    _configureCommand();
  }

  /// Configure the command's arguments and options.
  void _configureCommand() {
    if (signature != null) {
      _configureFromSignature();
    } else {
      configure(_argParser);
    }

    // Add help option to all commands
    _argParser.addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Display help information',
    );
  }

  /// Configure the command's arguments and options.
  ///
  /// Override this method to manually configure the command's arguments
  /// when not using a signature.
  @protected
  void configure(ArgParser parser) {}

  /// Parse the command signature and configure arguments.
  void _configureFromSignature() {
    final (_, arguments, options) = Parser.parse(signature!);

    // Store argument definitions for later use
    _arguments = arguments;

    // Configure options
    for (final opt in options) {
      switch (opt.mode) {
        case InputOptionMode.none:
          _argParser.addFlag(
            opt.name,
            abbr: opt.shortcut,
            help: opt.description,
            negatable: true,
          );
          break;
        case InputOptionMode.optional:
          _argParser.addOption(
            opt.name,
            abbr: opt.shortcut,
            help: opt.description,
            defaultsTo: opt.defaultValue.isNotEmpty ? opt.defaultValue : null,
          );
          break;
        case InputOptionMode.isArray:
          _argParser.addMultiOption(
            opt.name,
            abbr: opt.shortcut,
            help: opt.description,
          );
          break;
      }
    }
  }

  /// Set the application instance.
  @internal
  void setApplication(Application application) {
    _application = application;
  }

  /// Set the output instance.
  @internal
  void setOutput(Output output) {
    _output = output;
    _prompt = Prompt(output);
  }

  /// Get the application instance.
  @protected
  Application get application {
    if (_application == null) {
      throw StateError('Application has not been set on the command.');
    }
    return _application!;
  }

  /// Get the output instance.
  @protected
  Output get output {
    if (_output == null) {
      throw StateError('Output has not been set on the command.');
    }
    return _output!;
  }

  /// Get the prompt instance.
  @protected
  Prompt get prompt {
    if (_prompt == null) {
      throw StateError('Prompt has not been set on the command.');
    }
    return _prompt!;
  }

  /// Execute the console command.
  ///
  /// This method is called when the command is executed. Override this method
  /// to define the command's behavior.
  @protected
  FutureOr<void> handle();

  /// Run the console command.
  ///
  /// This method handles parsing arguments and executing the command.
  Future<void> run(List<String> args) async {
    try {
      // Split args into positional args and options
      final optionIndex = args.indexWhere((arg) => arg.startsWith('-'));
      if (optionIndex == -1) {
        _positionalArgs = args;
        _argResults = _argParser.parse([]);
      } else {
        _positionalArgs = args.sublist(0, optionIndex);
        _argResults = _argParser.parse(args.sublist(optionIndex));
      }

      await handle();
    } catch (e) {
      // TODO: Implement proper error handling
      rethrow;
    }
  }

  /// Get the value of a command argument.
  ///
  /// Returns the value of the specified argument, or null if not provided.
  T? argument<T>(String name) {
    if (_positionalArgs.isEmpty && _arguments.isNotEmpty) {
      throw StateError(
          'Command arguments have not been parsed. Call run() first.');
    }

    final argIndex = _arguments.indexWhere((arg) => arg.name == name);
    if (argIndex == -1) {
      throw ArgumentError('Argument "$name" is not defined.');
    }

    if (argIndex >= _positionalArgs.length) {
      final arg = _arguments[argIndex];
      if (arg.mode == InputArgumentMode.required) {
        throw ArgumentError('Required argument "$name" is missing.');
      }
      return null;
    }

    final value = _positionalArgs[argIndex];
    return value as T;
  }

  /// Get the value of a command option.
  ///
  /// Returns the value of the specified option, or null if not provided.
  T? option<T>(String name) {
    if (_argResults == null) {
      throw StateError(
          'Command arguments have not been parsed. Call run() first.');
    }
    return _argResults![name] as T?;
  }

  /// Check if an argument exists and has been provided.
  bool hasArgument(String name) {
    final argIndex = _arguments.indexWhere((arg) => arg.name == name);
    if (argIndex == -1) {
      return false;
    }
    return argIndex < _positionalArgs.length;
  }

  /// Check if an option exists and has been provided.
  bool hasOption(String name) {
    if (_argResults == null) {
      throw StateError(
          'Command arguments have not been parsed. Call run() first.');
    }
    return _argResults!.wasParsed(name);
  }

  /// Get the argument parser.
  @internal
  ArgParser get argumentParser => _argParser;

  /// Get the argument definitions.
  @internal
  List<InputArgument> get argumentDefinitions => _arguments;
}
