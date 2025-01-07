/// Exception thrown when PDO encounters an error.
class PDOException implements Exception {
  /// Creates a new PDO exception.
  ///
  /// The [message] parameter is required and describes the error.
  /// Optional [sqlState], [code], [statement], and [errorInfo] can provide more details.
  PDOException(
    this.message, {
    this.sqlState,
    this.code,
    this.statement,
    this.errorInfo,
  }) {
    // Validate required message
    assert(message.isNotEmpty, 'Message should not be empty');

    // Validate optional parameters if provided
    assert(sqlState == null || sqlState!.isNotEmpty,
        'SQLSTATE should not be empty if provided');
    assert(statement == null || statement!.isNotEmpty,
        'Statement should not be empty if provided');
  }

  /// The SQLSTATE error code
  final String? sqlState;

  /// The driver-specific error code
  final int? code;

  /// The error message
  final String message;

  /// The SQL statement that caused the error, if any
  final String? statement;

  /// Additional error information from the driver
  final Map<String, dynamic>? errorInfo;

  @override
  String toString() {
    final buffer = StringBuffer('PDOException: $message');

    if (sqlState != null) {
      buffer.write('\nSQLSTATE[$sqlState]');
    }

    if (code != null) {
      buffer.write('\nDriver Error Code: $code');
    }

    if (statement != null) {
      buffer.write('\nStatement: $statement');
    }

    if (errorInfo != null && errorInfo!.isNotEmpty) {
      buffer.write('\nDriver Error Info: $errorInfo');
    }

    return buffer.toString();
  }
}
