import 'package:pdo/src/core/pdo_column.dart';
import 'package:pdo/src/core/pdo_result.dart';

/// Creates a mock result set for testing.
PDOResult createMockResult({
  List<PDOColumn> columns = const [],
  int rowCount = 0,
}) {
  return PDOResult(columns, columns.length, rowCount);
}

/// Creates a mock column for testing.
PDOColumn createMockColumn({
  required String name,
  required int position,
  int? length,
  int? precision,
  String? type,
  List<String>? flags,
}) =>
    PDOColumn(
      name: name,
      position: position,
      length: length,
      precision: precision,
      type: type,
      flags: flags,
    );

/// Creates a sample set of columns for testing.
List<PDOColumn> createSampleColumns() => [
      createMockColumn(
        name: 'id',
        position: 0,
        type: 'INTEGER',
        length: 11,
        flags: ['NOT_NULL', 'PRIMARY_KEY', 'AUTO_INCREMENT'],
      ),
      createMockColumn(
        name: 'name',
        position: 1,
        type: 'VARCHAR',
        length: 255,
        flags: ['NOT_NULL'],
      ),
      createMockColumn(
        name: 'email',
        position: 2,
        type: 'VARCHAR',
        length: 255,
        flags: ['NOT_NULL', 'UNIQUE'],
      ),
      createMockColumn(
        name: 'created_at',
        position: 3,
        type: 'TIMESTAMP',
        flags: ['NOT_NULL', 'DEFAULT_CURRENT_TIMESTAMP'],
      ),
    ];

/// Creates sample row data for testing.
List<Map<String, dynamic>> createSampleRows() => [
      {
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
        'created_at': '2023-01-01 00:00:00',
      },
      {
        'id': 2,
        'name': 'Jane Smith',
        'email': 'jane@example.com',
        'created_at': '2023-01-02 00:00:00',
      },
    ];
