import 'dart:convert';
import 'dart:io';
import 'package:illuminate_console/console.dart';
import '../../utils/tool_info.dart';

/// Command to display versions of all tools in the stack.
class StackCommand extends Command {
  @override
  String get name => 'stack';

  @override
  String get description => 'Display versions of all tools in the stack';

  @override
  String get signature => '''
    stack 
      {--json : Output in JSON format}
      {--check : Only show missing tools}
    ''';

  Future<String?> _getCommandVersion(String command, List<String> args) async {
    try {
      final result = await Process.run(command, args);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String _cleanVersion(String version) {
    // Extract just the version number from various formats
    final versionPattern = RegExp(r'\d+\.\d+\.\d+');
    final match = versionPattern.firstMatch(version);
    return match?.group(0) ?? version;
  }

  Map<String, ToolCategory> _getToolsData() {
    return {
      'core': ToolCategory({
        'Artisan CLI': ToolInfo(
          version: '0.5.1',
          description: 'Protevus Platform CLI tool',
        ),
        'Dart SDK': ToolInfo(
          version: null,
          description: 'Dart programming language SDK',
        ),
        'Flutter': ToolInfo(
          version: null,
          description: 'Google\'s UI toolkit for building apps',
        ),
        'Git': ToolInfo(
          version: null,
          description: 'Version control system',
        ),
      }),
      'build': ToolCategory({
        'Melos': ToolInfo(
          version: null,
          description: 'Tool for managing Dart/Flutter monorepos',
        ),
        'Node.js': ToolInfo(
          version: null,
          description: 'JavaScript runtime environment',
        ),
      }),
      'devops': ToolCategory({
        'Docker': ToolInfo(
          version: null,
          description: 'Container platform',
        ),
        'kubectl': ToolInfo(
          version: null,
          description: 'Kubernetes command-line tool',
        ),
      }),
      'documentation': ToolCategory({
        'Python': ToolInfo(
          version: null,
          description: 'Python programming language',
        ),
        'MkDocs': ToolInfo(
          version: null,
          description: 'Project documentation generator',
        ),
      }),
    };
  }

  Map<String, dynamic> _toolsToJson(Map<String, ToolCategory> tools) {
    final result = <String, Map<String, Map<String, dynamic>>>{};

    for (final category in tools.entries) {
      result[category.key] = {};
      for (final tool in category.value.tools.entries) {
        result[category.key]![tool.key] = {
          'version': tool.value.version,
          'description': tool.value.description,
        };
      }
    }

    return result;
  }

  @override
  Future<void> handle() async {
    final jsonOutput = option<bool>('json') ?? false;
    final checkOnly = option<bool>('check') ?? false;

    // Initialize tools data structure
    final tools = _getToolsData();

    // Get versions
    tools['core']!.tools['Dart SDK']!.version =
        await _getCommandVersion('dart', ['--version']);
    tools['core']!.tools['Flutter']!.version =
        await _getCommandVersion('flutter', ['--version']);
    tools['core']!.tools['Git']!.version =
        await _getCommandVersion('git', ['--version']);
    tools['build']!.tools['Melos']!.version =
        await _getCommandVersion('melos', ['--version']);
    tools['build']!.tools['Node.js']!.version =
        await _getCommandVersion('node', ['--version']);
    tools['devops']!.tools['Docker']!.version =
        await _getCommandVersion('docker', ['--version']);
    tools['devops']!.tools['kubectl']!.version =
        await _getCommandVersion('kubectl', ['version', '--client']);
    tools['documentation']!.tools['Python']!.version =
        await _getCommandVersion('python', ['--version']);
    tools['documentation']!.tools['MkDocs']!.version =
        await _getCommandVersion('mkdocs', ['--version']);

    // Clean versions
    for (final category in tools.values) {
      for (final tool in category.tools.values) {
        if (tool.version != null) {
          tool.version = _cleanVersion(tool.version!);
        }
      }
    }

    // Collect missing tools
    final missingTools = <String>[];
    for (final category in tools.values) {
      for (final entry in category.tools.entries) {
        if (entry.value.version == null) {
          missingTools.add(entry.key);
        }
      }
    }

    if (jsonOutput) {
      final jsonData = {
        'tools': _toolsToJson(tools),
        'missing': missingTools,
      };
      final encoder = JsonEncoder.withIndent('  ');
      output.writeln(encoder.convert(jsonData));
      return;
    }

    if (checkOnly) {
      if (missingTools.isEmpty) {
        output.success('All required tools are installed.');
      } else {
        output.warning('Missing Tools:');
        for (final tool in missingTools) {
          output.warning('  • $tool is not installed');
        }
      }
      return;
    }

    // Standard output
    output.writeln('Protevus Platform Tool Versions');
    output.writeln('=============================');
    output.newLine();

    // Display each category
    for (final entry in tools.entries) {
      final category = entry.key;
      final categoryTools = entry.value.tools;

      // Convert category name to title case and plural
      final categoryTitle =
          '${category[0].toUpperCase()}${category.substring(1)} Tools:';
      output.writeln(categoryTitle);
      output.writeln('-' * (categoryTitle.length));

      for (final toolEntry in categoryTools.entries) {
        final name = toolEntry.key;
        final info = toolEntry.value;
        final version = info.version ?? 'Not installed';
        final description = info.description;

        output.writeln('${name.padRight(15)}: $version');
        output.writeln('${' ' * 16}${description}');
      }
      output.newLine();
    }

    if (missingTools.isNotEmpty) {
      output.warning('Missing Tools:');
      for (final tool in missingTools) {
        output.warning('  • $tool is not installed');
      }
    }
  }
}
