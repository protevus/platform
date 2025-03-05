import 'dart:convert';
import '../../command.dart';
import '../../output/table.dart';

/// A command that lists all available commands.
///
/// This command displays a formatted list of all available commands,
/// grouped by category with proper alignment and styling.
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

    if (format == 'json') {
      _displayJsonFormat(application.visibleCommands);
    } else {
      _displayTextFormat(application.visibleCommands);
    }
  }

  void _displayTextFormat(List<Command> commands) {
    // Display header with version and description
    output.info('Protevus Platform CLI v${application.version}');
    output.info(
        'A CLI tool for managing Protevus Platform development monorepo.');
    output.newLine();

    // Display usage information
    output.comment('Usage: ./artisan <command> [arguments]');
    output.writeln('─' * 50);
    output.newLine();

    // Display available commands section
    output.info('🚀 Available Commands');
    output.newLine();

    // Group commands by category
    final groupedCommands = _groupCommandsByCategory(commands);

    // Display each category
    for (final category in groupedCommands.entries) {
      // Category header with emoji
      final emoji = _getCategoryEmoji(category.key);
      output.info(' $emoji ${category.key} ');
      output.writeln('${'-' * (category.key.length + 4)}');

      // Create table for this category's commands
      final rows = category.value
          .map((command) => [
                '   ${command.name}',
                command.description,
              ])
          .toList();

      // Display table with bold cyan headers
      output.table(
        ['\x1B[1;36m   Command\x1B[0m', '\x1B[1;36mDescription\x1B[0m'],
        rows,
        columnAlignments: [ColumnAlignment.left, ColumnAlignment.left],
        borderStyle: BorderStyle.none,
        cellPadding: 1,
      );

      output.newLine();
    }

    // Help footer with styling
    output.newLine();
    output.comment(
        '💡 Tip: Use "<command> --help" for detailed information about a specific command');
  }

  /// Get an appropriate emoji for each category
  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'System Commands':
        return '⚙️';
      case 'Development Commands':
        return '🛠️';
      case 'Testing Commands':
        return '🧪';
      case 'Package Commands':
        return '📦';
      default:
        return '📌';
    }
  }

  /// Group commands by their category based on naming convention
  Map<String, List<Command>> _groupCommandsByCategory(List<Command> commands) {
    final groups = <String, List<Command>>{
      'System Commands': [],
      'Development Commands': [],
      'Testing Commands': [],
      'Package Commands': [],
      'Other Commands': [],
    };

    for (final command in commands) {
      final name = command.name.toLowerCase();
      if (name.startsWith('test') || name.contains('coverage')) {
        groups['Testing Commands']!.add(command);
      } else if (name.startsWith('generate') ||
          name.contains('format') ||
          name.contains('analyze')) {
        groups['Development Commands']!.add(command);
      } else if (name.startsWith('package') ||
          name.contains('melos') ||
          name.contains('deps')) {
        groups['Package Commands']!.add(command);
      } else if (name == 'list' ||
          name.contains('clean') ||
          name.contains('bootstrap')) {
        groups['System Commands']!.add(command);
      } else {
        groups['Other Commands']!.add(command);
      }
    }

    // Remove empty categories and sort commands within each category
    return Map.fromEntries(
      groups.entries
          .where((entry) => entry.value.isNotEmpty)
          .map((entry) => MapEntry(
                entry.key,
                entry.value..sort((a, b) => a.name.compareTo(b.name)),
              )),
    );
  }

  void _displayJsonFormat(List<Command> commands) {
    // Group commands by category for JSON output
    final groupedCommands = _groupCommandsByCategory(commands);

    final json = {
      'categories': groupedCommands.entries
          .map((entry) => {
                'name': entry.key,
                'emoji': _getCategoryEmoji(entry.key),
                'commands': entry.value
                    .map((command) => {
                          'name': command.name,
                          'description': command.description,
                          'hidden': command.hidden,
                        })
                    .toList(),
              })
          .toList(),
    };

    // Use JsonEncoder for pretty printing
    final encoder = JsonEncoder.withIndent('  ');
    output.writeln(encoder.convert(json));
  }
}
