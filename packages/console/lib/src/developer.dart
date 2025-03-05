import 'application.dart';
import 'output/output.dart';
import 'commands/system/versions_command.dart';
import 'commands/test/test_command.dart';
import 'commands/test/test_package_command.dart';
import 'commands/system/generate_command.dart';
import 'commands/system/generate_package_command.dart';
import 'commands/system/generate_check_command.dart';
import 'commands/system/generate_dumbtest_command.dart';
import 'commands/system/bootstrap_command.dart';
import 'commands/system/format_command.dart';
import 'commands/system/analyze_command.dart';
import 'commands/system/clean_command.dart';
import 'commands/system/package_command.dart';
import 'commands/system/publish_command.dart';

/// The development console application.
///
/// This class extends the base Application class to provide
/// additional commands and functionality specific to monorepo development.
class Developer extends Application {
  /// Create a new development console application.
  Developer({
    String name = 'Protevus Platform',
    String version = '0.5.1',
    Output? output,
  }) : super(
          name: name,
          version: version,
          output: output,
        ) {
    // Register development commands
    add(VersionsCommand());
    add(TestCommand());
    add(TestPackageCommand());
    add(GenerateCommand());
    add(GeneratePackageCommand());
    add(GenerateCheckCommand());
    add(GenerateDumbTestCommand());
    add(BootstrapCommand());
    add(FormatCommand());
    add(PackageCommand());
    add(PublishCommand());

    // Register melos commands
    add(MelosAnalyzeCommand());
    add(MelosCleanCommand());
  }
}
