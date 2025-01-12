import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:platform_mail/mail.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
import 'mailgun_driver_test.mocks.dart';

void main() {
  group('MailgunDriver', () {
    late MockClient client;
    late MailgunDriver driver;
    late MailgunConfig config;

    setUp(() {
      client = MockClient();
      config = MailgunConfig(
        apiKey: 'key-test',
        domain: 'test.example.com',
      );
      driver = MailgunDriver(config, client: client);
    });

    test('validates configuration', () {
      expect(driver.validateConfig(), isTrue);
    });

    test('throws on invalid configuration', () {
      expect(
        () => MailgunDriver(MailgunConfig(
          apiKey: '',
          domain: 'test.example.com',
        )),
        throwsA(isA<MailConfigException>()),
      );

      expect(
        () => MailgunDriver(MailgunConfig(
          apiKey: 'key-test',
          domain: '',
        )),
        throwsA(isA<MailConfigException>()),
      );
    });

    test('sends email with basic fields', () async {
      when(client.send(any)).thenAnswer((_) async {
        final response = http.StreamedResponse(
          Stream.value(utf8.encode('{"message": "Queued"}')),
          200,
        );
        return response;
      });

      await driver.send(
        to: [Address('to@example.com')],
        from: [Address('from@example.com')],
        subject: 'Test Subject',
        text: 'Test Body',
      );

      final captured =
          verify(client.send(captureAny)).captured.single as http.BaseRequest;
      expect(captured.method, equals('POST'));
      expect(captured.url.toString(),
          equals('${config.endpoint}/${config.domain}/messages'));

      final request = captured as http.MultipartRequest;
      expect(request.fields['to'], equals('to@example.com'));
      expect(request.fields['from'], equals('from@example.com'));
      expect(request.fields['subject'], equals('Test Subject'));
      expect(request.fields['text'], equals('Test Body'));
    });

    test('sends email with all fields', () async {
      when(client.send(any)).thenAnswer((_) async {
        final response = http.StreamedResponse(
          Stream.value(utf8.encode('{"message": "Queued"}')),
          200,
        );
        return response;
      });

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

      final request = verify(client.send(captureAny)).captured.single
          as http.MultipartRequest;
      expect(request.fields['to'], equals('To User <to@example.com>'));
      expect(request.fields['from'], equals('From User <from@example.com>'));
      expect(request.fields['cc'], equals('CC User <cc@example.com>'));
      expect(request.fields['bcc'], equals('BCC User <bcc@example.com>'));
      expect(request.fields['h:Reply-To'],
          equals('Reply User <reply@example.com>'));
      expect(request.fields['subject'], equals('Test Subject'));
      expect(request.fields['text'], equals('Test Text'));
      expect(request.fields['html'], equals('<p>Test HTML</p>'));
      expect(request.fields['h:X-Custom'], equals('value'));
      expect(request.fields['v:user_id'], equals('123'));
      expect(request.fields['o:tag'], equals('test'));
    });

    test('sends email with attachments', () async {
      when(client.send(any)).thenAnswer((_) async {
        final response = http.StreamedResponse(
          Stream.value(utf8.encode('{"message": "Queued"}')),
          200,
        );
        return response;
      });

      final attachment = Attachment(
        filename: 'test.txt',
        content: Uint8List.fromList('Hello'.codeUnits),
        mimeType: 'text/plain',
      );

      await driver.send(
        to: [Address('to@example.com')],
        from: [Address('from@example.com')],
        subject: 'Test Subject',
        attachments: [attachment],
      );

      final request = verify(client.send(captureAny)).captured.single
          as http.MultipartRequest;
      final file = request.files.single;
      expect(file.filename, equals('test.txt'));
      expect(file.contentType.toString(), equals('text/plain'));
      expect(await file.length, equals(5));
    });

    test('handles API errors', () async {
      when(client.send(any)).thenAnswer((_) async {
        final response = http.StreamedResponse(
          Stream.value(utf8.encode('{"message": "Invalid recipient"}')),
          400,
        );
        return response;
      });

      expect(
        () => driver.send(
          to: [Address('to@example.com')],
          from: [Address('from@example.com')],
          subject: 'Test Subject',
        ),
        throwsA(isA<MailSendException>()),
      );
    });

    test('handles network errors', () async {
      when(client.send(any))
          .thenThrow(http.ClientException('Connection failed'));

      expect(
        () => driver.send(
          to: [Address('to@example.com')],
          from: [Address('from@example.com')],
          subject: 'Test Subject',
        ),
        throwsA(isA<MailDriverException>()),
      );
    });

    test('closes client', () async {
      await driver.close();
      verify(client.close()).called(1);
    });
  });
}
