import 'dart:async';

/// A class that provides timeout functionality for executing code within a time limit.
///
/// This class allows for executing code with a specified timeout duration,
/// handling both synchronous and asynchronous operations.
class Timebox {
  /// Execute a callback within a specified time limit.
  static Future<T> run<T>(
    FutureOr<T> Function() callback, {
    required Duration timeout,
    FutureOr<T> Function()? onTimeout,
  }) async {
    try {
      final completer = Completer<T>();
      Timer? timer;

      // Set up timeout
      if (timeout != Duration.zero) {
        timer = Timer(timeout, () {
          if (!completer.isCompleted) {
            if (onTimeout != null) {
              // Execute timeout callback
              try {
                final result = onTimeout();
                if (result is Future<T>) {
                  result
                      .then(completer.complete)
                      .catchError(completer.completeError);
                } else {
                  completer.complete(result);
                }
              } catch (e) {
                completer.completeError(e);
              }
            } else {
              completer.completeError(
                TimeoutException('Operation timed out', timeout),
              );
            }
          }
        });
      }

      // Execute callback
      try {
        final result = callback();
        if (result is Future<T>) {
          result.then((value) {
            if (!completer.isCompleted) {
              completer.complete(value);
            }
          }).catchError((error) {
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          });
        } else {
          if (!completer.isCompleted) {
            completer.complete(result);
          }
        }
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }

      // Wait for result
      try {
        final result = await completer.future;
        timer?.cancel();
        return result;
      } catch (e) {
        timer?.cancel();
        rethrow;
      }
    } catch (e) {
      if (e is TimeoutException && onTimeout != null) {
        final result = onTimeout();
        if (result is Future<T>) {
          return await result;
        }
        return result;
      }
      rethrow;
    }
  }

  /// Execute a callback within a specified time limit, returning a default value on timeout.
  static Future<T> runWithDefault<T>(
    FutureOr<T> Function() callback, {
    required T defaultValue,
    required Duration timeout,
  }) async {
    return run(
      callback,
      timeout: timeout,
      onTimeout: () => defaultValue,
    );
  }

  /// Check if a callback completes within a specified time limit.
  static Future<bool> completes(
    FutureOr<void> Function() callback, {
    required Duration timeout,
  }) async {
    try {
      await run(
        callback,
        timeout: timeout,
      );
      return true;
    } on TimeoutException {
      return false;
    }
  }

  /// Execute a callback repeatedly until it completes or times out.
  static Future<T> retry<T>(
    FutureOr<T> Function() callback, {
    required Duration timeout,
    Duration retryInterval = const Duration(milliseconds: 100),
    int? maxAttempts,
  }) async {
    final stopwatch = Stopwatch()..start();
    var attempts = 0;

    while (true) {
      attempts++;

      if (maxAttempts != null && attempts > maxAttempts) {
        throw TimeoutException(
          'Operation timed out after $maxAttempts attempts',
          timeout,
        );
      }

      try {
        final remainingTime = timeout - stopwatch.elapsed;
        if (remainingTime <= Duration.zero) {
          throw TimeoutException('Operation timed out', timeout);
        }

        return await run(
          callback,
          timeout: remainingTime,
          onTimeout: () =>
              throw TimeoutException('Operation timed out', timeout),
        );
      } catch (e) {
        if (e is TimeoutException ||
            (maxAttempts != null && attempts >= maxAttempts)) {
          throw TimeoutException(
            'Operation timed out after $attempts attempts',
            timeout,
          );
        }

        // Wait before retrying
        final remainingTime = timeout - stopwatch.elapsed;
        if (remainingTime <= retryInterval) {
          throw TimeoutException('Operation timed out', timeout);
        }

        await Future.delayed(retryInterval);
      }
    }
  }
}
