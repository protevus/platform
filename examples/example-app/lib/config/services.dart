import 'package:example_app/services/auth_service.dart';
import 'package:example_app/services/orm_service.dart';
import 'package:example_app/services/websocket_service.dart';
import 'package:illuminate_foundation/foundation.dart';

/// Services to register on dox
/// -------------------------------
/// Since dox run on multi thread isolate, we need to register
/// below extra services to dox.
/// So that dox can register again on new isolate.
List<Service> services = <Service>[
  ORMService(),
  AuthService(),
  WebsocketService(),
];
