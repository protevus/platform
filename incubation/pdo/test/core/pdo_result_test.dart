import 'package:pdo/pdo.dart';
import 'package:test/test.dart';

import '../helpers/test_utils.dart';

void main() {
  group('PDOResult', () {
    late PDOResult result;
    late List<PDOColumn> columns;
    late List<Map<String, dynamic>> sampleData;

    setUp(() {
      columns = createSampleColumns();
      sampleData = createSampleRows();
      result = createMockResult(
        columns: columns,
        rowCount: sampleData.length,
      );
      result.setTestData(sampleData);
    });

    test('initializes with correct metadata', () {
      expect(result.columnCount, equals(columns.length));
      expect(result.rowCount, equals(sampleData.length));
      expect(result.position, equals(-1));
    });

    test('validates column positions', () {
      // Valid column positions
      expect(
        () => PDOResult(columns, columns.length, sampleData.length),
        returnsNormally,
      );

      // Invalid column positions
      final invalidColumns = [
        createMockColumn(name: 'invalid', position: 999, type: 'INTEGER'),
      ];
      expect(
        () => PDOResult(invalidColumns, invalidColumns.length, 0),
        throwsA(isA<PDOException>()),
      );
    });

    test('handles fetch modes', () {
      // Valid fetch modes
      expect(() => result.setFetchMode(PDO.FETCH_ASSOC), returnsNormally);
      expect(() => result.setFetchMode(PDO.FETCH_NUM), returnsNormally);
      expect(() => result.setFetchMode(PDO.FETCH_BOTH), returnsNormally);
      expect(() => result.setFetchMode(PDO.FETCH_OBJ), returnsNormally);
      expect(() => result.setFetchMode(PDO.FETCH_NAMED), returnsNormally);
      expect(() => result.setFetchMode(PDO.FETCH_KEY_PAIR), returnsNormally);

      // Invalid fetch mode
      expect(
        () => result.setFetchMode(999),
        throwsA(isA<PDOException>()),
      );
    });

    test('gets column metadata', () {
      // By index
      final meta0 = result.getColumnMeta(0);
      expect(meta0, isNotNull);
      expect(meta0!['name'], equals('id'));
      expect(meta0['type'], equals('INTEGER'));
      expect(meta0['flags'], contains('PRIMARY_KEY'));

      // By name
      final metaEmail = result.getColumnMeta('email');
      expect(metaEmail, isNotNull);
      expect(metaEmail!['name'], equals('email'));
      expect(metaEmail['type'], equals('VARCHAR'));
      expect(metaEmail['flags'], contains('UNIQUE'));

      // Invalid column
      expect(result.getColumnMeta(999), isNull);
      expect(result.getColumnMeta('nonexistent'), isNull);
    });

    test('fetches rows in different modes', () async {
      // Create a test result with sample data
      final testData = {
        'id': 1,
        'name': 'John',
        'email': 'john@example.com',
        'created_at': '2023-01-01',
      };

      // FETCH_ASSOC
      result.setFetchMode(PDO.FETCH_ASSOC);
      final assoc = await result.fetch();
      expect(assoc, isA<Map<String, dynamic>>());
      expect(assoc?['id'], equals(sampleData[0]['id']));
      expect(assoc?['name'], equals(sampleData[0]['name']));

      // FETCH_NUM
      result.setFetchMode(PDO.FETCH_NUM);
      final num = await result.fetch();
      expect(num, isA<List>());
      expect(num?.length, equals(columns.length));

      // FETCH_BOTH
      result.setFetchMode(PDO.FETCH_BOTH);
      final both = await result.fetch();
      expect(both, isA<Map>());
      expect(both?['id'], equals(sampleData[0]['id']));
      expect(both?['0'], equals(sampleData[0]['id']));

      // FETCH_OBJ
      result.setFetchMode(PDO.FETCH_OBJ);
      final obj = await result.fetch();
      expect(obj, isNotNull);

      // FETCH_NAMED
      result.setFetchMode(PDO.FETCH_NAMED);
      final named = await result.fetch();
      expect(named, isA<Map>());

      // FETCH_KEY_PAIR (requires exactly 2 columns)
      final keyPairColumns = [
        createMockColumn(name: 'id', position: 0, type: 'INTEGER'),
        createMockColumn(name: 'name', position: 1, type: 'VARCHAR'),
      ];
      final keyPairResult = PDOResult(keyPairColumns, 2, 1);
      keyPairResult.setTestData([
        {'id': 1, 'name': 'John'}
      ]);
      keyPairResult.setFetchMode(PDO.FETCH_KEY_PAIR);
      final keyPair = await keyPairResult.fetch();
      expect(keyPair, isA<Map>());

      // FETCH_KEY_PAIR with wrong number of columns should throw
      result.setFetchMode(PDO.FETCH_KEY_PAIR);
      expect(
        () => result.fetch(),
        throwsA(isA<PDOException>()),
      );
    });

    test('handles invalid fetch modes', () {
      expect(
        () => result.setFetchMode(999),
        throwsA(isA<PDOException>()),
      );
    });

    test('fetches all rows', () async {
      result.setFetchMode(PDO.FETCH_ASSOC);
      final allRows = await result.fetchAll();
      expect(allRows, isA<List>());
      expect(allRows.length, equals(sampleData.length));

      for (var i = 0; i < allRows.length; i++) {
        expect(allRows[i]['id'], equals(sampleData[i]['id']));
        expect(allRows[i]['name'], equals(sampleData[i]['name']));
      }
    });

    test('handles column access errors', () {
      expect(
        () => result.fetchColumn(-1),
        throwsA(isA<PDOException>()),
      );

      expect(
        () => result.fetchColumn(999),
        throwsA(isA<PDOException>()),
      );
    });
  });
}
