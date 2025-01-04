import 'package:platform_log/platform_log.dart';
import 'package:test/test.dart';

import 'utils/mocks.dart';

void main() {
  group('Logger', () {
    late MockLogger mockLogger;
    late MockEventDispatcher mockDispatcher;
    late Logger logger;

    setUp(() {
      mockLogger = MockLogger();
      mockDispatcher = MockEventDispatcher();
      logger = Logger(mockLogger, mockDispatcher);
    });

    test('forwards log calls to underlying logger', () {
      logger.info('test message');
      expect(mockLogger.logs, hasLength(1));
      expect(mockLogger.logs.first.level, equals('info'));
      expect(mockLogger.logs.first.message, equals('test message'));
    });

    test('dispatches events for each log', () {
      logger.error('error message');
      expect(mockDispatcher.events, hasLength(1));
      expect(mockDispatcher.events.first.level, equals('error'));
      expect(mockDispatcher.events.first.message, equals('error message'));
    });

    test('handles context in log calls', () {
      final context = {'user': 'test'};
      logger.warning('warning message', context);
      expect(mockLogger.logs.first.context, equals(context));
      expect(mockDispatcher.events.first.context, equals(context));
    });

    test('maintains shared context across log calls', () {
      logger.withContext({'shared': 'value'});
      logger.info('test');
      expect(mockLogger.logs.first.context, equals({'shared': 'value'}));

      logger.debug('another test', {'extra': 'context'});
      expect(mockLogger.logs.last.context,
          equals({'shared': 'value', 'extra': 'context'}));
    });

    test('clears context with withoutContext', () {
      logger.withContext({'shared': 'value'});
      logger.withoutContext();
      logger.info('test');
      expect(mockLogger.logs.first.context, isEmpty);
    });

    test('formats different message types', () {
      // String message
      logger.info('string message');
      expect(mockLogger.logs.last.message, equals('string message'));

      // Map message
      final map = {'key': 'value'};
      logger.info(map);
      expect(mockLogger.logs.last.message, equals(map.toString()));

      // Object message
      final object = DateTime(2023);
      logger.info(object);
      expect(mockLogger.logs.last.message, equals(object.toString()));
    });

    test('handles missing event dispatcher', () {
      final loggerWithoutDispatcher = Logger(mockLogger, null);
      expect(
        () => loggerWithoutDispatcher.listen((_) {}),
        throwsStateError,
      );
    });

    test('provides access to underlying logger', () {
      expect(logger.getLogger(), equals(mockLogger));
    });

    test('provides access to event dispatcher', () {
      expect(logger.getEventDispatcher(), equals(mockDispatcher));
    });
  });
}
