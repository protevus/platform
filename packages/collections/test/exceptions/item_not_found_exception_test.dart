import 'package:test/test.dart';
import 'package:illuminate_collections/src/exceptions/item_not_found_exception.dart';

void main() {
  group('ItemNotFoundException', () {
    test('can be created without parameters', () {
      final exception = ItemNotFoundException();
      expect(exception.toString(), equals('Item not found.'));
    });

    test('can be created with key only', () {
      final exception = ItemNotFoundException('test_key');
      expect(exception.toString(), equals('Item [test_key] not found.'));
    });

    test('can be created with key and message', () {
      final exception =
          ItemNotFoundException('test_key', 'Custom error message');
      expect(
          exception.toString(), equals('Item not found: Custom error message'));
    });

    test('handles different key types', () {
      expect(
        ItemNotFoundException(1).toString(),
        equals('Item [1] not found.'),
      );
      expect(
        ItemNotFoundException(2.5).toString(),
        equals('Item [2.5] not found.'),
      );
      expect(
        ItemNotFoundException(true).toString(),
        equals('Item [true] not found.'),
      );
      expect(
        ItemNotFoundException(['a', 'b']).toString(),
        equals('Item [[a, b]] not found.'),
      );
      expect(
        ItemNotFoundException({'key': 'value'}).toString(),
        equals('Item [{key: value}] not found.'),
      );
    });

    test('message takes precedence over key in toString()', () {
      final exception = ItemNotFoundException('test_key', 'Custom message');
      expect(
        exception.toString(),
        equals('Item not found: Custom message'),
        reason: 'Message should be used instead of key when both are provided',
      );
    });

    test('properties are accessible', () {
      final exception = ItemNotFoundException('test_key', 'Custom message');
      expect(exception.key, equals('test_key'));
      expect(exception.message, equals('Custom message'));
    });

    test('implements Exception', () {
      final exception = ItemNotFoundException();
      expect(exception, isA<Exception>());
    });
  });
}
