import '../../eloquent.dart';

abstract class Connector with DetectsLostConnections {
  ///
  /// The default DBO connection options.
  ///
  /// @var array
  ///
  Map<dynamic, dynamic> options = {};

  ///
  /// Get the DBO options based on the configuration.
  ///
  /// @param  array  $config
  /// @return array
  ///
  Map<dynamic, dynamic> getOptions(Map<dynamic, dynamic> config) {
    var optionsP = config['options'];
    //return array_diff_key(options, optionsP) + $options;
    //Utils.map_merge_sd(options, optionsP);
    if (optionsP != null) {
      return {...options, ...optionsP};
    }
    return options;
  }

  ///
  /// Create a new DBO connection.
  ///
  /// @param  string  $dsn
  /// @param  array   $config
  /// @param  array   $options
  /// @return \DBO
  ///
  dynamic createConnection(Map<String, dynamic> config);
}
