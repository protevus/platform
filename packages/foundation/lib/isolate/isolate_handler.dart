import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_foundation/isolate/isolate_interfaces.dart';
import 'package:illuminate_foundation/server/dox_server.dart';
import 'package:illuminate_routing/routing.dart';

/// process middleware and controller and sent data via sentPort
void isolateHandler(IsolateSpawnParameter param) async {
  /// send port of main isolate
  AppConfig appConfig = param.config;
  List<DoxService> services = param.services;

  /// creating dox in new isolate;
  Dox().isolateId = param.isolateId;
  Dox().initialize(appConfig);
  Dox().addServices(services);

  /// register routes
  Route().setRoutes(param.routes);

  /// starting registered services in new isolate;
  await Dox().startServices();

  /// starting server in new isolate
  DoxServer().setResponseHandler(param.config.responseHandler);

  await DoxServer().listen(
    param.config.serverPort,
    isolateId: param.isolateId,
  );
}
