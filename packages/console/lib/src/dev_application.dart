import 'application.dart';
import 'output/output.dart';
import 'commands/system/versions_command.dart';

/// The development console application.
///
/// This class extends the base Application class to provide
/// additional commands and functionality specific to monorepo development.
class DevApplication extends Application {
  /// Create a new development console application.
  DevApplication({
    String name = 'Protevus Platform',
    String version = '1.0.0',
    Output? output,
  }) : super(
          name: name,
          version: version,
          output: output,
        ) {
    // Register development commands
    add(VersionsCommand());
  }
}
