import 'application.dart';
import 'commands/system/versions_command.dart';
import 'commands/test/test_command.dart';
import 'commands/test/test_package_command.dart';
import 'commands/test/test_coverage_report_command.dart';
import 'commands/test/test_coverage_command.dart';
import 'commands/system/generate_command.dart';
import 'commands/system/generate_package_command.dart';
import 'commands/system/generate_check_command.dart';
import 'commands/system/generate_dumbtest_command.dart';
import 'commands/system/bootstrap_command.dart';
import 'commands/system/format_command.dart';
import 'commands/system/fix_command.dart';
import 'commands/system/analyze_command.dart';
import 'commands/system/clean_command.dart';
import 'commands/system/package_command.dart';
import 'commands/system/publish_command.dart';
import 'commands/system/deps_check_command.dart';
import 'commands/system/deps_upgrade_command.dart';
import 'commands/system/generate_config_command.dart';
import 'commands/system/create_command.dart';
import 'commands/system/create_template_command.dart';
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
import 'commands/system/docs_api_command.dart';
import 'commands/system/gitignore_setup_command.dart';
import 'commands/system/dart_info_command.dart';
import 'commands/system/docs_serve_command.dart';
import 'commands/system/list_dart_files_command.dart';
import 'commands/system/mkdocs_command.dart';
import 'commands/system/debug_pkgname_command.dart';
import 'commands/system/debug_pkgpath_command.dart';
import 'commands/system/debug_reflectable_command.dart';

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
    add(VersionsCommand());
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
    add(PackageCommand());
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
    add(DocsApiCommand());
    add(GitignoreSetupCommand());
    add(DartInfoCommand());
    add(DocsServeCommand());
    add(ListDartFilesCommand());
    add(MkdocsCommand());
    add(DebugPkgnameCommand());
    add(DebugPkgpathCommand());
    add(DebugReflectableCommand());

    // Register melos commands
    add(MelosAnalyzeCommand());
    add(MelosCleanCommand());
  }
}
