import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:platform_mail/mail.dart';

void main() {
  group('Attachment', () {
    test('creates with required parameters', () {
      final content = Uint8List.fromList([1, 2, 3]);
      final attachment = Attachment(
        filename: 'test.txt',
        content: content,
      );

      expect(attachment.filename, equals('test.txt'));
      expect(attachment.content, equals(content));
      expect(attachment.mimeType, equals('application/octet-stream'));
      expect(attachment.isInline, isFalse);
      expect(attachment.contentId, isNull);
      expect(attachment.headers, isNull);
    });

    test('creates with all parameters', () {
      final content = Uint8List.fromList([1, 2, 3]);
      final headers = {'X-Custom': 'value'};
      final attachment = Attachment(
        filename: 'test.txt',
        content: content,
        mimeType: 'text/plain',
        isInline: true,
        contentId: 'test-id',
        headers: headers,
      );

      expect(attachment.filename, equals('test.txt'));
      expect(attachment.content, equals(content));
      expect(attachment.mimeType, equals('text/plain'));
      expect(attachment.isInline, isTrue);
      expect(attachment.contentId, equals('test-id'));
      expect(attachment.headers, equals(headers));
    });

    test('creates from string', () {
      final attachment = Attachment.fromString(
        filename: 'test.txt',
        content: 'Hello, World!',
      );

      expect(attachment.filename, equals('test.txt'));
      expect(attachment.content,
          equals(Uint8List.fromList('Hello, World!'.codeUnits)));
      expect(attachment.mimeType, equals('text/plain'));
    });

    test('creates from base64', () {
      // 'Hello, World!' in base64
      final base64Content = 'SGVsbG8sIFdvcmxkIQ==';
      final attachment = Attachment.fromBase64(
        filename: 'test.txt',
        base64Content: base64Content,
      );

      expect(attachment.filename, equals('test.txt'));
      expect(
        String.fromCharCodes(attachment.content),
        equals('Hello, World!'),
      );
    });

    test('gets size correctly', () {
      final content = Uint8List.fromList([1, 2, 3, 4, 5]);
      final attachment = Attachment(
        filename: 'test.bin',
        content: content,
      );

      expect(attachment.size, equals(5));
    });

    test('copies with modifications', () {
      final original = Attachment(
        filename: 'test.txt',
        content: Uint8List.fromList([1, 2, 3]),
        mimeType: 'text/plain',
      );

      final modified = original.copyWith(
        filename: 'new.txt',
        mimeType: 'application/text',
      );

      expect(modified.filename, equals('new.txt'));
      expect(modified.content, equals(original.content));
      expect(modified.mimeType, equals('application/text'));
      expect(modified.isInline, equals(original.isInline));
    });

    test('compares attachments correctly', () {
      final content = Uint8List.fromList([1, 2, 3]);
      final attachment1 = Attachment(
        filename: 'test.txt',
        content: content,
        mimeType: 'text/plain',
      );
      final attachment2 = Attachment(
        filename: 'test.txt',
        content: content,
        mimeType: 'text/plain',
      );
      final attachment3 = Attachment(
        filename: 'other.txt',
        content: content,
        mimeType: 'text/plain',
      );

      expect(attachment1, equals(attachment2));
      expect(attachment1.hashCode, equals(attachment2.hashCode));
      expect(attachment1, isNot(equals(attachment3)));
    });
  });
}
