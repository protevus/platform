import 'package:platform_dbo/dbo.dart';
import 'package:platform_dbo/src/dbo_base.dart';
import 'package:platform_dbo/src/dbo_statement.dart';
import 'package:platform_dbo/src/dbo_exception.dart';
import 'package:platform_dbo/src/core/dbo_result.dart';
import 'package:platform_dbo/src/core/dbo_column.dart';
import 'package:platform_dbo/src/test_helpers/test_utils.dart';

/// Example implementation of a MySQL DBO driver.
/// This is just a demonstration and not a complete implementation.
class DBOMySql implements DBO {
  String _host = 'localhost';
  int _port = 3306;
  String? _database;
  Map<String, String> _options = {};
  final Map<int, dynamic> _attributes = {};

  /// The DSN (Data Source Name) used to connect to the database
  final String _dsn;

  /// The username used to connect to the database
  final String? _username;

  /// The password used to connect to the database
  final String? _password;

  /// The driver options used when connecting
  final Map<int, dynamic>? _driverOptions;

  DBOMySql(
    this._dsn, [
    this._username,
    this._password,
    this._driverOptions,
  ]) {
    _parseDsn(_dsn);
    _initializeConnection();
  }

  void _parseDsn(String dsn) {
    // Parse DSN string like: mysql:host=localhost;dbname=testdb;port=3306
    if (!dsn.startsWith('mysql:')) {
      throw DBOException('Invalid DSN format for MySQL');
    }

    final parts = dsn.substring(6).split(';');
    for (final part in parts) {
      final keyValue = part.split('=');
      if (keyValue.length != 2) continue;

      final key = keyValue[0].trim();
      final value = keyValue[1].trim();

      switch (key) {
        case 'host':
          _host = value;
          break;
        case 'port':
          _port = int.tryParse(value) ?? 3306;
          break;
        case 'dbname':
          _database = value;
          break;
        default:
          _options[key] = value;
      }
    }
  }

  void _initializeConnection() {
    // Set default attributes
    _attributes[DBO.ATTR_CASE] = DBO.CASE_NATURAL;
    _attributes[DBO.ATTR_ERRMODE] = DBO.ERRMODE_SILENT;
    _attributes[DBO.ATTR_ORACLE_NULLS] = DBO.NULL_NATURAL;
    _attributes[DBO.ATTR_STRINGIFY_FETCHES] = false;
    _attributes[DBO.ATTR_EMULATE_PREPARES] = true;
    _attributes[DBO.ATTR_DEFAULT_FETCH_MODE] = DBO.FETCH_BOTH;
    _attributes[DBO.ATTR_DRIVER_NAME] = 'mysql';
  }

  @override
  dynamic getAttribute(int attribute) {
    return _attributes[attribute];
  }

  @override
  bool setAttribute(int attribute, dynamic value) {
    _attributes[attribute] = value;
    return true;
  }

  @override
  DBOStatement prepare(String statement, [List<dynamic>? driverOptions]) {
    if (!statement.trim().toUpperCase().startsWith('SELECT')) {
      throw DBOException(
        'Execute failed: Invalid SQL statement',
        sqlState: '42000',
        statement: statement,
      );
    }
    return DBOMySqlStatement(this, statement);
  }

  bool _inTransaction = false;

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
  bool inTransaction() {
    return _inTransaction;
  }

  @override
  bool exec(String statement) {
    // Implement direct execution
    return true;
  }

  @override
  String? lastInsertId([String? name]) {
    // Implement last insert ID retrieval
    return null;
  }

  @override
  String quote(String string, [int parameterType = DBO.PARAM_STR]) {
    // Implement MySQL-specific string quoting
    return "'${string.replaceAll("'", "\\'")}'";
  }
}

/// MySQL-specific statement implementation
class DBOMySqlStatement implements DBOStatement {
  final DBOMySql _pdo;
  final String _queryString;
  DBOResult? _result;
  bool _executed = false;
  int _rowCount = 0;
  final Map<String, DBOParam> _boundParams = {};

  DBOMySqlStatement(this._pdo, this._queryString);

  @override
  String get queryString => _queryString;

  @override
  int get rowCount => _rowCount;

  @override
  int get columnCount => _result?.columnCount ?? 0;

  @override
  Future<bool> execute([List<dynamic>? parameters]) async {
    try {
      // Mock execution for testing
      final columns = createSampleColumns();
      final testData = createSampleRows();

      _result = DBOResult(columns, columns.length, testData.length);
      _result!.setTestData(testData);
      _executed = true;
      _rowCount = testData.length;

      // Reset position to start for fresh fetching
      final defaultMode = _pdo.getAttribute(DBO.ATTR_DEFAULT_FETCH_MODE);
      _result!.setFetchMode(defaultMode is int ? defaultMode : DBO.FETCH_BOTH);
      return true;
    } catch (e) {
      throw DBOException(
        'Execute failed: $e',
        sqlState: '42000',
        statement: _queryString,
      );
    }
  }

