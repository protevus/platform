import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

void main() {
  group('ViewErrorBag', () {
    late ViewErrorBag bag;
    late MessageBag messages;

    setUp(() {
      bag = ViewErrorBag();
      messages = MessageBag();
      messages.add('name', 'Name is required');
      messages.add('email', 'Email is invalid');
      messages.add('email', 'Email is required');
    });

    test('can get and put message bags', () {
      bag.put('default', messages);
      expect(bag.getBag('default'), equals(messages));
      expect(bag.getBags(), equals({'default': messages}));
    });

    test('checks bag existence', () {
      expect(bag.hasBag('default'), isFalse);
      bag.put('default', messages);
      expect(bag.hasBag('default'), isTrue);
    });

    test('counts total messages', () {
      bag.put('default', messages);
      expect(bag.count(), equals(3));
    });

    test('gets raw messages', () {
      bag.put('default', messages);
      final raw = bag.messages();
      expect(raw['default'], equals(messages.getMessages()));
    });

    test('gets all messages as flat array', () {
      bag.put('default', messages);
      final all = bag.all();
      expect(
          all,
          containsAll(
              ['Name is required', 'Email is invalid', 'Email is required']));
    });

    test('gets first message', () {
      expect(bag.first(), isNull);
      bag.put('default', messages);
      expect(bag.first(), equals('Name is required'));
    });

    test('gets first message from specific bag', () {
      expect(bag.firstFromBag('default'), isNull);
      bag.put('default', messages);
      expect(bag.firstFromBag('default'), equals('Name is required'));
    });

    test('checks if any messages exist', () {
      expect(bag.any(), isFalse);
      expect(bag.isEmpty, isTrue);
      expect(bag.isNotEmpty, isFalse);

      bag.put('default', messages);
      expect(bag.any(), isTrue);
      expect(bag.isEmpty, isFalse);
      expect(bag.isNotEmpty, isTrue);
    });

    test('converts to string', () {
      bag.put('default', messages);
      expect(bag.toString(),
          equals('Name is required\nEmail is invalid\nEmail is required'));
    });

    test('implements stringable methods', () {
      bag.put('default', messages);
      expect(bag.upper().toString(),
          equals('NAME IS REQUIRED\nEMAIL IS INVALID\nEMAIL IS REQUIRED'));
      expect(bag.lower().toString(),
          equals('name is required\nemail is invalid\nemail is required'));
      expect(bag.limit(10).toString(), equals('Name is re...'));
    });

    test('implements conditionable methods', () {
      bag.put('default', messages);

      var result = bag.when(true, (obj, value) => 'has messages',
          orElse: (obj, value) => 'no messages');
      expect(result, equals('has messages'));

      result = bag.unless(false, (obj, value) => 'has messages',
          orElse: (obj, value) => 'no messages');
      expect(result, equals('has messages'));

      var called = false;
      bag.whenThen(true, () => called = true);
      expect(called, isTrue);

      called = false;
      bag.unlessThen(false, () => called = true);
      expect(called, isTrue);
    });

    test('implements tappable methods', () {
      bag.put('default', messages);
      var tapped = false;

      final result = bag.tap((obj) {
        tapped = true;
        expect(obj, equals(bag));
      });

      expect(tapped, isTrue);
      expect(result, equals(bag));
    });

    test('implements equality', () {
      final bag1 = ViewErrorBag();
      final bag2 = ViewErrorBag();

      bag1.put('default', messages);
      expect(bag1, isNot(equals(bag2)));

      bag2.put('default', messages);
      expect(bag1, equals(bag2));
      expect(bag1.hashCode, equals(bag2.hashCode));
    });
  });
}
