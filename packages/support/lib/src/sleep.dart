import 'dart:async';
import 'dart:math' show Random;
import 'package:platform_macroable/platform_macroable.dart';
import 'carbon.dart';

/// A class that provides sleep functionality with various time units.
///
/// This class allows for sleeping (pausing execution) for specified durations,
/// with support for different time units and extensibility through macros.
class Sleep with Macroable {
  /// Random number generator for random sleep durations
  static final _random = Random();

  /// Sleep for the specified number of microseconds.
  static Future<void> usleep(int microseconds) async {
    await Future.delayed(Duration(microseconds: microseconds));
  }

  /// Sleep for the specified number of milliseconds.
  static Future<void> sleep(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  /// Sleep for the specified number of seconds.
  static Future<void> seconds(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
  }

  /// Sleep for the specified number of minutes.
  static Future<void> minutes(int minutes) async {
    await Future.delayed(Duration(minutes: minutes));
  }

  /// Sleep for the specified number of hours.
  static Future<void> hours(int hours) async {
    await Future.delayed(Duration(hours: hours));
  }

  /// Sleep for the specified number of days.
  static Future<void> days(int days) async {
    await Future.delayed(Duration(days: days));
  }

  /// Sleep until a specific Carbon instance.
  static Future<void> until(Carbon time) async {
    final now = Carbon.now();
    if (time.isAfter(now.dateTime)) {
      final difference = time.dateTime.difference(now.dateTime);
      if (difference.inMicroseconds > 0) {
        await Future.delayed(difference);
      }
    }
  }

  /// Sleep until a specific time of day.
  static Future<void> untilTime(TimeOfDay time) async {
    final now = Carbon.now();
    final target = Carbon(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, add one day
    if (target.isBefore(now.dateTime)) {
      return; // Don't sleep if time has passed
    }

    await until(target);
  }

  /// Sleep for a random duration between min and max milliseconds.
  static Future<void> random(int min, int max) async {
    // Normalize input
    if (min < 0) min = 0;
    if (max < min) max = min;

    // Calculate random duration, accounting for overhead
    final range = max -
        min -
        7; // Subtract 7ms to account for overhead and ensure we stay within bounds
    if (range <= 0) {
      await sleep(min);
    } else {
      final duration = min + _random.nextInt(range);
      await sleep(duration);
    }
  }
}

/// Represents a time of day in 24-hour format.
class TimeOfDay {
  /// The hour of the day (0-23).
  final int hour;

  /// The minute of the hour (0-59).
  final int minute;

  /// Creates a new time of day instance.
  const TimeOfDay({
    required this.hour,
    required this.minute,
  })  : assert(hour >= 0 && hour < 24),
        assert(minute >= 0 && minute < 60);

  /// Creates a duration from midnight to this time.
  Duration toDuration() {
    return Duration(hours: hour, minutes: minute);
  }

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
