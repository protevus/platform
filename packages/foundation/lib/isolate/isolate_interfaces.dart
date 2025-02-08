import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_routing/routing.dart';
import 'package:illuminate_support/support.dart';

class IsolateSpawnParameter {
  final int isolateId;
  final AppConfig config;
  final List<Service> services;
  final List<RouteData> routes;

  const IsolateSpawnParameter(
    this.isolateId,
    this.config,
    this.services, {
    this.routes = const <RouteData>[],
  });
}
