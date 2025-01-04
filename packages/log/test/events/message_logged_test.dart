import 'package:platform_log/platform_log.dart';
import 'package:test/test.dart';

void main() {
  group('MessageLogged', () {
    test('creates with default empty context', () {
      final event = MessageLogged('info', 'test message');
      expect(event.level, equals('info'));
      expect(event.message, equals('test message'));
      expect(event.context, equals({}));
    });

    test('creates with custom context', () {
      final context = {'user': 'test', 'action': 'login'};
      final event = MessageLogged('error', 'failed login', context: context);
      expect(event.level, equals('error'));
      expect(event.message, equals('failed login'));
      expect(event.context, equals(context));
    });

    test('context is immutable', () {
      final context = {'key': 'value'};
      final event = MessageLogged('info', 'test', context: context);

      // Original context should not be modified
      context['key'] = 'modified';
      expect(event.context['key'], equals('value'));

      // Event context should be immutable
      expect(
        () => event.context['key'] = 'modified',
        throwsUnsupportedError,
      );
    });
  });
}
