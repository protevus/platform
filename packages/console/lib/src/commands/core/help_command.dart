import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../command.dart';
import '../../output/table.dart';

/// A command that lists all available commands.
///
/// This command displays a formatted list of all available commands,
/// grouped by category with proper alignment and styling.
class HelpCommand extends Command {
  @override
  String get name => 'help';

  @override
  String get description => 'List all available commands';

  @override
  String get signature => 'help {--format=} : Output format (text, json)';

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
      output.writeln('-' * (category.key.length + 4));

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

  /// Get command directory from its file path
  String _getCommandDirectory(Command command) {
    // Get the command's name and class name
    final commandName = command.name;
    final className = command.runtimeType.toString();

    // Get all command directories
    final commandsDir =
        path.join('packages', 'console', 'lib', 'src', 'commands');
    final directories = Directory(commandsDir)
        .listSync()
        .whereType<Directory>()
        .where((dir) => path.basename(dir.path) != 'base')
        .toList();

    // Convert class name to file name
    final classFileName =
        '${className.replaceAllMapped(RegExp(r'([A-Z])'), (match) => '_${match[1]!.toLowerCase()}').toLowerCase().replaceFirst(RegExp(r'^_'), '')}.dart';

    // Try to find by file location first
    for (var dir in directories) {
      final dirName = path.basename(dir.path);
      final filePath = path.join(dir.path, classFileName);
      if (File(filePath).existsSync()) {
        return dirName;
      }
    }

    // If file not found and command has colon, try using the prefix
    if (commandName.contains(':')) {
      final mainCommand = commandName.split(':')[0];
      if (mainCommand == 'generate') {
        return 'development';
      }
      for (var dir in directories) {
        final dirName = path.basename(dir.path);
        if (dirName == mainCommand) {
          return dirName;
        }
      }
    }

    return 'other';
  }

  /// Get an appropriate emoji for each category
  String _getCategoryEmoji(String category) {
    final emojiMap = {
      'Core Commands': '🔧',
      'Development Workflow': '🛠️',
      'Testing & Quality': '🧪',
      'Service Management': '📦',
      'Documentation': '📚',
      'Release Management': '📤',
      'Other Commands': '📌',
    };
    return emojiMap[category] ?? '📌';
  }

  /// Group commands by their directory location
  Map<String, List<Command>> _groupCommandsByCategory(List<Command> commands) {
    final groups = <String, List<Command>>{};

    // Map directory names to display names
    final categoryMappings = {
      'core': 'Core Commands',
      'development': 'Development Workflow',
      'testing': 'Testing & Quality',
      'services': 'Service Management',
      'documentation': 'Documentation',
      'release': 'Release Management',
    };

    // Group commands by their directory
    for (final command in commands) {
      final directory = _getCommandDirectory(command);
      if (directory == 'base') continue; // Skip base commands

      final categoryName = categoryMappings[directory] ?? 'Other Commands';
      groups.putIfAbsent(categoryName, () => []).add(command);
    }

    // Sort commands within each category
    for (final commands in groups.values) {
      commands.sort((a, b) => a.name.compareTo(b.name));
    }

    // Return categories in specific order
    final orderedCategories = [
      'Core Commands',
      'Development Workflow',
      'Testing & Quality',
      'Service Management',
      'Documentation',
      'Release Management',
      'Other Commands',
    ];

    return Map.fromEntries(
      orderedCategories
          .where(groups.containsKey)
          .map((key) => MapEntry(key, groups[key]!)),
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
