import 'package:illuminate_foundation/dox_core.dart';

Future<void> startHttpServer(AppConfig config) async {
  Dox().initialize(config);
  await Dox().startServer();
}
