import 'package:dsr_log/log.dart';
import 'package:platform_contracts/contracts.dart';
import 'package:platform_support/platform_support.dart';

import 'configuration.dart';
import 'drivers/daily_logger.dart';
import 'drivers/emergency_logger.dart';
import 'drivers/single_logger.dart';
import 'drivers/slack_logger.dart';
import 'drivers/stack_logger.dart';
import 'logger.dart';

import 'package:platform_contracts/src/foundation/application.dart';

/// The log manager instance.
///
/// This class is responsible for creating and managing log channels.
class LogManager with LogConfiguration implements LoggerInterface {
  /// Creates a new [LogManager] instance.
  LogManager(this._app);

  final ApplicationContract _app;
  final Map<String, Logger> _channels = {};
  final Map<String, dynamic> _sharedContext = {};
  final Map<String, LoggerFactory> _customCreators = {};

  /// Build an on-demand log channel.
  Logger build(Map<String, dynamic> config) {
    _channels.remove('ondemand');
    return get('ondemand', config);
  }

  /// Create a new, on-demand aggregate logger instance.
  Logger stack(List<String> channels, [String? channel]) {
    return get(
      channel ?? channels.join('-'),
      {'channels': channels, 'driver': 'stack'},
    );
  }

  /// Get a log channel instance.
  Logger channel([String? channel]) => driver(channel);

  /// Get a log driver instance.
  Logger driver([String? driver]) => get(parseDriver(driver));

  /// Get the default log driver name.
  String? getDefaultDriver() => _app.make<String>('config.logging.default');

  /// Set the default log driver name.
  void setDefaultDriver(String name) {
    _app.instance('config.logging.default', name);
  }

  /// Register a custom driver creator.
  void extend(String driver, LoggerFactory callback) {
    _customCreators[driver] = callback;
  }

  /// Share context across channels and stacks.
  LogManager shareContext(Map<String, dynamic> context) {
    for (final channel in _channels.values) {
      channel.withContext(context);
    }

    _sharedContext.addAll(context);
    return this;
  }

  /// Get the shared context.
  Map<String, dynamic> sharedContext() => _sharedContext;

  /// Flush the log context on all currently resolved channels.
  LogManager withoutContext() {
    for (final channel in _channels.values) {
      channel.withoutContext();
    }
    return this;
  }

  /// Flush the shared context.
  LogManager flushSharedContext() {
    _sharedContext.clear();
    return this;
  }

  /// Get a log channel instance.
  Logger get(String name, [Map<String, dynamic>? config]) {
    try {
      return _channels[name] ??= _createChannel(
        name,
        config ?? configurationFor(name),
      ).withContext(_sharedContext);
    } catch (e) {
      return _createEmergencyLogger()
        ..emergency(
            'Unable to create configured logger. Using emergency logger.', {
          'exception': e,
        });
    }
  }

  /// Create a new channel instance.
  Logger _createChannel(String name, Map<String, dynamic>? config) {
    if (config == null) {
      throw ArgumentError('Log [$name] is not defined.');
    }

    final driver = config['driver'] as String?;

    if (driver == null) {
      throw ArgumentError('Log driver is not defined.');
    }

    if (_customCreators.containsKey(driver)) {
      return _customCreators[driver]!(_app, config);
    }

    return switch (driver) {
      'single' => _createSingleDriver(config),
      'daily' => _createDailyDriver(config),
      'slack' => _createSlackDriver(config),
      'stack' => _createStackDriver(config),
      'custom' => _createCustomDriver(config),
      _ => throw ArgumentError('Driver [$driver] is not supported.'),
    };
  }

  /// Create an emergency log handler to avoid silent failures.
  Logger _createEmergencyLogger() {
    final config = configurationFor('emergency');
    final path =
        config?['path'] as String? ?? '${_app.storagePath()}/logs/laravel.log';

    return Logger(
      EmergencyLogger(_app, path),
      _app.make<EventDispatcherContract>('events'),
    );
  }

  /// Create an instance of the single file log driver.
  Logger _createSingleDriver(Map<String, dynamic> config) {
    return Logger(
      SingleLogger(_app, config),
      _app.make<EventDispatcherContract>('events'),
    );
  }

  /// Create an instance of the daily file log driver.
  Logger _createDailyDriver(Map<String, dynamic> config) {
    return Logger(
      DailyLogger(_app, config),
      _app.make<EventDispatcherContract>('events'),
    );
  }

  /// Create an instance of the Slack log driver.
  Logger _createSlackDriver(Map<String, dynamic> config) {
    return Logger(
      SlackLogger(_app, config),
      _app.make<EventDispatcherContract>('events'),
    );
  }

  /// Create an instance of the "stack" log driver.
  Logger _createStackDriver(Map<String, dynamic> config) {
    final channels = config['channels'] as List<String>;
    final handlers = channels.map((channel) => this.channel(channel)).toList();

    return Logger(
      StackLogger(_app, config, handlers),
      _app.make<EventDispatcherContract>('events'),
    );
  }

  /// Create a custom log driver instance.
  Logger _createCustomDriver(Map<String, dynamic> config) {
    final factory = config['via'];
    if (factory == null) {
      throw ArgumentError('Custom logger factory not provided.');
    }

    if (factory is LoggerFactory) {
      return factory(_app, config);
    }

    return _app.make<LoggerFactory>(factory)(_app, config);
  }

  /// Get the log connection configuration.
  Map<String, dynamic>? configurationFor(String name) {
    return _app.make<Map<String, dynamic>>('config.logging.channels.$name');
  }

  @override
  String getFallbackChannelName() {
    return _app.environment(['local', 'staging', 'production']) ?? 'production';
  }

  /// Parse the driver name.
  String parseDriver(String? driver) {
    driver ??= getDefaultDriver();

    if (_app.runningUnitTests()) {
      driver ??= 'null';
    }

    return driver ?? getFallbackChannelName();
  }

  /// Forward log calls to the default driver.
  @override
  void emergency(Object message, [Map<String, dynamic> context = const {}]) {
    driver().emergency(message, context);
  }

  @override
  void alert(Object message, [Map<String, dynamic> context = const {}]) {
    driver().alert(message, context);
  }

  @override
  void critical(Object message, [Map<String, dynamic> context = const {}]) {
    driver().critical(message, context);
  }

  @override
  void error(Object message, [Map<String, dynamic> context = const {}]) {
    driver().error(message, context);
  }

  @override
  void warning(Object message, [Map<String, dynamic> context = const {}]) {
    driver().warning(message, context);
  }

  @override
  void notice(Object message, [Map<String, dynamic> context = const {}]) {
    driver().notice(message, context);
  }

  @override
  void info(Object message, [Map<String, dynamic> context = const {}]) {
    driver().info(message, context);
  }

  @override
  void debug(Object message, [Map<String, dynamic> context = const {}]) {
    driver().debug(message, context);
  }

  @override
  void log(String level, Object message,
      [Map<String, dynamic> context = const {}]) {
    driver().log(level, message, context);
  }
}

/// A factory function for creating custom loggers.
typedef LoggerFactory = Logger Function(
    ApplicationContract app, Map<String, dynamic> config);