  @override
  Future<bool> closeCursor() async {
    // Close MySQL statement and free resources
    _result = null;
    _executed = false;
    return true;
  }

  @override
  Future<dynamic> fetch([int? fetchMode]) async {
    if (!_executed || _result == null) {
      throw DBOException('Statement must be executed before fetching');
    }

    // Use the provided fetch mode or the current mode
    if (fetchMode != null) {
      _result!.setFetchMode(fetchMode);
    }

    return _result!.fetch();
  }

  @override
  Future<List<dynamic>> fetchAll([int? fetchMode]) async {
    if (!_executed || _result == null) {
      throw DBOException('Statement must be executed before fetching');
    }
    return _result!.fetchAll(fetchMode);
  }

  @override
  bool bindParam(
    dynamic parameter,
    dynamic value, {
    int type = DBO.PARAM_STR,
    int? length,
    dynamic driverOptions,
  }) {
    try {
      final param = DBOParam(
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
    } catch (e) {
      throw DBOException('Error binding parameter: $e');
    }
  }

  @override
  bool bindValue(dynamic parameter, dynamic value, [int type = DBO.PARAM_STR]) {
    return bindParam(parameter, value, type: type);
  }

  @override
  Map<String, dynamic>? getColumnMeta(dynamic column) {
    return _result?.getColumnMeta(column);
  }

  @override
  bool setFetchMode(int mode) {
    if (_result == null) {
      throw DBOException(
          'Statement must be executed before setting fetch mode');
    }
    _result!.setFetchMode(mode);
    return true;
  }

  @override
  bool bindColumn(
    dynamic column,
    dynamic value, {
    int type = DBO.PARAM_STR,
    int? length,
    dynamic driverOptions,
  }) {
    try {
      // Execute first to ensure we have column metadata
      if (!_executed) {
        execute();
      }

      final param = DBOParam(
        name: column is String ? column : null,
        position: column is int ? column - 1 : -1,
        value: value,
        type: type,
        length: length,
        driverOptions: driverOptions,
      );

      // Validate column exists
      if (param.position >= 0) {
        if (_result == null || param.position >= _result!.columnCount) {
          throw DBOException('Invalid column index');
        }
      } else if (param.name != null) {
        if (_result == null || _result!.getColumnMeta(param.name) == null) {
          throw DBOException('Column not found: ${param.name}');
        }
      }

      return true;
    } catch (e) {
      throw DBOException('Error binding column: $e');
    }
  }

  @override
  Future<dynamic> fetchColumn([int columnNumber = 0]) async {
    if (!_executed || _result == null) {
      throw DBOException('Statement must be executed before fetching');
    }
    return _result!.fetchColumn(columnNumber);
  }

  @override
  Future<bool> nextRowset() async {
    // For MySQL, this would move to the next result set if the query
    // returned multiple result sets (e.g., from stored procedures)
    throw DBOException('Multiple rowsets not supported');
  }

  @override
  String debugDumpParams() {
    final buffer = StringBuffer();
    buffer.writeln('SQL: [$_queryString]');
    buffer.writeln('Params: ${_boundParams.length}');

    _boundParams.forEach((key, param) {
      if (param.name != null) {
        buffer.writeln('Key: ${param.name}');
        buffer.writeln('paramno=${param.position}');
        buffer.writeln('name=[${param.name}]');
      } else {
        buffer.writeln('Key: Position #${param.position}');
        buffer.writeln('paramno=${param.position}');
        buffer.writeln('name=[]');
      }
      buffer.writeln('value=${param.value}');
      buffer.writeln('type=${param.type}');
    });

    return buffer.toString();
  }
}

void main() async {
  // Example usage of MySQL driver
  try {
    final dbo = DBOMySql(
      'mysql:host=localhost;dbname=testdb;port=3306',
      'username',
      'password',
    );

    // Set error mode to throw exceptions
    dbo.setAttribute(DBO.ATTR_ERRMODE, DBO.ERRMODE_EXCEPTION);

    // Test invalid SQL to trigger error
    try {
      dbo.prepare('INVALID SQL !@#');
      throw Exception('Should have thrown PDOException');
    } on DBOException catch (e) {
      print('Expected error: ${e.message}');
    }

    // Prepare and execute a valid statement
    final stmt = dbo.prepare('SELECT * FROM users WHERE id = ?');
    await stmt.execute([1]);

    // Fetch results
    final result = await stmt.fetchAll(DBO.FETCH_ASSOC);
    print(result);

    // Clean up
    await stmt.closeCursor();
  } on DBOException catch (e) {
    print('Database error: ${e.message}');
    if (e.sqlState != null) {
      print('SQLSTATE: ${e.sqlState}');
    }
  }
}
