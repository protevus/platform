import 'package:test/test.dart';
import 'package:platform_support/platform_support.dart';

class CustomCarbonFactory extends CarbonFactory {
  @override
  Carbon createFromCarbon(Carbon carbon) {
    return carbon.addDays(1); // Always add one day
  }
}

void main() {
  setUp(() {
    Date.useDefault();
    Carbon.setTestNow(null);
  });

  group('Date Facade', () {
    test('creates dates using default class', () {
      final date = Date.create(2017, 6, 27, 13, 14, 15);
      expect(date, isA<Carbon>());
      expect(date.toString(), equals('2017-06-27T13:14:15.000'));
    });

    test('creates dates using callable', () {
      Date.useCallable((Carbon carbon) => carbon.addDays(1));

      final date = Date.create(2017, 6, 27);
      expect(date.toString(), equals('2017-06-28T00:00:00.000'));
    });

    test('creates dates using factory', () {
      Date.useFactory(CustomCarbonFactory());

      final date = Date.create(2017, 6, 27);
      expect(date.toString(), equals('2017-06-28T00:00:00.000'));
    });

    test('creates dates from DateTime', () {
      final now = DateTime.now();
      final date = Date.fromDateTime(now);
      expect(date.dateTime, equals(now));
    });

    test('creates dates from current time', () {
      final testNow = Carbon(2017, 6, 27, 13, 14, 15);
      Date.setTestNow(testNow.dateTime);

      final date = Date.now();
      expect(date.toString(), equals('2017-06-27T13:14:15.000'));

      Date.setTestNow(null);
    });

    test('creates dates from milliseconds', () {
      final date = Date.fromMillisecondsSinceEpoch(1498569255000);
      expect(date.toString(), contains('2017-06-27'));
    });

    test('creates dates from microseconds', () {
      final date = Date.fromMicrosecondsSinceEpoch(1498569255000000);
      expect(date.toString(), contains('2017-06-27'));
    });

    test('creates dates from ISO string', () {
      final date = Date.parse('2017-06-27T13:14:15.000');
      expect(date.toString(), equals('2017-06-27T13:14:15.000'));
    });

    test('creates dates from UUID', () {
      final date = Date.fromUuid('71513cb4-f071-11ed-a0cf-325096b39f47');
      expect(date.toUtc().toString(), contains('2023-05-12'));
    });

    test('creates dates for today', () {
      final testNow = Carbon(2017, 6, 27, 13, 14, 15);
      Date.setTestNow(testNow.dateTime);

      final date = Date.today();
      expect(date.toString(), contains('2017-06-27'));

      Date.setTestNow(null);
    });

    test('creates dates for tomorrow', () {
      final testNow = Carbon(2017, 6, 27, 13, 14, 15);
      Date.setTestNow(testNow.dateTime);

      final date = Date.tomorrow();
      expect(date.toString(), contains('2017-06-28'));

      Date.setTestNow(null);
    });

    test('creates dates for yesterday', () {
      final testNow = Carbon(2017, 6, 27, 13, 14, 15);
      Date.setTestNow(testNow.dateTime);

      final date = Date.yesterday();
      expect(date.toString(), contains('2017-06-26'));

      Date.setTestNow(null);
    });

    test('throws on invalid handler', () {
      expect(
        () => Date.use(123),
        throwsArgumentError,
      );
    });

    test('resets to default handler', () {
      Date.useCallable((Carbon carbon) => carbon.addDays(1));
      Date.useDefault();

      final date = Date.create(2017, 6, 27);
      expect(date.toString(), equals('2017-06-27T00:00:00.000'));
    });

    test('processes dates through callable handler', () {
      Date.useCallable((Carbon carbon) => carbon.addDays(1));

      final date = Date.fromDateTime(DateTime(2017, 6, 27));
      expect(date.toString(), equals('2017-06-28T00:00:00.000'));
    });

    test('processes dates through factory handler', () {
      Date.useFactory(CustomCarbonFactory());

      final date = Date.fromDateTime(DateTime(2017, 6, 27));
      expect(date.toString(), equals('2017-06-28T00:00:00.000'));
    });

    test('throws on unsupported custom class', () {
      Date.useClass(Carbon);
      expect(Date.create(2017, 6, 27), isA<Carbon>());

      Date.useClass(DateTime);
      expect(
        () => Date.create(2017, 6, 27),
        throwsUnimplementedError,
      );
    });

    test('manages test time state', () {
      expect(Date.hasTestNow(), isFalse);

      final testNow = DateTime(2017, 6, 27, 13, 14, 15);
      Date.setTestNow(testNow);

      expect(Date.hasTestNow(), isTrue);
      expect(Date.getTestNow(), equals(testNow));

      Date.setTestNow(null);
      expect(Date.hasTestNow(), isFalse);
    });
  });
}
