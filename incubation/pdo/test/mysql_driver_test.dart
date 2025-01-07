import 'package:test/test.dart';
import 'package:pdo/pdo.dart';
import 'package:pdo/src/pdo_exception.dart';
import 'package:pdo/src/pdo_statement.dart';
import 'package:pdo/src/test_helpers/test_utils.dart';
import '../example/mysql_driver.dart';

void main() {
  group('PDOMySql', () {
    late PDOMySql pdo;

    setUp(() {
      pdo = PDOMySql(
        'mysql:host=localhost;dbname=testdb;port=3306',
        'test_user',
        'test_pass',
      );
      pdo.setAttribute(PDO.ATTR_DRIVER_NAME, 'mysql');
    });

    test('parses DSN correctly', () {
      expect(() => PDOMySql('invalid_dsn'), throwsA(isA<PDOException>()));

      final pdo = PDOMySql(
        'mysql:host=127.0.0.1;dbname=mydb;port=3307',
        'user',
        'pass',
      );

      expect(pdo.getAttribute(PDO.ATTR_DRIVER_NAME), equals('mysql'));
      expect(pdo.quote("O'Reilly"), equals("'O\\'Reilly'"));
    });

    test('handles attributes correctly', () {
      pdo.setAttribute(PDO.ATTR_CASE, PDO.CASE_UPPER);
      expect(pdo.getAttribute(PDO.ATTR_CASE), equals(PDO.CASE_UPPER));

      pdo.setAttribute(PDO.ATTR_ERRMODE, PDO.ERRMODE_EXCEPTION);
      expect(pdo.getAttribute(PDO.ATTR_ERRMODE), equals(PDO.ERRMODE_EXCEPTION));
    });

    test('prepares statements', () {
      final stmt = pdo.prepare('SELECT * FROM users WHERE id = ?');
      expect(stmt, isA<PDOStatement>());
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

  group('PDOMySqlStatement', () {
    late PDOMySql pdo;
    late PDOStatement stmt;

    setUp(() {
      pdo = PDOMySql(
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

      // Test different fetch modes
      stmt.setFetchMode(PDO.FETCH_ASSOC);
      final assocRow = await stmt.fetch();
      expect(assocRow, isA<Map<String, dynamic>>());
      expect(assocRow?['id'], equals(testRows[0]['id']));

      stmt.setFetchMode(PDO.FETCH_NUM);
      final numRow = await stmt.fetch();
      expect(numRow, isA<List>());
      expect(numRow?.length, equals(testColumns.length));

      stmt.setFetchMode(PDO.FETCH_OBJ);
      final objRow = await stmt.fetch();
      expect(objRow, isNotNull);

      // Test column metadata
      final meta = stmt.getColumnMeta(0);
      expect(meta, isNotNull);
      expect(meta!['name'], equals('id'));
      expect(meta['type'], equals('INTEGER'));
      expect(meta['flags'], contains('NOT_NULL'));
    });

    test('handles fetch modes', () async {
      await stmt.execute();

      expect(() => stmt.setFetchMode(999), throwsA(isA<PDOException>()));
      expect(stmt.setFetchMode(PDO.FETCH_ASSOC), isTrue);

      final rows = await stmt.fetchAll();
      expect(rows.length, equals(2)); // Should match sample data length
      expect(rows[0]['id'], equals(1));
      expect(rows[1]['name'], equals('Jane Smith'));
    });

    test('handles column binding', () {
      expect(
        () => stmt.bindColumn(999, null),
        throwsA(isA<PDOException>()),
      );

      expect(stmt.bindColumn('id', null), isTrue);
      expect(stmt.bindColumn(1, null, type: PDO.PARAM_INT), isTrue);
    });

    test('closes cursor', () async {
      await stmt.execute();
      expect(await stmt.closeCursor(), isTrue);

      // After closing, fetching should throw
      expect(
        () => stmt.fetch(),
        throwsA(isA<PDOException>()),
      );
    });

    test('handles multiple result sets', () async {
      await stmt.execute();
      expect(
        () => stmt.nextRowset(),
        throwsA(isA<PDOException>().having(
          (e) => e.message,
          'message',
          contains('Multiple rowsets not supported'),
        )),
      );
    });
  });

  group('Error handling', () {
    test('throws PDOException with correct information', () {
      final pdo = PDOMySql(
        'mysql:host=localhost;dbname=testdb',
        'test_user',
        'test_pass',
      );

      expect(
        () => pdo.prepare('INVALID SQL !@#'),
        throwsA(isA<PDOException>()
            .having((e) => e.message, 'message', contains('Execute failed'))
            .having((e) => e.sqlState, 'sqlState', equals('42000'))
            .having((e) => e.code, 'code', isNull)
            .having((e) => e.statement, 'statement', isNotNull)),
      );
    });
  });
}
