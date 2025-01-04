import 'package:platform_driver_rethinkdb/platform_driver_rethinkdb.dart';

void main() async {
  RethinkDb r = RethinkDb();
  Connection conn = await r.connect(
      db: 'testDB',
      host: "localhost",
      port: 28015,
      user: "admin",
      password: "");

  // Insert data into RethinkDB
  Map createdRecord = await r.table("user_account").insert([
    {
      'id': 1,
      'name': 'William',
      'children': [
        {'id': 1, 'name': 'Robert'},
        {'id': 2, 'name': 'Mariah'}
      ]
    },
    {
      'id': 2,
      'name': 'Peter',
      'children': [
        {'id': 1, 'name': 'Louis'}
      ],
      'nickname': 'Jo'
    },
    {'id': 3, 'name': 'Firstname Last'}
  ]).run(conn);

  print(createdRecord);

  // Retrive data from RethinkDB
  Cursor users =
      await r.table("user_account").filter({'name': 'Peter'}).run(conn);

  List userList = await users.toList();
  print(userList);

  conn.close();
}
