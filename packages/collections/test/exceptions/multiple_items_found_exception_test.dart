import 'package:test/test.dart';
import 'package:platform_collections/src/exceptions/multiple_items_found_exception.dart';

void main() {
  group('MultipleItemsFoundException', () {
    test('can be created without parameters', () {
      final exception = MultipleItemsFoundException();
      expect(exception.toString(),
          equals('Multiple items found when expecting exactly one.'));
    });

    test('can be created with count only', () {
      final exception = MultipleItemsFoundException(3);
      expect(exception.toString(),
          equals('Found 3 items when expecting exactly one.'));
    });

    test('can be created with count and message', () {
      final exception = MultipleItemsFoundException(3, 'Custom error message');
      expect(exception.toString(),
          equals('Multiple items found: Custom error message'));
    });

    test('message takes precedence over count in toString()', () {
      final exception = MultipleItemsFoundException(3, 'Custom message');
      expect(
        exception.toString(),
        equals('Multiple items found: Custom message'),
        reason:
            'Message should be used instead of count when both are provided',
      );
    });

    test('properties are accessible', () {
      final exception = MultipleItemsFoundException(3, 'Custom message');
      expect(exception.count, equals(3));
      expect(exception.message, equals('Custom message'));
    });

    test('implements Exception', () {
      final exception = MultipleItemsFoundException();
      expect(exception, isA<Exception>());
    });
  });
}
