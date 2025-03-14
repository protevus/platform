import 'application.dart';
import 'commands/core/stack_command.dart';
import 'commands/testing/test_command.dart';
import 'commands/testing/test_package_command.dart';
import 'commands/testing/test_coverage_report_command.dart';
import 'commands/testing/test_coverage_command.dart';
import 'commands/development/generate_command.dart';
import 'commands/development/generate_package_command.dart';
import 'commands/development/generate_check_command.dart';
import 'commands/development/generate_dumbtest_command.dart';
import 'commands/core/bootstrap_command.dart';
import 'commands/core/format_command.dart';
import 'commands/core/fix_command.dart';
import 'commands/core/analyze_command.dart';
import 'commands/core/clean_command.dart';
import 'commands/development/list_package_command.dart';
import 'commands/release/publish_command.dart';
import 'commands/release/version_command.dart';
import 'commands/development/deps_check_command.dart';
import 'commands/development/deps_upgrade_command.dart';
import 'commands/development/generate_config_command.dart';
import 'commands/development/create_command.dart';
import 'commands/development/create_template_command.dart';
import 'commands/services/services_command.dart';
import 'commands/services/up_command.dart';
import 'commands/services/down_command.dart';
import 'commands/services/status_command.dart';
import 'commands/services/logs_command.dart';
import 'commands/services/cleanup_command.dart';
import 'commands/services/add_command.dart';
import 'commands/services/remove_command.dart';
import 'commands/services/configure_command.dart';
import 'commands/services/discover_command.dart';
import 'commands/services/exec_command.dart';
import 'commands/development/generate_services_command.dart';
import 'commands/documentation/api_command.dart';
import 'commands/development/generate_gitignore_command.dart';
import 'commands/core/info_command.dart';
import 'commands/documentation/api_serve_command.dart';
import 'commands/development/list_files_command.dart';
import 'commands/documentation/docs_command.dart';
import 'commands/testing/debug_pkgname_command.dart';
import 'commands/testing/debug_pkgpath_command.dart';
import 'commands/testing/debug_reflectable_command.dart';

/// The development console application.
///
/// This class extends the base Application class to provide
/// additional commands and functionality specific to monorepo development.
class Developer extends Application {
  /// Create a new development console application.
  Developer({
    super.name = 'Protevus Platform',
    super.version,
    super.output,
  }) {
    // Register development commands
    add(StackCommand());
    add(TestCommand());
    add(TestPackageCommand());
    add(TestCoverageCommand());
    add(TestCoverageReportCommand());
    add(GenerateCommand());
    add(GeneratePackageCommand());
    add(GenerateCheckCommand());
    add(GenerateDumbTestCommand());
    add(BootstrapCommand());
    add(FormatCommand());
    add(FixCommand());
    add(ListPackageCommand());
    add(PublishCommand());
    add(DepsCheckCommand());
    add(DepsUpgradeCommand());
    add(GenerateConfigCommand());
    add(CreateCommand());
    add(CreateTemplateCommand());

    // Register services commands
    add(ServicesCommand());
    add(UpCommand());
    add(DownCommand());
    add(StatusCommand());
    add(LogsCommand());
    add(CleanupCommand());
    add(AddCommand());
    add(RemoveCommand());
    add(ConfigureCommand());
    add(DiscoverCommand());
    add(ExecCommand());
    add(GenerateServicesCommand());
    add(ApiCommand());
    add(GenerateGitignoreCommand());
    add(InfoCommand());
    add(ApiServeCommand());
    add(ListFilesCommand());
    add(DocsCommand());
    add(DebugPkgnameCommand());
    add(DebugPkgpathCommand());
    add(DebugReflectableCommand());

    // Register melos commands
    // Register melos commands
    add(AnalyzeCommand());
    add(CleanCommand());
    add(VersionCommand());
  }
}
