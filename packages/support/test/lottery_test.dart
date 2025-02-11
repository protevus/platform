import 'dart:math';
import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

class TestRandom implements Random {
  final List<int> values;
  int index = 0;

  TestRandom(this.values);

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();

  @override
  int nextInt(int max) => values[index++ % values.length];
}

void main() {
  group('Lottery', () {
    test('creates instance with valid parameters', () {
      expect(() => Lottery(10, 5), returnsNormally);
      expect(() => Lottery(10, 0), returnsNormally);
      expect(() => Lottery(10, 10), returnsNormally);
    });

    test('throws assertion error for invalid parameters', () {
      expect(() => Lottery(0, 0), throwsA(isA<AssertionError>()));
      expect(() => Lottery(-1, 0), throwsA(isA<AssertionError>()));
      expect(() => Lottery(5, 6), throwsA(isA<AssertionError>()));
      expect(() => Lottery(5, -1), throwsA(isA<AssertionError>()));
    });

    test('creates instance with odds', () {
      final lottery = Lottery.odds(1, 2);
      expect(lottery.tickets, equals(2));
      expect(lottery.winners, equals(1));
    });

    test('creates instance with percentage', () {
      final lottery = Lottery.percentage(50);
      expect(lottery.tickets, equals(100));
      expect(lottery.winners, equals(50));
    });

    test('throws assertion error for invalid percentage', () {
      expect(() => Lottery.percentage(-1), throwsA(isA<AssertionError>()));
      expect(() => Lottery.percentage(101), throwsA(isA<AssertionError>()));
    });

    test('always wins with full winners', () {
      final lottery = Lottery(5, 5);
      for (var i = 0; i < 100; i++) {
        expect(lottery.choose(), isTrue);
      }
    });

    test('never wins with zero winners', () {
      final lottery = Lottery(5, 0);
      for (var i = 0; i < 100; i++) {
        expect(lottery.choose(), isFalse);
      }
    });

    test('wins based on random value', () {
      final random = TestRandom([0, 1, 2, 3, 4]);
      final lottery = Lottery(5, 3, random);

      // Should win for values 0, 1, 2 (less than winners)
      // Should lose for values 3, 4 (greater than or equal to winners)
      expect(lottery.choose(), isTrue); // 0
      expect(lottery.choose(), isTrue); // 1
      expect(lottery.choose(), isTrue); // 2
      expect(lottery.choose(), isFalse); // 3
      expect(lottery.choose(), isFalse); // 4
    });

    test('runs async callback when winning', () async {
      final random = TestRandom([0]); // Will win
      final lottery = Lottery(2, 1, random);

      final result = await lottery.run(() async => 'winner');
      expect(result, equals('winner'));
    });

    test('skips async callback when losing', () async {
      final random = TestRandom([1]); // Will lose
      final lottery = Lottery(2, 1, random);

      final result = await lottery.run(() async => 'winner');
      expect(result, isNull);
    });

    test('runs sync callback when winning', () {
      final random = TestRandom([0]); // Will win
      final lottery = Lottery(2, 1, random);

      final result = lottery.sync(() => 'winner');
      expect(result, equals('winner'));
    });

    test('skips sync callback when losing', () {
      final random = TestRandom([1]); // Will lose
      final lottery = Lottery(2, 1, random);

      final result = lottery.sync(() => 'winner');
      expect(result, isNull);
    });

    test('calculates probability correctly', () {
      expect(Lottery(100, 50).probability, equals(50.0));
      expect(Lottery(100, 25).probability, equals(25.0));
      expect(Lottery(100, 75).probability, equals(75.0));
    });

    test('formats odds correctly', () {
      expect(Lottery(100, 50).odds, equals('50:100'));
      expect(Lottery(100, 25).odds, equals('25:100'));
      expect(Lottery(100, 75).odds, equals('75:100'));
    });
  });
}
