import 'package:dsr_log/log.dart';
import 'package:platform_contracts/contracts.dart';
import 'package:platform_contracts/src/foundation/application.dart';
import 'package:platform_support/platform_support.dart';

/// Base class for all logger implementations.
abstract class BaseLogger implements LoggerInterface {
  /// Creates a new [BaseLogger] instance.
  BaseLogger(this.app, this.config);

  /// The application instance.
  final ApplicationContract app;

  /// The logger configuration.
  final Map<String, dynamic> config;

  /// Get the log level from configuration.
  String getLevel() => config['level'] as String? ?? 'debug';

  /// Get the log path from configuration.
  String getPath() => config['path'] as String? ?? defaultPath;

  /// Get the default log path.
  String get defaultPath => '${app.storagePath()}/logs/laravel.log';

  /// Get the log bubble configuration.
  bool getBubble() => config['bubble'] as bool? ?? true;

  /// Get the log permission configuration.
  int? getPermission() => config['permission'] as int?;

  /// Get the log locking configuration.
  bool getLocking() => config['locking'] as bool? ?? false;

  /// Check if the application is running in a specific environment.
  bool isEnvironment(String env) => app.environment([env]) == env;

  /// Check if the application is running in local environment.
  bool get isLocal => isEnvironment('local');

  @override
  void emergency(Object message, [Map<String, dynamic> context = const {}]) {
    log('emergency', message, context);
  }

  @override
  void alert(Object message, [Map<String, dynamic> context = const {}]) {
    log('alert', message, context);
  }

  @override
  void critical(Object message, [Map<String, dynamic> context = const {}]) {
    log('critical', message, context);
  }

  @override
  void error(Object message, [Map<String, dynamic> context = const {}]) {
    log('error', message, context);
  }

  @override
  void warning(Object message, [Map<String, dynamic> context = const {}]) {
    log('warning', message, context);
  }

  @override
  void notice(Object message, [Map<String, dynamic> context = const {}]) {
    log('notice', message, context);
  }

  @override
  void info(Object message, [Map<String, dynamic> context = const {}]) {
    log('info', message, context);
  }

  @override
  void debug(Object message, [Map<String, dynamic> context = const {}]) {
    log('debug', message, context);
  }
}
