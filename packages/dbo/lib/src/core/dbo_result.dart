import 'dart:async';

import '../dbo_base.dart';
import '../dbo_exception.dart';
import 'dbo_column.dart';

/// Represents a DBO result set that provides access to query results.
class DBOResult {
  /// The columns in the result set
  final List<DBOColumn> _columns;

  /// The number of columns in the result set
  final int _columnCount;

  /// Current row position
  int _position = -1;

  /// The number of rows affected by the last execute
  final int _rowCount;

  /// Current fetch mode
  int _fetchMode;

  /// Current row data
  Map<String, dynamic>? _currentRow;

  /// Test data for mocking results
  final List<Map<String, dynamic>> _testData = [];

  /// Creates a new DBO result set.
  DBOResult(this._columns, this._columnCount, this._rowCount)
      : _fetchMode = DBO.FETCH_BOTH {
    _validateColumns();
  }

  /// Gets the number of rows in the result set.
  int get rowCount => _rowCount;

  /// Gets the number of columns in the result set.
  int get columnCount => _columnCount;

  /// Gets the current row number (0-based).
  int get position => _position;

  /// Sets test data for the result set (used in testing)
  void setTestData(List<Map<String, dynamic>> data) {
    _testData.clear();
    _testData.addAll(data);
  }

  /// Validates column metadata and normalizes column names if needed.
  void _validateColumns() {
    if (_columns.isEmpty) return;

    // Validate column indices
    for (var i = 0; i < _columns.length; i++) {
      if (_columns[i].position != i) {
        throw DBOException('Invalid column position for ${_columns[i].name}');
      }
    }
  }

  /// Sets the fetch mode for subsequent fetches.
  void setFetchMode(int mode) {
    if (![
      DBO.FETCH_ASSOC,
      DBO.FETCH_NUM,
      DBO.FETCH_BOTH,
      DBO.FETCH_OBJ,
      DBO.FETCH_BOUND,
      DBO.FETCH_COLUMN,
      DBO.FETCH_KEY_PAIR,
      DBO.FETCH_NAMED,
    ].contains(mode)) {
      throw DBOException('Invalid fetch mode');
    }
    _fetchMode = mode;
  }

  /// Fetches the next row from the result set.
  Future<dynamic> fetch([int? fetchMode]) async {
    fetchMode ??= _fetchMode;

    if (!moveNext()) {
      return null;
    }

    if (_currentRow == null) {
      return null;
    }

    return _formatRow(_currentRow!, fetchMode);
  }

  /// Fetches all remaining rows from the result set.
  Future<List<dynamic>> fetchAll([int? fetchMode]) async {
    fetchMode ??= _fetchMode;

    // Reset position to start
    _position = -1;

    final List<dynamic> results = [];
    while (moveNext()) {
      if (_currentRow != null) {
        results.add(_formatRow(_currentRow!, fetchMode));
      }
    }
    return results;
  }

  /// Fetches a single column from the next row.
  Future<dynamic> fetchColumn([int columnNumber = 0]) async {
    if (columnNumber < 0 || columnNumber >= _columnCount) {
      throw DBOException('Invalid column index');
    }

    if (!moveNext() || _currentRow == null) {
      return null;
    }

    if (columnNumber >= _columns.length) {
      throw DBOException('Column index out of bounds');
    }

    final column = _columns[columnNumber];
    return _currentRow![column.name];
  }

  /// Formats a row according to the fetch mode.
  dynamic _formatRow(Map<String, dynamic> row, int fetchMode) {
    switch (fetchMode) {
      case DBO.FETCH_ASSOC:
        return Map<String, dynamic>.from(row);

      case DBO.FETCH_NUM:
        return row.values.toList();

      case DBO.FETCH_BOTH:
        final both = Map<String, dynamic>.from(row);
        var index = 0;
        row.forEach((_, value) {
          both[index.toString()] = value;
          index++;
        });
        return both;

      case DBO.FETCH_OBJ:
        return _RowObject(row);

      case DBO.FETCH_NAMED:
        final named = <String, dynamic>{};
        row.forEach((key, value) {
          if (named.containsKey(key)) {
            if (named[key] is! List) {
              named[key] = [named[key]];
            }
            (named[key] as List).add(value);
          } else {
            named[key] = value;
          }
        });
        return named;

      case DBO.FETCH_KEY_PAIR:
        if (_columnCount != 2) {
          throw DBOException(
              'FETCH_KEY_PAIR requires exactly 2 columns in result set');
        }
        if (_columns.isEmpty) {
          throw DBOException('No columns available');
        }
        final key = row[_columns[0].name];
        final value = _columns.length > 1 ? row[_columns[1].name] : null;
        return {key: value};

      default:
        throw DBOException('Invalid fetch mode');
    }
  }

  /// Gets metadata about a column.
  Map<String, dynamic>? getColumnMeta(dynamic column) {
    int colIndex;

    if (column is int) {
      colIndex = column;
    } else if (column is String) {
      colIndex = _columns.indexWhere((col) => col.name == column);
    } else {
      throw DBOException('Invalid column identifier');
    }

    if (colIndex < 0 || colIndex >= _columnCount) {
      return null;
    }

    final col = _columns[colIndex];
    return {
      'name': col.name,
      'length': col.length,
      'precision': col.precision,
      'type': col.type,
      'flags': col.flags,
    };
  }

  /// Moves to the next row in the result set.
  bool moveNext() {
    if (_position >= _rowCount - 1) {
      _currentRow = null;
      return false;
    }

    _position++;

    // For testing, use test data if available
    if (_testData.isNotEmpty && _position < _testData.length) {
      _currentRow = Map<String, dynamic>.from(_testData[_position]);
      return true;
    }

    // In real implementation, this would fetch from the database driver
    return false;
  }

  /// Gets the current row.
  Map<String, dynamic> get current {
    if (_currentRow == null) {
      throw StateError('No row available');
    }
    return Map<String, dynamic>.from(_currentRow!);
  }
}

/// A wrapper class that makes a Map behave like an object with properties.
class _RowObject {
  final Map<String, dynamic> _data;

  _RowObject(this._data);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      final name = invocation.memberName.toString().split('"')[1];
      if (_data.containsKey(name)) {
        return _data[name];
      }
    }
    return super.noSuchMethod(invocation);
  }

  @override
  String toString() => _data.toString();
}
