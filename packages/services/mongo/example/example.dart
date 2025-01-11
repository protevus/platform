import 'package:platform_container/mirrors.dart';
import 'package:platform_foundation/core.dart';
import 'package:platform_mongo/angel3_mongo.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  var app = Application(reflector: MirrorsReflector());
  var db = Db('mongodb://localhost:27017/testDB');
  await db.open();
  await db.authenticate("root", "Qwerty", authDb: "admin");

  var service = app.use('/api/users', MongoService(db.collection('users')));

  service.afterCreated.listen((event) {
    print('New user: ${event.result}');
  });
}
