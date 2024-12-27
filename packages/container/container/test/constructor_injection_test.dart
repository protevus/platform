import 'package:test/test.dart';
import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';

// Test interfaces
abstract class Logger {
  void log(String message);
}

abstract class Config {
  String get value;
}

abstract class Database {
  void connect();
}

// Test implementations
class ConsoleLogger implements Logger {
  @override
  void log(String message) {}
}

class FileConfig implements Config {
  @override
  String get value => 'test';
}

class SqlDatabase implements Database {
  final Logger logger;
  final Config config;

  SqlDatabase(this.logger, this.config);

  @override
  void connect() {}
}

// Tracking implementations for dependency order test
class TrackingLogger implements Logger {
  final List<String> order;
  static int instanceCount = 0;

  TrackingLogger(this.order) {
    instanceCount++;
    order.add('logger');
  }

  @override
  void log(String message) {}
}

class TrackingConfig implements Config {
  final List<String> order;
  static int instanceCount = 0;

  TrackingConfig(this.order) {
    instanceCount++;
    order.add('config');
  }

  @override
  String get value => 'test';
}

class TrackingDatabase implements Database {
  final Logger logger;
  final Config config;
  final List<String> order;
  static int instanceCount = 0;

  TrackingDatabase(this.logger, this.config, this.order) {
    instanceCount++;
    order.add('database');
  }

  @override
  void connect() {}
}

// Custom config for multiple instances test
class CustomConfig implements Config {
  final String _value;

  CustomConfig(this._value);

  @override
  String get value => _value;
}

// Test service with multiple dependencies
class UserService {
  final Logger logger;
  final Database db;
  final Config config;

  UserService(this.logger, this.db, this.config);
}

// Test service with optional dependencies
class OptionalDepsService {
  final Logger logger;
  final Config? config;

  OptionalDepsService(this.logger, [this.config]);
}

// Test service with named parameters
class NamedParamsService {
  final Logger logger;
  final Config? config;

  NamedParamsService(this.logger, {this.config});
}

// Test service with mixed parameters
class MixedParamsService {
  final Logger logger;
  final Database db;
  final Config? config;
  final String? name;

  MixedParamsService(this.logger, this.db, {this.config, this.name});
}

// Test service with nested dependencies
class NestedService {
  final UserService userService;
  final Logger logger;

  NestedService(this.userService, this.logger);
}

void main() {
  group('Constructor Injection Tests', () {
    late Container container;

    setUp(() {
      container = Container(MirrorsReflector());
      container.bind(Logger).to(ConsoleLogger);
      container.bind(Config).to(FileConfig);
      container.bind(Database).to(SqlDatabase);

      // Reset tracking counters
      TrackingLogger.instanceCount = 0;
      TrackingConfig.instanceCount = 0;
      TrackingDatabase.instanceCount = 0;
    });

    test('injects basic dependencies', () {
      var service = container.make<UserService>();

      expect(service, isNotNull);
      expect(service.logger, isA<ConsoleLogger>());
      expect(service.config, isA<FileConfig>());
      expect(service.db, isA<SqlDatabase>());
    });

    test('injects nested dependencies', () {
      var service = container.make<NestedService>();

      expect(service, isNotNull);
      expect(service.logger, isA<ConsoleLogger>());
      expect(service.userService, isA<UserService>());
      expect(service.userService.logger, isA<ConsoleLogger>());
      expect(service.userService.config, isA<FileConfig>());
      expect(service.userService.db, isA<SqlDatabase>());
    });

    test('handles optional dependencies', () {
      container = Container(MirrorsReflector());
      container.bind(Logger).to(ConsoleLogger);

      var service = container.make<OptionalDepsService>();
      expect(service, isNotNull);
      expect(service.logger, isA<ConsoleLogger>());
      expect(service.config, isNull);

      // Now bind config and verify it gets injected
      container.bind(Config).to(FileConfig);
      service = container.make<OptionalDepsService>();
      expect(service.config, isA<FileConfig>());
    });

    test('handles named parameters', () {
      container = Container(MirrorsReflector());
      container.bind(Logger).to(ConsoleLogger);

      var service = container.make<NamedParamsService>();
      expect(service, isNotNull);
      expect(service.logger, isA<ConsoleLogger>());
      expect(service.config, isNull);

      // Now bind config and verify it gets injected
      container.bind(Config).to(FileConfig);
      service = container.make<NamedParamsService>();
      expect(service.config, isA<FileConfig>());
    });

    test('handles mixed parameters', () {
      var service = container.makeWith<MixedParamsService>({'name': 'test'});

      expect(service, isNotNull);
      expect(service.logger, isA<ConsoleLogger>());
      expect(service.db, isA<SqlDatabase>());
      expect(service.config, isNull);
      expect(service.name, equals('test'));

      // Now bind config and verify it gets injected
      container.bind(Config).to(FileConfig);
      service = container.make<MixedParamsService>();
      expect(service.config, isA<FileConfig>());
    });

    test('handles parameter overrides', () {
      var customConfig = FileConfig();
      var service = container.makeWith<UserService>({'config': customConfig});

      expect(service, isNotNull);
      expect(service.logger, isA<ConsoleLogger>());
      expect(service.config, same(customConfig));
    });

    test('resolves dependencies in correct order', () {
      var order = <String>[];

      container = Container(MirrorsReflector());
      container.registerSingleton<Logger>(TrackingLogger(order));
      container.registerSingleton<Config>(TrackingConfig(order));
      container.registerSingleton<Database>(TrackingDatabase(
          container.make<Logger>(), container.make<Config>(), order));

      // Create service and verify order
      container.make<UserService>();

      expect(order, equals(['logger', 'config', 'database']));
      expect(TrackingLogger.instanceCount, equals(1),
          reason: 'Logger should be instantiated once');
      expect(TrackingConfig.instanceCount, equals(1),
          reason: 'Config should be instantiated once');
      expect(TrackingDatabase.instanceCount, equals(1),
          reason: 'Database should be instantiated once');
    });

    test('throws on missing required dependency', () {
      container =
          Container(MirrorsReflector()); // Fresh container with no bindings

      expect(() => container.make<UserService>(),
          throwsA(isA<BindingResolutionException>()));
    });

    test('handles multiple instances with different configurations', () {
      var container1 = Container(MirrorsReflector());
      var container2 = Container(MirrorsReflector());

      container1.bind(Logger).to(ConsoleLogger);
      container2.bind(Logger).to(ConsoleLogger);
      container1.bind(Database).to(SqlDatabase);
      container2.bind(Database).to(SqlDatabase);

      container1.registerSingleton<Config>(CustomConfig('config1'));
      container2.registerSingleton<Config>(CustomConfig('config2'));

      var service1 = container1.make<UserService>();
      var service2 = container2.make<UserService>();

      expect(service1.config.value, equals('config1'));
      expect(service2.config.value, equals('config2'));
    });

    test('throws when trying to instantiate abstract class', () {
      container = Container(MirrorsReflector());

      expect(() => container.make<Logger>(),
          throwsA(isA<BindingResolutionException>()));
    });

    test('throws when dependency is abstract', () {
      container = Container(MirrorsReflector());
      container.bind(Database).to(SqlDatabase);

      expect(() => container.make<Database>(),
          throwsA(isA<BindingResolutionException>()));
    });
  });
}
