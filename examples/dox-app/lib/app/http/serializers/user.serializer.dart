import 'package:illuminate_foundation/dox_core.dart';

import '../../../app/models/user/user.model.dart';

class UserSerializer extends Serializer<User> {
  UserSerializer(super.data);

  @override
  Map<String, dynamic> convert(User m) {
    return m.toJson();
  }
}
