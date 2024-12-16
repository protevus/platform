import 'package:test/test.dart';
import 'package:platform_support/platform_support.dart';
import 'package:platform_macroable/platform_macroable.dart';

void main() {
  late Carbon now;

  setUp(() {
    now = Carbon(2017, 6, 27, 13, 14, 15);
    Carbon.setTestNow(now.dateTime);
  });

  tearDown(() {
    Carbon.setTestNow(null);
    Macroable.flushMacros<Carbon>();
  });

  group('Carbon', () {
    test('instance is properly configured', () {
      expect(now, isA<Carbon>());
      expect(now.year, equals(2017));
      expect(now.month, equals(6));
      expect(now.day, equals(27));
      expect(now.hour, equals(13));
      expect(now.minute, equals(14));
      expect(now.second, equals(15));
    });

    test('Carbon is macroable when not called statically', () {
      // Register a macro for calculating decades difference
      Macroable.macro<Carbon>('diffInDecades', (Carbon self,
          [Carbon? dt, bool abs = true]) {
        final other = dt ?? Carbon.now();
        final years = self.year - other.year;
        return (years ~/ 10).abs();
      });

      final future = Carbon.now().addYears(25);
      expect((now as dynamic).diffInDecades(future), equals(2));
    });

    test('Carbon is macroable when called statically', () {
      // Register a static macro for getting two days ago at noon
      Carbon twoDaysAgoAtNoon() {
        final result = Carbon.now().subtract(Duration(days: 2));
        result.hour = 12;
        result.minute = 0;
        result.second = 0;
        return result;
      }

      Macroable.macro<Carbon>('twoDaysAgoAtNoon', twoDaysAgoAtNoon);

      final result = (Carbon.now() as dynamic).twoDaysAgoAtNoon();
      expect(result.toString(), equals('2017-06-25T12:00:00.000'));
    });

    test('Carbon can serialize to string', () {
      expect(now.toString(), equals('2017-06-27T13:14:15.000'));
    });

    test('setTestNow affects now() instances', () {
      final testNow = Carbon(2017, 6, 27, 13, 14, 15);
      Carbon.setTestNow(testNow.dateTime);

      expect(Carbon.now().toString(), equals('2017-06-27T13:14:15.000'));
    });

    test('Carbon is conditionable', () {
      final carbon = Carbon.now();

      // Test when condition is false
      final result1 = carbon.when(false, (self, _) {
        return (self as Carbon).addDays(1);
      });
      expect((result1 as Carbon).isToday(), isTrue);

      // Test when condition is true
      final result2 = carbon.when(true, (self, _) {
        return (self as Carbon).addDays(1);
      });
      expect((result2 as Carbon).isTomorrow(), isTrue);
    });

    test('createFromUuid handles UUID v1', () {
      final carbon = Carbon.fromUuid('71513cb4-f071-11ed-a0cf-325096b39f47');
      expect(
        carbon.toUtc().toString(),
        contains('2023-05-12'),
      );
    });

    test('date comparison methods work correctly', () {
      final earlier = Carbon(2017, 6, 27, 13, 0, 0);
      final later = Carbon(2017, 6, 27, 14, 0, 0);

      expect(earlier.isBefore(later.dateTime), isTrue);
      expect(later.isAfter(earlier.dateTime), isTrue);
      expect(earlier.isAtSameMomentAs(Carbon(2017, 6, 27, 13, 0, 0).dateTime),
          isTrue);
    });

    test('date modification methods work correctly', () {
      final date = Carbon(2017, 6, 27, 13, 0, 0);

      expect(date.addYears(1).year, equals(2018));
      expect(date.addMonths(1).month, equals(7));
      expect(date.addDays(1).day, equals(28));
      expect(date.addHours(1).hour, equals(14));
      expect(date.addMinutes(1).minute, equals(1));
      expect(date.addSeconds(1).second, equals(1));
    });

    test('relative date checks work correctly', () {
      final today = Carbon.now();
      final tomorrow = today.addDays(1);
      final yesterday = today.subtract(Duration(days: 1));

      expect(today.isToday(), isTrue);
      expect(tomorrow.isTomorrow(), isTrue);
      expect(yesterday.isYesterday(), isTrue);
    });

    test('weekend checks work correctly', () {
      // 2017-06-27 was a Tuesday
      expect(now.isWeekday(), isTrue);
      expect(now.isWeekend(), isFalse);

      // Move to Saturday
      final weekend = now.addDays(4);
      expect(weekend.isWeekend(), isTrue);
      expect(weekend.isWeekday(), isFalse);
    });
  });
}
