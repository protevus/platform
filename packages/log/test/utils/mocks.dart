import 'package:dsr_log/log.dart';
import 'package:platform_contracts/contracts.dart';
import 'package:platform_contracts/src/foundation/application.dart';

/// A mock logger implementation for testing.
class MockLogger implements LoggerInterface {
  final List<LogEntry> logs = [];

  @override
  void log(String level, Object message,
      [Map<String, dynamic> context = const {}]) {
    logs.add(LogEntry(level, message, context));
  }

  @override
  void emergency(Object message, [Map<String, dynamic> context = const {}]) =>
      log('emergency', message, context);

  @override
  void alert(Object message, [Map<String, dynamic> context = const {}]) =>
      log('alert', message, context);

  @override
  void critical(Object message, [Map<String, dynamic> context = const {}]) =>
      log('critical', message, context);

  @override
  void error(Object message, [Map<String, dynamic> context = const {}]) =>
      log('error', message, context);

  @override
  void warning(Object message, [Map<String, dynamic> context = const {}]) =>
      log('warning', message, context);

  @override
  void notice(Object message, [Map<String, dynamic> context = const {}]) =>
      log('notice', message, context);

  @override
  void info(Object message, [Map<String, dynamic> context = const {}]) =>
      log('info', message, context);

  @override
  void debug(Object message, [Map<String, dynamic> context = const {}]) =>
      log('debug', message, context);
}

/// A mock event dispatcher implementation for testing.
class MockEventDispatcher implements EventDispatcherContract {
  final List<dynamic> events = [];

  @override
  List<dynamic>? dispatch(event, [payload = const [], bool halt = false]) {
    events.add(event);
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A mock application implementation for testing.
class MockApplication implements ApplicationContract {
  final Map<String, dynamic> config = {
    'logging': {
      'default': 'single',
      'channels': {
        'single': {
          'driver': 'single',
          'path': '/tmp/logs/test.log',
        },
        'daily': {
          'driver': 'daily',
          'path': '/tmp/logs/daily.log',
          'days': 7,
        },
        'slack': {
          'driver': 'slack',
          'url': 'https://hooks.slack.com/test',
          'channel': '#logs',
        },
        'stack': {
          'driver': 'stack',
          'channels': ['single', 'slack'],
        },
      },
    },
  };

  final Map<Type, dynamic> bindings = {};

  @override
  T make<T>(String abstract, [List parameters = const []]) {
    if (abstract.startsWith('config.')) {
      final parts = abstract.split('.');
      var current = config;
      for (var i = 1; i < parts.length; i++) {
        current = current[parts[i]] as Map<String, dynamic>;
      }
      return current as T;
    }
    return bindings[T] as T;
  }

  @override
  T instance<T>(String abstract, T instance) {
    bindings[T] = instance;
    return instance;
  }

  @override
  String environment(List<String> environments) => 'testing';

  @override
  bool runningUnitTests() => true;

  @override
  String storagePath([String path = '']) => '/tmp';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A log entry for testing.
class LogEntry {
  final String level;
  final Object message;
  final Map<String, dynamic> context;

  LogEntry(this.level, this.message, this.context);

  @override
  String toString() => '[$level] $message $context';
}
