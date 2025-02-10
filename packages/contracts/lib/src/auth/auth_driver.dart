import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_database/query_builder.dart';

abstract class AuthDriver {
  Future<Model<dynamic>?> verifyToken(RequestInterface req);

  Future<Model<dynamic>?> attempt(Map<String, dynamic> credentials);

  String? createToken(Map<String, dynamic>? userPayload);
}
