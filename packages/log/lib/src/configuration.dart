import 'package:logging/logging.dart' as logging;
import 'package:meta/meta.dart';

/// Mixin that provides log configuration parsing functionality.
mixin LogConfiguration {
  /// The mapping of log level strings to their corresponding [Level] values.
  @protected
  final levels = {
    'debug': logging.Level.FINE,
    'info': logging.Level.INFO,
    'notice': logging.Level.INFO, // Dart doesn't have NOTICE, map to INFO
    'warning': logging.Level.WARNING,
    'error': logging.Level.SEVERE,
    'critical': logging.Level.SHOUT,
    'alert': logging.Level.SHOUT, // Dart doesn't have ALERT, map to SHOUT
    'emergency':
        logging.Level.SHOUT, // Dart doesn't have EMERGENCY, map to SHOUT
  };

  /// Get the fallback log channel name.
  ///
  /// This is used when no specific channel is specified.
  @protected
  String getFallbackChannelName();

  /// Parse the string level into a [Level] constant.
  ///
  /// Throws [ArgumentError] if the level is invalid.
  @protected
  logging.Level parseLevel(Map<String, dynamic> config) {
    final level = config['level'] as String? ?? 'debug';

    if (levels.containsKey(level)) {
      return levels[level]!;
    }

    throw ArgumentError('Invalid log level: $level');
  }

  /// Parse the action level from the given configuration.
  ///
  /// This is used for determining when to trigger special logging actions.
  /// Throws [ArgumentError] if the action level is invalid.
  @protected
  logging.Level parseActionLevel(Map<String, dynamic> config) {
    final level = config['action_level'] as String? ?? 'debug';

    if (levels.containsKey(level)) {
      return levels[level]!;
    }

    throw ArgumentError('Invalid log action level: $level');
  }

  /// Extract the log channel from the given configuration.
  ///
  /// If no channel name is specified in the config, returns the fallback channel name.
  @protected
  String parseChannel(Map<String, dynamic> config) {
    return config['name'] as String? ?? getFallbackChannelName();
  }
}
