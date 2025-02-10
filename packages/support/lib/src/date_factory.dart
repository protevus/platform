import 'package:illuminate_macroable/macroable.dart';
import 'carbon.dart';

/// A factory for creating Carbon instances with customizable behavior.
///
/// Similar to Laravel's DateFactory, this provides a way to customize
/// how Carbon instances are created and manipulated.
class DateFactory {
  /// The default class that will be used for all created dates.
  static Type get defaultClassName => Carbon;

  /// The type (class) of dates that should be created.
  static Type? _dateClass;

  /// This callable may be used to intercept date creation.
  static Function? _callable;

  /// The Carbon factory that should be used when creating dates.
  static CarbonFactory? _factory;

  /// Use the given handler when generating dates.
  ///
  /// The handler can be:
  /// - A Type (class) that extends or implements Carbon
  /// - A Function that takes a Carbon and returns a Carbon
  /// - A CarbonFactory instance
  ///
  /// Example:
  /// ```dart
  /// // Using a custom class
  /// DateFactory.use(CustomCarbon);
  ///
  /// // Using a callable
  /// DateFactory.use((carbon) => carbon.addDays(1));
  ///
  /// // Using a factory
  /// DateFactory.use(CustomCarbonFactory());
  /// ```
  static void use(dynamic handler) {
    if (handler is Function) {
      useCallable(handler);
    } else if (handler is Type) {
      useClass(handler);
    } else if (handler is CarbonFactory) {
      useFactory(handler);
    } else {
      throw ArgumentError(
        'Invalid date creation handler. Please provide a Type, Function, or CarbonFactory.',
      );
    }
  }

  /// Use the default date class when generating dates.
  ///
  /// Example:
  /// ```dart
  /// DateFactory.useDefault();
  /// ```
  static void useDefault() {
    _dateClass = null;
    _callable = null;
    _factory = null;
  }

  /// Execute the given callable on each date creation.
  ///
  /// Example:
  /// ```dart
  /// DateFactory.useCallable((carbon) => carbon.addDays(1));
  /// ```
  static void useCallable(Function callable) {
    _callable = callable;
    _dateClass = null;
    _factory = null;
  }

  /// Use the given date type (class) when generating dates.
  ///
  /// Example:
  /// ```dart
  /// DateFactory.useClass(CustomCarbon);
  /// ```
  static void useClass(Type dateClass) {
    _dateClass = dateClass;
    _factory = null;
    _callable = null;
  }

  /// Use the given Carbon factory when generating dates.
  ///
  /// Example:
  /// ```dart
  /// DateFactory.useFactory(CustomCarbonFactory());
  /// ```
  static void useFactory(CarbonFactory factory) {
    _factory = factory;
    _dateClass = null;
    _callable = null;
  }

  /// Creates a new Carbon instance.
  ///
  /// Example:
  /// ```dart
  /// final date = DateFactory.create(2023, 1, 1);
  /// ```
  static Carbon create([
    int year = 0,
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    String? tz,
  ]) {
    final carbon = Carbon(year, month, day, hour, minute, second);
    return _processDate(carbon);
  }

  /// Creates a Carbon instance from a DateTime.
  ///
  /// Example:
  /// ```dart
  /// final date = DateFactory.fromDateTime(DateTime.now());
  /// ```
  static Carbon fromDateTime(DateTime dateTime) {
    final carbon = Carbon.fromDateTime(dateTime);
    return _processDate(carbon);
  }

  /// Creates a Carbon instance for the current date and time.
  ///
  /// Example:
  /// ```dart
  /// final now = DateFactory.now();
  /// ```
  static Carbon now() {
    final carbon = Carbon.now();
    return _processDate(carbon);
  }

  /// Creates a Carbon instance from milliseconds since epoch.
  ///
  /// Example:
  /// ```dart
  /// final date = DateFactory.fromMillisecondsSinceEpoch(1640995200000);
  /// ```
  static Carbon fromMillisecondsSinceEpoch(int milliseconds,
      {bool isUtc = false}) {
    final carbon =
        Carbon.fromMillisecondsSinceEpoch(milliseconds, isUtc: isUtc);
    return _processDate(carbon);
  }

  /// Creates a Carbon instance from microseconds since epoch.
  ///
  /// Example:
  /// ```dart
  /// final date = DateFactory.fromMicrosecondsSinceEpoch(1640995200000000);
  /// ```
  static Carbon fromMicrosecondsSinceEpoch(int microseconds,
      {bool isUtc = false}) {
    final carbon =
        Carbon.fromMicrosecondsSinceEpoch(microseconds, isUtc: isUtc);
    return _processDate(carbon);
  }

  /// Creates a Carbon instance from an ISO 8601 string.
  ///
  /// Example:
  /// ```dart
  /// final date = DateFactory.parse('2023-01-01T00:00:00Z');
  /// ```
  static Carbon parse(String input) {
    final carbon = Carbon.parse(input);
    return _processDate(carbon);
  }

  /// Creates a Carbon instance from a UUID's timestamp.
  ///
  /// Example:
  /// ```dart
  /// final date = DateFactory.fromUuid('71513cb4-f071-11ed-a0cf-325096b39f47');
  /// ```
  static Carbon fromUuid(String uuid) {
    final carbon = Carbon.fromUuid(uuid);
    return _processDate(carbon);
  }

  /// Process a Carbon instance through the configured handler.
  static Carbon _processDate(Carbon carbon) {
    if (_callable != null) {
      return _callable!(carbon);
    }

    if (_factory != null) {
      return _factory!.createFromCarbon(carbon);
    }

    if (_dateClass != null && _dateClass != Carbon) {
      throw UnimplementedError(
        'Custom date classes not yet supported. Use a callable or factory instead.',
      );
    }

    return carbon;
  }
}

/// Interface for creating Carbon instances.
///
/// Implement this interface to provide custom Carbon creation logic.
abstract class CarbonFactory {
  /// Creates a Carbon instance from another Carbon instance.
  Carbon createFromCarbon(Carbon carbon);
}
