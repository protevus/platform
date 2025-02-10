import 'package:test/test.dart';
import 'package:illuminate_mail/mail.dart';

void main() {
  group('MailManager', () {
    late MailManager manager;

    setUp(() {
      manager = MailManager();
    });

    test('registers and retrieves drivers', () {
      final config = LogConfig();
      manager.extend('log', (_) => LogDriver(config));

      final driver = manager.driver('log');
      expect(driver, isA<LogDriver>());
    });

    test('throws on unknown driver', () {
      expect(
        () => manager.driver('unknown'),
        throwsA(isA<MailConfigException>()),
      );
    });

    test('sets and gets default driver', () {
      final config = LogConfig();
      manager.extend('log', (_) => LogDriver(config));
      manager.setDefaultDriver('log');

      expect(manager.getDefaultDriver(), equals('log'));
      expect(manager.driver(), isA<LogDriver>());
    });

    test('throws on invalid default driver', () {
      expect(
        () => manager.setDefaultDriver('unknown'),
        throwsA(isA<MailConfigException>()),
      );
    });

    test('creates SMTP driver', () {
      final config = SmtpConfig(
        host: 'smtp.example.com',
        port: 587,
        username: 'user',
        password: 'pass',
      );
      manager.extend('smtp', (_) => SmtpDriver(config));

      final driver = manager.driver('smtp');
      expect(driver, isA<SmtpDriver>());
    });

    test('creates Mailgun driver', () {
      final config = MailgunConfig(
        apiKey: 'key',
        domain: 'example.com',
      );
      manager.extend('mailgun', (_) => MailgunDriver(config));

      final driver = manager.driver('mailgun');
      expect(driver, isA<MailgunDriver>());
    });

    test('creates Log driver', () {
      final config = LogConfig();
      manager.extend('log', (_) => LogDriver(config));

      final driver = manager.driver('log');
      expect(driver, isA<LogDriver>());
    });

    test('caches drivers', () {
      var createCount = 0;
      final config = LogConfig();
      manager.extend('log', (_) {
        createCount++;
        return LogDriver(config);
      });

      // Get driver multiple times
      final driver1 = manager.driver('log');
      final driver2 = manager.driver('log');

      expect(driver1, same(driver2));
      expect(createCount, equals(1));
    });

    test('supports multiple drivers', () {
      manager.extend('log1', (_) => LogDriver(LogConfig()));
      manager.extend('log2', (_) => LogDriver(LogConfig()));

      expect(manager.driver('log1'), isA<LogDriver>());
      expect(manager.driver('log2'), isA<LogDriver>());
      expect(manager.driver('log1'), isNot(same(manager.driver('log2'))));
    });

    test('closes all drivers', () async {
      manager.extend('log1', (_) => LogDriver(LogConfig()));
      manager.extend('log2', (_) => LogDriver(LogConfig()));

      // Access drivers to create them
      manager.driver('log1');
      manager.driver('log2');

      // Should not throw
      await manager.close();
    });
  });
}
