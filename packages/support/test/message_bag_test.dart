import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

void main() {
  group('MessageBag', () {
    late MessageBag messages;

    setUp(() {
      messages = MessageBag();
    });

    test('creates instance with empty messages', () {
      expect(messages.isEmpty, isTrue);
      expect(messages.length, equals(0));
      expect(messages.keys(), isEmpty);
    });

    test('adds messages', () {
      messages.add('key', 'message');
      expect(messages.isEmpty, isFalse);
      expect(messages.length, equals(1));
      expect(messages.keys(), equals(['key']));
    });

    test('gets first message', () {
      messages.add('key', 'first');
      messages.add('key', 'second');
      expect(messages.first(), equals('first'));
      expect(messages.first('key'), equals('first'));
    });

    test('gets all messages for key', () {
      messages.add('key', 'first');
      messages.add('key', 'second');
      expect(messages.get('key'), equals(['first', 'second']));
    });

    test('gets all messages', () {
      messages.add('key1', 'message1');
      messages.add('key2', 'message2');
      expect(
          messages.all(),
          equals({
            'key1': ['message1'],
            'key2': ['message2'],
          }));
    });

    test('checks if has messages', () {
      expect(messages.has('key'), isFalse);
      messages.add('key', 'message');
      expect(messages.has('key'), isTrue);
      expect(messages.has(['key', 'other']), isTrue);
    });

    test('forgets messages', () {
      messages.add('key', 'message');
      expect(messages.has('key'), isTrue);
      messages.forget('key');
      expect(messages.has('key'), isFalse);
    });

    test('merges messages from map', () {
      messages.merge({
        'key1': ['message1'],
        'key2': ['message2'],
      });
      expect(
          messages.all(),
          equals({
            'key1': ['message1'],
            'key2': ['message2'],
          }));
    });

    test('merges messages from message provider', () {
      final other = MessageBag()..add('key', 'message');
      messages.merge(other);
      expect(
          messages.all(),
          equals({
            'key': ['message'],
          }));
    });

    test('formats messages', () {
      messages.add('key', 'message');
      messages.setFormat('Error: :message');
      expect(messages.first(), equals('Error: message'));
    });

    test('converts to array', () {
      messages.add('key', 'message');
      final array = messages.toArray();
      expect(array['messages'], isA<Map>());
      expect(array['format'], equals(':message'));
      expect(array['isEmpty'], isFalse);
      expect(array['length'], equals(1));
    });

    test('converts to json', () {
      messages.add('key', 'message');
      final json = messages.toJson();
      expect(json, contains('"messages"'));
      expect(json, contains('"format"'));
      expect(json, contains('"isEmpty"'));
      expect(json, contains('"length"'));
    });

    test('provides message bag', () {
      expect(messages.getMessageBag(), equals(messages));
    });

    test('extends stringable functionality', () {
      messages.add('key', 'hello world');
      expect(messages.toString(), isA<String>());
      expect(messages.upper().toString(), equals('HELLO WORLD'));
    });
  });
}
