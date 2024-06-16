
import 'connection.dart';

abstract class Connector {
  /// Create a connection to a Redis cluster.
  ///
  /// @param config
  /// @param options
  /// @return Connection
  Connection connect(Map<String, dynamic> config, Map<String, dynamic> options);

  /// Create a connection to a Redis instance.
  ///
  /// @param config
  /// @param clusterOptions
  /// @param options
  /// @return Connection
  Connection connectToCluster(Map<String, dynamic> config, Map<String, dynamic> clusterOptions, Map<String, dynamic> options);
}
