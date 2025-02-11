import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

void main() {
  group('Sleep', () {
    test('sleeps for microseconds', () async {
      final start = DateTime.now();
      await Sleep.usleep(1000); // 1000 microseconds = 1 millisecond
      final duration = DateTime.now().difference(start);
      expect(duration.inMilliseconds, greaterThanOrEqualTo(0));
    });

    test('sleeps for milliseconds', () async {
      final start = DateTime.now();
      await Sleep.sleep(10); // 10 milliseconds
      final duration = DateTime.now().difference(start);
      expect(duration.inMilliseconds, greaterThanOrEqualTo(5)); // Very lenient
    });

    test('sleeps for seconds', () async {
      final start = DateTime.now();
      await Sleep.seconds(1); // 1 second
      final duration = DateTime.now().difference(start);
      expect(duration.inMilliseconds,
          greaterThanOrEqualTo(950)); // Allow 50ms variance
    });

    test('sleeps until specific time', () async {
      final futureTime = Carbon.now().addMilliseconds(50);
      final start = DateTime.now();
      await Sleep.until(futureTime);
      final duration = DateTime.now().difference(start);
      expect(duration.inMilliseconds,
          greaterThanOrEqualTo(35)); // Allow 15ms variance
    });

    test('does not sleep if time is in the past', () async {
      final pastTime = Carbon.now().addSeconds(-1);
      final start = DateTime.now();
      await Sleep.until(pastTime);
      final duration = DateTime.now().difference(start);
      expect(duration.inMilliseconds, lessThan(100));
    });

    test('does not sleep if time of day has passed', () async {
      final now = DateTime.now();
      final timeOfDay = TimeOfDay(
        hour: now.hour,
        minute: now.minute,
      );
      final start = DateTime.now();
      await Sleep.untilTime(timeOfDay);
      final duration = DateTime.now().difference(start);
      expect(duration.inMilliseconds, lessThan(100));
    });

    test('sleeps for random duration within range', () async {
      final start = DateTime.now();
      await Sleep.random(10, 20); // Between 10-20 milliseconds
      final duration = DateTime.now().difference(start);
      expect(duration.inMilliseconds,
          greaterThanOrEqualTo(5)); // Allow 5ms variance
      expect(
          duration.inMilliseconds, lessThanOrEqualTo(25)); // Allow 5ms variance
    });

    test('handles invalid random range', () async {
      final start = DateTime.now();
      await Sleep.random(-10, 5); // Should use 0 as min
      final duration = DateTime.now().difference(start);
      expect(duration.inMilliseconds, greaterThanOrEqualTo(0));
      expect(
          duration.inMilliseconds, lessThanOrEqualTo(10)); // Allow 5ms variance

      final start2 = DateTime.now();
      await Sleep.random(10, 5); // Should use min for both
      final duration2 = DateTime.now().difference(start2);
      expect(duration2.inMilliseconds,
          greaterThanOrEqualTo(5)); // Allow 5ms variance
      expect(duration2.inMilliseconds,
          lessThanOrEqualTo(15)); // Allow 5ms variance
    });

    test('validates TimeOfDay constructor', () {
      expect(
          () => TimeOfDay(hour: -1, minute: 0), throwsA(isA<AssertionError>()));
      expect(
          () => TimeOfDay(hour: 24, minute: 0), throwsA(isA<AssertionError>()));
      expect(
          () => TimeOfDay(hour: 0, minute: -1), throwsA(isA<AssertionError>()));
      expect(
          () => TimeOfDay(hour: 0, minute: 60), throwsA(isA<AssertionError>()));
      expect(() => TimeOfDay(hour: 12, minute: 30), returnsNormally);
    });

    test('formats TimeOfDay as string', () {
      expect(const TimeOfDay(hour: 9, minute: 5).toString(), equals('09:05'));
      expect(const TimeOfDay(hour: 15, minute: 30).toString(), equals('15:30'));
      expect(const TimeOfDay(hour: 0, minute: 0).toString(), equals('00:00'));
      expect(const TimeOfDay(hour: 23, minute: 59).toString(), equals('23:59'));
    });

    test('converts TimeOfDay to Duration', () {
      expect(const TimeOfDay(hour: 1, minute: 30).toDuration(),
          equals(Duration(hours: 1, minutes: 30)));
      expect(const TimeOfDay(hour: 0, minute: 0).toDuration(),
          equals(Duration.zero));
      expect(const TimeOfDay(hour: 23, minute: 59).toDuration(),
          equals(Duration(hours: 23, minutes: 59)));
    });
  });
}
