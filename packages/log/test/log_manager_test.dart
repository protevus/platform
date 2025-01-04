import 'package:dsr_log/log.dart';
import 'package:platform_contracts/contracts.dart';
import 'package:platform_log/platform_log.dart';
import 'package:test/test.dart';

import 'utils/mocks.dart';

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

void main() {
  group('LogManager', () {
    late MockApplication app;
    late LogManager manager;

    setUp(() {
      app = MockApplication();
      app.instance('events', MockEventDispatcher());
      manager = LogManager(app);
    });

    test('creates default channel', () {
      final logger = manager.channel();
      expect(logger, isNotNull);
    });

    test('creates specific channel', () {
      final logger = manager.channel('daily');
      expect(logger, isNotNull);
    });

    test('creates stack channel', () {
      final logger = manager.channel('stack');
      expect(logger, isNotNull);
    });

    test('reuses existing channels', () {
      final first = manager.channel('single');
      final second = manager.channel('single');
      expect(identical(first, second), isTrue);
    });

    test('builds on-demand channel', () {
      final config = {
        'driver': 'single',
        'path': '/tmp/logs/custom.log',
      };
      final logger = manager.build(config);
      expect(logger, isNotNull);
    });

    test('creates custom stack', () {
      final logger = manager.stack(['single', 'daily']);
      expect(logger, isNotNull);
    });

    test('shares context across channels', () {
      final context = {'shared': 'value'};
      manager.shareContext(context);

      final single = manager.channel('single');
      final daily = manager.channel('daily');

      expect(single.getLogger(), isA<LoggerInterface>());
      expect(daily.getLogger(), isA<LoggerInterface>());
    });

    test('clears context from all channels', () {
      manager.shareContext({'shared': 'value'});
      manager.withoutContext();

      final logger = manager.channel();
      expect(logger, isNotNull);
    });

    test('supports custom drivers', () {
      manager.extend('custom', (app, config) {
        return Logger(
          MockLogger(),
          app.make<EventDispatcherContract>('events'),
        );
      });

      final config = {
        'driver': 'custom',
        'custom': 'config',
      };
      final logger = manager.build(config);
      expect(logger, isNotNull);
    });

    test('falls back to emergency logger on error', () {
      app.config['logging']['channels']['broken'] = {
        'driver': 'invalid',
      };

      final logger = manager.channel('broken');
      expect(logger, isNotNull);
    });

    test('forwards log calls to default channel', () {
      final message = 'test message';
      final context = {'key': 'value'};

      manager.info(message, context);
      manager.error(message, context);
      manager.warning(message, context);
      manager.debug(message, context);
    });
  });
}
