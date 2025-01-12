import 'dart:async';
import 'dart:convert';

import 'package:platform_dbo/dbo.dart';
import '../contracts/session_driver.dart';

/// A session driver that stores sessions in a database.
class DatabaseSessionDriver implements SessionDriver {
  final DBO _db;
  final String _table;
  final JsonCodec _json;

  /// Creates a new database session driver.
  ///
  /// The [db] parameter is the DBO instance to use.
  /// The [table] parameter is the name of the sessions table (defaults to 'sessions').
  DatabaseSessionDriver(
    this._db, {
    String table = 'sessions',
    JsonCodec? json,
  })  : _table = table,
        _json = json ?? const JsonCodec() {
    _createTable();
  }

  Future<void> _createTable() async {
    // Table creation is handled by migrations
  }

  @override
  Future<Map<String, dynamic>?> read(String id) async {
    final stmt = _db.prepare('''
      SELECT payload FROM $_table 
      WHERE id = ? AND last_activity > ?
    ''');

    stmt.bindValue(1, id, DBO.PARAM_STR);
    stmt.bindValue(
      2,
      DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      DBO.PARAM_STR,
    );

    await stmt.execute();
    final row = await stmt.fetch(DBO.FETCH_ASSOC);
    if (row == null) {
      return null;
    }

    try {
      return _json.decode(row['payload'] as String) as Map<String, dynamic>;
    } catch (_) {
      await destroy(id);
      return null;
    }
  }

  @override
  Future<void> write(String id, Map<String, dynamic> data) async {
    final stmt = _db.prepare('''
      INSERT INTO $_table (id, payload, last_activity)
      VALUES (?, ?, ?)
      ON DUPLICATE KEY UPDATE
        payload = VALUES(payload),
        last_activity = VALUES(last_activity)
    ''');

    stmt.bindValue(1, id, DBO.PARAM_STR);
    stmt.bindValue(2, _json.encode(data), DBO.PARAM_STR);
    stmt.bindValue(3, DateTime.now().toIso8601String(), DBO.PARAM_STR);

    await stmt.execute();
  }

  @override
  Future<void> destroy(String id) async {
    final stmt = _db.prepare('DELETE FROM $_table WHERE id = ?');
    stmt.bindValue(1, id, DBO.PARAM_STR);
    await stmt.execute();
  }

  @override
  Future<List<String>> all() async {
    final stmt = _db.prepare('SELECT id FROM $_table');
    await stmt.execute();
    final rows = await stmt.fetchAll(DBO.FETCH_ASSOC);
    return rows.map((row) => row['id'] as String).toList(growable: false);
  }

  @override
  Future<void> gc(Duration lifetime) async {
    final stmt = _db.prepare('DELETE FROM $_table WHERE last_activity < ?');
    stmt.bindValue(
      1,
      DateTime.now().subtract(lifetime).toIso8601String(),
      DBO.PARAM_STR,
    );
    await stmt.execute();
  }
}
