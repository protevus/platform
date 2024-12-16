import 'connection.dart';

/// Interface for Redis connectors.
abstract class Connector {
  /// Create a connection to a Redis cluster.
  Connection connect(Map<String, dynamic> config, Map<String, dynamic> options);

  /// Create a connection to a Redis instance.
  Connection connectToCluster(
    Map<String, dynamic> config,
    Map<String, dynamic> clusterOptions,
    Map<String, dynamic> options,
  );
}
