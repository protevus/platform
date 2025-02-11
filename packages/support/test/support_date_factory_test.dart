import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

class CustomCarbonFactory extends CarbonFactory {
  @override
  Carbon createFromCarbon(Carbon carbon) {
    return carbon.addDays(1); // Always add one day
  }
}

void main() {
  setUp(() {
    DateFactory.useDefault();
  });

  group('DateFactory', () {
    test('creates dates using default class', () {
      final date = DateFactory.create(2017, 6, 27, 13, 14, 15);
      expect(date, isA<Carbon>());
      expect(date.toString(), equals('2017-06-27T13:14:15.000'));
    });

    test('creates dates using callable', () {
      DateFactory.useCallable((Carbon carbon) => carbon.addDays(1));

      final date = DateFactory.create(2017, 6, 27);
      expect(date.toString(), equals('2017-06-28T00:00:00.000'));
    });

    test('creates dates using factory', () {
      DateFactory.useFactory(CustomCarbonFactory());

      final date = DateFactory.create(2017, 6, 27);
      expect(date.toString(), equals('2017-06-28T00:00:00.000'));
    });

    test('creates dates from DateTime', () {
      final now = DateTime.now();
      final date = DateFactory.fromDateTime(now);
      expect(date.dateTime, equals(now));
    });

    test('creates dates from current time', () {
      final testNow = Carbon(2017, 6, 27, 13, 14, 15);
      Carbon.setTestNow(testNow.dateTime);

      final date = DateFactory.now();
      expect(date.toString(), equals('2017-06-27T13:14:15.000'));

      Carbon.setTestNow(null);
    });

    test('creates dates from milliseconds', () {
      final date = DateFactory.fromMillisecondsSinceEpoch(1498569255000);
      expect(date.toString(), contains('2017-06-27'));
    });

    test('creates dates from microseconds', () {
      final date = DateFactory.fromMicrosecondsSinceEpoch(1498569255000000);
      expect(date.toString(), contains('2017-06-27'));
    });

    test('creates dates from ISO string', () {
      final date = DateFactory.parse('2017-06-27T13:14:15.000');
      expect(date.toString(), equals('2017-06-27T13:14:15.000'));
    });

    test('creates dates from UUID', () {
      final date = DateFactory.fromUuid('71513cb4-f071-11ed-a0cf-325096b39f47');
      expect(date.toUtc().toString(), contains('2023-05-12'));
    });

    test('throws on invalid handler', () {
      expect(
        () => DateFactory.use(123),
        throwsArgumentError,
      );
    });

    test('resets to default handler', () {
      DateFactory.useCallable((Carbon carbon) => carbon.addDays(1));
      DateFactory.useDefault();

      final date = DateFactory.create(2017, 6, 27);
      expect(date.toString(), equals('2017-06-27T00:00:00.000'));
    });

    test('processes dates through callable handler', () {
      DateFactory.useCallable((Carbon carbon) => carbon.addDays(1));

      final date = DateFactory.fromDateTime(DateTime(2017, 6, 27));
      expect(date.toString(), equals('2017-06-28T00:00:00.000'));
    });

    test('processes dates through factory handler', () {
      DateFactory.useFactory(CustomCarbonFactory());

      final date = DateFactory.fromDateTime(DateTime(2017, 6, 27));
      expect(date.toString(), equals('2017-06-28T00:00:00.000'));
    });

    test('throws on unsupported custom class', () {
      DateFactory.useClass(Carbon);
      expect(DateFactory.create(2017, 6, 27), isA<Carbon>());

      DateFactory.useClass(DateTime);
      expect(
        () => DateFactory.create(2017, 6, 27),
        throwsUnimplementedError,
      );
    });
  });
}
