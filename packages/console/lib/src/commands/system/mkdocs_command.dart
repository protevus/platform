import 'dart:io';
import 'dart:convert';
import '../../command.dart';

/// Command to manage MkDocs documentation
class MkdocsCommand extends Command {
  @override
  String get name => 'mkdocs';

  @override
  String get description => 'Manage MkDocs documentation';

  @override
  String get signature =>
      'mkdocs {action : Action to perform (serve, build, get-deps, gh-deploy)} {--port=8000 : Port to serve documentation on (only for serve action)} {--clean : Clean the site directory before building or deploying} {--strict : Enable strict mode for build and deploy (fail on warnings)}';

  @override
  Future<void> handle() async {
    try {
      // Get the action argument
      final action = argument<String>('action');
      if (action == null ||
          !['serve', 'build', 'get-deps', 'gh-deploy'].contains(action)) {
        throw ArgumentError(
            'Action must be one of: serve, build, get-deps, gh-deploy');
      }

      // Show what we're doing
      switch (action) {
        case 'serve':
          output.info('Starting MkDocs development server...');
          break;
        case 'build':
          output.info('Building MkDocs documentation...');
          break;
        case 'get-deps':
          output.info('Installing MkDocs dependencies...');
          break;
        case 'gh-deploy':
          output.info('Deploying documentation to GitHub Pages...');
          break;
      }

      // Build command args starting with mkdocs command
      final args = ['mkdocs', action];

      // Add options based on action
      switch (action) {
        case 'serve':
          final port = option<String>('port') ?? '8000';
          args.addAll(['--dev-addr', '0.0.0.0:$port']);
          break;
        case 'build':
          if (option<bool>('clean') == true) {
            args.add('--clean');
          }
          break;
        case 'gh-deploy':
          if (option<bool>('clean') == true) {
            args.add('--clean');
          }
          break;
      }

      // Add strict mode if requested (for build and gh-deploy)
      if (option<bool>('strict') == true &&
          (action == 'build' || action == 'gh-deploy')) {
        args.add('--strict');
      }

      // Execute mkdocs command directly
      final process = await Process.start(
        'mkdocs',
        args.sublist(
            1), // Skip the 'mkdocs' command itself since we're running it directly
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

      // Show success message
      switch (action) {
        case 'serve':
          final port = option<String>('port') ?? '8000';
          output.success('MkDocs server started successfully');
          output.info('View documentation at http://localhost:$port');
          break;
        case 'build':
          output.success('Documentation built successfully');
          output.info('Documentation is available in the site/ directory');
          break;
        case 'get-deps':
          output.success('MkDocs dependencies installed successfully');
          break;
        case 'gh-deploy':
          output.success('Documentation deployed to GitHub Pages successfully');
          break;
      }
    } catch (e) {
      output.error(
          'Failed to ${argument<String>('action')} documentation - see output above for details');
      rethrow;
    }
  }
}
