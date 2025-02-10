import 'dart:async';

import 'package:illuminate_dbo/src/core/dbo_param.dart';
import 'package:illuminate_dbo/src/core/dbo_result.dart';
import 'package:illuminate_dbo/src/dbo_base.dart';
import 'package:illuminate_dbo/src/dbo_exception.dart';

/// Represents a prepared statement and, after the statement is executed, an associated result set.
class DBOStatement {
  /// Creates a new DBO statement.
  DBOStatement(this._dbo, this._queryString);

  /// The DBO instance that created this statement
  final DBO _dbo;

  /// The original query string
  final String _queryString;

  /// The query with bound parameters interpolated (for emulated prepares)
  String? _activeQueryString;

  /// Whether the statement has been executed
  bool _executed = false;

  /// The number of rows affected by the last execute
  final int _rowCount = 0;

  /// The current result set
  DBOResult? _result;

  /// Bound parameters for the statement
  final Map<String, DBOParam> _boundParams = {};

  /// Bound columns for the result
  final Map<String, DBOParam> _boundColumns = {};

  /// Gets the original query string.
  String get queryString => _queryString;

  /// Gets the number of rows affected by the last execute.
  int get rowCount => _rowCount;

  /// Gets the number of columns in the result set.
  int get columnCount => _result?.columnCount ?? 0;

  /// Binds a parameter to the statement.
  ///
  /// [parameter] can be either a parameter number (1-based) or name.
  /// [value] is the value to bind.
  /// [type] is one of the DBO.PARAM_* constants.
  /// [length] is the maximum length for string parameters.
  /// [driverOptions] are additional driver-specific options.
  bool bindParam(
    dynamic parameter,
    dynamic value, {
    int type = DBO.PARAM_STR,
    int? length,
    dynamic driverOptions,
  }) {
    try {
      var paramName = parameter is String ? parameter : null;
      if (paramName != null && !paramName.startsWith(':')) {
        paramName = ':$paramName';
      }

      final param = DBOParam(
        name: paramName,
        position: parameter is int ? parameter - 1 : -1,
        value: value,
        type: type,
        length: length,
        driverOptions: driverOptions,
      );

      // Validate parameter name/number
      if (param.name != null && param.name!.isEmpty) {
        throw DBOException('Invalid parameter name');
      }
      if (param.position < -1) {
        throw DBOException('Invalid parameter index');
      }

      // Store the parameter
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

  /// Binds a value directly to a parameter.
  bool bindValue(dynamic parameter, dynamic value,
          [int type = DBO.PARAM_STR]) =>
      bindParam(parameter, value, type: type);

  /// Binds a column to a variable.
  bool bindColumn(
    dynamic column,
    dynamic value, {
    int type = DBO.PARAM_STR,
    int? length,
    dynamic driverOptions,
  }) {
    try {
      final param = DBOParam(
        name: column is String ? column : null,
        position: column is int ? column - 1 : -1,
        value: value,
        type: type,
        length: length,
        driverOptions: driverOptions,
      );

      // Store the column binding
      if (param.name != null) {
        _boundColumns[param.name!] = param;
      } else {
        _boundColumns[param.position.toString()] = param;
      }

      return true;
    } catch (e) {
      throw DBOException('Error binding column: $e');
    }
  }

  /// Executes the prepared statement.
  Future<bool> execute([List<dynamic>? parameters]) async {
    try {
      if (parameters != null) {
        // Bind positional parameters
        for (var i = 0; i < parameters.length; i++) {
          bindValue(i + 1, parameters[i]);
        }
      }

      // Execute the statement
      // This will be implemented by database drivers
      throw UnimplementedError();
    } catch (e) {
      throw DBOException(
        'Execute failed: $e',
        statement: _activeQueryString ?? _queryString,
      );
    }
  }

  /// Fetches the next row from the result set.
  Future<dynamic> fetch([int? fetchMode]) async {
    if (!_executed) {
      throw DBOException('Statement must be executed before fetching');
    }

    return _result?.fetch(fetchMode);
  }

  /// Fetches all rows from the result set.
  Future<List<dynamic>> fetchAll([int? fetchMode]) async {
    if (!_executed) {
      throw DBOException('Statement must be executed before fetching');
    }

    return await _result?.fetchAll(fetchMode) ?? [];
  }

  /// Fetches a single column from the next row.
  Future<dynamic> fetchColumn([int columnNumber = 0]) async {
    if (!_executed) {
      throw DBOException('Statement must be executed before fetching');
    }

    return _result?.fetchColumn(columnNumber);
  }

  /// Sets the default fetch mode for this statement.
  bool setFetchMode(int mode) {
    if (!_executed) {
      throw DBOException(
          'Statement must be executed before setting fetch mode');
    }

    _result?.setFetchMode(mode);
    return true;
  }

  /// Gets metadata about a column.
  Map<String, dynamic>? getColumnMeta(dynamic column) {
    if (!_executed) {
      throw DBOException(
          'Statement must be executed before getting column metadata');
    }

    return _result?.getColumnMeta(column);
  }

  /// Advances to the next rowset in a multi-rowset statement.
  Future<bool> nextRowset() async {
    throw UnimplementedError();
  }

  /// Closes the cursor, allowing the statement to be executed again.
  Future<bool> closeCursor() async {
    _result = null;
    _executed = false;
    return true;
  }

  /// Debug dump of parameters - useful for debugging.
  String debugDumpParams() {
    final buffer = StringBuffer();

    buffer.writeln('SQL: [$_queryString]');

    if (_activeQueryString != null && _activeQueryString != _queryString) {
      buffer.writeln('Sent SQL: [$_activeQueryString]');
    }

    buffer.writeln('Params: ${_boundParams.length}');

    _boundParams.forEach((key, param) {
      buffer
        ..writeln('Key: ${param.name ?? 'Position #${param.position}'}')
        ..writeln('paramno=${param.position}')
        ..writeln('name=[${param.name ?? ''}]')
        ..writeln('value=$param.value')
        ..writeln('type=${param.type}');
    });

    return buffer.toString();
  }
}
