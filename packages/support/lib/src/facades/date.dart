import '../carbon.dart';
import '../date_factory.dart';

/// A static facade for date operations.
///
/// Similar to Laravel's Date facade, this provides static access
/// to DateFactory functionality.
class Date {
  // Private constructor to prevent instantiation
  Date._();

  /// Use the given handler when generating dates.
  ///
  /// Example:
  /// ```dart
  /// // Using a callable
  /// Date.use((carbon) => carbon.addDays(1));
  ///
  /// // Using a factory
  /// Date.use(CustomCarbonFactory());
  /// ```
  static void use(dynamic handler) => DateFactory.use(handler);

  /// Use the default date class when generating dates.
  ///
  /// Example:
  /// ```dart
  /// Date.useDefault();
  /// ```
  static void useDefault() => DateFactory.useDefault();

  /// Execute the given callable on each date creation.
  ///
  /// Example:
  /// ```dart
  /// Date.useCallable((carbon) => carbon.addDays(1));
  /// ```
  static void useCallable(Function callable) =>
      DateFactory.useCallable(callable);

  /// Use the given date type (class) when generating dates.
  ///
  /// Example:
  /// ```dart
  /// Date.useClass(CustomCarbon);
  /// ```
  static void useClass(Type dateClass) => DateFactory.useClass(dateClass);

  /// Use the given Carbon factory when generating dates.
  ///
  /// Example:
  /// ```dart
  /// Date.useFactory(CustomCarbonFactory());
  /// ```
  static void useFactory(CarbonFactory factory) =>
      DateFactory.useFactory(factory);

  /// Creates a new Carbon instance.
  ///
  /// Example:
  /// ```dart
  /// final date = Date.create(2023, 1, 1);
  /// ```
  static Carbon create([
    int year = 0,
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    String? tz,
  ]) =>
      DateFactory.create(year, month, day, hour, minute, second, tz);

  /// Creates a Carbon instance from a DateTime.
  ///
  /// Example:
  /// ```dart
  /// final date = Date.fromDateTime(DateTime.now());
  /// ```
  static Carbon fromDateTime(DateTime dateTime) =>
      DateFactory.fromDateTime(dateTime);

  /// Creates a Carbon instance for the current date and time.
  ///
  /// Example:
  /// ```dart
  /// final now = Date.now();
  /// ```
  static Carbon now() => DateFactory.now();

  /// Creates a Carbon instance from milliseconds since epoch.
  ///
  /// Example:
  /// ```dart
  /// final date = Date.fromMillisecondsSinceEpoch(1640995200000);
  /// ```
  static Carbon fromMillisecondsSinceEpoch(int milliseconds,
          {bool isUtc = false}) =>
      DateFactory.fromMillisecondsSinceEpoch(milliseconds, isUtc: isUtc);

  /// Creates a Carbon instance from microseconds since epoch.
  ///
  /// Example:
  /// ```dart
  /// final date = Date.fromMicrosecondsSinceEpoch(1640995200000000);
  /// ```
  static Carbon fromMicrosecondsSinceEpoch(int microseconds,
          {bool isUtc = false}) =>
      DateFactory.fromMicrosecondsSinceEpoch(microseconds, isUtc: isUtc);

  /// Creates a Carbon instance from an ISO 8601 string.
  ///
  /// Example:
  /// ```dart
  /// final date = Date.parse('2023-01-01T00:00:00Z');
  /// ```
  static Carbon parse(String input) => DateFactory.parse(input);

  /// Creates a Carbon instance from a UUID's timestamp.
  ///
  /// Example:
  /// ```dart
  /// final date = Date.fromUuid('71513cb4-f071-11ed-a0cf-325096b39f47');
  /// ```
  static Carbon fromUuid(String uuid) => DateFactory.fromUuid(uuid);

  /// Creates a Carbon instance for today.
  ///
  /// Example:
  /// ```dart
  /// final today = Date.today();
  /// ```
  static Carbon today() => DateFactory.now();

  /// Creates a Carbon instance for tomorrow.
  ///
  /// Example:
  /// ```dart
  /// final tomorrow = Date.tomorrow();
  /// ```
  static Carbon tomorrow() => DateFactory.now().addDays(1);

  /// Creates a Carbon instance for yesterday.
  ///
  /// Example:
  /// ```dart
  /// final yesterday = Date.yesterday();
  /// ```
  static Carbon yesterday() => DateFactory.now().subtract(Duration(days: 1));

  /// Gets the current test time instance.
  ///
  /// Example:
  /// ```dart
  /// final testNow = Date.getTestNow();
  /// ```
  static DateTime? getTestNow() => Carbon.getTestNow();

  /// Sets the test time instance.
  ///
  /// Example:
  /// ```dart
  /// Date.setTestNow(DateTime(2023, 1, 1));
  /// ```
  static void setTestNow(DateTime? testNow) => Carbon.setTestNow(testNow);

  /// Returns true if test time is set.
  ///
  /// Example:
  /// ```dart
  /// if (Date.hasTestNow()) {
  ///   print('Using test time');
  /// }
  /// ```
  static bool hasTestNow() => Carbon.hasTestNow();
}
