import 'dart:async';

import '../driver.dart';

/// A task scheduler that supports cron-style scheduling and intervals.
class Scheduler {
  final Driver _driver;
  final Map<String, _ScheduledTask> _tasks = {};
  Timer? _timer;
  bool _running = false;

  /// Creates a new scheduler using the specified concurrency driver.
  Scheduler(this._driver);

  /// Schedules a task to run at specified intervals.
  ///
  /// Returns a unique ID that can be used to cancel the task.
  String schedule(
    FutureOr<void> Function() task, {
    Duration? interval,
    String? cron,
    bool runImmediately = false,
  }) {
    if (interval == null && cron == null) {
      throw SchedulerException(
        'Either interval or cron expression must be specified',
      );
    }

    final id = _generateId();
    final scheduledTask = _ScheduledTask(
      task: task,
      interval: interval,
      cron: cron != null ? CronExpression(cron) : null,
      lastRun: runImmediately ? null : DateTime.now(),
    );

    _tasks[id] = scheduledTask;

    if (runImmediately) {
      _executeTask(id, scheduledTask);
    }

    if (_running) {
      _startTimer(); // Restart timer to account for new task
    }

    return id;
  }

  /// Cancels a scheduled task.
  ///
  /// Returns true if the task was found and cancelled, false otherwise.
  bool cancel(String id) {
    final removed = _tasks.remove(id) != null;
    if (removed && _running) {
      _startTimer(); // Restart timer to account for removed task
    }
    return removed;
  }

  /// Starts the scheduler.
  void start() {
    if (_running) return;
    _running = true;
    _startTimer();
  }

  /// Stops the scheduler.
  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    _timer?.cancel();

    if (_tasks.isEmpty) {
      _timer = null;
      return;
    }

    // Find next task execution time
    final now = DateTime.now();
    DateTime? nextRun;
    for (final entry in _tasks.entries) {
      final task = entry.value;
      final taskNextRun = task.nextRunTime(now);
      if (nextRun == null || taskNextRun.isBefore(nextRun)) {
        nextRun = taskNextRun;
      }
    }

    if (nextRun != null) {
      final delay = nextRun.difference(now);
      _timer = Timer(delay, () => _checkTasks());
    }
  }

  void _checkTasks() {
    final now = DateTime.now();
    final tasksToRun = <String, _ScheduledTask>{};

    // Find tasks that need to run
    for (final entry in _tasks.entries) {
      final id = entry.key;
      final task = entry.value;
      if (task.shouldRun(now)) {
        tasksToRun[id] = task;
      }
    }

    // Execute tasks
    for (final entry in tasksToRun.entries) {
      _executeTask(entry.key, entry.value);
    }

    // Restart timer for next run
    if (_running) {
      _startTimer();
    }
  }

  Future<void> _executeTask(String id, _ScheduledTask task) async {
    task.lastRun = DateTime.now();
    try {
      await _driver.run(task.task);
    } catch (e, st) {
      // Log error since this is a scheduled task
      Zone.current.handleUncaughtError(e, st);
    }
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();
}

/// A scheduled task with its execution configuration.
class _ScheduledTask {
  final FutureOr<void> Function() task;
  final Duration? interval;
  final CronExpression? cron;
  DateTime? lastRun;

  _ScheduledTask({
    required this.task,
    this.interval,
    this.cron,
    this.lastRun,
  });

  bool shouldRun(DateTime now) {
    if (lastRun == null) return true;

    if (interval != null) {
      return now.difference(lastRun!) >= interval!;
    }

    if (cron != null) {
      final nextRun = cron!.nextAfter(lastRun!);
      return now.isAfter(nextRun) || now.isAtSameMomentAs(nextRun);
    }

    return false;
  }

  DateTime nextRunTime(DateTime now) {
    if (lastRun == null) return now;

    if (interval != null) {
      return lastRun!.add(interval!);
    }

    if (cron != null) {
      return cron!.nextAfter(lastRun!);
    }

    return now;
  }
}

/// Parses and evaluates cron expressions.
class CronExpression {
  final String expression;
  final List<_CronField> _fields;

  CronExpression(this.expression) : _fields = _parseCronExpression(expression);

  /// Returns the next execution time after the given date.
  DateTime nextAfter(DateTime date) {
    var next = date;
    bool valid;
    do {
      valid = true;
      next = next.add(const Duration(minutes: 1));
      next = DateTime(
        next.year,
        next.month,
        next.day,
        next.hour,
        next.minute,
        0,
        0,
        0,
      );

      // Check if time matches cron expression
      if (!_fields[0].matches(next.minute)) valid = false;
      if (!_fields[1].matches(next.hour)) valid = false;
      if (!_fields[2].matches(next.day)) valid = false;
      if (!_fields[3].matches(next.month)) valid = false;
      if (!_fields[4].matches(next.weekday % 7)) valid = false;
    } while (!valid);

    return next;
  }

  static List<_CronField> _parseCronExpression(String expression) {
    final parts = expression.split(' ');
    if (parts.length != 5) {
      throw SchedulerException(
        'Invalid cron expression: must have 5 fields (minute, hour, day, month, weekday)',
      );
    }

    return [
      _CronField(parts[0], 0, 59), // minute
      _CronField(parts[1], 0, 23), // hour
      _CronField(parts[2], 1, 31), // day
      _CronField(parts[3], 1, 12), // month
      _CronField(parts[4], 0, 6), // weekday (0-6, Sunday=0)
    ];
  }
}

/// A single field in a cron expression.
class _CronField {
  final Set<int> values = {};

  _CronField(String field, int min, int max) {
    if (field == '*') {
      for (var i = min; i <= max; i++) {
        values.add(i);
      }
      return;
    }

    for (final part in field.split(',')) {
      if (part.contains('-')) {
        final range = part.split('-');
        final start = int.parse(range[0]);
        final end = int.parse(range[1]);
        for (var i = start; i <= end; i++) {
          values.add(i);
        }
      } else if (part.contains('/')) {
        final step = part.split('/');
        final stepSize = int.parse(step[1]);
        for (var i = min; i <= max; i += stepSize) {
          values.add(i);
        }
      } else {
        values.add(int.parse(part));
      }
    }

    // Validate values are within range
    for (final value in values) {
      if (value < min || value > max) {
        throw SchedulerException(
          'Invalid cron field value $value: must be between $min and $max',
        );
      }
    }
  }

  bool matches(int value) => values.contains(value);
}

/// Exception thrown when scheduler operations fail.
class SchedulerException implements Exception {
  final String message;

  SchedulerException(this.message);

  @override
  String toString() => 'SchedulerException: $message';
}
