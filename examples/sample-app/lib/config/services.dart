import 'package:illuminate_support/support.dart';
import 'package:sample_app/services/orm_service.dart';

/// Services to register on dox
/// -------------------------------
/// Since dox run on multi thread isolate, we need to register
/// below extra services to dox so that dox can
/// register again on new isolate.
List<Service> services = <Service>[
  ORMService(),
];
