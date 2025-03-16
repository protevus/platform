import 'dart:io';
import '../base/mkdocs_command.dart';

/// Command to manage MkDocs documentation
class DocsCommand extends MkDocsCommand {
  @override
  String get name => 'docs';

  @override
  String get description => 'Manage MkDocs documentation';

  @override
  String get signature => '''docs 
{action : Action to perform (serve, build, get-deps, gh-deploy)}
{--port=8000 : Port to serve documentation on (only for serve action)}
{--clean : Clean the site directory before building or deploying}
{--strict : Enable strict mode for build and deploy (fail on warnings)}
{--no-livereload : Disable live reload when serving}
{--dirty-reload : Enable dirty reload when serving}
{--message= : Custom commit message for gh-deploy}
{--force : Force deploy even with local changes}''';

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
          final port = int.parse(option<String>('port') ?? '8000');
          await serve(
            port: port,
            strict: option<bool>('strict') ?? false,
            livereload: !(option<bool>('no-livereload') ?? false),
            dirtyReload: option<bool>('dirty-reload') ?? false,
          );
          output.success('MkDocs server started successfully');
          output.info('View documentation at http://localhost:$port');
          break;

        case 'build':
          output.info('Building MkDocs documentation...');
          await build(
            clean: option<bool>('clean') ?? false,
            strict: option<bool>('strict') ?? false,
          );
          output.success('Documentation built successfully');
          output.info('Documentation is available in the site/ directory');
          break;

        case 'get-deps':
          output.info('Installing MkDocs dependencies...');
          // Check if pip is available
          final result = await Process.run('pip', ['--version']);
          if (result.exitCode != 0) {
            throw Exception(
                'pip is not installed. Please install Python and pip first.');
          }

          // Install mkdocs and required packages
          final process = await Process.start(
            'pip',
            [
              'install',
              'mkdocs',
              'mkdocs-material',
              'mkdocs-git-revision-date-plugin'
            ],
            mode: ProcessStartMode.inheritStdio,
          );

          final exitCode = await process.exitCode;
          if (exitCode != 0) {
            throw Exception('Failed to install dependencies');
          }

          // Verify mkdocs is now installed
          if (!await isInstalled()) {
            throw Exception('MkDocs installation failed');
          }

          output.success('MkDocs dependencies installed successfully');
          break;

        case 'gh-deploy':
          output.info('Deploying documentation to GitHub Pages...');
          await ghDeploy(
            clean: option<bool>('clean') ?? false,
            strict: option<bool>('strict') ?? false,
            message: option<String>('message'),
            force: option<bool>('force') ?? false,
          );
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
