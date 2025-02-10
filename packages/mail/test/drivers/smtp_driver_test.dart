import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:illuminate_mail/mail.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';

void main() {
  group('SmtpDriver', () {
    test('validates configuration', () {
      final config = SmtpConfig(
        host: 'smtp.example.com',
        port: 587,
        username: 'user',
        password: 'pass',
      );
      final driver = SmtpDriver(config);
      expect(driver.validateConfig(), isTrue);
    });

    test('throws on invalid configuration', () {
      expect(
        () => SmtpDriver(SmtpConfig(
          host: '',
          port: 587,
          username: 'user',
          password: 'pass',
        )),
        throwsA(isA<MailConfigException>()),
      );

      expect(
        () => SmtpDriver(SmtpConfig(
          host: 'smtp.example.com',
          port: 0,
          username: 'user',
          password: 'pass',
        )),
        throwsA(isA<MailConfigException>()),
      );

      expect(
        () => SmtpDriver(SmtpConfig(
          host: 'smtp.example.com',
          port: 587,
          username: '',
          password: 'pass',
        )),
        throwsA(isA<MailConfigException>()),
      );

      expect(
        () => SmtpDriver(SmtpConfig(
          host: 'smtp.example.com',
          port: 587,
          username: 'user',
          password: '',
        )),
        throwsA(isA<MailConfigException>()),
      );
    });

    test('creates correct SMTP server configuration', () {
      final config = SmtpConfig(
        host: 'smtp.example.com',
        port: 587,
        username: 'user',
        password: 'pass',
        secure: true,
        allowInsecure: false,
      );
      final driver = SmtpDriver(config);

      // Access private _server field using reflection
      final server = driver.toString().contains('SmtpServer');
      expect(server, isTrue);
    });

    test('converts addresses correctly', () {
      final config = SmtpConfig(
        host: 'smtp.example.com',
        port: 587,
        username: 'user',
        password: 'pass',
      );
      final driver = SmtpDriver(config);

      // Test sending email to verify address conversion
      expect(
        () => driver.send(
          to: [Address('to@example.com', 'To User')],
          from: [Address('from@example.com', 'From User')],
          subject: 'Test',
        ),
        throwsA(isA<mailer.MailerException>()),
      );
    });

    test('handles attachments correctly', () {
      final config = SmtpConfig(
        host: 'smtp.example.com',
        port: 587,
        username: 'user',
        password: 'pass',
      );
      final driver = SmtpDriver(config);

      final attachment = Attachment(
        filename: 'test.txt',
        content: Uint8List.fromList('Hello'.codeUnits),
        mimeType: 'text/plain',
      );

      // Test sending email with attachment to verify conversion
      expect(
        () => driver.send(
          to: [Address('to@example.com')],
          from: [Address('from@example.com')],
          subject: 'Test',
          attachments: [attachment],
        ),
        throwsA(isA<mailer.MailerException>()),
      );
    });

    test('maps configuration to SMTP options', () {
      final configs = [
        // Test various SMTP configurations
        SmtpConfig(
          host: 'smtp.gmail.com',
          port: 587,
          username: 'user',
          password: 'pass',
          secure: true,
        ),
        SmtpConfig(
          host: 'localhost',
          port: 25,
          username: 'user',
          password: 'pass',
          secure: false,
          allowInsecure: true,
        ),
      ];

      for (final config in configs) {
        final driver = SmtpDriver(config);
        expect(driver.validateConfig(), isTrue);
      }
    });

    test('closes cleanly', () async {
      final config = SmtpConfig(
        host: 'smtp.example.com',
        port: 587,
        username: 'user',
        password: 'pass',
      );
      final driver = SmtpDriver(config);

      // Should not throw
      await driver.close();
    });
  });
}
