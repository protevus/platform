# Belatuk RethinkDB

A dart driver for connecting to RethinkDB, the open-source database for the realtime web. This driver is a fork of [RethinkDB Driver](https://github.com/G0mb/rethink_db) with dependencies upgraded to support Dart 3.

## Getting Started

### Installation

* Start `rethinkDB` as a container service. Refer to [Running rethinkDB](doc/README.md)

* Install from [Pub](https://pub.dev/)

```bash
dart pub add platform_driver_rethinkdb

```

* Or add to the `pubspec.yaml` file

```yaml
dependencies:
  platform_driver_rethinkdb: ^1.0.0
```

* Import the package into your project:

```dart
import 'package:platform_driver_rethinkdb/platform_driver_rethinkdb.dart';
```

### Example

```dart
RethinkDb r = RethinkDb();

final connection = await r.connection(
  db: 'test',
  host: 'localhost',
  port: 28015,
  user: 'admin',
  password: '',
);

// Create table
await r.db('test').tableCreate('tv_shows').run(connection);

// Insert data
await r.table('tv_shows').insert([
      {'name': 'Star Trek TNG', 'episodes': 178},
      {'name': 'Battlestar Galactica', 'episodes': 75}
    ]).run(connection);

// Fetch data
var result = await r.table('tv_shows').get(1).run(connection);
```

## References

* For more information about RethinkDB, please visit [RethinkDB](https://rethinkdb.com/)
* For RethinkDB API documentation, please refer to [RethinkDB API](https://rethinkdb.com/api/javascript/)
