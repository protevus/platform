import 'package:symfony/http_foundation.dart';

abstract class SupportsBasicAuth {
  /// Attempt to authenticate using HTTP Basic Auth.
  ///
  /// @param  String  field
  /// @param  Map<String, dynamic>  extraConditions
  /// @return Response|null
  Response? basic({String field = 'email', Map<String, dynamic> extraConditions = const {}});

  /// Perform a stateless HTTP Basic login attempt.
  ///
  /// @param  String  field
  /// @param  Map<String, dynamic>  extraConditions
  /// @return Response|null
  Response? onceBasic({String field = 'email', Map<String, dynamic> extraConditions = const {}});
}
