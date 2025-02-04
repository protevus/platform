import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_foundation/router/route_data.dart';

class IsolateSpawnParameter {
  final int isolateId;
  final AppConfig config;
  final List<DoxService> services;
  final List<RouteData> routes;

  const IsolateSpawnParameter(
    this.isolateId,
    this.config,
    this.services, {
    this.routes = const <RouteData>[],
  });
}
