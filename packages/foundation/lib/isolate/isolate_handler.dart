import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_foundation/isolate/isolate_interfaces.dart';
import 'package:illuminate_foundation/server/server.dart';
import 'package:illuminate_routing/routing.dart';
import 'package:illuminate_support/support.dart';

/// process middleware and controller and sent data via sentPort
void isolateHandler(IsolateSpawnParameter param) async {
  /// send port of main isolate
  AppConfig appConfig = param.config;
  List<Service> services = param.services;

  /// creating dox in new isolate;
  Application().isolateId = param.isolateId;
  Application().initialize(appConfig);
  Application().addServices(services);

  /// register routes
  Route().setRoutes(param.routes);

  /// starting registered services in new isolate;
  await Application().startServices();

  /// starting server in new isolate
  Server().setResponseHandler(param.config.responseHandler);

  await Server().listen(
    param.config.serverPort,
    isolateId: param.isolateId,
  );
}
