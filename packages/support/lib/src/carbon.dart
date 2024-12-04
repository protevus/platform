import 'package:platform_macroable/platform_macroable.dart';
import 'package:platform_conditionable/platform_conditionable.dart';
import 'package:uuid/uuid.dart';

/// A DateTime wrapper that provides additional functionality.
///
/// Similar to Laravel's Carbon class, this provides additional functionality
/// on top of Dart's DateTime class.
class Carbon with Macroable, Conditionable {
  /// The underlying DateTime instance
  DateTime _dateTime;

  /// Test time instance for mocking
  static DateTime? _testNow;

  /// Creates a new Carbon instance.
  Carbon(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  ]) : _dateTime = DateTime(
          year,
          month,
          day,
          hour,
          minute,
          second,
          millisecond,
          microsecond,
        );

  /// Creates a Carbon instance from a DateTime.
  Carbon.fromDateTime(DateTime dateTime) : _dateTime = dateTime;

  /// Creates a Carbon instance from milliseconds since epoch.
  factory Carbon.fromMillisecondsSinceEpoch(int milliseconds,
      {bool isUtc = false}) {
    return Carbon.fromDateTime(
        DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: isUtc));
  }

  /// Creates a Carbon instance from microseconds since epoch.
  factory Carbon.fromMicrosecondsSinceEpoch(int microseconds,
      {bool isUtc = false}) {
    return Carbon.fromDateTime(
        DateTime.fromMicrosecondsSinceEpoch(microseconds, isUtc: isUtc));
  }

  /// Creates a Carbon instance for the current date and time.
  factory Carbon.now() {
    return _testNow != null
        ? Carbon.fromDateTime(_testNow!)
        : Carbon.fromDateTime(DateTime.now());
  }

  /// Creates a Carbon instance from an ISO 8601 string.
  factory Carbon.parse(String input) {
    return Carbon.fromDateTime(DateTime.parse(input));
  }

  /// Creates a Carbon instance from a UUID's timestamp.
  factory Carbon.fromUuid(String uuid) {
    final timestamp = UuidTime.fromUuid(uuid).timestamp;
    // UUID v1 timestamp is in 100-nanosecond intervals since UUID epoch (1582-10-15)
    // Need to convert to Unix epoch (1970-01-01)
    const uuidToUnixEpoch =
        0x01B21DD213814000; // Offset between epochs in 100ns intervals
    final unixTimestamp =
        ((timestamp - uuidToUnixEpoch) ~/ 10000); // Convert to milliseconds
    return Carbon.fromMillisecondsSinceEpoch(unixTimestamp);
  }

  /// Sets the test time instance.
  static void setTestNow(DateTime? testNow) {
    _testNow = testNow;
  }

  /// Gets the test time instance.
  static DateTime? getTestNow() {
    return _testNow;
  }

  /// Returns true if test time is set.
  static bool hasTestNow() {
    return _testNow != null;
  }

  /// Clears the test time instance.
  static void clearTestNow() {
    _testNow = null;
  }

  /// Returns a new Carbon instance with the specified duration added.
  Carbon add(Duration duration) {
    return Carbon.fromDateTime(_dateTime.add(duration));
  }

  /// Returns a new Carbon instance with the specified duration subtracted.
  Carbon subtract(Duration duration) {
    return Carbon.fromDateTime(_dateTime.subtract(duration));
  }

  /// Returns a new Carbon instance in the local time zone.
  Carbon toLocal() {
    return Carbon.fromDateTime(_dateTime.toLocal());
  }

  /// Returns a new Carbon instance in UTC.
  Carbon toUtc() {
    return Carbon.fromDateTime(_dateTime.toUtc());
  }

  /// Returns true if this Carbon instance is before the other.
  bool isBefore(DateTime other) {
    return _dateTime.isBefore(other);
  }

  /// Returns true if this Carbon instance is after the other.
  bool isAfter(DateTime other) {
    return _dateTime.isAfter(other);
  }

  /// Returns true if this Carbon instance is at the same moment as the other.
  bool isAtSameMomentAs(DateTime other) {
    return _dateTime.isAtSameMomentAs(other);
  }

  /// Returns the difference between this Carbon instance and another DateTime.
  Duration difference(DateTime other) {
    return _dateTime.difference(other);
  }

  /// Returns a new Carbon instance with the specified years added.
  Carbon addYears(int years) {
    return Carbon.fromDateTime(DateTime(
      _dateTime.year + years,
      _dateTime.month,
      _dateTime.day,
      _dateTime.hour,
      _dateTime.minute,
      _dateTime.second,
      _dateTime.millisecond,
      _dateTime.microsecond,
    ));
  }

  /// Returns a new Carbon instance with the specified months added.
  Carbon addMonths(int months) {
    var m = _dateTime.month + months;
    var y = _dateTime.year;
    while (m > 12) {
      m -= 12;
      y++;
    }
    while (m < 1) {
      m += 12;
      y--;
    }
    return Carbon.fromDateTime(DateTime(
      y,
      m,
      _dateTime.day,
      _dateTime.hour,
      _dateTime.minute,
      _dateTime.second,
      _dateTime.millisecond,
      _dateTime.microsecond,
    ));
  }

  /// Returns a new Carbon instance with the specified days added.
  Carbon addDays(int days) {
    return add(Duration(days: days));
  }

  /// Returns a new Carbon instance with the specified hours added.
  Carbon addHours(int hours) {
    return add(Duration(hours: hours));
  }

  /// Returns a new Carbon instance with the specified minutes added.
  Carbon addMinutes(int minutes) {
    return add(Duration(minutes: minutes));
  }

  /// Returns a new Carbon instance with the specified seconds added.
  Carbon addSeconds(int seconds) {
    return add(Duration(seconds: seconds));
  }

  /// Returns a new Carbon instance with the specified milliseconds added.
  Carbon addMilliseconds(int milliseconds) {
    return add(Duration(milliseconds: milliseconds));
  }

  /// Returns a new Carbon instance with the specified microseconds added.
  Carbon addMicroseconds(int microseconds) {
    return add(Duration(microseconds: microseconds));
  }

  /// Returns true if this Carbon instance is today.
  bool isToday() {
    final now = Carbon.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this Carbon instance is tomorrow.
  bool isTomorrow() {
    final tomorrow = Carbon.now().addDays(1);
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Returns true if this Carbon instance is yesterday.
  bool isYesterday() {
    final yesterday = Carbon.now().subtract(Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns true if this Carbon instance is in the future.
  bool isFuture() {
    return isAfter(Carbon.now()._dateTime);
  }

  /// Returns true if this Carbon instance is in the past.
  bool isPast() {
    return isBefore(Carbon.now()._dateTime);
  }

  /// Returns true if this Carbon instance is a weekday.
  bool isWeekday() {
    return !isWeekend();
  }

  /// Returns true if this Carbon instance is a weekend.
  bool isWeekend() {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  /// Returns a string representation of this Carbon instance.
  @override
  String toString() {
    return _dateTime.toIso8601String();
  }

  // DateTime property forwarding

  int get year => _dateTime.year;
  int get month => _dateTime.month;
  int get day => _dateTime.day;
  int get hour => _dateTime.hour;
  int get minute => _dateTime.minute;
  int get second => _dateTime.second;
  int get millisecond => _dateTime.millisecond;
  int get microsecond => _dateTime.microsecond;
  int get weekday => _dateTime.weekday;
  bool get isUtc => _dateTime.isUtc;
  DateTime get dateTime => _dateTime;
  String toIso8601String() => _dateTime.toIso8601String();

  // Setters for modifying time components
  set hour(int value) {
    _dateTime = DateTime(
      _dateTime.year,
      _dateTime.month,
      _dateTime.day,
      value,
      _dateTime.minute,
      _dateTime.second,
      _dateTime.millisecond,
      _dateTime.microsecond,
    );
  }

  set minute(int value) {
    _dateTime = DateTime(
      _dateTime.year,
      _dateTime.month,
      _dateTime.day,
      _dateTime.hour,
      value,
      _dateTime.second,
      _dateTime.millisecond,
      _dateTime.microsecond,
    );
  }

  set second(int value) {
    _dateTime = DateTime(
      _dateTime.year,
      _dateTime.month,
      _dateTime.day,
      _dateTime.hour,
      _dateTime.minute,
      value,
      _dateTime.millisecond,
      _dateTime.microsecond,
    );
  }
}

/// Helper class for extracting timestamp from UUID v1.
class UuidTime {
  final int timestamp;

  UuidTime._(this.timestamp);

  /// Creates a UuidTime instance from a UUID string.
  factory UuidTime.fromUuid(String uuid) {
    // UUID v1 timestamp is stored in bytes 0-7
    final bytes = Uuid.parse(uuid);
    final timeLow =
        bytes[3] | (bytes[2] << 8) | (bytes[1] << 16) | (bytes[0] << 24);
    final timeMid = bytes[5] | (bytes[4] << 8);
    final timeHigh = bytes[7] | (bytes[6] << 8);
    final timestamp = ((timeHigh & 0x0FFF) << 48) | (timeMid << 32) | timeLow;
    return UuidTime._(timestamp);
  }
}
