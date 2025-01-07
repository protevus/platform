/// Dart Database Objects an implementation of PHP's PDO (PHP Data Objects) database abstraction layer.
///
/// This library provides a consistent interface for accessing databases in Dart,
/// similar to PHP's PDO extension. It supports multiple database drivers through
/// a single, consistent API.
library dbo;

export 'src/dbo_base.dart' show DBO;
export 'src/dbo_statement.dart' show DBOStatement;
export 'src/dbo_exception.dart' show DBOException;
export 'src/core/dbo_result.dart' show DBOResult;
export 'src/core/dbo_param.dart' show DBOParam;
export 'src/core/dbo_column.dart' show DBOColumn;
