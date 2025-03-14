import 'dart:io';
import '../base/melos_command.dart';

/// Command to version packages in the monorepo
class VersionCommand extends MelosCommand {
  @override
  String get name => 'version';

  @override
  String get description => 'Version packages in the monorepo';

  @override
  String get signature => '''version 
{package-name? : Package to version}
{version-type? : Version type (major, minor, patch)}
{--p|prerelease : Version packages as prerelease}
{--g|graduate : Graduate prerelease versions to stable}
{--preid= : Prerelease identifier (e.g. alpha, beta)}
{--dependent-preid= : Prerelease identifier for dependent packages}
{--a|all : Version private packages that are skipped by default}
{--c|changelog : Update CHANGELOG.md files (defaults to true)}
{--no-changelog : Skip updating CHANGELOG.md files}
{--d|dependent-constraints : Update dependency version constraints (defaults to true)}
{--no-dependent-constraints : Skip updating dependency constraints}
{--D|dependent-versions : Make new patch version for dependent packages (defaults to true)}
{--no-dependent-versions : Skip making new patch version for dependent packages}
{--t|git-tag-version : Tag the release (defaults to true)}
{--no-git-tag-version : Skip tagging the release}
{--C|git-commit-version : Commit version changes (defaults to true)}
{--no-git-commit-version : Skip committing version changes}
{--r|release-url : Generate release URL (defaults to false)}
{--no-release-url : Skip generating release URL}
{--m|message= : Custom commit message}
{--yes : Skip confirmation prompt}
{--V|manual-version= : Manual version for package (format: package:version)}
{--scope= : Include only packages matching glob (repeatable)}
{--ignore= : Exclude packages matching glob (repeatable)}
{--diff= : Filter packages based on changes}
{--depends-on= : Include only packages depending on package (repeatable)}
{--no-depends-on= : Include only packages not depending on package (repeatable)}
{--include-dependents : Include all transitive dependents}
{--include-dependencies : Include all transitive dependencies}''';

  /// List of flags that support negation with --no- prefix
  static const negatableFlags = {
    'changelog',
    'dependent-constraints',
    'dependent-versions',
    'git-tag-version',
    'git-commit-version',
    'release-url',
  };

  /// List of flags that don't support negation
  static const nonNegatableFlags = {
    'prerelease',
    'graduate',
    'all',
    'yes',
    'include-dependents',
    'include-dependencies',
  };

  @override
  Future<void> handle() async {
    final args = <String>[];

    // Add positional arguments if provided
    final packageName = argument('package-name');
    final versionType = argument('version-type');
    if (packageName != null && versionType != null) {
      args.addAll([packageName, versionType]);
    }

    // Add flag options
    for (final flag in [...negatableFlags, ...nonNegatableFlags]) {
      if (option(flag) == true) {
        args.add('--$flag');
      } else if (option(flag) == false && negatableFlags.contains(flag)) {
        // Only add --no- prefix for flags that support negation
        args.add('--no-$flag');
      }
    }

    // Add value options
    for (final opt in [
      'preid',
      'dependent-preid',
      'message',
      'manual-version',
      'scope',
      'ignore',
      'diff',
      'depends-on',
      'no-depends-on'
    ]) {
      final value = option(opt);
      if (value != null) {
        args.add('--$opt=$value');
      }
    }

    // Create a process to handle interactive input
    final process = await Process.start(
      'melos',
      ['version', ...args],
      mode: ProcessStartMode.inheritStdio,
      environment: Platform.environment,
    );

    // Wait for the process to complete
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      output.info('Operation cancelled no versioning occured');
    }
  }
}
