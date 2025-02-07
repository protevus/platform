import 'package:illuminate_foundation/foundation.dart';

Future<void> startHttpServer(AppConfig config) async {
  Application().initialize(config);
  await Application().startServer();
}
