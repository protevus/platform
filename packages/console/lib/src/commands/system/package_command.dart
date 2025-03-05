import '../melos/melos_command.dart';

/// Command to list packages in the workspace
class PackageCommand extends MelosCommand {
  @override
  String get name => 'package';

  @override
  String get description => 'List packages in the workspace';

  @override
  String get signature =>
      'package {--json : Output in JSON format} {--long : Show extended package information} {--relative : Show relative paths} {--scope=* : Filter packages by name} {--since : Only list packages that have changed since the last tag/commit} {--no-private : Exclude private packages} {--no-published : Exclude published packages} {--dir=* : Filter packages by directory} {--dependencies : Include package dependencies} {--dependents : Include package dependents} {--graph : Show dependency graph as JSON} {--gviz : Show dependency graph in Graphviz format} {--cycles : Find cycles in package dependencies} {--parsable : Show parsable output}';

  @override
  Future<void> handle() async {
    final args = <String>[];

    // Map command options to melos args
    if (option<bool>('json') == true) args.add('--json');
    if (option<bool>('long') == true) args.add('--long');
    if (option<bool>('relative') == true) args.add('--relative');
    if (option<bool>('since') == true) args.add('--since');
    if (option<bool>('no-private') == true) args.add('--no-private');
    if (option<bool>('no-published') == true) args.add('--no-published');
    if (option<bool>('dependencies') == true) {
      args.add('--include-dependencies');
    }
    if (option<bool>('dependents') == true) args.add('--include-dependents');
    if (option<bool>('graph') == true) args.add('--graph');
    if (option<bool>('gviz') == true) args.add('--gviz');
    if (option<bool>('cycles') == true) args.add('--cycles');
    if (option<bool>('parsable') == true) args.add('--parsable');

    // Handle array options
    final scopes = option<List<String>>('scope');
    if (scopes != null) {
      for (final scope in scopes) {
        args.add('--scope=$scope');
      }
    }

    final dirs = option<List<String>>('dir');
    if (dirs != null) {
      for (final dir in dirs) {
        args.add('--dir=$dir');
      }
    }

    try {
      await executeMelos('list', args: args);
      output.success('Package list completed successfully');
    } catch (e) {
      output.error('Failed to list packages - see output above for details');
      rethrow;
    }
  }
}
