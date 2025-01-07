import '../pdo/core/pdo_interface.dart';

abstract class ConnectorInterface {
  ///
  /// Establish a database connection.
  ///
  /// @param  array  $config
  /// @return \DBO
  ///
  Future<PDOInterface> connect(Map<String, dynamic> config);
}
