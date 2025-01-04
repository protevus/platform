import 'package:dsr_log/log.dart';
import 'package:platform_log/platform_log.dart';
import 'package:test/test.dart';

import '../utils/mocks.dart';

void main() {
  group('StackLogger', () {
    late MockApplication app;
    late List<Logger> handlers;
    late List<MockLogger> mockLoggers;

    setUp(() {
      app = MockApplication();
      mockLoggers = [
        MockLogger(),
        MockLogger(),
        MockLogger(),
      ];
      handlers = mockLoggers.map((mock) => Logger(mock, null)).toList();
    });

    test('forwards messages to all handlers', () {
      final config = {
        'level': 'debug',
      };

      final logger = StackLogger(app, config, handlers);
      logger.info('test message', {'context': 'value'});

      for (final mock in mockLoggers) {
        expect(mock.logs, hasLength(1));
        expect(mock.logs.first.level, equals('info'));
        expect(mock.logs.first.message, equals('test message'));
        expect(mock.logs.first.context, equals({'context': 'value'}));
      }
    });

    test('respects log level', () {
      final config = {
        'level': 'error', // Only log error and above
      };

      final logger = StackLogger(app, config, handlers);
      logger.debug('debug message'); // Should not be logged
      logger.info('info message'); // Should not be logged
      logger.error('error message'); // Should be logged
      logger.critical('critical message'); // Should be logged

      for (final mock in mockLoggers) {
        expect(mock.logs, hasLength(2)); // Only error and critical
        expect(
          mock.logs.any(
              (log) => log.level == 'error' && log.message == 'error message'),
          isTrue,
        );
        expect(
          mock.logs.any((log) =>
              log.level == 'critical' && log.message == 'critical message'),
          isTrue,
        );
      }
    });

    test('handles empty handlers list', () {
      final config = {
        'level': 'debug',
      };

      final logger = StackLogger(app, config, []);

      // Should not throw
      expect(() => logger.info('test message'), returnsNormally);
    });

    test('handles handler failures', () {
      final throwingLogger = Logger(
        ThrowingLogger(),
        null,
      );

      final config = {
        'level': 'debug',
      };

      final logger = StackLogger(app, config, [...handlers, throwingLogger]);

      // Should not throw and other handlers should still receive the message
      logger.info('test message');

      for (final mock in mockLoggers) {
        expect(mock.logs, hasLength(1));
        expect(mock.logs.first.message, equals('test message'));
      }
    });

    test('maintains message order', () {
      final config = {
        'level': 'debug',
      };

      final logger = StackLogger(app, config, handlers);
      final messages = [
        'first message',
        'second message',
        'third message',
      ];

      for (final message in messages) {
        logger.info(message);
      }

      for (final mock in mockLoggers) {
        expect(mock.logs, hasLength(messages.length));
        for (var i = 0; i < messages.length; i++) {
          expect(mock.logs[i].message, equals(messages[i]));
        }
      }
    });
  });
}

/// A logger that throws on every method call.
class ThrowingLogger implements LoggerInterface {
  @override
  void log(String level, Object message,
      [Map<String, dynamic> context = const {}]) {
    throw Exception('Simulated failure');
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
