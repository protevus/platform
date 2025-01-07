/// A Dart implementation of PHP's PDO (PHP Data Objects) database abstraction layer.
///
/// This library provides a consistent interface for accessing databases in Dart,
/// similar to PHP's PDO extension. It supports multiple database drivers through
/// a single, consistent API.
library pdo;

export 'src/pdo_base.dart' show PDO;
export 'src/pdo_statement.dart' show PDOStatement;
export 'src/pdo_exception.dart' show PDOException;
export 'src/core/pdo_result.dart' show PDOResult;
export 'src/core/pdo_param.dart' show PDOParam;
export 'src/core/pdo_column.dart' show PDOColumn;
