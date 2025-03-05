import '../../command.dart';

/// A command that lists all available commands.
class ListCommand extends Command {
  @override
  String get name => 'list';

  @override
  String get description => 'List all available commands';

  @override
  String get signature => 'list {--format=} : Output format (text, json)';

  @override
  Future<void> handle() async {
    final format = option('format') ?? 'text';

    output.info('Available commands:');
    output.newLine();

    final commands = application.visibleCommands;
    commands.sort((a, b) => a.name.compareTo(b.name));

    if (format == 'json') {
      _displayJsonFormat(commands);
    } else {
      _displayTextFormat(commands);
    }

    output.newLine();
    output.success(
        'Use "<command> --help" for more information about a command.');
  }

  void _displayTextFormat(List<Command> commands) {
    for (final command in commands) {
      output.writeln('  ${command.name}');
      output.writeln('    ${command.description}');
      output.newLine();
    }
  }

  void _displayJsonFormat(List<Command> commands) {
    final json = {
      'commands': commands
          .map((command) => {
                'name': command.name,
                'description': command.description,
                'hidden': command.hidden,
              })
          .toList(),
    };

    output.writeln(json.toString());
  }
}
