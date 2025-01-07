import 'package:test/test.dart';
import 'package:platform_dbo/dbo.dart';
import 'package:platform_dbo/src/test_helpers/test_utils.dart';

import '../example/mysql_driver.dart';

void main() {
  group('DBOMySql', () {
    late DBOMySql pdo;

    setUp(() {
      pdo = DBOMySql(
        'mysql:host=localhost;dbname=testdb;port=3306',
        'test_user',
        'test_pass',
      );
      pdo.setAttribute(DBO.ATTR_DRIVER_NAME, 'mysql');
    });

    test('parses DSN correctly', () {
      expect(() => DBOMySql('invalid_dsn'), throwsA(isA<DBOException>()));

      final pdo = DBOMySql(
        'mysql:host=127.0.0.1;dbname=mydb;port=3307',
        'user',
        'pass',
      );

      expect(pdo.getAttribute(DBO.ATTR_DRIVER_NAME), equals('mysql'));
      expect(pdo.quote("O'Reilly"), equals("'O\\'Reilly'"));
    });

    test('handles attributes correctly', () {
      pdo.setAttribute(DBO.ATTR_CASE, DBO.CASE_UPPER);
      expect(pdo.getAttribute(DBO.ATTR_CASE), equals(DBO.CASE_UPPER));

      pdo.setAttribute(DBO.ATTR_ERRMODE, DBO.ERRMODE_EXCEPTION);
      expect(pdo.getAttribute(DBO.ATTR_ERRMODE), equals(DBO.ERRMODE_EXCEPTION));
    });

    test('prepares statements', () {
      final stmt = pdo.prepare('SELECT * FROM users WHERE id = ?');
      expect(stmt, isA<DBOStatement>());
      expect(stmt.queryString, equals('SELECT * FROM users WHERE id = ?'));
    });

    test('handles transactions', () {
      expect(pdo.beginTransaction(), isTrue);
      expect(pdo.inTransaction(), isTrue);
      expect(pdo.commit(), isTrue);
      expect(pdo.inTransaction(), isFalse);

      expect(pdo.beginTransaction(), isTrue);
      expect(pdo.rollBack(), isTrue);
      expect(pdo.inTransaction(), isFalse);
    });
  });

  group('DBOMySqlStatement', () {
    late DBOMySql pdo;
    late DBOStatement stmt;

    setUp(() {
      pdo = DBOMySql(
        'mysql:host=localhost;dbname=testdb',
        'test_user',
        'test_pass',
      );
      stmt = pdo.prepare('SELECT * FROM users WHERE id = ? AND name = :name');
    });

    test('binds parameters correctly', () {
      expect(stmt.bindValue(1, 123), isTrue);
      expect(stmt.bindParam(':name', 'John'), isTrue);

      final dump = stmt.debugDumpParams();
      expect(dump,
          contains('SQL: [SELECT * FROM users WHERE id = ? AND name = :name]'));
      expect(dump, contains('Position #0'));
      expect(dump, contains('name=[:name]'));
    });

    test('executes and fetches results', () async {
      // Set up test data
      final testColumns = createSampleColumns();
      final testRows = createSampleRows();

      await stmt.execute([1, 'John']);

      // Test FETCH_ASSOC mode
      stmt.setFetchMode(DBO.FETCH_ASSOC);
      final assocRow = await stmt.fetch();
      expect(assocRow, isA<Map<String, dynamic>>());
      expect(assocRow?['id'], equals(testRows[0]['id']));

      // Test FETCH_NUM mode
      await stmt.execute(); // Reset for next fetch
      stmt.setFetchMode(DBO.FETCH_NUM);
      final numRow = await stmt.fetch();
      expect(numRow, isA<List>());
      expect(numRow?.length, equals(testColumns.length));

      // Test FETCH_OBJ mode
      await stmt.execute(); // Reset for next fetch
      stmt.setFetchMode(DBO.FETCH_OBJ);
      final objRow = await stmt.fetch();
      expect(objRow, isNotNull);
      expect(objRow.toString(), contains('id: ${testRows[0]['id']}'));
      expect(objRow.toString(), contains('name: ${testRows[0]['name']}'));

      // Test column metadata
      final meta = stmt.getColumnMeta(0);
      expect(meta, isNotNull);
      expect(meta!['name'], equals('id'));
      expect(meta['type'], equals('INTEGER'));
      expect(meta['flags'], contains('NOT_NULL'));
    });

    test('handles fetch modes', () async {
      await stmt.execute();

      expect(() => stmt.setFetchMode(999), throwsA(isA<DBOException>()));
      expect(stmt.setFetchMode(DBO.FETCH_ASSOC), isTrue);

      // Reset cursor and fetch with default mode
      await stmt.closeCursor();
      await stmt.execute();
      final rows = await stmt.fetchAll();
      expect(rows.length, equals(2)); // Should match sample data length
      expect(rows[0]['id'], equals(1));
      expect(rows[1]['name'], equals('Jane Smith'));
    });

    test('handles column binding', () {
      expect(
        () => stmt.bindColumn(999, null),
        throwsA(isA<DBOException>()),
      );

      expect(stmt.bindColumn('id', null), isTrue);
      expect(stmt.bindColumn(1, null, type: DBO.PARAM_INT), isTrue);
    });

    test('closes cursor', () async {
      await stmt.execute();
      expect(await stmt.closeCursor(), isTrue);

      // After closing, fetching should throw
      expect(
        () => stmt.fetch(),
        throwsA(isA<DBOException>()),
      );
    });

    test('handles multiple result sets', () async {
      await stmt.execute();
      expect(
        () => stmt.nextRowset(),
        throwsA(isA<DBOException>().having(
          (e) => e.message,
          'message',
          contains('Multiple rowsets not supported'),
        )),
      );
    });
  });

  group('Error handling', () {
    test('throws PDOException with correct information', () {
      final pdo = DBOMySql(
        'mysql:host=localhost;dbname=testdb',
        'test_user',
        'test_pass',
      );

      expect(
        () => pdo.prepare('INVALID SQL !@#'),
        throwsA(isA<DBOException>()
            .having((e) => e.message, 'message', contains('Execute failed'))
            .having((e) => e.sqlState, 'sqlState', equals('42000'))
            .having((e) => e.code, 'code', isNull)
            .having((e) => e.statement, 'statement', isNotNull)),
      );
    });
  });
}
