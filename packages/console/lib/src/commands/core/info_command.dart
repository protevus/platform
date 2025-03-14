import 'dart:io';
import 'dart:convert';
import '../../command.dart';

/// Command to display Dart SDK and environment information
class InfoCommand extends Command {
  @override
  String get name => 'info';

  @override
  String get description => 'Display Dart SDK and environment information';

  @override
  String get signature =>
      'info {--scope=* : Only show information for packages matching the given name pattern}';

  @override
  Future<void> handle() async {
    try {
      // Handle scoped execution
      final scopes = option<List<String>>('scope');
      String? scope;
      if (scopes != null && scopes.isNotEmpty) {
        scope = scopes.first;
        output.info('Retrieving Dart SDK information for package: $scope');
      } else {
        output.info('Retrieving Dart SDK and environment information...');
      }

      // Build command
      final args = ['dart', 'info'];

      // Execute command through melos if scoped, directly if not
      final process = scope != null
          ? await Process.start(
              'melos',
              ['exec', '--scope=$scope', '--', ...args],
              runInShell: true,
            )
          : await Process.start(
              'dart',
              ['info'],
              runInShell: true,
            );

      // Stream output in real-time
      process.stdout
          .transform(utf8.decoder)
          .listen((data) => output.writeln(data.trim()));
      process.stderr
          .transform(utf8.decoder)
          .listen((data) => output.error(data.trim()));

      // Wait for process to complete
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        throw Exception('Command failed with exit code $exitCode');
      }

      output.success('Dart SDK information retrieved successfully');
    } catch (e) {
      output.error(
          'Failed to retrieve Dart SDK information - see output above for details');
      rethrow;
    }
  }
}
