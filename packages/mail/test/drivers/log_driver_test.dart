import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:platform_mail/mail.dart';

void main() {
  group('LogDriver', () {
    late LogDriver driver;
    late StringBuffer output;

    setUp(() {
      output = StringBuffer();
      // Redirect print to our buffer
      final zone = Zone.current.fork(
        specification: ZoneSpecification(
          print: (_, __, ___, String message) {
            output.writeln(message);
          },
        ),
      );
      zone.run(() {
        driver = LogDriver(const LogConfig());
      });
    });

    test('validates configuration', () {
      expect(driver.validateConfig(), isTrue);
    });

    test('logs email with basic fields', () async {
      await driver.send(
        to: [Address('to@example.com')],
        from: [Address('from@example.com')],
        subject: 'Test Subject',
        text: 'Test Body',
      );

      final log = output.toString();
      expect(log, contains('📧 Email logged:'));

      final json = jsonDecode(log.split('📧 Email logged:\n')[1])
          as Map<String, dynamic>;
      expect(json['to'], equals(['to@example.com']));
      expect(json['from'], equals(['from@example.com']));
      expect(json['subject'], equals('Test Subject'));
      expect(json['text'], equals('Test Body'));
    });

    test('logs email with all fields', () async {
      await driver.send(
        to: [Address('to@example.com', 'To User')],
        from: [Address('from@example.com', 'From User')],
        cc: [Address('cc@example.com', 'CC User')],
        bcc: [Address('bcc@example.com', 'BCC User')],
        replyTo: [Address('reply@example.com', 'Reply User')],
        subject: 'Test Subject',
        text: 'Test Text',
        html: '<p>Test HTML</p>',
        headers: {'X-Custom': 'value'},
        metadata: {'user_id': '123'},
        tags: ['test', 'example'],
      );

      final log = output.toString();
      final json = jsonDecode(log.split('📧 Email logged:\n')[1])
          as Map<String, dynamic>;

      expect(json['to'], equals(['To User <to@example.com>']));
      expect(json['from'], equals(['From User <from@example.com>']));
      expect(json['cc'], equals(['CC User <cc@example.com>']));
      expect(json['bcc'], equals(['BCC User <bcc@example.com>']));
      expect(json['reply_to'], equals(['Reply User <reply@example.com>']));
      expect(json['subject'], equals('Test Subject'));
      expect(json['text'], equals('Test Text'));
      expect(json['html'], equals('<p>Test HTML</p>'));
      expect(json['headers'], equals({'X-Custom': 'value'}));
      expect(json['metadata'], equals({'user_id': '123'}));
      expect(json['tags'], equals(['test', 'example']));
    });

    test('logs email with attachments', () async {
      await driver.send(
        to: [Address('to@example.com')],
        from: [Address('from@example.com')],
        subject: 'Test Subject',
        attachments: [
          Attachment.fromString(
            filename: 'test.txt',
            content: 'Hello, World!',
            mimeType: 'text/plain',
          ),
        ],
      );

      final log = output.toString();
      final json = jsonDecode(log.split('📧 Email logged:\n')[1])
          as Map<String, dynamic>;
      final attachments = json['attachments'] as List<dynamic>;

      expect(attachments, hasLength(1));
      expect(
          attachments.first,
          equals({
            'filename': 'test.txt',
            'mime_type': 'text/plain',
            'size': 13, // Length of 'Hello, World!'
          }));
    });

    test('pretty prints JSON when configured', () async {
      driver = LogDriver(const LogConfig(pretty: true));
      await driver.send(
        to: [Address('to@example.com')],
        from: [Address('from@example.com')],
        subject: 'Test Subject',
      );

      final log = output.toString();
      expect(log, contains('\n  ')); // Check for indentation
    });

    test('does not pretty print JSON when disabled', () async {
      driver = LogDriver(const LogConfig(pretty: false));
      await driver.send(
        to: [Address('to@example.com')],
        from: [Address('from@example.com')],
        subject: 'Test Subject',
      );

      final log = output.toString();
      expect(log.split('📧 Email logged:\n')[1], isNot(contains('\n')));
    });
  });
}
