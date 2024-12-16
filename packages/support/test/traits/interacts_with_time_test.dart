import 'package:test/test.dart';
import 'package:platform_support/platform_support.dart';

class TestClass with InteractsWithTime {}

void main() {
  group('InteractsWithTime', () {
    late TestClass instance;

    setUp(() {
      instance = TestClass();
    });

    test('currentTime returns current time', () {
      final time = instance.currentTime();
      expect(time, isA<Carbon>());
      expect(time.isToday(), isTrue);
    });

    test('sleep delays execution', () async {
      final start = instance.currentTime();
      await instance.sleep(100);
      final elapsed = instance.elapsedTime(start.dateTime);
      expect(elapsed, greaterThanOrEqualTo(100));
    });

    test('sleepUntil delays until timestamp', () async {
      final start = instance.currentTime();
      final target = start.addMilliseconds(100);
      await instance.sleepUntil(target.dateTime);
      final elapsed = instance.elapsedTime(start.dateTime);
      expect(elapsed, greaterThanOrEqualTo(100));
    });

    test('sleepUntil does not delay for past timestamps', () async {
      final start = instance.currentTime();
      final pastTime = start.subtract(Duration(milliseconds: 100));
      await instance.sleepUntil(pastTime.dateTime);
      final elapsed = instance.elapsedTime(start.dateTime);
      expect(elapsed, lessThan(50)); // Allow some execution time
    });

    test('elapsedTime returns milliseconds since timestamp', () async {
      final start = instance.currentTime();
      await instance.sleep(100);
      final elapsed = instance.elapsedTime(start.dateTime);
      expect(elapsed, greaterThanOrEqualTo(100));
    });

    test('works with test time', () {
      final testNow = Carbon.fromDateTime(DateTime(2023, 1, 1));
      Date.setTestNow(testNow.dateTime);

      final time = instance.currentTime();
      expect(time.year, equals(2023));
      expect(time.month, equals(1));
      expect(time.day, equals(1));

      Date.setTestNow(null);
    });
  });
}
