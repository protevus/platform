import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_migration/migration.dart';
import 'package:sample_app/config/app.dart';

void main() async {
  /// Initialize Dox
  Application().initialize(appConfig);

  /// Run database migration before starting server.
  /// Since Migration need to process only once,
  /// it do not required to register in services.
  await Migration().migrate();

  /// Start dox http server
  await Application().startServer();
}
