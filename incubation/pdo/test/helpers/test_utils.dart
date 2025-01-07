import 'package:pdo/pdo.dart';

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

/// A mock PDO driver for testing that doesn't require a real database connection.
class MockPDO implements PDO {
  final Map<int, dynamic> _attributes = {};
  bool _inTransaction = false;

  @override
  dynamic getAttribute(int attribute) => _attributes[attribute];

  @override
  bool setAttribute(int attribute, dynamic value) {
    _attributes[attribute] = value;
    return true;
  }

  @override
  bool beginTransaction() {
    if (_inTransaction) {
      return false;
    }
    _inTransaction = true;
    return true;
  }

  @override
  bool commit() {
    if (!_inTransaction) {
      return false;
    }
    _inTransaction = false;
    return true;
  }

  @override
  bool rollBack() {
    if (!_inTransaction) {
      return false;
    }
    _inTransaction = false;
    return true;
  }

  @override
  bool inTransaction() => _inTransaction;

  @override
  PDOStatement prepare(String statement, [List<dynamic>? driverOptions]) =>
      MockPDOStatement(this, statement);

  @override
  bool exec(String statement) => true;

  @override
  String? lastInsertId([String? name]) => '1';

  @override
  String quote(String string, [int parameterType = PDO.PARAM_STR]) =>
      "'${string.replaceAll("'", "\\'")}'";
}

/// A mock PDO statement for testing.
class MockPDOStatement implements PDOStatement {
  MockPDOStatement(this._pdo, this._queryString);
  final MockPDO _pdo;
  final String _queryString;
  PDOResult? _result;
  bool _executed = false;
  final int _rowCount = 0;
  final Map<String, PDOParam> _boundParams = {};
  final Map<String, PDOParam> _boundColumns = {};

  @override
  String get queryString => _queryString;

  @override
  int get rowCount => _rowCount;

  @override
  int get columnCount => _result?.columnCount ?? 0;

  @override
  Future<bool> execute([List<dynamic>? parameters]) async {
    _executed = true;
    _result = createMockResult(
      columns: createSampleColumns(),
      rowCount: createSampleRows().length,
    );
    return true;
  }

  @override
  Future<bool> closeCursor() async {
    _result = null;
    _executed = false;
    return true;
  }

  @override
  Future<dynamic> fetch([int? fetchMode]) async {
    if (!_executed || _result == null) {
      throw PDOException('Statement must be executed before fetching');
    }
    return _result!.fetch(fetchMode);
  }

  @override
  Future<List<dynamic>> fetchAll([int? fetchMode]) async {
    if (!_executed || _result == null) {
      throw PDOException('Statement must be executed before fetching');
    }
    return _result!.fetchAll(fetchMode);
  }

  @override
  Future<dynamic> fetchColumn([int columnNumber = 0]) async {
    if (!_executed || _result == null) {
      throw PDOException('Statement must be executed before fetching');
    }
    return _result!.fetchColumn(columnNumber);
  }

  @override
  bool bindParam(
    dynamic parameter,
    dynamic value, {
    int type = PDO.PARAM_STR,
    int? length,
    dynamic driverOptions,
  }) {
    final param = PDOParam(
      name: parameter is String ? parameter : null,
      position: parameter is int ? parameter - 1 : -1,
      value: value,
      type: type,
      length: length,
      driverOptions: driverOptions,
    );

    if (param.name != null) {
      _boundParams[param.name!] = param;
    } else {
      _boundParams[param.position.toString()] = param;
    }

    return true;
  }

  @override
  bool bindValue(dynamic parameter, dynamic value,
          [int type = PDO.PARAM_STR]) =>
      bindParam(parameter, value, type: type);

  @override
  bool bindColumn(
    dynamic column,
    dynamic value, {
    int type = PDO.PARAM_STR,
    int? length,
    dynamic driverOptions,
  }) {
    final param = PDOParam(
      name: column is String ? column : null,
      position: column is int ? column - 1 : -1,
      value: value,
      type: type,
      length: length,
      driverOptions: driverOptions,
    );

    if (param.name != null) {
      _boundColumns[param.name!] = param;
    } else {
      _boundColumns[param.position.toString()] = param;
    }

    return true;
  }

  @override
  Map<String, dynamic>? getColumnMeta(dynamic column) =>
      _result?.getColumnMeta(column);

  @override
  bool setFetchMode(int mode) {
    if (_result == null) {
      throw PDOException(
          'Statement must be executed before setting fetch mode');
    }
    _result!.setFetchMode(mode);
    return true;
  }

  @override
  Future<bool> nextRowset() async {
    throw PDOException('Multiple rowsets not supported in mock implementation');
  }

  @override
  String debugDumpParams() {
    final buffer = StringBuffer();
    buffer
      ..writeln('SQL: [$_queryString]')
      ..writeln('Params: ${_boundParams.length}');
    _boundParams.forEach((key, param) {
      buffer
        ..writeln('Key: ${param.name ?? 'Position #${param.position}'}')
        ..writeln('paramno=${param.position}')
        ..writeln('name=[${param.name ?? ''}]')
        ..writeln('value=${param.value}')
        ..writeln('type=${param.type}');
    });
    return buffer.toString();
  }
}
