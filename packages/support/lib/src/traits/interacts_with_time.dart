import '../carbon.dart';
import '../facades/date.dart';

/// Provides time-related functionality.
///
/// This trait provides methods for working with time, such as getting the current
/// time, sleeping, or measuring time intervals.
mixin InteractsWithTime {
  /// Get a Carbon instance for the current time.
  Carbon currentTime() => Date.now();

  /// Sleep for the given number of milliseconds.
  Future<void> sleep(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  /// Sleep until the given timestamp.
  Future<void> sleepUntil(DateTime timestamp) async {
    final now = currentTime().dateTime;
    if (timestamp.isAfter(now)) {
      final duration = timestamp.difference(now).inMilliseconds;
      // Add a small buffer (1ms) to ensure we meet the minimum duration
      await sleep(duration + 1);
    }
  }

  /// Get the time elapsed since a given timestamp in milliseconds.
  int elapsedTime(DateTime start) {
    return currentTime().dateTime.difference(start).inMilliseconds;
  }
}
